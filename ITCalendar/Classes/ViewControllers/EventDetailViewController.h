//
//  EventDetailViewController.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@class Event;

/**
 イベントの詳細ビューコントローラ
 */
@interface EventDetailViewController : UITableViewController
<UINavigationControllerDelegate, EKEventEditViewDelegate,
UIActionSheetDelegate>


// 初期化
- (id)initWithEvent:(Event*)event;
@end
