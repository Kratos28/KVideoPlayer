//
//  KPlayerModel.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPlayerModel : NSObject

/** 视频标题 */
@property (nonatomic, copy  ) NSString     *title;
/** 视频URL */
@property (nonatomic, strong) NSURL        *videoURL;
/** 视频封面本地图片 */
@property (nonatomic, strong) UIImage      *placeholderImage;
/** 播放器View的父视图（非cell播放使用这个）*/
@property (nonatomic, weak  ) UIView       *fatherView;

/**
 * 视频封面网络图片url
 * 如果和本地图片同时设置，则忽略本地图片，显示网络图片
 */
@property (nonatomic, copy  ) NSString     *placeholderImageURLString;
/**
 * 视频分辨率字典, 分辨率标题与该分辨率对应的视频URL.
 * 例如: @{@"高清" : @"https://xx/xx-hd.mp4", @"标清" : @"https://xx/xx-sd.mp4"}
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *resolutionDic;
/** 从xx秒开始播放视频(默认0) */
@property (nonatomic, assign) NSInteger    seekTime;
// cell播放视频，以下属性必须设置值
@property (nonatomic, strong) UIScrollView *scrollView;
/** cell所在的indexPath */
@property (nonatomic, strong) NSIndexPath  *indexPath;
/**
 * cell上播放必须指定
 * 播放器View的父视图tag（根据tag值在cell里查找playerView加到哪里)
 */
@property (nonatomic, assign) NSInteger    fatherViewTag;


@end
