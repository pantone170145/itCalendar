//
//  IndicatorView.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/25.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "IndicatorView.h"

#define kLoadingText @"読み込み中...  "

@interface IndicatorView ()
{
 @private
    UIActivityIndicatorView *_indicator;
    UILabel                 *_titleLabel;
    UILabel                 *_titleLabelOffline;
}
@end

@implementation IndicatorView


- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 80, 20)];
    if (!self) {
        // Initialization code
        return nil;
    }
    
    // アクティビティインジケータの作成
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    // ラベルの作成
    _titleLabel =  [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 110, 20)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:11];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = kLoadingText;
    _titleLabelOffline = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 110, 20)];
    _titleLabelOffline.backgroundColor = [UIColor clearColor];
    _titleLabelOffline.font = [UIFont systemFontOfSize:11];
    _titleLabelOffline.textColor = [UIColor whiteColor];
    _titleLabelOffline.text = @"オフライン";
    _titleLabel.hidden = YES;
    _titleLabelOffline.hidden = YES;
    
    [self addSubview:_indicator];
    [self addSubview:_titleLabel];
    [self addSubview:_titleLabelOffline];
    
    return self;
}

- (void)startAnimation
{
    _titleLabelOffline.hidden = YES;
    _titleLabel.hidden = NO;
    [_indicator startAnimating];
}
- (void)stopAnimation
{
    _titleLabel.hidden = YES;
    _titleLabelOffline.hidden = YES;
    [_indicator stopAnimating];
}

// オフライン表示
- (void)showOfflineText
{
    [self stopAnimation];
    _titleLabelOffline.hidden = NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
