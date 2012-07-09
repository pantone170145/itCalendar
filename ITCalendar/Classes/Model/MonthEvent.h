//
//  MonthEvent.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DayEvent;

// 特定の月のイベントクラス
@interface MonthEvent : NSObject
<NSCopying>

#pragma mark property

@property (nonatomic, readonly) NSDate *monthDate;

// 日付をキーとした1日ごとのイベント辞書
// key: yyyy-MM-dd value: DayEvent配列
@property (nonatomic, strong) NSDictionary *dayEventsDict;

#pragma mark -
#pragma mark method

/**
 @brief 月で初期化する
 @param monthDate: 月の日付
 @return instance
 */
- (id)initWithMonthDate:(NSDate *)monthDate;

/**
 @brief 日付を指定して１日のイベントを取得する
 @param aDate: 対象の|NSDate| object
 @return 取得した１日のイベント
 */
- (DayEvent *)dayEventAtDate:(NSDate *)aDate;

/**
 @brief 日付文字列を指定して１日のイベントを取得する
 @param aDateString: yyyy-MM-dd形式の文字列
 @return 取得した１日のイベント
 */
- (DayEvent *)dayEventAtDateString:(NSString *)aDateString;


/**
 @brief １日のイベントを設定する
 @param dayEvent: 設定する|DayEvent|object
 @return 
 */
// DatEventの設定
- (void)setDayEvent:(DayEvent *)dayEvent;

@end


#pragma mark -

@interface MonthEvent (Utility)

/**
 @brief 検索ワードでフィルターしたMonthEventを取得
 @param words: 検索対象の|NSString|配列
 @return 取得した|MonthEvent|object
 */
- (MonthEvent *)monthEventWithSearchWords:(NSArray *)words;

/**
 @brief 検索ワードを指定したDayEventの取得
 @param aDate: 対象の|NSDate|object
 @param words: 検索対象の|NSString|配列
 @return 取得した|DayEvent|object
 */
- (DayEvent *)dayEventAtDate:(NSDate *)aDate withSearchWords:(NSArray *)words;


/**
 @brief 対象月が今月か判定する
 @param
 @return YES: 今月 NO: 今月以外
 */
- (BOOL)isThisMonth;

@end