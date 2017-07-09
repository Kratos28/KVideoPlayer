//
//  KPlayerControlView.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/4.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPlayerControlView : UIView
- (void)playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
@end
