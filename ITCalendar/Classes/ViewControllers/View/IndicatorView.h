//
//  IndicatorView.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/25.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndicatorView : UIView

- (void)startAnimation;
- (void)stopAnimation;
// オフライン表示
- (void)showOfflineText;
@end
