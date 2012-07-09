//
//  GCALResponse.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/20.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kGCALTitle;
extern NSString *kGCALDetail;
extern NSString *kGCALDate;
extern NSString *kGCALPlace;
extern NSString *kGCALDescription;

// google calendar レスポンス
@interface GCALResponse : NSObject

@property (nonatomic, strong) NSDate *requestMonth;    // リクエスト月
@property (nonatomic, strong) NSArray *entries;     // エントリ配列

// 初期化
- (id)initWithGCALJson:(NSDictionary *)jsonValue;
@end


// エントリ
@interface GCALEntry : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *place;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *startWeek;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *endWeek;


- (id)initWithEntry:(NSDictionary *)entry;
@end