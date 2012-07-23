//
//  NSDate+ITCalendar.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

// ITCalendar APP 独自のフォーマッタ
// NSLocaleをja_JP指定として文字列をフォーマットします。
// そのため、すでにja_JP指定のNSDateに使用すると、9時間のずれが生じます
@interface NSDate (ITCalendar)

// yyyy-MM-dd
- (NSString*)ITFormatStringOfDate;
// yyyy-MM
- (NSString*)ITFormatStringOfMonth;
@end
