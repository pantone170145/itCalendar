//
//  MonthCalendarViewController.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/13.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "MonthCalendarViewController.h"
#import "EventManager.h"
#import "OperationManager.h"
#import "EventCell.h"
#import "EventDetailViewController.h"
#import "GCALAsyncLoader.h"

@interface MonthCalendarViewController ()
{
 @private
    NSArray *_rows;
}

#pragma mark -
#pragma mark private method

/**
 @brief セルの更新
 @param cell 対象のセル
 @param indexPath 対象のインデックス
 */
- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

/**
 @brief ビューの再描画
 @param 
 @return 
 */
- (void)reload;

/**
 @brief 選択中の日付に、イベントが存在するかどうか
 @param 
 @return return YES: イベントあり NO: イベントなし
 */
- (BOOL)selectedDateHasEvents;

// 
// @brief 指定のインデックスはイベントなし表示セルかどうか
// @param indexPath 対象のインデックス
// @return YES: イベント無し表示用セル NO: 通常セル
//
- (BOOL)isNoEventCellatIndexPath:(NSIndexPath *)indexPath;


#pragma mark -
#pragma mark event

/**
 @brief 選択日付を変更する
 @param newDate: 新たに選択する日
 @return 
 */
- (void)selectDate:(NSDate *)newDate;

/**
 @brief 月変更
 @param 選択対象の日(月の移動ボタンの場合は１日が。前月の日付を選択した場合は
        その日付が入る)
 @return 
 */
- (void)monthDidChange:(NSDate *)selectedDate;

/**
 @brief セルのクリックイベント
 対象のイベント詳細ビューに画面遷移する
 @param indexPath: 対象のインデックス
 @return 
 */
- (void)tableViewCellDidSelectAtIdexPath:(NSIndexPath *)indexPath;


@end

@implementation MonthCalendarViewController


#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _rows = [NSArray array];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ View cycle
#pragma mark ------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // デフォルトで今日を選択する
    [self selectDate:[NSDate localeToday]];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // toolbar show
    [[self navigationController] setToolbarHidden:NO
                                         animated:animated];
    // deselect
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // toolbar hidden
    [[self navigationController] setToolbarHidden:YES
                                         animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------

// セル更新
- (void)updateTableViewCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // イベントなし表示セル
    if ([self isNoEventCellatIndexPath:indexPath]) {
        cell.textLabel.text = @"イベントはありません";
        cell.textLabel.textAlignment = UITextAlignmentCenter;     // センター揃え
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"ヒラギノ角ゴ ProN W6" size:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return;
    }
    
    // イベントセル
    EventCell *eventCell = (EventCell *)cell;
    eventCell.titleLabel.text = ((Event*)[_rows objectAtIndex:indexPath.row]).title;
    eventCell.timeLabel.text = ((Event*)[_rows objectAtIndex:indexPath.row]).startTime.hours;
}

// ビューの再描画
- (void)reload
{
    NSDate *selectedMonthDate = [EventManager sharedManager].currentMonthEvent.monthDate;
    
    // 現在選択中の日付を保持
    NSDate *selectedDate = [self.monthView dateSelected];
    
    // 月が変更されていた場合
    if (![selectedMonthDate isSameDay:[selectedDate firstOfMonth]]) {
        // カレンダー月を切り替える
        [self calendarMonthView:self.monthView monthDidChange:selectedMonthDate animated:YES];
        return;
    }
    
    // カレンダー更新
    [self.monthView reload];
    
    // 選択を戻す
    [self selectDate:selectedDate];
}

- (BOOL)selectedDateHasEvents
{
    return (0 < [_rows count]);
}

- (BOOL)isNoEventCellatIndexPath:(NSIndexPath *)indexPath
{
    // 最後のセルがイベントなし表示セル
    return ([_rows count] == indexPath.row);
}

#pragma mark ------------------------------------------
#pragma mark ------ event
#pragma mark ------------------------------------------

- (void)selectDate:(NSDate *)newDate
{
    // カレンダーの背景画像変更
    [self.monthView selectDate:newDate];
    
    // 選択された日付のイベントを取得
    _rows = [[EventManager sharedManager] eventsAtDate:newDate];
	
	[self.tableView reloadData];
}

- (void)monthDidChange:(NSDate *)selectedDate
{
    // 日付のタイル選択で月が移動した場合は、日まで指定されているため。
    // 月のみのNSDateを取得
    NSDate *monthDate = [selectedDate firstOfMonth];
    
    // 選択月を変更
    [[EventManager sharedManager] changeCurrentMonth:monthDate withNotification:NO];
    
    // 日を選択
    [self selectDate:selectedDate];
    
    // カレンダー読み込み
    [[OperationManager sharedManager].loadingOperation startLoading:monthDate];
}

- (void)tableViewCellDidSelectAtIdexPath:(NSIndexPath *)indexPath
{
    // 詳細画面への画面遷移
    // 戻るボタンに、現在選択されている日付を設定する
    Event *event = [_rows objectAtIndex:indexPath.row];
    NSString *backButtonTitle = [NSString stringWithFormat:@"%@/%@(%@)",
                                 event.startTime.month,
                                 event.startTime.day,
                                 event.startTime.week];
    UIBarButtonItem *backBarButtonItem = 
    [[UIBarButtonItem alloc] initWithTitle:backButtonTitle
                                     style:UIBarButtonItemStyleBordered
                                    target:nil 
                                    action:nil];
    [self.parentViewController.navigationItem setBackBarButtonItem:backBarButtonItem];
    // 詳細ビュー
    EventDetailViewController* detailViewController
    = [[EventDetailViewController alloc] initWithEvent:[_rows objectAtIndex:indexPath.row]];
    // 画面遷移
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark ------------------------------------------
#pragma mark ------ TKCalendarMonthView
#pragma mark ------------------------------------------
- (BOOL) calendarMonthView:(TKCalendarMonthView*)monthView monthShouldChange:(NSDate*)month animated:(BOOL)animated
{
    return YES;
}
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate
{
    return [[EventManager sharedManager] marksArrayFromDate:startDate toDate:lastDate];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
    
    [self selectDate:date];
}

- (void) calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)month animated:(BOOL)animated{
    
	[super calendarMonthView:mv monthDidChange:month animated:animated];

    [self monthDidChange:month];
    
}

#pragma mark ------------------------------------------
#pragma mark ------ tableview delegate & data source
#pragma mark ------------------------------------------

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // イベントなし表示用のセル+1する
    return [_rows count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // イベントが無い場合のみイベントなし用のセルを表示する
    // そのため、イベントがある場合はイベントなし表示セルの高さを0にする
    if ([self selectedDateHasEvents] && [self isNoEventCellatIndexPath:indexPath]) {
        return 0;
    }
    return 44;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *EventCellIdentifier = @"EventCell";
    static NSString *CellIdentifier = @"Cell";
    static BOOL hasAlreadyRegisterNib = NO;
    // register nib file
    if (!hasAlreadyRegisterNib) {
        UINib *cellNib = [UINib nibWithNibName:EventCellIdentifier bundle:nil];
        [tv registerNib:cellNib forCellReuseIdentifier:EventCellIdentifier];
        hasAlreadyRegisterNib = YES;
    }

    // イベントなし表示セルの場合
    if ([self isNoEventCellatIndexPath:indexPath]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [self updateTableViewCell:cell atIndexPath:indexPath];
        return cell;
    }
    
    // イベントセル
    EventCell* eventCell = [tv dequeueReusableCellWithIdentifier:EventCellIdentifier];
    // update cell
    [self updateTableViewCell:eventCell atIndexPath:indexPath];	
    return eventCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    // イベントなし用のセルは何もしない
    if ([self isNoEventCellatIndexPath:indexPath])return;
    
    [self tableViewCellDidSelectAtIdexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 背景色をボーダー上にするため、
    if (indexPath.row % 2) {
        [cell setBackgroundColor:RGBA(240, 240, 240, 1)];
    }
}



#pragma mark ------------------------------------------
#pragma mark ------ ContainerCalendarOperation
#pragma mark ------------------------------------------

// 再描画オペレーション
- (void)reloadOperation
{
    [self reload];
}

// "今日"ボタンのオペレーション
- (void)todayButtonOperation
{
    // 選択中の月が今月では無い場合は、今月に移動する
    if (![[EventManager sharedManager].currentMonthEvent isThisMonth]) {
        
        NSDate *thisMonth = [NSDate localThisMonth];
        [self calendarMonthView:self.monthView monthDidChange:thisMonth animated:YES];
    }
    
    // 今日を選択する
    [self selectDate:[NSDate localeToday]];

}

@end
