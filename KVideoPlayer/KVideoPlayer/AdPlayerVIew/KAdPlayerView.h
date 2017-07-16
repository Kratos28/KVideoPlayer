//
//  KAdPlayerView.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/13.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class KVideoAdConfiguration;
@class KAdPlayerView;
@protocol KAdPlayerViewDelegate  <NSObject>
@optional
/**
 *  video本地读取/或下载完成回调
 */
-(void)adPlayerView:(KAdPlayerView *_Nullable)adPlayerView videoDownLoadFinish:(NSURL *_Nonnull)pathURL;
/**
 *  广告点击
 */
- (void)adClick:(KAdPlayerView *_Nullable)KAdPlayerView;


-(void)adPlayerView:(KAdPlayerView *)adPlayerView videoDownLoadProgress:(float)progress total:(unsigned long long)total current:(unsigned long long)current;


//倒计时回调
-(void)adPlayerView:(KAdPlayerView *)adPlayerView customSkipView:(UIView *)customSkipView duration:(NSInteger)duration;


/**
 视频播放完毕
 */
- (void)playerPlayEnd;
@end



@interface KAdPlayerView : UIView
@property (nonatomic ,assign) id  <KAdPlayerViewDelegate> delegate;
+ (instancetype _Nonnull )sharedPlayerViewWithFatherView:(UIView *_Nonnull)view  videoAdConfiguaration:(KVideoAdConfiguration *_Nonnull)videoAdconfiguration delegate:(nullable id)delegate;
@end
NS_ASSUME_NONNULL_END
