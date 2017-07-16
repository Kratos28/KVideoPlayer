//
//  KAdPlayerView.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/13.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "KAdPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KAdButton.h"
#import "KVideoAdConfiguration.h"
#import "NSString+KVideoAd.h"
#import "KVideoAdCache.h"
#import "KVideoAdDownloader.h"

#define DISPATCH_SOURCE_CANCEL_SAFE(time) if(time)\
{\
dispatch_source_cancel(time);\
time = nil;\
}

@interface KAdPlayerView()
@property (nonatomic, strong) AVPlayer     *adPlayer;
/** 播放属性 */
@property (nonatomic, strong) AVPlayerItem    *adPlayerItem;
@property (nonatomic, strong) AVURLAsset      *adUrlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer          *adPlayerLayer;
//静音按钮
@property (nonatomic, strong) UIButton *muteBtn;
//详情按钮
@property (nonatomic, strong) UIButton *detailsBtn;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) UIView *fatherView;
@property (nonatomic, strong) UIButton *fullScreenBtn;
@property (nonatomic, strong) KAdButton *adSkipButton;
@property(nonatomic,copy)dispatch_source_t waitDataTimer;
@property(nonatomic,copy)dispatch_source_t skipTimer;
@property(nonatomic,strong)KVideoAdConfiguration *videoAdConfiguration;
@end

@implementation KAdPlayerView

#pragma mark getter
- (UIButton *)muteBtn
{
    if (!_muteBtn) {
        _muteBtn = [[UIButton alloc]init];
        [_muteBtn setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
        [_muteBtn setImage:[UIImage imageNamed:@"voice-close"] forState:UIControlStateSelected];
        [_muteBtn addTarget:self action:@selector(muteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteBtn;
}

- (UIButton *)detailsBtn
{
    if (!_detailsBtn) {
        _detailsBtn = [[UIButton alloc]init];
        [_detailsBtn setTitle:@"查看详情" forState:UIControlStateNormal];
        [_detailsBtn addTarget:self action:@selector(detailsBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];[_detailsBtn setBackgroundImage:[UIImage imageNamed:@"bg1"] forState:UIControlStateNormal];
        _detailsBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        

    }
    return _detailsBtn;
}
- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc]init];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"enlarge"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"Player_shrinkscreen"] forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _fullScreenBtn;
}

-(KAdButton *)adSkipButton
{
    if(_adSkipButton == nil)
    {
        _adSkipButton = [[KAdButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-70,25, 70, 40)];
        _adSkipButton.hidden = YES;
        [_adSkipButton addTarget:self action:@selector(adSkipButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _adSkipButton.leftRightSpace = 5;
        _adSkipButton.topBottomSpace = 5;
    }
    return _adSkipButton;
}


#pragma action
- (void)muteBtnClick:(UIButton *)button
{
    button.selected = !button.selected;
    self.adPlayer.muted = button.isSelected;
    
}
//详情点击
- (void)detailsBtnBtnClick:(UIButton *)button
{
    
}
- (void)fullScreenBtnClick:(UIButton *)button
{

}
- (void)adSkipButtonClick
{
    [self removeAndAnimate];
}

- (instancetype)initWithFatherView:(UIView *)view  videoAdconfiguration:(KVideoAdConfiguration *)videoAdConfiguration
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor yellowColor];
        self.fatherView = view;
        
        //        self.adUrlAsset = [AVURLAsset assetWithURL:self.videoAdURL];
        //        self.adPlayerItem = [AVPlayerItem playerItemWithAsset:self.adUrlAsset];
        //        self.adPlayer = [AVPlayer playerWithPlayerItem:self.adPlayerItem];
        self.videoAdConfiguration = videoAdConfiguration;
        [self configAdView];
        
    }
    return self;
}
+ (instancetype)sharedPlayerViewWithFatherView:(UIView *)view  videoAdconfiguration:(KVideoAdConfiguration *)videoAdConfiguration {
    static KAdPlayerView *playerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[KAdPlayerView alloc] initWithFatherView:view videoAdconfiguration:videoAdConfiguration];
        
    });
    return playerView;
}
+ (instancetype)sharedPlayerViewWithFatherView:(UIView *)view  videoAdConfiguaration:(KVideoAdConfiguration *)videoAdconfiguration delegate:(nullable id)delegate
{
    KAdPlayerView *adPlayerView = [self sharedPlayerViewWithFatherView:view videoAdconfiguration:videoAdconfiguration];
    adPlayerView.delegate = delegate;
    return adPlayerView;
}

/**
 *  获取系统音量
 */
- (void)configureVolume
{
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    for (UIView *view in [volumeView subviews]) {
        //如果是MPVolumeSlider控件
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
         
            break;
        }
        
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) {/*处理错误*/}
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.adPlayerLayer.frame = self.bounds;



    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(25);

        make.trailing.mas_equalTo(-50);
        make.bottom.mas_equalTo(-10);

    }];
    
    
    [self.detailsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(25);
        make.trailing.mas_offset(-80);
        make.bottom.mas_equalTo(-10);
    }];
    
    
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(25);
        
        make.trailing.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
    }];
    
}

- (void)configAdView
{
    [self setupVideoAdForConfiguration:self.videoAdConfiguration];

    if (self.fatherView) {
        [self removeFromSuperview];
        [self.fatherView addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
        
    }
 
    [self addSubview:self.muteBtn];
    [self addSubview:self.detailsBtn];
    [self addSubview:self.fullScreenBtn];
}
- (void)setAdPlayerItem:(AVPlayerItem *)adPlayerItem{
    if (_adPlayerItem == adPlayerItem) {return;}
    
    if (adPlayerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:adPlayerItem];
        [_adPlayerItem removeObserver:self forKeyPath:@"status"];
        [_adPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_adPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_adPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _adPlayerItem = adPlayerItem;
    if (adPlayerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:adPlayerItem];
        [adPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [adPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [adPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [adPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.adPlayer.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.adPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
                // 添加playerLayer到self.layer
                [self.layer insertSublayer:self.adPlayerLayer atIndex:0];

            }
        
        }
    }
}
//启动定时器
- (void)startSkipDispathTimer
{
    KVideoAdConfiguration *configuartion = self.videoAdConfiguration;
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    if (!configuartion.skipButtonType) configuartion.skipButtonType = SkipTypeTimeText;
    __block NSInteger duration = 5;//默认是5秒
    //如果configuartion.duration 存在 将时间赋值给duation
    if (configuartion.duration) duration = configuartion.duration;
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           if ([self.delegate respondsToSelector:@selector(adPlayerView:customSkipView:duration:)]) {
               [self.delegate adPlayerView:self customSkipView:configuartion.customSkipView duration:duration];
           }
           if (!configuartion.customSkipView)
           {
               [self.adSkipButton stateWithskipType:configuartion.skipButtonType andDuration:duration];
           }
           if (duration==0) {
               DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer);
//               [self removeAndAnimate]; return ;
           }
           duration --;
       });
    });
    dispatch_resume(_skipTimer);
}


-(void)setupVideoAdForConfiguration:(KVideoAdConfiguration *)configuration
{
    if (!configuration.videoNameOrURLString.length) return;
    if (configuration.videoNameOrURLString.k_isURLString) { //如果configuration有URL
        [KVideoAdCache async_saveVideoUrl:configuration.videoNameOrURLString];
        
        NSURL *pathURL = [KVideoAdCache getCacheVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
        if (pathURL) {
            if ([self.delegate respondsToSelector:@selector(adPlayerView:videoDownLoadFinish:)]) {
                [self.delegate adPlayerView:self videoDownLoadFinish:pathURL];
            }
            self.adUrlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
            self.adPlayerItem = [AVPlayerItem playerItemWithAsset:self.adUrlAsset];
            self.adPlayer = [AVPlayer playerWithPlayerItem:self.adPlayerItem];
            self.adPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.adPlayer];
            [self play];
        }else
        {
            [[KVideoAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:configuration.videoNameOrURLString] progress:^(unsigned long long total, unsigned long long current) {
                if([self.delegate respondsToSelector:@selector(adPlayerView:videoDownLoadProgress:total:current:)])
                {
                    [self.delegate adPlayerView:self videoDownLoadProgress:current/(float)total total:total current:current];
                }
                
            } completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
                if ([self.delegate respondsToSelector:@selector(adPlayerView:videoDownLoadFinish:)]) {
                    [self.delegate adPlayerView:self videoDownLoadFinish:location];
                }
            }];
        }
    }else
    {//configuration没有URL ,就去Bundle找
        NSString *path = [[NSBundle mainBundle]pathForResource:configuration.videoNameOrURLString ofType:nil];
        if (path) {
            if ([self.delegate respondsToSelector:@selector(adPlayerView:videoDownLoadFinish:)]) {
                [self.delegate adPlayerView:self videoDownLoadFinish:[NSURL URLWithString:path]];
            }
            self.adUrlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:configuration.videoNameOrURLString]];
            self.adPlayerItem = [AVPlayerItem playerItemWithAsset:self.adUrlAsset];
            self.adPlayer = [AVPlayer playerWithPlayerItem:self.adPlayerItem];
            self.adPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.adPlayer];
            [self play];
        }else
        {
            NSLog(@"Error:视频文件未找到,或名称有误!");
        }
    }
    //开始启用定时器
    [self startSkipDispathTimer];
    //添加剩余时间按钮
    [self addSkipButtonForConfiguration:configuration];
    
}
- (void)play {
    self.isPlay = YES;
    
    [self.adPlayer play];
}
- (void)stop
{
    self.isPlay = NO;

    [self.adPlayer pause];
}
-(void)addSkipButtonForConfiguration:(KVideoAdConfiguration *)configuration
{
    if(!configuration.duration) configuration.duration = 5;
    if(!configuration.skipButtonType) configuration.skipButtonType = SkipTypeTimeText;
    
    //如果存在用户自定义剩余时间按钮
    if(configuration.customSkipView)
    {
        [self addSubview:configuration.customSkipView];
    }
    else
    {
        [self addSubview:self.adSkipButton];
        //配置剩余时间按钮
        [self.adSkipButton stateWithskipType:configuration.skipButtonType andDuration:configuration.duration];
    }
}

- (void)moviePlayDidEnd:(AVPlayerItem *)item
{
    [self removeAndAnimate];
 
}

- (void)removeAndAnimate
{
    [UIView animateWithDuration:0.8 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self remove];
    }];
}
- (void)remove
{
    DISPATCH_SOURCE_CANCEL_SAFE(_waitDataTimer);
    DISPATCH_SOURCE_CANCEL_SAFE(_skipTimer);
    if (self.isPlay) {
        self.isPlay = NO;
        [self stop];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerPlayEnd)]) {
        [self.delegate playerPlayEnd];
    }
    
    [_adPlayerItem removeObserver:self forKeyPath:@"status"];
    [_adPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_adPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_adPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.adPlayerItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.adPlayerLayer removeFromSuperlayer];
    [self.adPlayer replaceCurrentItemWithPlayerItem:nil];
    self.adPlayer = nil;
    self.adUrlAsset = nil;
    self.videoAdConfiguration = nil;
    [self removeFromSuperview];
    NSLog(@"%@",self.adPlayer);
    NSLog(@"%@",self.adPlayerItem);
    NSLog(@"%@",self.adUrlAsset);
    NSLog(@"%@",self.waitDataTimer);
    
    NSLog(@"%@",self.skipTimer);


}
- (void)dealloc
{

    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"释放");
}
@end
