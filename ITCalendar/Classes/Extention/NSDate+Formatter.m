//
//  NSDate+Formatter.m
//  Navigation
//
//  Created 12/05/30.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

- (NSString*)formatStringWithStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:style];
    return [formatter stringFromDate:self];
}

- (NSString*)formatStringWithFormat:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSString*)formatStringWithFormat:(NSString*)format
                             locale:(NSLocale*)locale
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

@end


