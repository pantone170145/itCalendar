//
//  ContainerCalendarViewController.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/17.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCALAsyncLoader.h"
#import "LoadingOperation.h"

@interface ContainerCalendarViewController : UIViewController
<UISearchBarDelegate, LoadingOperationDelegate>
@end