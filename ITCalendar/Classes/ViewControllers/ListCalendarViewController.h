//
//  ListCalendarViewController.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerCalendarOperation.h"

/**
 リスト形式のビューコントローラ
 */
@interface ListCalendarViewController : UITableViewController
<UISearchBarDelegate, ContainerCalendarOperation>

@end

/**
 ListCalendarに表示するセクションのヘッダ
 */
@interface SectionHeaderView : UIView

@end