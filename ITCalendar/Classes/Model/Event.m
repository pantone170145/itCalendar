//
//  Event.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "Event.h"
#import "GCALResponse.h"

@interface Time ()

- (id)initWithYear:(NSString *)year
             month:(NSString *)month
               day:(NSString *)day
              week:(NSString *)week
             hours:(NSString *)hours;
@end

@implementation Time

@synthesize year = _year;
@synthesize month = _month;
@synthesize day = _day;
@synthesize week = _week;
@synthesize hours = _hours;

- (id)initWithYear:(NSString *)year
             month:(NSString *)month
               day:(NSString *)day
              week:(NSString *)week
             hours:(NSString *)hours;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _year = [year copy];
    _month = [month copy];
    _day = [day copy];
    _week = [week copy];
    _hours = [hours copy];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Time *clone = [[[self class] allocWithZone:zone]
                   initWithYear:_year 
                   month:_month
                   day:_day
                   week:_week
                   hours:_hours];
    return clone;
}

- (NSDate *)date
{
    static NSCalendar *calendar;
    static NSUInteger flags;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
        flags
        = NSEraCalendarUnit
        | NSYearCalendarUnit
        | NSMonthCalendarUnit
        | NSDayCalendarUnit
        | NSHourCalendarUnit
        | NSMinuteCalendarUnit
        | NSSecondCalendarUnit
        | NSWeekCalendarUnit
        | NSWeekdayCalendarUnit
        | NSWeekdayOrdinalCalendarUnit;
    });
    
    // コンポーネント取得
    NSDateComponents *comps = [calendar components:flags
                                          fromDate:[NSDate date]];
    // コンポーネント設定
    comps.year = [_year integerValue];
    comps.month = [_month integerValue];
    comps.day = [_day integerValue];
    
    NSArray *tokens = [_hours componentsSeparatedByString:@":"];
    comps.hour = [[tokens objectAtIndex:0] integerValue];
    comps.minute = [[tokens objectAtIndex:1] integerValue];
    
    NSDate *date = [calendar dateFromComponents:comps];
    return date;
}

@end

@interface Event ()

- (id)initWithTitle:(NSString *)title
          startTime:(Time *)startTime
            endTime:(Time *)endTime
              place:(NSString *)place
     descriptionUrl:(NSString *)descriptionUrl
          detailUrl:(NSString *)detailUrl;

@end

@implementation Event

@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize place = _place;
@synthesize descriptionUrl = _descriptionUrl;
@synthesize detailUrl = _detailUrl;

#pragma mark ------------------------------------------
#pragma mark ------ init/dealloc
#pragma mark ------------------------------------------

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

// GCALEntry --> Event
- (id)initWithGCALEntry:(GCALEntry *)entry
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    {
        NSArray *tokens = [entry.startDate componentsSeparatedByString:@"-"];
        NSString *year = [tokens objectAtIndex:0];
        NSString *month = ([tokens count] > 1) ? [tokens objectAtIndex:1] : nil;
        NSString *day = ([tokens count] > 2) ? [tokens objectAtIndex:2] : nil;
        _startTime = [[Time alloc] initWithYear:year month:month day:day week:entry.startWeek hours:entry.startTime];
    }
    {
        NSArray *tokens = [entry.endDate componentsSeparatedByString:@"-"];
        NSString *year = [tokens objectAtIndex:0];
        NSString *month = ([tokens count] > 1) ? [tokens objectAtIndex:1] : nil;
        NSString *day = ([tokens count] > 2) ? [tokens objectAtIndex:2] : nil;
        _endTime = [[Time alloc] initWithYear:year month:month day:day week:entry.endWeek hours:entry.endTime];
    }
 
    _title = entry.title;
    _place = entry.place;
    _descriptionUrl = entry.description;
    _detailUrl = entry.detail;
    
    // 識別子を作成する
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    _identifier = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return self;
}

- (BOOL)compareEvent:(Event *)event
{
    return (NSOrderedSame == [event.identifier compare:_identifier]);
}

#pragma mark ------------------------------------------
#pragma mark ------ NSCopying
#pragma mark ------------------------------------------

- (id)initWithTitle:(NSString *)title
          startTime:(Time *)startTime
            endTime:(Time *)endTime
              place:(NSString *)place
     descriptionUrl:(NSString *)descriptionUrl
          detailUrl:(NSString *)detailUrl;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _title = [title copy];
    _startTime = [startTime copy];
    _endTime = [endTime copy];
    _place = [place copy];
    _descriptionUrl = [descriptionUrl copy];
    _detailUrl = [detailUrl copy];
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Event *clone = [[[self class] allocWithZone:zone]
                    initWithTitle:_title
                    startTime:_startTime
                    endTime:_endTime
                    place:_place
                    descriptionUrl:_descriptionUrl
                    detailUrl:_detailUrl];
    return clone;
}
@end



