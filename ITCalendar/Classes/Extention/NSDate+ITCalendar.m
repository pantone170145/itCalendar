//
//  NSDate+ITCalendar.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "NSDate+ITCalendar.h"

@implementation NSDate (ITCalendar)

- (NSLocale *)sharedLocale_ja
{
    static NSLocale *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    });
    return sharedInstance;
}

- (NSString*)ITFormatStringOfDate
{
    // 日本時間でフォーマット指定する
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[self sharedLocale_ja]];
    });
    return [formatter stringFromDate:self];
}

- (NSString*)ITFormatStringOfMonth
{
    // 日本時間でフォーマット指定する
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM"];
        [formatter setLocale:[self sharedLocale_ja]];
    });
    return [formatter stringFromDate:self];
}
@end
