//
//  ContainerCalendarOperation.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContainerCalendarOperation <NSObject>

// "今日"ボタンオペレーション
- (void)todayButtonOperation;

// 表示更新
- (void)reloadOperation;

@end
