//
//  OperationManager.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "OperationManager.h"

@implementation OperationManager

@synthesize loadingOperation = _loadingOperation;

+ (OperationManager*)sharedManager
{
    static OperationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OperationManager alloc] init];
    });
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _loadingOperation = [[LoadingOperation alloc] init];
    
    return self;
}

@end
