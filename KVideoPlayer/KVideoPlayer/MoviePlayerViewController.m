//
//  MoviePlayerViewController.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/6.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import "KVideoPlayerView.h"
#import "KPlayerModel.h"
#import "Masonry.h"
#import "UINavigationController+ZFFullscreenPopGesture.h"
#import "UIViewController+PlayerRotation.h"
#import "KAdPlayerView.h"
#import "KAdPlayerView.h"
#import "KVideoAdConfiguration.h"

@interface MoviePlayerViewController () <KPlayerDelegate>
@property (strong, nonatomic) KVideoPlayerView *playerView;
@property (nonatomic, strong) KPlayerModel *playerModel;
@property (weak, nonatomic) IBOutlet UIView *playerFatherView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation MoviePlayerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.zf_prefersNavigationBarHidden = YES;

    
//    self.playerFatherView = [[UIView alloc] init];
//    [self.view addSubview:self.playerFatherView];
//    [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(20);
//        make.leading.trailing.mas_equalTo(0);
//        // 这里宽高比16：9,可自定义宽高比
//        make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
//    }];
    
    
    UIView *view1 = [[UIView alloc]init];
    [self.view addSubview: view1];
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(250);
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(view1.mas_width).multipliedBy(9.0f/16.0);
        
    }];
    
    
    KVideoAdConfiguration *videoAdconfiguration = [KVideoAdConfiguration new];
    //广告停留时间
    videoAdconfiguration.duration = 15;
    
    //广告视频URLString/或本地视频名(请带上后缀)
    //注意:视频广告只支持先缓存,下次显示
    videoAdconfiguration.videoNameOrURLString = @"http://ohnzw6ag6.bkt.clouddn.com/video0.mp4";
    //视频缩放模式
    //广告点击打开链接
    videoAdconfiguration.openURLString = @"http://www.baidu.com";
    //广告显示完成动画
    videoAdconfiguration.showFinishAnimate = KShowFinishAnimateFadein;
    //广告显示完成动画时间
    videoAdconfiguration.showFinishAnimateTime = 0.8;
    
    //跳过按钮类型
    videoAdconfiguration.skipButtonType = SkipTypeTimeText;
    
    
    [KAdPlayerView sharedPlayerViewWithFatherView:view1 videoAdConfiguaration:videoAdconfiguration delegate:nil];

    

    
    [self setupUI];
    
    
  
    
    // Do any additional setup after loading the view.
}
- (void)playerBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}
// 返回值要必须为NO
- (BOOL)shouldAutorotate {
    return NO;
}
- (void)setupUI
{
    [self.playerView autoPlayTheVideo];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // pop回来时候是否自动播放
    if (self.navigationController.viewControllers.count == 2 && self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        self.playerView.playerPushedOrPresented = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // push出下一级页面时候暂停
    if (self.navigationController.viewControllers.count == 3 && self.playerView && !self.playerView.isPauseByUser)
    {
        self.isPlaying = YES;
        self.playerView.playerPushedOrPresented = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (KPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[KPlayerModel alloc] init];
        _playerModel.title            = @"这里设置视频标题";
        //http://gg.3gtv.net/media/172.18.222.45,20101,361/320x180.m3u8
        _playerModel.videoURL         =  self.videoURL;
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        _playerModel.fatherView       = self.playerFatherView;
        //        _playerModel.resolutionDic = @{@"高清" : self.videoURL.absoluteString,
        //                                       @"标清" : self.videoURL.absoluteString};
    }
    return _playerModel;
}


- (KVideoPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[KVideoPlayerView alloc] init];
        
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // KPlayerControlView *controlView = [[KPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用KPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
        _playerView.delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（KPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = KPlayerLayerGravityResize;
        
        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = YES;
        
        // 打开预览图
        self.playerView.hasPreviewView = YES;
        
    }
    return _playerView;
}
@end
