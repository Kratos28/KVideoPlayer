//
//  KAdButton.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SkipType) {
    
    SkipTypeNone      = 1,//无
    SkipTypeTime      = 2,//倒计时
    SkipTypeText      = 3,//跳过
    SkipTypeTimeText  = 4,//倒计时+跳过
    
};


@interface KAdButton : UIButton

@property(nonatomic,strong)UILabel *timeLab;
//设置左右间距
@property(nonatomic,assign)CGFloat leftRightSpace;
//设置上下间距
@property(nonatomic,assign)CGFloat topBottomSpace;


-(void)stateWithskipType:(SkipType)skipType andDuration:(NSInteger)duration;

@end
