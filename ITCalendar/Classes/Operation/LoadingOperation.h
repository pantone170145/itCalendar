//
//  LoadingOperation.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingOperation : NSObject

#pragma mark property

@property (nonatomic, weak) id delegate;
@property (atomic) BOOL isLoading;

#pragma mark method

// |monthDate|の読み込みを開始する
- (void)startLoading:(NSDate *)atMonthDate;

@end


@protocol LoadingOperationDelegate <NSObject>

- (void)operationWillStartLoading:(LoadingOperation *)operation;
- (void)operationDidFinishLoading:(LoadingOperation *)operation;
- (void)operation:(LoadingOperation *)operation didFailWithError:(NSError *)error;

@end