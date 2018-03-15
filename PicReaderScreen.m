//
//  PicReaderScreen.m
//  moffice
//
//  Created by 30san on 2018/3/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "PicReaderScreen.h"

#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define SCREEN_W [UIScreen mainScreen].bounds.size.width

#define MAXSCale 1.5
#define MINSCale 1

@interface PicReaderScreen ()

@property (nonatomic, assign) BOOL isLongImg;


@end

@implementation PicReaderScreen

- (instancetype)initWithImage:(UIImage *)image
{
  self = [super init];
  if (self) {
    self.showImage = image;
    self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
    self.isLongImg = NO;
    [self initUI];
    //加载图片后的位置调整
    [self limitImg];
    //添加手势
    [self initGestureRecognizer];
    
  }
  return self;
}

- (void)initUI{
  _showImageView = [[UIImageView alloc]init];
  _showImageView.frame = CGRectMake(0, 0, self.showImage.size.width, self.showImage.size.height);
  _showImageView.center = self.center;
  _showImageView.image = self.showImage;
  _showImageView.contentMode = UIViewContentModeScaleAspectFit;
  _showImageView.backgroundColor = [UIColor blackColor];
  
  _showImageView.userInteractionEnabled = YES;
  [self addSubview:_showImageView];
}

- (void)initGestureRecognizer{
  //点击退出
  UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImg:)];
  [self addGestureRecognizer:tapGes];
  //缩放
  UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchImg:)];
  [_showImageView addGestureRecognizer:pinchGes];
  //拖动
  UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panImg:)];
  [_showImageView addGestureRecognizer:panGes];
  //长按
  UILongPressGestureRecognizer *pressGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(pressImg:)];
  pressGes.allowableMovement = 1500.0f;
  pressGes.minimumPressDuration = 1.0;
  [_showImageView addGestureRecognizer:pressGes];
  
  
}

- (void)loadImage{
  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.alpha = 1;
  } completion:nil];
}

- (void)limitImg{
  CGFloat imgWidth = _showImage.size.width;
  CGFloat imgHeight = _showImage.size.height;
  CGFloat scale = 0;
  CGRect rect = CGRectZero;
  if (MAX(imgWidth, imgHeight) > MIN(imgWidth, imgHeight) * 3) {
    self.isLongImg = YES;
  }
  if (imgWidth/imgHeight < SCREEN_W/SCREEN_H) {
    //图宽/图高<屏宽/屏高 - 高填充满，两边有黑
    if (_isLongImg) {
      scale = SCREEN_W / imgWidth;
      rect = CGRectMake(0,0,imgWidth * scale, imgHeight * scale);
      //            _showImageView.frame = rect;
    }else{
      scale = SCREEN_H / imgHeight;
      rect = CGRectMake((SCREEN_W - imgWidth * scale)/2,0,imgWidth * scale, imgHeight * scale);
      //            _showImageView.frame = rect;
    }
    
  }else{
    //图宽/图高>屏宽/屏高 - 宽填充满，上下有黑
    if (_isLongImg) {
      scale = SCREEN_H / imgHeight;
      rect = CGRectMake(0,0,imgWidth * scale, imgHeight * scale);
      //            _showImageView.frame = rect;
    }else{
      scale = SCREEN_W / imgWidth;
      rect = CGRectMake(0,(SCREEN_H - imgHeight * scale)/2,imgWidth * scale, imgHeight * scale);
      //            _showImageView.frame = rect;
    }
    
  }
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:0 animations:^{
    _showImageView.frame = rect;
  } completion:nil];
  
}

//点击手势
- (void)tapImg:(UITapGestureRecognizer*)gesture{
  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.alpha = 0;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
  }];
}

//长按手势
- (void)pressImg:(UITapGestureRecognizer*)gesture{
  if (gesture.state == UIGestureRecognizerStateBegan) {
    UIAlertController *savePicController = [UIAlertController alertControllerWithTitle:@"是否保存图片到相册" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [savePicController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      UIImageWriteToSavedPhotosAlbum(self.showImage, self, @selector(image:didFinshSavingWithError:contextInfo:), nil);
    }]];
    [savePicController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *currentViewController = [self getCurrentViewController];
    [currentViewController presentViewController:savePicController animated:YES completion:nil];
  }
}

- (void)image:(UIImage *)image didFinshSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
  if (error == nil) {
    UIAlertController *saveSuccessController = [UIAlertController alertControllerWithTitle:@"保存成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [saveSuccessController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *currentViewController = [self getCurrentViewController];
    [currentViewController presentViewController:saveSuccessController animated:YES completion:nil];
    NSLog(@"save success");
  }else{
    NSString *errorStr = [NSString stringWithFormat:@"%@",error];
    UIAlertController *saveFailController = [UIAlertController alertControllerWithTitle:@"保存失败" message:errorStr preferredStyle:UIAlertControllerStyleAlert];
    [saveFailController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *currentViewController = [self getCurrentViewController];
    [currentViewController presentViewController:saveFailController animated:YES completion:nil];
    NSLog(@"save fail");
  }
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



//缩放手势
- (void)pinchImg:(UIPinchGestureRecognizer *)gesture{
  CGFloat getScale = gesture.scale;
  if (!_isLongImg) {
    //当查看的图片为长图时，将禁止缩放
    if (gesture.state == UIGestureRecognizerStateChanged) {
      //            gesture.view.center = self.center;
      gesture.view.transform = CGAffineTransformScale(gesture.view.transform, getScale, getScale);
      gesture.scale = 1;
    }
    if (gesture.state == UIGestureRecognizerStateEnded){
      [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        gesture.scale = [self getScaleByImgWithSale:gesture.scale];
        gesture.view.center = self.center;
        gesture.view.transform = CGAffineTransformScale(gesture.view.transform, gesture.scale, gesture.scale);
      } completion:^(BOOL finished) {
        gesture.scale = 1;
      }];
    }
    
  }
}

- (CGFloat)getScaleByImgWithSale:(float)scale{
  CGFloat viewWidth = _showImageView.frame.size.width;
  CGFloat viewHeight = _showImageView.frame.size.height;
  CGFloat imgWidth = _showImage.size.width;
  CGFloat imgHeight = _showImage.size.height;
  
  if (imgWidth/imgHeight < SCREEN_W/SCREEN_H) {
    //图宽/图高<屏宽/屏高 - 高填充满，两边有黑
    CGFloat noteHeight = viewHeight;
    CGFloat noteWidth = viewHeight * imgWidth/imgHeight;
    if (noteWidth > SCREEN_W * MAXSCale) {
      scale = SCREEN_W * MAXSCale / noteWidth;
    }
    if (noteHeight < SCREEN_H * MINSCale) {
      scale = SCREEN_H * MINSCale / noteHeight;
    }
  }else{
    //图宽/图高>屏宽/屏高 - 宽填充满，上下有黑
    CGFloat noteWidth = viewWidth;
    CGFloat noteHeight = viewWidth * imgHeight/imgWidth;
    if (noteHeight > SCREEN_H * MAXSCale) {
      scale = SCREEN_H * MAXSCale / noteHeight;
      
    }
    if (noteWidth < SCREEN_W * MINSCale) {
      scale = SCREEN_W * MINSCale / noteWidth;
    }
  }
  return scale;
}

//拖动
/*
 关于拖动限制的计算思路
 参数：x,y 当前拖动界面的中心点坐标
 noteWidth,noteHeight 缩放后的实际宽高
 SCREEN_W,SCREEN_H 屏宽高
 需考虑的判断条件:
 图宽/图高>屏宽/屏高 -宽填充满/高填充满
 图高:屏高 图宽:屏宽
 需满足的要求:
 拿 图高 > 图宽 说明，反之同理
 1.图高<屏高 图宽<屏宽 时，图片的中心点与屏幕中心点一致，不允许拖动
 2.图高>屏高 图宽<屏宽 时，只允许上下拖动(限制上下极限)，不允许左右拖动
 3.图高>屏高 图宽>屏宽 时，允许上下拖动(限制上下极限)，左右拖动(限制左右极限)
 */

- (void)panImg:(UIPanGestureRecognizer *)gesture{
  //获取手指移动坐标
  CGPoint transition = [gesture translationInView:self];
  CGFloat x = gesture.view.center.x + transition.x;
  CGFloat y = gesture.view.center.y + transition.y;
  
  if (gesture.state == UIGestureRecognizerStateChanged) {
    gesture.view.center = CGPointMake(x, y);
    [gesture setTranslation:CGPointZero inView:self];
  }
  if (gesture.state == UIGestureRecognizerStateEnded){
    //操作完成的位置修正
    CGFloat viewWidth = _showImageView.frame.size.width;
    CGFloat viewHeight = _showImageView.frame.size.height;
    CGFloat imgWidth = _showImage.size.width;
    CGFloat imgHeight = _showImage.size.height;
    
    if (imgWidth/imgHeight <= SCREEN_W/SCREEN_H) {
      //图宽/图高<屏宽/屏高 - 高填充满，两边有黑
      CGFloat noteWidth = viewHeight * imgWidth/imgHeight;
      CGFloat noteHeight = viewHeight;
      if (noteHeight <= SCREEN_H && noteWidth <= SCREEN_W) {
        //图高<屏高 图宽<屏宽 时，图片的中心点与屏幕中心点一致，不允许拖动
        x = SCREEN_W/2;
        y = SCREEN_H/2;
      }
      if (noteHeight >= SCREEN_H && noteWidth < SCREEN_W) {
        //图高>屏高 图宽<屏宽 时，只允许上下拖动(限制上下极限)，不允许左右拖动
        x = SCREEN_W/2;
        if (y >= noteHeight/2) {
          //顶部限定
          y = noteHeight/2;
        }
        if (y - SCREEN_H + noteHeight/2 <= 0) {
          //底部限定
          y = SCREEN_H - noteHeight/2;
        }
        
      }
      if (noteHeight > SCREEN_H && noteWidth >= SCREEN_W) {
        if ((x + noteWidth/2) <= SCREEN_W) {
          x = SCREEN_W - noteWidth/2;
        }
        if (x > noteWidth/2) {
          x = noteWidth/2;
        }
        if (y >= noteHeight/2) {
          //顶部限定
          y = noteHeight/2;
        }
        if (y - SCREEN_H + noteHeight/2 <= 0) {
          //底部限定
          y = SCREEN_H - noteHeight/2;
        }
      }
    }else{
      //图宽/图高>屏宽/屏高 - 宽填充满，上下有黑
      CGFloat noteWidth = viewWidth;
      CGFloat noteHeight = viewWidth * imgHeight/imgWidth;
      if (noteHeight < SCREEN_H && noteWidth < SCREEN_W) {
        //图高<屏高 图宽<屏宽 时，图片的中心点与屏幕中心点一致，不允许拖动
        x = SCREEN_W/2;
        y = SCREEN_H/2;
      }
      if (noteHeight < SCREEN_H && noteWidth >= SCREEN_W) {
        //图高<屏高 图宽>屏宽 时，只允许左右拖动(限制左右极限)，不允许上下拖动
        y = SCREEN_H/2;
        if (x >= noteWidth/2) {
          //左边限定
          x = noteWidth/2;
        }
        if (x - SCREEN_W + noteWidth/2 <= 0) {
          //右边限定
          x = SCREEN_W - noteWidth/2;
        }
      }
      if (noteHeight >= SCREEN_H && noteWidth > SCREEN_W) {
        if (x >= noteWidth/2) {
          //左边限定
          x = noteWidth/2;
        }
        if (x - SCREEN_W + noteWidth/2 <= 0) {
          //右边限定
          x = SCREEN_W - noteWidth/2;
        }
        if ((y + noteHeight/2) <= SCREEN_H) {
          y = SCREEN_H - noteHeight/2;
        }
        if (y > noteHeight/2) {
          y = noteHeight/2;
        }
      }
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
      gesture.view.center = CGPointMake(x, y);
      [gesture setTranslation:CGPointZero inView:self];
    } completion:nil];
  }
}

@end
