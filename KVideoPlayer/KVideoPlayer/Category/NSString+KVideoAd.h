//
//  NSString+KVideoAd.h
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KVideoAd)

@property(nonatomic,assign,readonly)BOOL k_isURLString;

@property(nonatomic,copy,readonly,nonnull)NSString *k_videoName;

@property(nonatomic,copy,readonly,nonnull)NSString *k_md5String;

-(BOOL)k_containsSubString:(nonnull NSString *)subString;

@end
