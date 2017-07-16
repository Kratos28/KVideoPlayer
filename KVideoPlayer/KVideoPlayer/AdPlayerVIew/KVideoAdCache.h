//
//  KVideoAdCache.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface KVideoAdCache : NSObject
NS_ASSUME_NONNULL_BEGIN
+(void)async_saveVideoUrl:(NSString *_Nullable)url;
+(NSString *_Nullable)videoPathWithURL:(NSURL *_Nullable)url;
+(BOOL)checkVideoInCacheWithURL:(NSURL *)url;
+(nullable NSURL *)getCacheVideoWithURL:(NSURL *_Nullable)url;
+(void)async_saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url;

NS_ASSUME_NONNULL_END
@end
