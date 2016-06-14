//
//  GGBannerView.h
//  GGBannerView
//
//  Created by kimi on 6/14/16.
//  Copyright © 2016 kimi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^pictureSelectBlock)(NSInteger index);

@interface GGBannerView : UIView

/** pic array **/
@property (strong, nonatomic) NSArray *pics;
/** pageControl indicator color **/
@property (strong, nonatomic) UIColor *pageColor;
@property (strong, nonatomic) UIColor *pageSelColor;
/** block */
@property (nonatomic, copy) pictureSelectBlock pictureSelectBlock;
/** return the clicked index */
- (void)returnIndex:(pictureSelectBlock)block;

/** reload image  ----- NEEDED ----- **/
- (void)reloadView;
@end
