//
//  EventDetailTitleCell.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "EventDetailTitleCell.h"

@interface EventDetailTitleCell ()
{
 @private
    IBOutlet UILabel* _titleLabel;
    IBOutlet UILabel* _dateAndTimeLabel;
}

@end

@implementation EventDetailTitleCell

@synthesize titleLabel = _titleLabel;
@synthesize dateAndTimeLabel = _dateAndTimeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
