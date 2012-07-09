//
//  EventDetailDescriptionCell.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "EventDetailDescriptionCell.h"

@interface EventDetailDescriptionCell ()
{
 @private
    IBOutlet UILabel* _detailLabel;
    IBOutlet UITextView* _titleView;
}
@end

@implementation EventDetailDescriptionCell
@synthesize detailLabel = _detailLabel;
@synthesize titleView = _titleView;

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
