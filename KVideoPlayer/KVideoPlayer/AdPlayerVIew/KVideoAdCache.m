//
//  KVideoAdCache.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "KVideoAdCache.h"
#import "NSString+KVideoAd.h"
static NSString *const key_cacheVideoUrlString = @"kVideoAd_key_cacheVideoUrlString";

@implementation KVideoAdCache
+(void)async_saveVideoUrl:(NSString *)url
{
    if (url ==nil) return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:key_cacheVideoUrlString];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}
+(nullable NSURL *)getCacheVideoWithURL:(NSURL *)url
{
    NSString *savePath = [[self videoAdCachePath] stringByAppendingPathComponent:url.absoluteString.k_videoName];
    //如果存在
    if([[NSFileManager defaultManager] fileExistsAtPath:savePath])
    {
        return [NSURL fileURLWithPath:savePath];
    }
    return nil;
}
+ (NSString *)videoAdCachePath
{
    NSString *path =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/KVideoAdCache"];
    [self checkDirectory:path];
    return path;
}
+ (void)checkDirectory:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}
+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        NSLog(@"KVideoAdCachePath:%@",path);
        [self addDoNotBackupAttribute:path];
    }
}
+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error to set do not backup attribute, error = %@", error);
    }
}

+(void)async_saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self saveVideoAtLocation:location URL:url];
    });
    
}
+(nullable NSURL *)saveVideoAtLocation:(NSURL *)location URL:(NSURL *)url
{
    NSString *savePath = [[self kVideoAdCachePath] stringByAppendingPathComponent:url.absoluteString.k_videoName];
    NSURL *savePathUrl = [NSURL fileURLWithPath:savePath];
    
    BOOL result =[[NSFileManager defaultManager] moveItemAtURL:location toURL:savePathUrl error:nil];
    
    if (result) {
        
        return savePathUrl;
        
    }else{
        
        return nil;
    }
}
//获取文件路径
+(NSString *)videoPathWithURL:(NSURL *)url
{
    if(url==nil) return nil;
    return [[self kVideoAdCachePath] stringByAppendingPathComponent:url.absoluteString.k_videoName];
}
//获取缓存路径
+ (NSString *)kVideoAdCachePath{
    
    NSString *path =[NSHomeDirectory() stringByAppendingPathComponent:@"Library/KVideoAdCache"];
    [self checkDirectory:path];
    return path;
    
}
+(BOOL)checkVideoInCacheWithURL:(NSURL *)url
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPathWithURL:url]];
}

@end
