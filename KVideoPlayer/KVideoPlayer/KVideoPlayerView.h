//
//  KVideoPlayerVIew.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPlayerControlViewDelagate.h"

@class KPlayerModel;
@protocol KPlayerDelegate <NSObject>
@optional
/** 返回按钮事件 */
- (void)playerBackAction;
/** 下载视频 */
- (void)playerDownload:(NSString *)url;
/** 控制层即将显示 */
- (void)playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen;
/** 控制层即将隐藏 */
- (void)playerControlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen;

@end

// 播放器的几种状态
typedef NS_ENUM(NSInteger, KPlayerState) {
    KPlayerStateFailed,     // 播放失败
    KPlayerStateBuffering,  // 缓冲中
    KPlayerStatePlaying,    // 播放中
    KPlayerStateStopped,    // 停止播放
    KPlayerStatePause       // 暂停播放
};





@interface KVideoPlayerView : UIView

/** 设置代理 */
@property (nonatomic, weak) id<KPlayerDelegate>  delegate;
/** 是否有下载功能(默认是关闭) */
@property (nonatomic, assign) BOOL  hasDownload;
/** 是否开启预览图 */
@property (nonatomic, assign) BOOL  hasPreviewView;

/** 当cell播放视频由全屏变为小屏时候，是否回到中间位置(默认YES) */
@property (nonatomic, assign) BOOL                    cellPlayerOnCenter;

/** 静音（默认为NO）*/
@property (nonatomic, assign) BOOL                    mute;

+ (instancetype)sharedPlayerView;

/**
 * 指定播放的控制层和模型
 * 控制层传nil，默认使用KPlayerControlView(如自定义可传自定义的控制层)
 */
- (void)playerControlView:(UIView *)controlView playerModel:(KPlayerModel *)playerModel;

/**
 * 使用自带的控制层时候可使用此API
 */
- (void)playerModel:(KPlayerModel *)playerModel;

/**
 *  自动播放，默认不自动播放
 */
- (void)autoPlayTheVideo;

/**
 *  重置player
 */
- (void)resetPlayer;

/**
 *  在当前页面，设置新的视频时候调用此方法
 */
- (void)resetToPlayNewVideo:(KPlayerModel *)playerModel;

/**
 *  播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;



@end
