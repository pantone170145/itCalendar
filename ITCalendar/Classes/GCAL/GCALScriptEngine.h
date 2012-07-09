//
//  GDScriptEngine.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/19.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCALResponse;

// ITカレンダー用のgoogle calendarを取得するための
// htmlを読み込む
@interface GCALScriptEngine : NSObject
<UIWebViewDelegate>

@property (nonatomic, weak) id delegate;

- (void)loadCalendarAtMonth:(NSDate*)monthDate;
@end


@protocol GCALScriptEngineDelegate <NSObject>

- (void)gcalScriptEngine:(GCALScriptEngine*)gcalScriptEngine
        didReceivedResponse:(GCALResponse *)jsonResult;

- (void)gcalScriptEngine:(GCALScriptEngine *)gcalScriptEngine
        didFailWithError:(NSError *)error;

@end