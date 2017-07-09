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
- (IBAction)play:(id)sender {
    MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
    movie.videoURL  = [NSURL URLWithString: @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4"];
    [self.navigationController pushViewController:movie animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
