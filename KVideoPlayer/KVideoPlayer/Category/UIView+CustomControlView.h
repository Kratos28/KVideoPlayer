//
//  UIView+CustomControlView.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/5.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPlayerModel.h"
#import "KPlayerControlViewDelagate.h"




@interface UIView (CustomControlView)
@property (nonatomic, weak) id<KPlayerControlViewDelagate> delegate;

/**
 * 设置播放模型
 */
- (void)playerModel:(KPlayerModel *)playerModel;

- (void)playerShowOrHideControlView;
/**
 * 显示控制层
 */
- (void)playerShowControlView;

/**
 * 隐藏控制层*/
- (void)playerHideControlView;

/**
 * 重置ControlView
 */
- (void)playerResetControlView;

/**
 * 切换分辨率时重置ControlView
 */
- (void)playerResetControlViewForResolution;

/**
 * 取消自动隐藏控制层view
 */
- (void)playerCancelAutoFadeOutControlView;

/**
 * 开始播放（用来隐藏placeholderImageView）
 */
- (void)playerItemPlaying;

/**
 * 播放完了
 */
- (void)playerPlayEnd;

/**
 * 是否有下载功能
 */
- (void)playerHasDownloadFunction:(BOOL)sender;

/**
 * 是否有切换分辨率功能
 * @param resolutionArray 分辨率名称的数组
 */
- (void)playerResolutionArray:(NSArray *)resolutionArray;

/**
 * 播放按钮状态 (播放、暂停状态)
 */
- (void)playerPlayBtnState:(BOOL)state;

/**
 * 锁定屏幕方向按钮状态
 */
- (void)playerLockBtnState:(BOOL)state;

/**
 * 下载按钮状态
 */
- (void)playerDownloadBtnState:(BOOL)state;

/**
 * 加载的菊花
 */
- (void)playerActivity:(BOOL)animated;

/**
 * 设置预览图
 
 * @param draggedTime 拖拽的时长
 * @param image       预览图
 */
- (void)playerDraggedTime:(NSInteger)draggedTime sliderImage:(UIImage *)image;

/**
 * 拖拽快进 快退
 
 * @param draggedTime 拖拽的时长
 * @param totalTime   视频总时长
 * @param forawrd     是否是快进
 * @param preview     是否有预览图
 */
- (void)playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd hasPreview:(BOOL)preview;

/**
 * 滑动调整进度结束结束
 */
- (void)playerDraggedEnd;

/**
 * 正常播放
 
 * @param currentTime 当前播放时长
 * @param totalTime   视频总时长
 * @param value       slider的value(0.0~1.0)
 */
- (void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;

/**
 * progress显示缓冲进度
 */
- (void)playerSetProgress:(CGFloat)progress;

/**
 * 视频加载失败
 */
- (void)playerItemStatusFailed:(NSError *)error;

/**
 * 小屏播放
 */
- (void)playerBottomShrinkPlay;

/**
 * 在cell播放
 */
- (void)playerCellPlay;
@end
