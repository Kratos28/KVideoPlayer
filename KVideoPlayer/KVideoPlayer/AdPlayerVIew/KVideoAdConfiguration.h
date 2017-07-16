//
//  KLaunchAdConfiguration.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KAdButton.h"

NS_ASSUME_NONNULL_BEGIN

//显示完成动画时间默认时间
static CGFloat const KshowFinishAnimateTimeDefault = 0.8;
/**
 *  显示完成动画
 */
typedef NS_ENUM(NSInteger , KShowFinishAnimate) {
    
    /**
     *  无
     */
    KShowFinishAnimateNone = 1,
    /**
     *  普通淡入(default)
     */
    KShowFinishAnimateFadein = 2,
    /**
     *  放大淡入
     */
    KShowFinishAnimateLite = 3
    
};


@interface KVideoAdConfiguration : NSObject
/**
 *  video本地名或网络链接URL string
 */
@property(nonatomic,copy)NSString *videoNameOrURLString;
/**
 *  停留时间(default 5 ,单位:秒)
 */
@property(nonatomic,assign) NSInteger duration;
/**
 *  跳过按钮类型(default SkipTypeTimeText)
 */
@property(nonatomic,assign) SkipType skipButtonType;


/**
 *  显示完成动画(default ShowFinishAnimateFadein)
 */
@property(nonatomic,assign) KShowFinishAnimate showFinishAnimate;
/**
 *  显示完成动画时间(default 0.8 , 单位:秒)
 */
@property(nonatomic,assign) CGFloat showFinishAnimateTime;
/**
 *  点击打开页面地址
 */
@property(nonatomic,copy)NSString *openURLString;
/**
 *  自定义跳过按钮(若定义此视图,将会自定替换系统跳过按钮)
 */
@property(nonatomic,strong) UIView *customSkipView;

@end
NS_ASSUME_NONNULL_END
