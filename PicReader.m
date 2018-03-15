//
//  PicReader.m
//  moffice
//  Created by 30san on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//
//  iOS 图片预览工具
//  单击返回
//  长按询问是否保存
//  支持缩放拖动
//  特别针对长图进行优化
//  by Dawninest

#import "PicReader.h"
#import "PicReaderScreen.h"

@interface PicReader ()

@property (nonatomic, strong) NSString *picPath;

@end

@implementation PicReader


RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(loadPicReader:(NSString *)picPath){
  dispatch_async(dispatch_get_main_queue(), ^{
    self.picPath = picPath;
    if ([[self.picPath substringToIndex:7] isEqualToString:@"file://"]) {
      self.picPath = [self.picPath substringFromIndex:7];
    }
    UIImage *showImage = [UIImage imageWithContentsOfFile:self.picPath];
    PicReaderScreen *picReaderScrren = [[PicReaderScreen alloc]initWithImage:showImage];
    UIViewController *currentViewController = [self getCurrentViewController];
    [currentViewController.view addSubview:picReaderScrren];
    [picReaderScrren loadImage];
  });
}

//获取当前viewcontroller
- (UIViewController *)getCurrentViewController{
  UIViewController *currentViewController = nil;
  UIWindow *window = [[UIApplication sharedApplication]keyWindow];
  if (window.windowLevel != UIWindowLevelNormal) {
    NSArray *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow *tmpWin in windows) {
      if (tmpWin.windowLevel == UIWindowLevelNormal) {
        window = tmpWin;
        break;
      }
    }
  }
  UIView *frontView = [[window subviews]objectAtIndex:0];
  id nextResponder = [frontView nextResponder];
  if ([nextResponder isKindOfClass:[UIViewController class]]) {
    currentViewController = nextResponder;
  }else{
    currentViewController = window.rootViewController;
  }
  return currentViewController;
}

@end
