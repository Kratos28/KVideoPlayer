//
//  UIWindow+CurrentViewController.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/9.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (CurrentViewController)

//返回当前window最上层的控制器
+ (UIViewController*)currentViewController;

@end
