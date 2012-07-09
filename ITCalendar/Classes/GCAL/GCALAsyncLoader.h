//
//  GCALAsyncLoader.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/19.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCALScriptEngine.h"

typedef void (^completeBlock_t)(NSDate *loadedMonthDate);
typedef void (^errorBlock_t)(NSError *error);

// google calendar 情報を非同期で読み込む
@interface GCALAsyncLoader : NSObject
<GCALScriptEngineDelegate>

// load
- (void)loadCalendarAtMonth:(NSDate *)monthDate
completeBlock:(completeBlock_t)completeBlock
  errorBlock:(errorBlock_t)errorBlock;
@end