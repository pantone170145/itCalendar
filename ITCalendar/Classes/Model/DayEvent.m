//
//  DayEvent.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "DayEvent.h"
#import "Event.h"

@interface DayEvent ()

- (id)initWithDate:(NSDate *)date
        dateString:(NSString *)dateString
            events:(NSArray *)events;

@end
@implementation DayEvent

@synthesize date = _date;
@synthesize dateString = _dateString;
@synthesize events = _events;

#pragma mark ------------------------------------------
#pragma mark ------ init/dealloc
#pragma mark ------------------------------------------

- (id)_init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _events = [[NSArray alloc] init];
    return self;
}

// |date|で初期化
- (id)initWithDate:(NSDate*)date
{
    if (![self _init]) {
        return nil;
    }
    [self setDate:date];
    return self;
}

// yyyy-MM-dd形式の文字列で初期化する
- (id)initWithDateString:(NSString *)dateString
{
    if (![self _init]) {
        return nil;
    }
    [self setDateString:dateString];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ NSCopying
#pragma mark ------------------------------------------
- (id)initWithDate:(NSDate *)date
        dateString:(NSString *)dateString
            events:(NSArray *)events
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _date = [date copy];
    _dateString = [dateString copy];
    _events = [events copy];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    DayEvent *clone = [[[self class] allocWithZone:zone]
                       initWithDate:_date dateString:_dateString events:_events];
    return clone;
}


#pragma mark ------------------------------------------
#pragma mark ------ accessor
#pragma mark ------------------------------------------

// |date|をプロパティに設定する
// 同時に日付文字列を作成する
- (void)setDate:(NSDate *)date
{
    if (date != _date) {
        _date = date;
        _dateString = [date ITFormatStringOfDate];
    }
}
- (void)setDateString:(NSString *)dateString
{
    if (![dateString isEqualToString:_dateString]) {
        
        // - で分割
        NSArray *tokens = [dateString componentsSeparatedByString:@"-"];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
        // 設定
        [comp setYear:[[tokens objectAtIndex:0] intValue]];
        [comp setMonth:[[tokens objectAtIndex:1] intValue]];
        [comp setDay:[[tokens objectAtIndex:2] intValue]];
        
        NSDate *date = [gregorian dateFromComponents:comp];
        _date = date;
        _dateString = dateString;        
    }
}

@end


#pragma mark -
@implementation DayEvent (Utility)

// 検索ワードでフィルターしたDayEventを取得
- (DayEvent *)dayEventWithSearchWords:(NSArray *)words
{
    DayEvent *newDayEvent = [self copy];
    NSMutableArray *newEvents = [NSMutableArray array];
    
    // イベント
    for (Event *event  in _events) {
        
        BOOL isMatch = YES;
        // 検索ワード
        for (NSString *word in words) {
            // 検索ワードに一致するかどうか
            // 大文字小文字を区別しない  NSCaseInsensitiveSearch
            // 全角半角を区別しない NSWidthInsensitiveSearch
            NSRange searchResult = [event.title rangeOfString:word];
            if (NSNotFound == searchResult.location) {
                // 一致しない
                isMatch = NO;
                break;
            }    
        }
        
        // 一致する
        if (isMatch) {
            [newEvents addObject:event];
        }
    }
    newDayEvent.events = newEvents;
    return newDayEvent;
}

@end


