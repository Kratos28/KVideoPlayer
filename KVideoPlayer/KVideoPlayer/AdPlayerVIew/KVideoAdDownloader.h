//
//  KVideoAdDownloader.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/16.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^KAdDownloadProgressBlock)(unsigned long long total, unsigned long long current);
typedef void(^KAdDownloadVideoCompletedBlock)(NSURL * _Nullable location, NSError * _Nullable error);
@protocol KAdDownloadDelegate <NSObject>

- (void)downloadFinishWithURL:(nonnull NSURL *)url;

@end
@interface KVideoAdDownloader : NSObject
@property (assign, nonatomic ,nonnull)id<KAdDownloadDelegate> delegate;
+ (nonnull instancetype )sharedDownloader;
- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable KAdDownloadProgressBlock)progressBlock completed:(nullable KAdDownloadVideoCompletedBlock)completedBlock;
@end
