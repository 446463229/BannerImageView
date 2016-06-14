//
//  GGBannerView.m
//  GGBannerView
//
//  Created by kimi on 6/14/16.
//  Copyright © 2016 kimi. All rights reserved.
//

#import "GGBannerView.h"
#import <CommonCrypto/CommonDigest.h>

@interface GGBannerView () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *picScrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSTimer *time;
@property (assign, nonatomic) NSInteger curIndex;
@end

@implementation GGBannerView

#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _picScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _picScrollView.delegate = self;
        _picScrollView.pagingEnabled = YES;
        _picScrollView.bounces = YES;
        _picScrollView.showsHorizontalScrollIndicator = NO;
        _picScrollView.showsVerticalScrollIndicator = NO;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 25, frame.size.width, 25)];
        
        [self addSubview:_picScrollView];
        [self addSubview:_pageControl];
        _curIndex = 0;
    }
    return self;
}

#pragma mark - setter method

- (void)setPageColor:(UIColor *)pageColor
{
    _pageColor = pageColor;
    _pageControl.pageIndicatorTintColor = self.pageColor;
}

- (void)setPageSelColor:(UIColor *)pageSelColor
{
    _pageSelColor = pageSelColor;
    _pageControl.currentPageIndicatorTintColor = self.pageSelColor;
}

#pragma mark - reload banner view
-(void)reloadView {
    if (self.pics.count == 0) {
        return;
    }
    CGFloat picWidth = _picScrollView.frame.size.width * (self.pics.count + (self.pics.count == 1 ? 0 : 1));
    _picScrollView.contentSize = CGSizeMake(picWidth, 0);
    
    for (int i = 0; i <= (self.pics.count == 1 ? self.pics.count - 1 : self.pics.count); i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.clipsToBounds = YES;
        NSString *urlStr = @"";
        if (i == 0) {
            urlStr = self.pics[self.pics.count - 1];
        }else {
            urlStr = self.pics[i - 1];
        }
        [self loadImage:urlStr imageView:imageView];
        [self setVFrame:i imageView:imageView];
        [_picScrollView addSubview:imageView];
    }
    
    _picScrollView.contentOffset = CGPointMake((self.pics.count == 1 ? 0 : self.picScrollView.frame.size.width), 0);
    _pageControl.numberOfPages = self.pics.count;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickpicView:)];
    [_picScrollView addGestureRecognizer:tap];
    [self addTimer];
}

#pragma mark - click event

- (void)clickpicView:(UIGestureRecognizer *)sender {
    self.pictureSelectBlock(_curIndex);
}
- (void)returnIndex:(pictureSelectBlock)block{
    self.pictureSelectBlock = block;
}

#pragma mark - the index of the images

- (void)setBttonFrame:(int)index withButton:(UIButton *)sender{
    sender.frame = CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setVFrame:(int)index imageView:(UIImageView *)image{
    image.frame = CGRectMake(self.frame.size.width * index, 0, self.frame.size.width, self.frame.size.height);
}


#pragma mark - next image

- (void)nextImage{
    if (_curIndex == self.pics.count - 1) {
        self.pageControl.currentPage = 0;
        _curIndex = 0;
    }else {
        self.pageControl.currentPage++;
        _curIndex++;
    }
    CGFloat x = (_curIndex + 1) * self.picScrollView.frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _picScrollView.contentOffset = CGPointMake(x, 0);
    } completion:^(BOOL finished) {
        if (finished && _curIndex == self.pics.count - 1) {
            _picScrollView.contentOffset = CGPointMake(0, 0);
        }
    }];
}


#pragma mark - scrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.time invalidate]; //stop the timer while begin dragging
    self.time = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];//begin the timer while begin dragging
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.pics.count == 1) {
        return;
    }
    if (scrollView.contentOffset.x == self.pics.count * scrollView.frame.size.width) {
        _picScrollView.contentOffset = CGPointMake(0, 0);
    }else if (scrollView.contentOffset.x == 0) {
        _picScrollView.contentOffset = CGPointMake(self.pics.count * scrollView.frame.size.width, 0);
    }
    for (int i = 0; i <= self.pics.count; i++) {
        if (scrollView.contentOffset.x == i * self.frame.size.width) {
            if (i == 0) {
                self.pageControl.currentPage = self.pics.count - 1;
                _curIndex = self.pics.count - 1;
            }else {
                self.pageControl.currentPage = i - 1;
                _curIndex = i - 1;
            }
        }
    }
}

#pragma mark - add timer
- (void)addTimer{
    if (self.pics.count != 1) {
        self.time = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    }
}

#pragma mark - image related
/** download image */
- (void)loadImage:(NSString *)urlStr imageView:(UIImageView *)imgView {
    imgView.layer.borderWidth = 0.2;
    imgView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil) {
        return;
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        if ([self getImageWithName:[self md5:urlStr]] != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                imgView.image = [self getImageWithName:[self md5:urlStr]];
            }];
        }else {
            NSData *resultData = [NSData dataWithContentsOfURL:url];
            UIImage *img = [UIImage imageWithData:resultData];
            if (img != nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    imgView.image = img;
                    [self saveImage:img withName:[self md5:urlStr]];
                }];
            }
        }
    }];
}

/** save image */
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *UIImageJPEGRepresentation (UIImage *image, CGFloat compressionQuality);
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
}

/** get the images */
- (UIImage *)getImageWithName:(NSString *)imageName{
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    return savedImage;
}

/** md5 the image path */
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
