//
//  KVideoPlayerVIew.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "KVideoPlayerView.h"
#import "KPlayerModel.h"
#import "KPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+CustomControlView.h"
#import "Masonry.h"
#import "KBrightnessView.h"
@interface KVideoPlayerView () <UIGestureRecognizerDelegate,KPlayerControlViewDelagate>
/** 单击 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/** 双击 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) id                     timeObserver;
@property (nonatomic, strong) KPlayerModel   *playerModel;
@property (nonatomic, strong) UIView     *controlView;
/** 是否为全屏 */
@property (nonatomic, assign) BOOL                   isFullScreen;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                   isPauseByUser;
/** 滑杆 */
@property (nonatomic, strong) UISlider               *volumeViewSlider;
/** 播放属性 */
@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                   isLocalVideo;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;
/** 视频填充模式 */
@property (nonatomic, copy) NSString    *videoGravity;
/** 是否自动播放 */
@property (nonatomic, assign) BOOL  isAutoPlay;
/** 播发器的几种状态 */
@property (nonatomic, assign) KPlayerState  state;
@property (nonatomic, strong) NSIndexPath            *indexPath;
/** ViewController中页面是否消失 */
@property (nonatomic, assign) BOOL                   viewDisappear;
/** slider预览图 */
@property (nonatomic, strong) UIImage                *thumbImg;
@property (nonatomic, assign) NSInteger    seekTime;

@property (nonatomic, strong) NSDictionary           *resolutionDic;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray                *videoURLArray;

/** palyer加到tableView */
@property (nonatomic, strong) UIScrollView           *scrollView;
@property (nonatomic, strong) NSURL                  *videoURL;

/** 是否在cell上播放video */
@property (nonatomic, assign) BOOL                   isCellVideo;
/** 是否缩小视频在底部 */
@property (nonatomic, assign) BOOL                   isBottomVideo;
/** 是否切换分辨率*/
@property (nonatomic, assign) BOOL                   isChangeResolution;
/** 是否正在拖拽 */
@property (nonatomic, assign) BOOL                   isDragged;
/** 小窗口距屏幕右边和下边的距离 */
@property (nonatomic, strong) UIPanGestureRecognizer *shrinkPanGesture;

/** 是否锁定屏幕方向 */
@property (nonatomic, assign) BOOL                   isLocked;

/** 播放完了*/
@property (nonatomic, assign) BOOL                   playDidEnd;
/** 是否再次设置URL播放视频 */
@property (nonatomic, assign) BOOL                   repeatToPlay;

/** 小窗口距屏幕右边和下边的距离 */
@property (nonatomic, assign) CGPoint                shrinkRightBottomPoint;

/** 当cell划出屏幕的时候停止播放（默认为NO） */
@property (nonatomic, assign) BOOL                    stopPlayWhileCellNotVisable;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat                sliderLastValue;
@end

@implementation KVideoPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeThePlayer];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeThePlayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
/**
 *  初始化player
 */
- (void)initializeThePlayer {
    self.cellPlayerOnCenter = YES;
}


+ (instancetype)sharedPlayerView {
    static KVideoPlayerView *playerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerView = [[KVideoPlayerView alloc] init];
    });
    return playerView;
}

- (void)playerControlView:(UIView *)controlView playerModel:(KPlayerModel *)playerModel
{
    if (!controlView) {
        KPlayerControlView *defaultControlView = [[KPlayerControlView alloc] init];
        self.controlView = defaultControlView;
    }else
    {
        self.controlView = controlView;
    }
    self.playerModel = playerModel;
}

- (void)autoPlayTheVideo
{
    [self configPlayer];
}

- (NSString *)videoGravity {
    if (!_videoGravity) {
        _videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _videoGravity;
}



/**
 * 使用自带的控制层时候可使用此API
 */
- (void)playerModel:(KVideoPlayerView *)playerModel
{
    
}

/**
 *  player添加到fatherView上
 */
- (void)addPlayerToFatherView:(UIView *)view {
    // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
    if (view) {
        [self removeFromSuperview];
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
}

- (void)setResolutionDic:(NSDictionary *)resolutionDic {
    _resolutionDic = resolutionDic;
    self.videoURLArray = [resolutionDic allValues];
}
- (void)setPlayerModel:(KPlayerModel *)playerModel {
    _playerModel = playerModel;
    
    if (playerModel.seekTime) { self.seekTime = playerModel.seekTime; }
    [self.controlView playerModel:playerModel];
    // 分辨率
    if (playerModel.resolutionDic) {
        self.resolutionDic = playerModel.resolutionDic;
    }
    
    if (playerModel.scrollView && playerModel.indexPath && playerModel.videoURL) {
        NSCAssert(playerModel.fatherViewTag, @"请指定playerViews所在的faterViewTag");
        [self cellVideoWithScrollView:playerModel.scrollView AtIndexPath:playerModel.indexPath];
        if ([self.scrollView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)playerModel.scrollView;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:playerModel.indexPath];
            UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
            [self addPlayerToFatherView:fatherView];
        } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)playerModel.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:playerModel.indexPath];
            UIView *fatherView = [cell.contentView viewWithTag:playerModel.fatherViewTag];
            [self addPlayerToFatherView:fatherView];
        }
    } else {
        NSCAssert(playerModel.fatherView, @"请指定playerView的faterView");
        [self addPlayerToFatherView:playerModel.fatherView];
    }
    self.videoURL = playerModel.videoURL;
  
}
/**
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {return;}
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                [self setNeedsLayout];
                [self layoutIfNeeded];
                // 添加playerLayer到self.layer
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                self.state = KPlayerStatePlaying;
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
                panRecognizer.delegate = self;
                [panRecognizer setMaximumNumberOfTouches:1];
                [panRecognizer setDelaysTouchesBegan:YES];
                [panRecognizer setDelaysTouchesEnded:YES];
                [panRecognizer setCancelsTouchesInView:YES];
                [self addGestureRecognizer:panRecognizer];
                
                // 跳到xx秒播放视频
                if (self.seekTime) {
                    [self seekToTime:self.seekTime completionHandler:nil];
                }
                self.player.muted = self.mute;
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.state = KPlayerStateFailed;
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.controlView playerSetProgress:timeInterval / totalDuration];
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                self.state = KPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.state == KPlayerStateBuffering){
                self.state = KPlayerStatePlaying;
            }
        }
    } else if (object == self.scrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            if (self.isFullScreen) { return; }
            // 当tableview滚动时处理playerView的位置
            [self handleScrollOffsetWithDict:change];
        }
    }
}
/**
 *  回到cell显示
 */
- (void)updatePlayerViewToCell {
    if (!self.isBottomVideo) { return; }
    self.isBottomVideo = NO;
    [self setOrientationPortraitConstraint];
    [self.controlView playerCellPlay];
}
/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint {
    if (self.isCellVideo) {
        if ([self.scrollView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)self.scrollView;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
            self.isBottomVideo = NO;
            if (![tableView.visibleCells containsObject:cell]) {
                [self updatePlayerViewToBottom];
            } else {
                UIView *fatherView = [cell.contentView viewWithTag:self.playerModel.fatherViewTag];
                [self addPlayerToFatherView:fatherView];
            }
        } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)self.scrollView;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
            self.isBottomVideo = NO;
            if (![collectionView.visibleCells containsObject:cell]) {
                [self updatePlayerViewToBottom];
            } else {
                UIView *fatherView = [cell viewWithTag:self.playerModel.fatherViewTag];
                [self addPlayerToFatherView:fatherView];
            }
        }
    } else {
        [self addPlayerToFatherView:self.playerModel.fatherView];
    }
    
    [self toOrientation:UIInterfaceOrientationPortrait];
    self.isFullScreen = NO;
}

/**
 *  设置横屏的约束
 */
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    //UI重新布局
    [self toOrientation:orientation];
    self.isFullScreen = YES;
}
- (void)toOrientation:(UIInterfaceOrientation)orientation {
    // 获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }
    
    // 根据要旋转的方向,使用Masonry重新修改限制
    if (orientation != UIInterfaceOrientationPortrait) {//
        // 这个地方加判断是为了从全屏的一侧,直接到全屏的另一侧不用修改限制,否则会出错;
        if (currentOrientation == UIInterfaceOrientationPortrait) {
            [self removeFromSuperview];
            KBrightnessView *brightnessView = [KBrightnessView sharedBrightnessView];
            [[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
                make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
    }
    // iOS6.0之后,设置状态条的方法能使用的前提是shouldAutorotate为NO,也就是说这个视图控制器内,旋转要关掉;
    // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.transform = CGAffineTransformIdentity;
    self.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}


/**
 *  缩小到底部，显示小视频
 */
- (void)updatePlayerViewToBottom {
    if (self.isBottomVideo) { return; }
    self.isBottomVideo = YES;
    if (self.playDidEnd) { // 如果播放完了，滑动到小屏bottom位置时，直接resetPlayer
        self.repeatToPlay = NO;
        self.playDidEnd   = NO;
        [self resetPlayer];
        return;
    }
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    if (CGPointEqualToPoint(self.shrinkRightBottomPoint, CGPointZero)) { // 没有初始值
        self.shrinkRightBottomPoint = CGPointMake(10, self.scrollView.contentInset.bottom+10);
    } else {
        [self setShrinkRightBottomPoint:self.shrinkRightBottomPoint];
    }
    // 小屏播放
    [self.controlView playerBottomShrinkPlay];
}
#pragma mark - tableViewContentOffset

/**
 *  KVO TableViewContentOffset
 *
 *  @param dict void
 */
- (void)handleScrollOffsetWithDict:(NSDictionary*)dict {
    if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.indexPath];
        NSArray *visableCells = tableView.visibleCells;
        if ([visableCells containsObject:cell]) {
            // 在显示中
            [self updatePlayerViewToCell];
        } else {
            if (self.stopPlayWhileCellNotVisable) {
                [self resetPlayer];
            } else {
                // 在底部
                [self updatePlayerViewToBottom];
            }
        }
    } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPath];
        if ( [collectionView.visibleCells containsObject:cell]) {
            // 在显示中
            [self updatePlayerViewToCell];
        } else {
            if (self.stopPlayWhileCellNotVisable) {
                [self resetPlayer];
            } else {
                // 在底部
                [self updatePlayerViewToBottom];
            }
        }
    }
}


#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.state = KPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
        
    });
}


#pragma mark - NSNotification Action

/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification {
    self.state = KPlayerStateStopped;
    if (self.isBottomVideo && !self.isFullScreen) { // 播放完了，如果是在小屏模式 && 在bottom位置，直接关闭播放器
        self.repeatToPlay = NO;
        self.playDidEnd   = NO;
        [self resetPlayer];
    } else {
        if (!self.isDragged) { // 如果不是拖拽中，直接结束播放
            self.playDidEnd = YES;
            //结束播放
            [self.controlView playerPlayEnd];
        }
    }
}



#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}


- (void)configPlayer
{
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    // 初始化playerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.backgroundColor = [UIColor blackColor];
    // 此处为默认视频填充模式
    self.playerLayer.videoGravity = self.videoGravity;
    
    
    // 自动播放
    self.isAutoPlay = YES;
    // 添加播放进度计时器
    [self createTimer];
    
    
    // 获取系统音量
    [self configureVolume];
    
    
    // 本地文件不设置PlayerStateBuffering状态
    if ([self.playerModel.videoURL.scheme isEqualToString:@"file"]) {
        self.state = KPlayerStatePlaying;
        self.isLocalVideo = YES;
        [self.controlView playerDownloadBtnState:NO];
    } else {
        self.state = KPlayerStateBuffering;
        self.isLocalVideo = NO;
        [self.controlView playerDownloadBtnState:YES];
    }
    
    [self play];
    // 开始播放
    [self play];
    self.isPauseByUser = NO;
    
}
/**
 *  创建手势
 */
- (void)createGesture {
    // 单击
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self addGestureRecognizer:self.singleTap];
    
    // 双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    self.doubleTap.delegate                = self;
    self.doubleTap.numberOfTouchesRequired = 1; //手指数
    self.doubleTap.numberOfTapsRequired    = 2;
    [self addGestureRecognizer:self.doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

#pragma mark 开始播放
- (void)play
{
    [self.controlView playerPlayBtnState:YES];
    if (self.state ==KPlayerStatePause) {
        self.state = KPlayerStatePlaying;
    }
    self.isPauseByUser = NO;
    [_player play];
}

/**
 * 暂停
 */
- (void)pause {
    [self.controlView playerPlayBtnState:NO];
    if (self.state == KPlayerStatePlaying) { self.state = KPlayerStatePause;}
    self.isPauseByUser = YES;
    [_player pause];
}

/**
 *  设置播放的状态
 *
 *  @param state ZFPlayerState
 */
- (void)setState:(KPlayerState)state {
    _state = state;
    // 控制菊花显示、隐藏 ,如果 state == KPlayerStateBuffering 加载菊花
    [self.controlView playerActivity:state == KPlayerStateBuffering];
    if (state == KPlayerStatePlaying || state == KPlayerStateBuffering) {
        // 隐藏占位图
        [self.controlView playerItemPlaying];
    } else if (state == KPlayerStateFailed) {
        NSError *error = [self.playerItem error];
        [self.controlView playerItemStatusFailed:error];
    }
}

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        [self.controlView playerActivity:YES];
        [self.player pause];
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            [weakSelf.controlView playerActivity:NO];
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            [weakSelf.player play];
            weakSelf.seekTime = 0;
            weakSelf.isDragged = NO;
            // 结束滑动
            [weakSelf.controlView playerDraggedEnd];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp && !weakSelf.isLocalVideo) { weakSelf.state =KPlayerStateBuffering; }
            
        }];
    }
}

/**
 *  用于cell上播放player
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 */
- (void)cellVideoWithScrollView:(UIScrollView *)scrollView
                    AtIndexPath:(NSIndexPath *)indexPath {
    // 如果页面没有消失，并且playerItem有值，需要重置player(其实就是点击播放其他视频时候)
    if (!self.viewDisappear && self.playerItem) { [self resetPlayer]; }
    // 在cell上播放视频
    self.isCellVideo      = YES;
    // viewDisappear改为NO
    self.viewDisappear    = NO;
    // 设置tableview
    self.scrollView       = scrollView;
    // 设置indexPath
    self.indexPath        = indexPath;
    // 在cell播放
    [self.controlView playerCellPlay];
    
    self.shrinkPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(shrikPanAction:)];
    self.shrinkPanGesture.delegate = self;
    [self addGestureRecognizer:self.shrinkPanGesture];
}


- (void)createTimer {
    __weak typeof(self) weakSelf = self;
    //添加定时器,每隔一秒调用一次
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        //AVPlayerItem  包含视频详细信息
        AVPlayerItem *currentItem = weakSelf.playerItem;
        //此属性提供视频项目可以寻求的时间范围集合。提供的范围可能是不连续的。
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        // timescale . value/timescale = seconds
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [weakSelf.controlView playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];

        }
    }];
}

/**
 *  获取系统音量
 */
- (void)configureVolume
{
    
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]) {
        //如果是MPVolumeSlider控件
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
            //取出MPVolumeSlider控件 赋值给_volumeViewSlider
            _volumeViewSlider = (UISlider *)view;
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (gestureRecognizer == self.shrinkPanGesture && self.isCellVideo) {
        if (!self.isBottomVideo || self.isFullScreen) {
            return NO;
        }
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer != self.shrinkPanGesture) {
        if ((self.isCellVideo && !self.isFullScreen) || self.playDidEnd || self.isLocked){
            return NO;
        }
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.isBottomVideo && !self.isFullScreen) {
            return NO;
        }
    }
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    return YES;
}
/**
 *  videoURL的setter方法
 *
 *  @param videoURL videoURL
 */
- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    
    // 每次加载视频URL都设置重播为NO
    self.repeatToPlay = NO;
    self.playDidEnd   = NO;
    
    // 添加通知
    [self addNotifications];
    
    self.isPauseByUser = YES;
    
    // 添加手势
    [self createGesture];
    
}

#pragma mark - 观察者、通知

/**
 *  添加观察者、通知
 */
- (void)addNotifications {
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStatusBarOrientationChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

/**
 *  解锁屏幕方向锁定
 */
- (void)unLockTheScreen {
    // 调用AppDelegate单例记录播放状态是否锁屏
    [KBrightnessView sharedBrightnessView].isLockScreen = NO;
    [self.controlView playerLockBtnState:NO];
    self.isLocked = NO;
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

#pragma mark 屏幕转屏相关

/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        [self setOrientationLandscapeConstraint:orientation];
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortraitConstraint];
    }
}
// 状态条变化通知（在前台播放才去处理）
- (void)onStatusBarOrientationChange {
//    if (!self.didEnterBackground) {
//        // 获取到当前状态条的方向
//        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
//        if (currentOrientation == UIInterfaceOrientationPortrait) {
//            [self setOrientationPortraitConstraint];
//            if (self.cellPlayerOnCenter) {
//                if ([self.scrollView isKindOfClass:[UITableView class]]) {
//                    UITableView *tableView = (UITableView *)self.scrollView;
//                    [tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//                    
//                } else if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
//                    UICollectionView *collectionView = (UICollectionView *)self.scrollView;
//                    [collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//                }
//            }
//            [self.brightnessView removeFromSuperview];
//            [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
//            [self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.width.height.mas_equalTo(155);
//                make.leading.mas_equalTo((ScreenWidth-155)/2);
//                make.top.mas_equalTo((ScreenHeight-155)/2);
//            }];
//        } else {
//            if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
//                [self toOrientation:UIInterfaceOrientationLandscapeRight];
//            } else if (currentOrientation == UIDeviceOrientationLandscapeLeft){
//                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
//            }
//            [self.brightnessView removeFromSuperview];
//            [self addSubview:self.brightnessView];
//            [self.brightnessView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.center.mas_equalTo(self);
//                make.width.height.mas_equalTo(155);
//            }];
//            
//        }
//    }
}

#pragma mark - Action

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)singleTapAction:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[NSNumber class]] && ![(id)gesture boolValue]) {
        [self _fullScreenAction];
        return;
    }
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBottomVideo && !self.isFullScreen) { [self _fullScreenAction]; }
        else {
            if (self.playDidEnd) { return; }
            else {
                [self.controlView playerShowOrHideControlView];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isAutoPlay) {
        UITouch *touch = [touches anyObject];
        if(touch.tapCount == 1) {
            [self performSelector:@selector(singleTapAction:) withObject:@(NO) ];
        } else if (touch.tapCount == 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction:) object:nil];
            [self doubleTapAction:touch.gestureRecognizers.lastObject];
        }
    }
}
/**
 *  双击播放/暂停
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    if (self.playDidEnd) { return;  }
    // 显示控制层
    [self.controlView playerShowControlView];
    if (self.isPauseByUser) { [self play]; }
    else { [self pause]; }
    if (!self.isAutoPlay) {
        self.isAutoPlay = YES;
        [self configPlayer];
    }
}

/** 全屏 */
- (void)_fullScreenAction {
    if ([KBrightnessView sharedBrightnessView].isLockScreen) {
        //解锁屏幕
        [self unLockTheScreen];
        return;
    }
    if (self.isFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        self.isFullScreen = NO;
        return;
    } else {
        //获取当前设备的方向
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            //左边
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            //设备右边
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        self.isFullScreen = YES;
    }
}
#pragma mark 设置controlView的代理
- (void)setControlView:(UIView *)controlView {
    if (_controlView) { return; }
    _controlView = controlView;
    controlView.delegate = self;
    [self addSubview:controlView];
    [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}



- (void)dealloc {
    self.playerItem = nil;
    self.scrollView  = nil;
    [KBrightnessView sharedBrightnessView].isLockScreen = NO;
    [self.controlView playerCancelAutoFadeOutControlView];
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    // 移除time观察者
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

#pragma mark - PlayerControlViewDelegate


- (void)controlView:(UIView *)controlView playAction:(UIButton *)sender {
    self.isPauseByUser = !self.isPauseByUser;
    if (self.isPauseByUser) {
        [self pause];
        if (self.state == KPlayerStatePlaying) { self.state = KPlayerStatePause;}
    } else {
        [self play];
        if (self.state == KPlayerStatePause) { self.state = KPlayerStatePlaying; }
    }
    
    if (!self.isAutoPlay) {
        self.isAutoPlay = YES;
        [self configPlayer];
    }
}


- (void)controlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    if ([self.delegate respondsToSelector:@selector(playerControlViewWillShow:isFullscreen:)]) {
        [self.delegate playerControlViewWillShow:controlView isFullscreen:fullscreen];
    }
}

- (void)controlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen {
    if ([self.delegate respondsToSelector:@selector(playerControlViewWillHidden:isFullscreen:)]) {
        [self.delegate playerControlViewWillHidden:controlView isFullscreen:fullscreen];
    }
}
//滑杆拖动调用
- (void)controlView:(UIView *)controlView progressSliderValueChanged:(UISlider *)slider
{
    //如果视频已经缓冲好
    if (self.player.currentItem.status == AVPlayerStatusReadyToPlay)
    {
        self.isDragged = YES;
        BOOL style = false;
        CGFloat value = slider.value - self.sliderLastValue;
        if (value >0) {style = YES;} //是快进
        if (value <0) {style = NO;} //是快退
        if (value == 0) {return ;} //没有拖动
        self.sliderLastValue = slider.value;
        CGFloat totalTime = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;//获取总时长
        //计算出拖动的当前秒数
        CGFloat dragedSeconds = floorf(totalTime * slider.value);
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
        //更改conrtolViewUI
        [controlView playerDraggedTime:dragedSeconds totalTime:totalTime isForward:style hasPreview:self.isFullScreen ? self.hasPreviewView : NO];
        if (totalTime > 0)
        { // 当总时长 > 0时候才能拖动slider
            if (self.isFullScreen && self.hasPreviewView)
            {  //如果是全屏并且是开启预览图
                [self.imageGenerator cancelAllCGImageGeneration]; //取消视频所有关键帧图片
                self.imageGenerator.appliesPreferredTrackTransform = YES;
                self.imageGenerator.maximumSize = CGSizeMake(100, 56);
                [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) { //生成图片时候调用
                    if (result != AVAssetImageGeneratorSucceeded)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [controlView playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : [UIImage imageNamed:@"Player_loading_bgView"]];
                        });
                    } else
                    {
                        self.thumbImg = [UIImage imageWithCGImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [controlView playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : [UIImage imageNamed:@"Player_loading_bgView"]];
                        });
                    }

                }];
                
            }
        }else
        {
            // 此时设置slider值为0
            slider.value = 0;
        }
    }else
    {
        // player状态加载失败
        // 此时设置slider值为0
        slider.value = 0;
    }
    
}

- (void)controlView:(UIView *)controlView progressSliderTouchEnded:(UISlider *)slider
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {//视频状态是能正常播放的
        //设备不是用户点击了暂停按钮
        self.isPauseByUser = NO;
        self.isDragged = NO;
        // 视频总时间长度
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
         // 从xx秒开始播放视频跳转
        [self seekToTime:dragedSeconds completionHandler:nil];
    }
}
/** 重播按钮事件 */
- (void)controlView:(UIView *)controlView repeatPlayAction:(UIButton *)sender
{
    // 没有播放完
    self.playDidEnd   = NO;
    // 重播改为NO
    self.repeatToPlay = NO;
    [self seekToTime:0 completionHandler:nil];
    
    if ([self.videoURL.scheme isEqualToString:@"file"]) {
        self.state = KPlayerStatePlaying;
    } else {
        //视屏没有缓存本地
        self.state = KPlayerStateBuffering;
    }
}
/** 全屏按钮事件 */
- (void)controlView:(UIView *)controlView fullScreenAction:(UIButton *)sender
{
    //全屏动作
    [self _fullScreenAction];

}
@end
