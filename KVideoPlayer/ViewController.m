//
//  ViewController.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayerViewController.h"
#import "KVideoPlayerView.h"
#import "KAdPlayerView.h"
#import "Masonry.h"
#import "KVideoAdConfiguration.h"

@interface ViewController () <KPlayerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1458625865688ONE.mp4"];
    
    
//    UIView *view1 = [[UIView alloc]init];
//    [self.view addSubview: view1];
//    
//    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(250);
//        make.leading.trailing.mas_equalTo(0);
//        make.height.mas_equalTo(view1.mas_width).multipliedBy(9.0f/16.0);
//        
//    }];
//    
//    
//    KVideoAdConfiguration *videoAdconfiguration = [KVideoAdConfiguration new];
//    //广告停留时间
//    videoAdconfiguration.duration = 15;
//    
//    //广告视频URLString/或本地视频名(请带上后缀)
//    //注意:视频广告只支持先缓存,下次显示
//    videoAdconfiguration.videoNameOrURLString = @"http://ohnzw6ag6.bkt.clouddn.com/video0.mp4";
//    //视频缩放模式
//    //广告点击打开链接
//    videoAdconfiguration.openURLString = @"http://www.baidu.com";
//    //广告显示完成动画
//    videoAdconfiguration.showFinishAnimate = KShowFinishAnimateFadein;
//    //广告显示完成动画时间
//    videoAdconfiguration.showFinishAnimateTime = 0.8;
//    
//    //跳过按钮类型
//    videoAdconfiguration.skipButtonType = SkipTypeTimeText;
//    
//    
//    [KAdPlayerView sharedPlayerViewWithFatherView:view1 videoAdConfiguaration:videoAdconfiguration delegate:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MoviePlayerViewController *movie = (MoviePlayerViewController *)segue.destinationViewController;
    movie.videoURL                   = [NSURL URLWithString: @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
