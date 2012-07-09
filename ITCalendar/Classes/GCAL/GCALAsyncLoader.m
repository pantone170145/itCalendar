//
//  GCALAsyncLoader.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/19.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "GCALAsyncLoader.h"
#import "GCALResponse.h"
#import "EventManager.h"
#import "EventManager.h"

@interface GCALAsyncLoader ()
{
 @private
    GCALScriptEngine*   _gcalScriptEngine;
    completeBlock_t     _completeBlock;
    errorBlock_t        _errorBlock;
}
@end

@implementation GCALAsyncLoader


#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _gcalScriptEngine = [[GCALScriptEngine alloc] init];
    [_gcalScriptEngine setDelegate:self];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ public method
#pragma mark ------------------------------------------

// load
- (void)loadCalendarAtMonth:(NSDate*)monthDate
completeBlock:(completeBlock_t)completeBlock
  errorBlock:(errorBlock_t)errorBlock
{
    _completeBlock = [completeBlock copy];
    _errorBlock = [errorBlock copy];
    [_gcalScriptEngine loadCalendarAtMonth:[monthDate copy]];
}
#pragma mark ------------------------------------------
#pragma mark ------ GCALScriptEngineDelegate
#pragma mark ------------------------------------------
- (void)gcalScriptEngine:(GCALScriptEngine *)gcalScriptEngine didReceivedResponse:(GCALResponse *)gcalResponse
{
    LOG_METHOD;
    
    // 非同期処理
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalDispatchQueue, ^{
        // イベントを保存する
        [[EventManager sharedManager] saveMonthEvent:gcalResponse];
        
        _completeBlock(gcalResponse.requestMonth);
    });
}

- (void)gcalScriptEngine:(GCALScriptEngine *)gcalScriptEngine didFailWithError:(NSError *)error
{
    LOG_METHOD;
    
    // 非同期処理
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalDispatchQueue, ^{
        _errorBlock(error);
    });
    
}

@end
