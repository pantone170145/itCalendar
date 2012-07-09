//
//  EventCell.h
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UILabel* titleLabel;

@end
