//
//  NSDate+ITCalendar.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

// ITCalendar APP 独自のフォーマッタ
@interface NSDate (ITCalendar)

// yyyy-MM-dd
- (NSString*)ITFormatStringOfDate;
// yyyy-MM
- (NSString*)ITFormatStringOfMonth;
@end
