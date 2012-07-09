//
//  EventManager.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <TapkuLibrary/TapkuLibrary.h>
#import "EventManager.h"
#import "OperationManager.h"

#import "GCALResponse.h"

@interface EventManager ()
{
 @private
    dispatch_queue_t _syncQueue;
    
    // 月をキーとした月ごとのイベント辞書
    // key: yyyy-MM value: MonthEvent
    NSMutableDictionary *_monthEventDict;
}

// |monthEvent|を登録する
- (void)setMonthEvent:(MonthEvent *)monthEvent;

// 検索ワードを設定する
- (void)setSearchWord:(NSString *)searchWord;

@end

@implementation EventManager

@synthesize currentMonthEvent = _currentMonthEvent;
@synthesize hasSearch = _hasSearch;
@synthesize searchWords = _searchWords;

#pragma mark ------------------------------------------
#pragma mark ------ init/dealloc
#pragma mark ------------------------------------------

// singleton object
+ (EventManager*)sharedManager
{
    static EventManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EventManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    // シリアルディスパッチキュー作成
    _syncQueue = dispatch_queue_create("jp.itcalendar.gcd.serialDispatchQueue", NULL);
    // 月イベントdictionary
    _monthEventDict = [[NSMutableDictionary alloc] init];
    // 検索ワード
    _searchWords = [NSArray array];
    
 
//    [self loadTestData];
    return self;
}

- (void)dealloc
{
    dispatch_release(_syncQueue);
}

// テストデータ読み込み
- (void)loadTestData
{
    NSDate* today = [[NSDate date] nextDate];
    
    Event* event1 = [[Event alloc] init];
    event1.title = @"[愛知]テストイベント1あああああああああああああああああああああああああいいいいい";
//    event1.startTime = @"9:00";
//    event1.dateAndTime = @"6/15(金), 9:00〜12:00";
    event1.place = @"愛知県名古屋市名東区藤が丘244サンロイヤル富が丘";
//    event1.placeUrl = @"http://www.yahoo.co.jp";
    event1.descriptionUrl = @"http://www.google.co.jp";
    event1.detailUrl = @"http://www.gmail.co.jp";
    
    Event* event2 = [[Event alloc] init];
    event2.title = @"[愛知]テストイベント2";
//    event2.startTime = @"11:00";
//    event2.dateAndTime = @"6/15(金), 22:00〜24:00";
    event2.place = @"愛知県名古屋市名東区藤が丘244サンロイヤル富が丘";
//    event2.placeUrl = @"http://www.yahoo.co.jp";
    event2.descriptionUrl = @"http://www.google.co.jp";
    event2.detailUrl = @"http://www.gmail.co.jp";
    
    
    // 一日のイベントとして登録
    NSMutableArray *ma = [NSMutableArray array];
    DayEvent* itEventsOfDay = [[DayEvent alloc] initWithDate:today];
    [ma addObject:event1];
    [ma addObject:event2];    
    itEventsOfDay.events = ma;
    
    DayEvent* itEventsOfDay2 = [[DayEvent alloc] initWithDate:[today nextDate]];
    NSMutableArray *ma2 = [NSMutableArray array];
    [ma2 addObject:event2];
    [ma2 addObject:event1];    
    itEventsOfDay2.events = ma2;

    
    // 1ヶ月のイベント作成
    MonthEvent* itEventsOfMonth = [[MonthEvent alloc] initWithMonthDate:[[NSDate date] monthDate]];
    [itEventsOfMonth.dayEventsDict setValue:itEventsOfDay forKey:itEventsOfDay.dateString];
    [itEventsOfMonth.dayEventsDict setValue:itEventsOfDay2 forKey:itEventsOfDay2.dateString];
    
    // 登録
    [_monthEventDict setValue:itEventsOfMonth forKey:[itEventsOfMonth.monthDate ITFormatStringOfMonth]];
}


#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------
- (void)setMonthEvent:(MonthEvent *)monthEvent
{
    [_monthEventDict setValue:monthEvent forKey:[monthEvent.monthDate ITFormatStringOfMonth] ];
}

// 検索ワードを指定する
- (void)setSearchWord:(NSString *)searchWord
{
    // 前後の空白をトリムする
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedWord = [searchWord stringByTrimmingCharactersInSet:charSet];
    
    // 入力なしの場合は全件検索とする
    if (0 == [trimmedWord length]) {
        _hasSearch = NO;
        _searchWords = [NSArray array];
        return;
    }
    
    // 検索内容の設定    
    _hasSearch = YES;
    // 空白文字で分割する
    // 全角を半角に変更
    NSString *replacedString = [trimmedWord stringByReplacingOccurrencesOfString:@"　" withString:@" "];
    _searchWords = [replacedString componentsSeparatedByString:@" "];
}


#pragma mark ------------------------------------------
#pragma mark ------ public
#pragma mark ------------------------------------------

// |monthDate|を指定して、MonthEventを取得
- (MonthEvent *)monthEventAtMonth:(NSDate *)monthDate
{
    MonthEvent *monthEvent = [_monthEventDict objectForKey:[monthDate ITFormatStringOfMonth]];
    // 検索ワードが指定されている場合、検索ワードで指定する
    if (_hasSearch) {
        monthEvent = [monthEvent monthEventWithSearchWords:_searchWords];
    }
    
    if (!monthEvent) {
        monthEvent = [[MonthEvent alloc] initWithMonthDate:monthDate];
        [_monthEventDict setValue:monthEvent forKey:[monthDate ITFormatStringOfMonth]];
    }
    return [monthEvent copy];
}

// |date|を指定して、ITEvent配列取得
- (NSArray*)eventsAtDate:(NSDate*)date
{
    LOG_METHOD;
    LOG(@"date: %@", date);
    LOG(@"itFormatString: %@", [date ITFormatStringOfDate]);
    LOG(@"itFormatStringwithstyle: %@", [date formatStringWithStyle:kCFDateFormatterFullStyle]);

    // 検索ワードが指定されている場合、検索ワードでフィルターする
    MonthEvent* monthEvent = [_monthEventDict objectForKey:[date ITFormatStringOfMonth]];
    DayEvent* dayEvent = (_hasSearch)
    ? [[monthEvent monthEventWithSearchWords:_searchWords] dayEventAtDate:date withSearchWords:_searchWords]
    : [monthEvent.dayEventsDict objectForKey:[date ITFormatStringOfDate]];
    
    return dayEvent.events;
}

// |fromDate|から|toDate|のイベント有無Array取得
- (NSArray*)marksArrayFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    MonthEvent *monthEvent = [_monthEventDict objectForKey:[fromDate ITFormatStringOfMonth]];
    // 検索ワードが指定されている場合、検索ワードでフィルターする
    if (_hasSearch) {
        monthEvent = [monthEvent monthEventWithSearchWords:_searchWords];
    }
    
    NSMutableArray* marksArray = [NSMutableArray array];
    NSDate* d = fromDate;
    NSDate* m = [fromDate monthDate];
    
	while (YES) {
		
        if ([[monthEvent.dayEventsDict allKeys] containsObject:[d ITFormatStringOfDate]]) {
            // イベントありの場合
            [marksArray addObject:[NSNumber numberWithBool:YES]];
        } else {
            // イベントなしの場合
            [marksArray addObject:[NSNumber numberWithBool:NO]];
        }

        // 次の日を取得
		d = [d nextDate];
		if ([d compare:toDate]==NSOrderedDescending) {
            break;
        }
        // 月が変わった場合、次月のイベントオブジェクトを取得
        if ([m compare:[d monthDate]] != NSOrderedSame) {
            m = [d monthDate];
            monthEvent = [_monthEventDict objectForKey:[m ITFormatStringOfMonth]];
            // 検索ワードが指定されている場合、検索ワードでフィルターする
            if (_hasSearch) {
                monthEvent = [monthEvent monthEventWithSearchWords:_searchWords];
            }
        }
	}
    return marksArray;
}

// 取得したgoogle calendar データを保存する
- (void)saveMonthEvent:(GCALResponse*)gcalResponse
{
    // 同期をとる
    dispatch_sync(_syncQueue, ^{
                
        // 対象月判定用文字列
        NSString *fromMonthString = [gcalResponse.requestMonth ITFormatStringOfMonth];
        NSString *toMonthString = [[gcalResponse.requestMonth nextMonth] ITFormatStringOfMonth];

        MonthEvent *monthEvent = [[MonthEvent alloc] initWithMonthDate:gcalResponse.requestMonth];

        // すべてのエントリ
        for (NSDictionary *entry in gcalResponse.entries) {
                        
            // 1件のエントリを作成
            GCALEntry *gcalEntry = [[GCALEntry alloc] initWithEntry:entry];
            
            NSString *key = [gcalEntry startDate];
            
            // 対象月の範囲かどうかの判定
            
            if (NSOrderedDescending == [key compare:fromMonthString]
                && NSOrderedAscending == [key compare:toMonthString]) {
                DayEvent *dayEvent = [monthEvent dayEventAtDateString:key];
                
                // GCALEntry --> Event
                Event *event = [[Event alloc] initWithGCALEntry:gcalEntry];
                
                // add
                NSMutableArray *ma = [dayEvent.events mutableCopy];
                [ma addObject:event];
                dayEvent.events = ma;
                [monthEvent setDayEvent:dayEvent];
            }
        }
        
        [self setMonthEvent:monthEvent];

    });
}

- (void)searchEventForWord:(NSString *)word
{
    // 検索ワードの設定
    [self setSearchWord:word];
    
    // カレントイベントの更新
    _currentMonthEvent = [self monthEventAtMonth:_currentMonthEvent.monthDate];
}

// 選択月の変更
- (void)changeCurrentMonth:(NSDate *)atMonthDate withNotification:(BOOL)flag
{
    // 選択月を変更
    if (flag) {
        [self willChangeValueForKey:kCurrentMonthEvent];        
    }
    _currentMonthEvent = [self monthEventAtMonth:atMonthDate];
    if (flag) {
        [self didChangeValueForKey:kCurrentMonthEvent];
    }
    
}
@end
