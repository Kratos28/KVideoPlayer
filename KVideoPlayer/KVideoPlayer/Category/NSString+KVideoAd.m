//
//  NSString+KVideoAd.m
//  KVideoPlayer
//
//  Created by Kratos on 2017/7/15.
//  Copyright © 2017年 Kratos. All rights reserved.
//

#import "NSString+KVideoAd.h"
#import  <CommonCrypto/CommonDigest.h>
@implementation NSString (KVideoAd)
- (BOOL)k_isURLString
{
    if ([self hasPrefix:@"https://"] || [self hasPrefix:@"http://"]) return YES;
    return NO;
}

- (NSString *)k_videoName
{
    return [self.k_md5String stringByAppendingString:@".mp4"];
}

- (NSString *)k_md5String
{
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc]initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count ++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
-(BOOL)k_containsSubString:(nonnull NSString *)subString
{
    if(subString==nil) return NO;
    if([self rangeOfString:subString].location ==NSNotFound) return NO;
    return YES;
}
@end
