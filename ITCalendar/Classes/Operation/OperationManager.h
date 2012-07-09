//
//  OperationManager.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoadingOperation.h"

@interface OperationManager : NSObject

#pragma mark property
@property (nonatomic, strong) LoadingOperation *loadingOperation;

#pragma mark method

// シングルトン取得
+ (OperationManager*)sharedManager;

@end
