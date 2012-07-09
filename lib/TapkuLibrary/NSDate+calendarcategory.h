//
//  NSDate+calendarcategory.h
//  TapkuLibrary
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (calendarcategory)
- (NSDate*) firstOfMonth;
- (NSDate*) nextMonth;
- (NSDate*) previousMonth;

- (NSDate*) lastOfMonthDate;
+ (NSDate*) lastofMonthDate;
+ (NSDate*) lastOfCurrentMonth;

- (NSDate*) nextDate;
@end
