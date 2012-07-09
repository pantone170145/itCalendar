//
//  NSDate+locale.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/21.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (locale)
+ (NSDate *)localeToday;
+ (NSDate *)localThisMonth;
@end
