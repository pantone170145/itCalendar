//
//  NSDate+Formatter.h
//  Navigation
//
//  Created 12/05/30.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSDate 簡易フォーマッタ
@interface NSDate (Formatter)
// |style|でformatしたNSString*を返す
- (NSString*)formatStringWithStyle:(NSDateFormatterStyle)style;
// |format|で指定したNSString*を返す
- (NSString*)formatStringWithFormat:(NSString*)format;
// |format| & |locale|で指定したNSString*を返す
- (NSString*)formatStringWithFormat:(NSString*)format
                             locale:(NSLocale*)locale;
@end
