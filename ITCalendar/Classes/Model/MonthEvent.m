//
//  MonthEvent.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "MonthEvent.h"
#import <TapkuLibrary/TapkuLibrary.h>
#import "DayEvent.h"

@interface MonthEvent ()
{
 @private
    NSMutableDictionary *_dayEventsDict;
}
- (id)initWithMonthDate:(NSDate *)monthDate
           dayEventsDict:(NSMutableDictionary *)dayEventsDict;
@end

@implementation MonthEvent

@synthesize monthDate = _monthDate;
@synthesize dayEventsDict = _dayEventsDict;

#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------

- (id)initWithMonthDate:(NSDate *)monthDate
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _monthDate = monthDate;
    _dayEventsDict = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ NSCopying
#pragma mark ------------------------------------------
- (id)initWithMonthDate:(NSDate *)monthDate
          dayEventsDict:(NSMutableDictionary *)dayEventsDict
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _monthDate = [monthDate copy];
    _dayEventsDict = [dayEventsDict mutableCopy];
    return  self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MonthEvent *clone = [[[self class] allocWithZone:zone]
                         initWithMonthDate:_monthDate dayEventsDict:_dayEventsDict];
    return clone;
}

#pragma mark ------------------------------------------
#pragma mark ------ public method
#pragma mark ------------------------------------------
// DayEventの取得
// 存在しなければ作成する
- (DayEvent *)dayEventAtDate:(NSDate *)aDate
{
    return [self dayEventAtDateString:[aDate ITFormatStringOfDate]];
}
- (DayEvent *)dayEventAtDateString:(NSString *)aDateString
{
    DayEvent *dayEvent = [_dayEventsDict objectForKey:aDateString];
    if (!dayEvent) {
        dayEvent = [[DayEvent alloc] initWithDateString:aDateString];
        [_dayEventsDict setValue:dayEvent forKey:aDateString];
    }
    return dayEvent;
}

// DatEventの設定
- (void)setDayEvent:(DayEvent *)dayEvent
{
    [_dayEventsDict setValue:dayEvent forKey:dayEvent.dateString];
}

@end


#pragma mark -

@implementation MonthEvent (Utility)

// 検索ワードでフィルターしたMonthEventを取得
- (MonthEvent *)monthEventWithSearchWords:(NSArray *)words
{
    MonthEvent *newMonthEvent = [self copy];
    NSMutableDictionary *newDayEventsDict = [[NSMutableDictionary alloc] init];
    NSArray *allObjects = [_dayEventsDict allValues];
    
    // すべての日イベント
    for (DayEvent *dayEvent in allObjects) {
        DayEvent *newDayEvent = [dayEvent dayEventWithSearchWords:words];
        // イベントが１件もなければ除外する
        if (0 == [newDayEvent.events count]) {
            continue;
        }
        [newDayEventsDict setValue:newDayEvent forKey:newDayEvent.dateString];
    }
    
    newMonthEvent.dayEventsDict = newDayEventsDict;
    return newMonthEvent;
}


// 検索ワードを指定したDayEventの取得
- (DayEvent *)dayEventAtDate:(NSDate *)aDate withSearchWords:(NSArray *)words
{
    DayEvent *dayEvent = [self dayEventAtDate:aDate];
    // 検索ワードでフィルターする
    return [dayEvent dayEventWithSearchWords:words];
}

// 対象月が今月か判定する
// @return YES: 今月 NO: 今月以外
- (BOOL)isThisMonth
{
    NSDate *thisMonth = [NSDate localThisMonth];
    return [_monthDate isSameDay:thisMonth];
}


@end
