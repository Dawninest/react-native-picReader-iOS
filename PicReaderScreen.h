//
//  PicReaderScreen.h
//  moffice
//
//  Created by 30san on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicReaderScreen : UIView

- (instancetype)initWithImage:(UIImage *)image;
- (void)loadImage;

@property(nonatomic,strong) UIImage *showImage;
@property(nonatomic,strong) UIImageView *showImageView;

@end
