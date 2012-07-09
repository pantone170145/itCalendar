//
//  EventManager.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "DayEvent.h"
#import "MonthEvent.h"

#define kCurrentMonthEvent @"currentMonthEvent"

@class GCALResponse;

// Eventモデル管理クラス
@interface EventManager : NSObject

#pragma mark property

// 選択中の月イベント
@property (nonatomic, strong) MonthEvent *currentMonthEvent;

// 検索されているかどうかのフラグ
@property (nonatomic) BOOL hasSearch;
// 検索ワード
@property (nonatomic, strong) NSArray *searchWords; 


#pragma mark method

/**
 @brief シングルトン取得
 @param 
 @return 
 */
+ (EventManager*)sharedManager;

/**
 @brief 月を指定して、月イベント取得
 @param monthDate: 対象月
 @return 取得した月イベント
 */
- (MonthEvent *)monthEventAtMonth:(NSDate *)monthDate;

/**
 @brief 日を指定して、イベントを取得
 @param date: 対象の日
 @return 取得した対象の日の|Event|配列
 */
- (NSArray *)eventsAtDate:(NSDate *)date;

/**
 @brief |startDate|から|lastDate|のイベント有無Array取得
        MonthCalendarViewのイベント有無表示に使用する
 @param fromDate: 開始日
 @param toDate: 終了日
 @return イベントあり:1 イベントなし:0 -->の配列
 */
- (NSArray *)marksArrayFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 @brief 取得したgoogle calendar データをモデルクラスへ保存する
 @param gcalResponse: GCALレスポンスデータ
 @return
 */
- (void)saveMonthEvent:(GCALResponse *)gcalResponse;

/**
 @brief イベントを検索する
        検索結果で|currentMonthEvent|を更新する
 @param word: 検索ワード
 @return 
 */
- (void)searchEventForWord:(NSString *)word;

/**
 @brief 選択月の変更
 @param atMonthDate: 変更後のNSDate
 @param flag: 通知の有無 YES: 通知あり NO: 通知なし
 */
- (void)changeCurrentMonth:(NSDate *)atMonthDate withNotification:(BOOL)flag;

@end