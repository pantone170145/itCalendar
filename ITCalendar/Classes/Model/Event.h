//
//  Event.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCALEntry;

@interface Time : NSObject
<NSCopying>

@property (nonatomic, copy) NSString *year;             // yyyy
@property (nonatomic, copy) NSString *month;            // MM
@property (nonatomic, copy) NSString *day;              // dd
@property (nonatomic, copy) NSString *week;             // 曜日
@property (nonatomic, copy) NSString *hours;            // 時間

// @brief Time --> NSDateに変換する
// @return NSDate object
- (NSDate *)date;

@end


@interface Event : NSObject
<NSCopying>
@property (nonatomic, copy) NSString *identifier;       // 識別子
@property (nonatomic, copy) NSString *title;            // タイトル
@property (nonatomic, copy) Time     *startTime;        // 開始日時
@property (nonatomic, copy) Time     *endTime;          // 終了日時
@property (nonatomic, copy) NSString *place;            // 場所
@property (nonatomic, copy) NSString *descriptionUrl;   // 説明URL
@property (nonatomic, copy) NSString *detailUrl;        // 詳細URL

/**
 @brief GCALEntryオブジェクトで初期化する
 @param entry: GCALEntry object
 @return
 */
- (id)initWithGCALEntry:(GCALEntry *)entry;

/**
 @brief Eventを比較する
 @param 
 @return YES: same event. NO: different event.
 */
- (BOOL)compareEvent:(Event *)event;

@end

