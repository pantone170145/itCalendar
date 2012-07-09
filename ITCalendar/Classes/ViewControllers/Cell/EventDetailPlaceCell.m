//
//  EventDetailPlaceCell.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "EventDetailPlaceCell.h"

@interface EventDetailPlaceCell ()
{
 @private
    IBOutlet UILabel* _placeTitleLabel;
    IBOutlet UILabel* _placeUrlLabel;
}
@end

@implementation EventDetailPlaceCell

@synthesize placeTitleLabel = _placeTitleLabel;
@synthesize placeUrlLabel = _placeUrlLabel;

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
