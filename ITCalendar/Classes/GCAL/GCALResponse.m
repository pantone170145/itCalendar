//
//  GCALResponse.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/20.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "GCALResponse.h"

// dictionary key
const NSString *kGCALResult = @"result";

const NSString *kGCALTitle = @"title";          // タイトル
const NSString *kGCALDetail = @"entryLink";     // 詳細
const NSString *kGCALPlace = @"location";       // 場所
const NSString *kGCALDescription = @"content";  // 説明
const NSString *kGCALStartDate = @"startDate";   // 開始日時
const NSString *kGCALStartTime = @"startTime";   // 開始時間
const NSString *kGCALStartWeek = @"startWeek";   // 開始曜日
const NSString *kGCALEndDate = @"endDate";       // 終了日時
const NSString *kGCALEndTime = @"endTime";       // 終了時間
const NSString *kGCALEndWeek = @"endWeek";       // 終了曜日


@implementation GCALResponse

@synthesize requestMonth = _requestMonth;
@synthesize entries = _entries;

- (id)initWithGCALJson:(NSDictionary *)jsonValue
{
    self = [super init];
    if (!self) {
        return nil;
    }
    NSArray *jsonArray = [jsonValue objectForKey:kGCALResult];
    NSMutableArray *values = [NSMutableArray array];
    for (NSDictionary *entry in jsonArray) {
        [values addObject:entry];
    }
    _entries = values;
    return self;
}
@end

@implementation GCALEntry
@synthesize title = _title;
@synthesize detail = _detail;
@synthesize place = _place;
@synthesize description = _description;
@synthesize startDate = _startDate;
@synthesize startTime = _startTime;
@synthesize startWeek = _startWeek;
@synthesize endDate = _endDate;
@synthesize endTime = _endTime;
@synthesize endWeek = _endWeek;

- (id)initWithEntry:(NSDictionary *)entry;
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _title = [entry objectForKey:kGCALTitle];
    _detail = [entry objectForKey:kGCALDetail];
    _place = [entry objectForKey:kGCALPlace];
    _description = [entry objectForKey:kGCALDescription];
    _startDate = [entry objectForKey:kGCALStartDate];
    _startTime = [entry objectForKey:kGCALStartTime];
    _startWeek = [entry objectForKey:kGCALStartWeek];
    _endDate = [entry objectForKey:kGCALEndDate];
    _endTime = [entry objectForKey:kGCALEndTime];
    _endWeek = [entry objectForKey:kGCALEndWeek];
    return self;
}
@end