//
//  LoadingOperation.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "LoadingOperation.h"
#import "EventManager.h"
#import "GCALAsyncLoader.h"
#import "TapkuLibrary/TapkuLibrary.h"

@interface LoadingOperation ()

- (GCALAsyncLoader *)sharedGCALAsyncLoader;

@end

@implementation LoadingOperation

@synthesize delegate = _delegate;
@synthesize isLoading = _isLoading;


- (GCALAsyncLoader *)sharedGCALAsyncLoader
{
    static GCALAsyncLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GCALAsyncLoader alloc] init];
    });
    return sharedInstance;
}


#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _isLoading = NO;
    return self;
}


#pragma mark ------------------------------------------
#pragma mark ------ public method
#pragma mark ------------------------------------------

// |monthDate|の読み込みを開始する
- (void)startLoading:(NSDate *)atMonthDate
{
    _isLoading = YES;
    
    if ([_delegate respondsToSelector:@selector(operationWillStartLoading:)]) {
        // メインスレッドから通知する
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate operationWillStartLoading:self];
        });
    }
    
    // カレンダ情報の読み込み開始
    [[self sharedGCALAsyncLoader]
     loadCalendarAtMonth:atMonthDate
     completeBlock:^(NSDate *loadedDate){
         
         _isLoading = NO;
         if ([_delegate respondsToSelector:@selector(operationDidFinishLoading:)]) {
             [_delegate operationDidFinishLoading:self];
         }
         // 選択中の月と、読み込みが完了した月が異なる場合は更新しない
         if (![[EventManager sharedManager].currentMonthEvent.monthDate isSameDay:loadedDate]) {
             return;
         }
         // 選択月を変更
         [[EventManager sharedManager] changeCurrentMonth:loadedDate withNotification:YES];
     }
     errorBlock:^(NSError *error){
         
         _isLoading = NO;
         if ([_delegate respondsToSelector:@selector(operation:didFailWithError:)]) {
             [_delegate operation:self didFailWithError:error];
         }
     }];
}

@end
