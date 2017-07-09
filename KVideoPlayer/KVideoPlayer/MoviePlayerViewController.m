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
@interface MoviePlayerViewController ()
@property (strong, nonatomic) KVideoPlayerView *playerView;
@property (nonatomic, strong) KPlayerModel *playerModel;
@property (nonatomic, strong) UIView *playerFatherView;
@end

@implementation MoviePlayerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.playerFatherView = [[UIView alloc] init];
    [self.view addSubview:self.playerFatherView];
    [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.leading.trailing.mas_equalTo(0);
        // 这里宽高比16：9,可自定义宽高比
        make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
    }];
    
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI
{
    [self.playerView autoPlayTheVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (KPlayerModel *)playerModel {
    if (!_playerModel) {
        _playerModel                  = [[KPlayerModel alloc] init];
        _playerModel.title            = @"这里设置视频标题";
        _playerModel.videoURL         =  [NSURL URLWithString:@"http://baobab.wdjcdn.com/1456665467509qingshu.mp4"];
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
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [_playerView playerControlView:nil playerModel:self.playerModel];
        
        // 设置代理
//        _playerView.delegate = self;
        
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResize;
        
        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = YES;
        
        // 打开预览图
        self.playerView.hasPreviewView = YES;
        
    }
    return _playerView;
}
@end
