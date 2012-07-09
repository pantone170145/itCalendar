//
//  DayEvent.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCALEntry;

// 一日のイベント
@interface DayEvent : NSObject
<NSCopying>

#pragma mark property

@property (nonatomic, strong) NSDate *date;             // 日付
@property (nonatomic, strong) NSString *dateString;     // 日付文字列
@property (nonatomic, strong) NSArray *events;          // イベント配列

#pragma mark method

/**
 @brief 日付で初期化する
 @param date: 対象の|NSDate|object
 @return instance
 */
- (id)initWithDate:(NSDate *)date;

/**
 @brief yyyy-MM-dd形式の文字列で初期化する
 @param dateString: yyyy-MM-dd形式の文字列
 @return instance
 */
- (id)initWithDateString:(NSString *)dateString;

@end



#pragma mark -

@interface DayEvent (Utility)

/**
 @brief 検索ワードでフィルターしたDayEventを取得
 @param
 @return
 */
- (DayEvent *)dayEventWithSearchWords:(NSArray *)words;


@end
