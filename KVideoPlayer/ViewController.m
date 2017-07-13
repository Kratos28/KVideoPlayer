//
//  ViewController.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    


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
