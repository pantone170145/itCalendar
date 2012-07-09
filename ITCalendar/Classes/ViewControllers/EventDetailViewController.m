//
//  EventDetailViewController.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventDetailTitleCell.h"
#import "EventDetailPlaceCell.h"
#import "EventDetailDescriptionCell.h"
#import "Event.h"

@interface EventDetailViewController ()
{
 @private
    Event           *_event;
    EKEventStore    *_eventStore;
}

#pragma mark -
#pragma mark private method

/**
 @brief セル更新
 @param cell: 対象セル
 @param indexPath: 対象インデックス
 @return 
 */

- (void)updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

/**
 @brief 表示用の日時を取得する
 @param 
 @return
 */
- (NSString *)dateAndTime;


#pragma mark -
#pragma mark event

/**
 @brief イベントの登録処理
        EventEditViewを表示する
 @param
 @return
 */
- (void)addEventRegistration;

/**
 @brief アクションボタンイベント
 @param
 @return
 */
- (void)actionButtonDidClicked:(id)sender;
@end

@implementation EventDetailViewController

#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------
- (id)initWithEvent:(Event*)event
{
    self = [super initWithNibName:@"EventDetailViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    _event = event;
    [self setTitle:@"イベントの詳細"];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------

- (void)updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (0 == indexPath.row) {
        // title
        EventDetailTitleCell* titleCell = (EventDetailTitleCell*)cell;
        titleCell.titleLabel.text = _event.title;
        // 日時
        titleCell.dateAndTimeLabel.text = [self dateAndTime];
        return;
    } else if (1 == indexPath.row) {
        // place
        EventDetailPlaceCell* placeCell = (EventDetailPlaceCell*)cell;
        placeCell.placeTitleLabel.text = _event.place;
        return;
    }
    
    // 説明/詳細
    EventDetailDescriptionCell* descriptionCell = (EventDetailDescriptionCell*)cell;
    
    if (2 == indexPath.row) {
        // 説明
        descriptionCell.detailLabel.text = @"説明";
        descriptionCell.titleView.text = _event.descriptionUrl;
        return;
    }
    
    // 詳細
    descriptionCell.detailLabel.text = @"詳細";
    descriptionCell.titleView.text = _event.detailUrl;
}

- (NSString *)dateAndTime
{
    // |_event|から表示用の日時を作成する
    NSString *zeroHours = @"0:00";
    if ([_event.startTime.hours isEqualToString:zeroHours]
        && [_event.endTime.hours isEqualToString:zeroHours]) {
        
        // 時間を表示しない
        
        // 月日も同じ場合、開始日のみ表示
        if ([_event.startTime.month isEqualToString:_event.endTime.month]
            && [_event.startTime.day isEqualToString:_event.endTime.day]) {
            return [NSString stringWithFormat:@"%@/%@(%@)",
                    _event.startTime.month,
                    _event.startTime.day,
                    _event.startTime.week];
        }
        
        // 月日が違う場合、開始日〜終了日
        return [NSString stringWithFormat:@"%@/%@(%@)〜%@/%@(%@)",
                _event.startTime.month,
                _event.startTime.day,
                _event.startTime.week,
                _event.endTime.month,
                _event.endTime.day,
                _event.endTime.week];
        
    }
    
    // 時間を表示する
    return [NSString stringWithFormat:@"%@/%@(%@)\n%@〜%@",
            _event.startTime.month,
            _event.startTime.day,
            _event.startTime.week,
            _event.startTime.hours,
            _event.endTime.hours];
}


#pragma mark ------------------------------------------
#pragma mark ------ view life cycle
#pragma mark ------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

    _eventStore = [[EKEventStore alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // アクションボタン追加
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self action:@selector(actionButtonDidClicked:)];
    self.navigationItem.rightBarButtonItem = actionButton;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // アクションボタン消去
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ------------------------------------------
#pragma mark ------ Table view data source
#pragma mark ------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return 132;
    }
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TitleCellIdentifier = @"EventDetailTitleCell";
    static NSString *PlaceCellIdentifier = @"EventDetailPlaceCell";
    static NSString *DescriptionCellIdentifier = @"EventDetailDescriptionCell";
    
    static BOOL hasAlreadyRegisterNibTitle = NO;
    static BOOL hasAlreadyRegisterNibPlace = NO;
    static BOOL hasAlreadyRegisterNibDescription = NO;
    UITableViewCell* cell;
    
    if (0 == indexPath.row) {
        // title
        if (!hasAlreadyRegisterNibTitle) {
            [tableView registerNib:[UINib nibWithNibName:TitleCellIdentifier bundle:nil]
            forCellReuseIdentifier:TitleCellIdentifier];
        }
        cell = [tableView dequeueReusableCellWithIdentifier:TitleCellIdentifier];
    } else if (1 == indexPath.row) {
        // place
        if (!hasAlreadyRegisterNibPlace) {
            [tableView registerNib:[UINib nibWithNibName:PlaceCellIdentifier bundle:nil]
            forCellReuseIdentifier:PlaceCellIdentifier];
        }
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceCellIdentifier];
    } else {
        // 説明/詳細
        if (!hasAlreadyRegisterNibDescription) {
            [tableView registerNib:[UINib nibWithNibName:DescriptionCellIdentifier bundle:nil]
            forCellReuseIdentifier:DescriptionCellIdentifier];
        }
        cell = [tableView dequeueReusableCellWithIdentifier:DescriptionCellIdentifier];
    }

    // Configure the cell...
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark ------------------------------------------
#pragma mark ------ event
#pragma mark ------------------------------------------

- (void)addEventRegistration
{
    // 登録イベントの作成
    EKEvent *newEvent = [EKEvent eventWithEventStore:_eventStore];
    newEvent.title = _event.title;
    newEvent.location = _event.place;
    newEvent.startDate = [_event.startTime date];
    newEvent.endDate = [_event.endTime date];
    newEvent.allDay = NO;
    newEvent.URL = [NSURL URLWithString:_event.detailUrl];
    newEvent.notes = [NSString stringWithFormat:@"説明\n%@", _event.descriptionUrl];
    
    // カレンダー情報編集コントローラ表示
    EKEventEditViewController *eventEditViewController = [[EKEventEditViewController alloc] init];
    eventEditViewController.editViewDelegate = self;
    eventEditViewController.eventStore = _eventStore;
    eventEditViewController.event = newEvent;
    // modal表示
    [self presentModalViewController:eventEditViewController animated:YES];
}

- (void)actionButtonDidClicked:(id)sender
{
    // アクションシートを表示する
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"キャンセル"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"カレンダーに追加する", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark ------------------------------------------
#pragma mark ------ EventKit / EventEditViewControllerDelegate
#pragma mark ------------------------------------------

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    
    NSError *error = nil;
    
    switch (action) {
        case EKEventEditViewActionCanceled:
            break;
            
        case EKEventEditViewActionSaved:
        {
            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            
            LOG(@"error %@", error.description);
            break;
        }
        case EKEventEditViewActionDeleted:
            [controller.eventStore removeEvent:controller.event span:EKSpanThisEvent error:&error];
            break;
        default:
            break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark ------------------------------------------
#pragma mark ------ UIActionSheetDelegate
#pragma mark ------------------------------------------
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LOG_METHOD;
    LOG(@"butotnIndex: %d", buttonIndex);
    if (1 == buttonIndex) {
        // キャンセル
        return;
    }
    
    // カレンダー追加ビューを表示する
    [self addEventRegistration];
}


@end

