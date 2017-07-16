//
//  KVideoAdDownloader.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/16.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "KVideoAdDownloader.h"
#import "NSString+KVideoAd.h"
#import "KVideoAdCache.h"

@interface KVideoAdDownloader() <NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate>
@property (strong, nonatomic, nonnull) NSOperationQueue *downloadVideoQueue;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic, copy) KAdDownloadProgressBlock progressBlock;
@property (nonatomic, copy ) KAdDownloadVideoCompletedBlock completedBlock;
@property (strong, nonatomic) NSURLSession *session;
@property(strong,nonatomic)NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSMutableDictionary *allDownloadDict;

@end

@implementation KVideoAdDownloader
+(nonnull instancetype )sharedDownloader{
    static KVideoAdDownloader *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken,^{
        
        instance = [[KVideoAdDownloader alloc] init];
        
    });
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadVideoQueue = [NSOperationQueue new];
        _downloadVideoQueue.maxConcurrentOperationCount = 3;
        _downloadVideoQueue.name = @"com.kratos.KVideoPlayer";
    }
    return self;
}

-(nonnull instancetype)initWithURL:(nonnull NSURL *)url delegateQueue:(nonnull NSOperationQueue *)queue progress:(nullable KAdDownloadProgressBlock)progressBlock completed:(nullable KAdDownloadVideoCompletedBlock)completedBlock
{
    self = [super init];
    if (self) {
        
        self.url = url;
        self.progressBlock = progressBlock;
        _completedBlock = completedBlock;
        NSURLSessionConfiguration * sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                     delegate:self
                                                delegateQueue:queue];
        self.downloadTask =  [self.session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
        [self.downloadTask resume];
    }
    return self;
    
}
- (void)downloadVideoWithURL:(nonnull NSURL *)url progress:(nullable KAdDownloadProgressBlock)progressBlock completed:(nullable KAdDownloadVideoCompletedBlock)completedBlock
{
    if(self.allDownloadDict[url.absoluteString.k_md5String]) return;
    //allDownlaadDict不存在，开始下载
    KVideoAdDownloader * download = [[KVideoAdDownloader alloc] initWithURL:url delegateQueue:_downloadVideoQueue progress:progressBlock completed:completedBlock];
    [self.allDownloadDict setObject:download forKey:url.absoluteString.k_md5String];
}

- (void)downLoadVideoAndCacheWithURLArray:(nonnull NSArray <NSURL *> * )urlArray
{
    [urlArray enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
        
        if(![KVideoAdCache checkVideoInCacheWithURL:url])
        {
            [self downloadVideoWithURL:url progress:nil completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
                
                if(!error && location) [KVideoAdCache async_saveVideoAtLocation:location URL:url];
                
            }];
        }
        
    }];
    
}

- (NSMutableDictionary *)allDownloadDict {
    if (!_allDownloadDict) {
        
        _allDownloadDict = [[NSMutableDictionary alloc] init];
    }
    
    return _allDownloadDict;
}
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    NSError *error=nil;
    NSURL *toURL = [NSURL fileURLWithPath:[KVideoAdCache videoPathWithURL:self.url]];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:toURL error:&error];
    if(error)  NSLog(@"error=%@",error);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_completedBlock) {
            
            if(!error)
            {
                _completedBlock(toURL,nil);
            }
            else
            {
                _completedBlock(nil,error);
            }
            // 防止重复调用
            _completedBlock = nil;
        }
        //下载完成回调
        if ([self.delegate respondsToSelector:@selector(downloadFinishWithURL:)]) {
            [self.delegate downloadFinishWithURL:self.url];
        }
    });
    
    [self.session invalidateAndCancel];
    self.session = nil;
}


@end
