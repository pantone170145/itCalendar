//
//  NSDate+locale.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/21.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "NSDate+locale.h"
#import "TapkuLibrary/TapkuLibrary.h"

@implementation NSDate (locale)

+ (NSDate *)localeToday
{
   return [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
}

+ (NSDate *)localThisMonth
{
    return [[self localeToday] firstOfMonth];
}
@end
