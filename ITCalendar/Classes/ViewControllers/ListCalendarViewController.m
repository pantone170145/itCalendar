//
//  ListCalendarViewController.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/15.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "TapkuLibrary/TapkuLibrary.h"
#import "ListCalendarViewController.h"
#import "EventDetailViewController.h"
#import "EventCell.h"
#import "EventManager.h"
#import "OperationManager.h"

enum NavigationBarButton {
    kNavigationBarButtonBack = 0,
    kNavigationBarButtonForward,
};

@interface ListCalendarViewController ()
{
 @private
    IBOutlet UITableView    *_tableView;
    NSDictionary            *_rowsDict;      // key: section value rowデータ(Event)配列
    NSArray                 *_keys;          // _rowsDictのキー配列
    NSDictionary            *_indexDict;
}

#pragma mark -
#pragma mark private method

/**
 @brief ナビゲーションバーを初期化する
        月移動ボタンの作成、検索バーのサイズ調整
 @param 
 @return 
 */
- (void)initNavigationBar;

/**
 @brief ナビゲーションバーを元に戻す
 @param 
 @return 
 */
- (void)clearNavigationBar;

/**
 @brief 1日のイベントを取得する
 @param section: 対象のセクション
 @return 取得した|DayEvent|
 */
- (DayEvent *)dayEventAtSection:(NSInteger)section;

/**
 @brief セル更新
 @param cell: 対象セル
 @param indexPath: 対象インデックス
 @return 
 */
- (void)updateCell:(EventCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 @brief 再描画
 @param 
 @return 
 */
- (void)reload;

/**
 @brief table headerViewに表示するラベルの取得
        月にイベントが無い場合に、"yyyy年MM月"を表示する
 @param 
 @return 表示する|UILabel|
 */
- (UILabel *)tableHeaderLabel;

/**
 @brief "今日"セクションまでスクロールする
        存在しない場合は何もしない
 @param 
 @return 
 */
- (void)scrollToToday;


#pragma mark -
#pragma mark event

/**
 @brief 月移動ボタンのクリックイベント
 @param sender: 押されたUIBarButtonItem
 @return 
 */
- (void)monthChangeButtonDidClick:(id)sender;

/**
 @brief セルのクリックイベント
        対象のイベント詳細ビューに画面遷移する
 @param indexPath: 対象のインデックス
 @return 
 */
- (void)tableViewCellDidSelectAtIdexPath:(NSIndexPath *)indexPath;


@end

@implementation ListCalendarViewController

@synthesize tableView = _tableView;

#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------
- (id)init
{
    self = [super initWithNibName:@"ListCalendarViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    _indexDict = [NSDictionary dictionary];
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------
- (void)initNavigationBar
{
    LOG_RECT(self.parentViewController.navigationItem.titleView.frame);
    
    // 検索バーのサイズ調整
    self.parentViewController.navigationItem.titleView.frame = CGRectMake(105, 0, 218, 44);
    // ナビゲーションバーの左上に戻る進ボタンを作成する
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:107
                                                                                target:self
                                                                                action:@selector(monthChangeButtonDidClick:)];
    backButton.tag = kNavigationBarButtonBack;
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:108
                                                                                   target:self
                                                                                   action:@selector(monthChangeButtonDidClick:)];
    forwardButton.tag = kNavigationBarButtonForward;
    self.parentViewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backButton, forwardButton, nil];
}
- (void)clearNavigationBar
{
    // 検索バーのサイズ調整
    self.parentViewController.navigationItem.titleView.frame = CGRectMake(5, 0, 310, 44);
    // ナビゲーションバーの左上に戻る進ボタンを作成する
    self.parentViewController.navigationItem.leftBarButtonItems = nil;
}

- (DayEvent*)dayEventAtSection:(NSInteger)section
{
    id key = [_keys objectAtIndex:section];
    DayEvent* dayEvent = [_rowsDict objectForKey:key];
    return dayEvent;
}

// セル更新
- (void)updateCell:(EventCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // セクションから1日のイベントを取得
    DayEvent* dayEvent = [self dayEventAtSection:indexPath.section];
    
    // イベントあり
    if (indexPath.row < [dayEvent.events count]) {
        Event *event = [dayEvent.events objectAtIndex:indexPath.row];
        cell.titleLabel.text = event.title;
        cell.timeLabel.text = event.startTime.hours;
        return;
    }
    cell.titleLabel.text = @"";
    cell.timeLabel.text = @"";    
}

- (void)reload
{
    // 今日
    NSDate *today = [NSDate localeToday];
    
    // 指定されている月のイベントを取得し、メンバにコピーする
    MonthEvent *monthEvent = [[EventManager sharedManager].currentMonthEvent copy];
        
    _rowsDict = [monthEvent.dayEventsDict copy];
    _keys = [_rowsDict allKeys];
    
    
    // 今月を表示中でかつ今日のイベントが存在しない場合
    // 無条件で今日のセクションを表示する
    if ([monthEvent isThisMonth]
        && (0 == [[monthEvent dayEventAtDate:today].events count])) {
        
        // 今日のセクションを追加
        NSMutableArray *newKeys = [_keys mutableCopy];
        [newKeys addObject:[today ITFormatStringOfDate]];
        _keys = newKeys;
        NSMutableDictionary *newDict = [_rowsDict mutableCopy];
        // 今日をダミー登録
        DayEvent *dummy = [[DayEvent alloc] initWithDate:today];
        [newDict setValue:dummy forKey:[today ITFormatStringOfDate]];
        _rowsDict = newDict;
    }
    
    _keys = [_keys sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    int i = 0;
    for (NSString *key in _keys) {
        DayEvent *dayEvent = [_rowsDict objectForKey:key];
        for (Event *event in dayEvent.events) {
            [dict setObject:[[NSNumber alloc] initWithInt:i] forKey:event.identifier];
            i++;
        }
    }
    _indexDict = dict;
    
    // ヘッダーの作成
    // イベントが０件の場合のみ、年月がわからないため表示する
    if (0 == [_rowsDict count]) {
        _tableView.tableHeaderView = [self tableHeaderLabel];
    } else {
        _tableView.tableHeaderView = nil;
    }

    [_tableView reloadData];
}

- (UILabel *)tableHeaderLabel
{
    NSDate *selectedMonthDate = [EventManager sharedManager].currentMonthEvent.monthDate;
    
    
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSString *title = ([localeIdentifier isEqualToString:@"ja_JP"])
    ? [NSString stringWithFormat:@"%@年%@",[selectedMonthDate yearString],[selectedMonthDate monthString]]      // ja_JP
    : [NSString stringWithFormat:@"%@%@",[selectedMonthDate monthString],[selectedMonthDate yearString]];     // else
    
    UILabel *tableHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 22)];
    tableHeader.backgroundColor = [UIColor clearColor];
    tableHeader.textAlignment = UITextAlignmentCenter;
    tableHeader.textColor = [UIColor lightGrayColor];
    tableHeader.text = title;
    tableHeader.numberOfLines = 2;
    tableHeader.font = [UIFont fontWithName:@"ヒラギノ角ゴ ProN W6" size:14];
    
    return tableHeader;
}

- (void)scrollToToday
{
    // 今日のセクションが一番上にくるようにスクロールする
    
    NSDate *today = [NSDate localeToday];
    NSUInteger section = [_keys indexOfObject:[today ITFormatStringOfDate]];
    
    // 存在しない場合は何もしない
    if (NSNotFound == section) {
        return;
    }
    // 指定セクションが上にくるようスクロール
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    [_tableView scrollToRowAtIndexPath:indexPath
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:YES];

}

#pragma mark ------------------------------------------
#pragma mark ------ event
#pragma mark ------------------------------------------

- (void)monthChangeButtonDidClick:(id)sender
{
    // カレンダー情報ロード中の場合は読み込まない
    // 連続クリックの禁止
    if ([OperationManager sharedManager].loadingOperation.isLoading) {
        return;
    }
    
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSDate *selectedMonthDate = [EventManager sharedManager].currentMonthEvent.monthDate;
    
    NSDate *newMonthDate = (kNavigationBarButtonBack == button.tag)
    ? [selectedMonthDate previousMonth]
    : [selectedMonthDate nextMonth];
    
    // 月変更
    [[EventManager sharedManager] changeCurrentMonth:newMonthDate withNotification:YES];
    
    // 対象月のデータロード開始
    [[OperationManager sharedManager].loadingOperation startLoading:newMonthDate];
}

- (void)tableViewCellDidSelectAtIdexPath:(NSIndexPath *)indexPath
{
    // 詳細画面への画面遷移
    // 戻るボタンに、現在選択されている日付を設定する
    DayEvent *dayEvent = [self dayEventAtSection:indexPath.section];
    Event *event = [dayEvent.events objectAtIndex:indexPath.row];
    NSString *backButtonTitle = [NSString stringWithFormat:@"%@/%@(%@)",
                                 event.startTime.month,
                                 event.startTime.day,
                                 event.startTime.week];
    LOG(@"%@", backButtonTitle);
    UIBarButtonItem *backBarButtonItem = 
    [[UIBarButtonItem alloc] initWithTitle:backButtonTitle
                                     style:UIBarButtonItemStyleBordered
                                    target:nil 
                                    action:nil];
    [self.parentViewController.navigationItem setBackBarButtonItem:backBarButtonItem];
    // 詳細ビュー
    EventDetailViewController* detailViewController
    = [[EventDetailViewController alloc] initWithEvent:event];
    // 画面遷移
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark ------------------------------------------
#pragma mark ------ view life cycle
#pragma mark ------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    // view layout
    CGRect rect = self.view.frame;
    rect.size.height -= (self.navigationController.toolbar.frame.size.height * 2);
    [self.view setFrame:rect];
    [_tableView setFrame:rect];
    [self reload];
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
    [[self navigationController] setToolbarHidden:NO
                                         animated:animated];
    [self initNavigationBar];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:YES
                                         animated:animated];
    [self clearNavigationBar];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark ------------------------------------------
#pragma mark ------ Table view data source
#pragma mark ------------------------------------------

// セクション数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_keys count];
}

// セクションごとの行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    DayEvent* dayEvent = [self dayEventAtSection:section];
    // １件もイベントが無い場合、１行とする（今日を表示用）
    return (0 == [dayEvent.events count]) ? 1 : [dayEvent.events count];
}

// セクション名
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 曜日+日付をセクション名とする
    DayEvent* dayEvent = [self dayEventAtSection:section];
    NSString* sectionTitle = [NSString stringWithFormat:@"　　%@　　　　　　　%@",
                              [dayEvent.date weekdayString],
                              dayEvent.dateString];
    return sectionTitle;
}

// セクションのインデックスタイトル
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSString*(^trimZero)(NSString*) = ^(NSString *string){
        NSString *first = [string substringToIndex:1];
        LOG(@"%@", first);
        if ([first isEqualToString:@"0"]) return [string substringFromIndex:1];
        return string;
    };
    // yyyy-MM-dd --> MM/ddを取得する
    NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity:[_keys count]];
    for (NSString *key in _keys) {
        NSArray *tokens = [key componentsSeparatedByString:@"-"];
        NSString *indexTitle = [NSString stringWithFormat:@"%@/%@",
                                trimZero([tokens objectAtIndex:1]),
                                trimZero([tokens objectAtIndex:2])];
        [indexArray addObject:indexTitle];
    }
    return indexArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    static BOOL hasAlreadyRegisterNib = NO;
    // register nib file
    if (!hasAlreadyRegisterNib) {
        UINib *cellNib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        [tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    }
    
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // update cell
    [self updateCell:cell atIndexPath:indexPath];
    return cell;
}


#pragma mark ------------------------------------------
#pragma mark ------ Table view delegate
#pragma mark ------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1件もイベントが無い場合（今日を表示用）
    // セルの高さを0とする
    DayEvent *dayEvent = [self dayEventAtSection:indexPath.section];
    if (0 == [dayEvent.events count]) return 0;
    return 44;
}

// セクションのヘッダービューを返す
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 今日のセクションの場合のみ、文字色を青にする
    DayEvent *dayEvent = [self dayEventAtSection:section];
    NSDate *today = [NSDate localeToday];

    SectionHeaderView *headerView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [headerView setBackgroundColor:RGBA(176, 186, 194, 0.9)];
    
    tableView.sectionHeaderHeight = headerView.frame.size.height;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, headerView.frame.size.width - 20, 20)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    
    if ([today isSameDay:dayEvent.date]) {
        // 今日のセクション
        label.textColor = RGBA(0, 116, 231, 1);
        label.shadowColor = [UIColor whiteColor];
    } else {
        // 今日以外
        label.textColor = [UIColor whiteColor];
        label.shadowColor = RGBA(0, 0, 0, 0.44);
    }
    
    [headerView addSubview:label];
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayEvent *dayEvent = [self dayEventAtSection:indexPath.section];
    if (dayEvent.events.count == 0) {
        return;
    }
    Event *event = [dayEvent.events objectAtIndex:indexPath.row];
    NSNumber *index = [_indexDict objectForKey:event.identifier];
    // 背景色をボーダー上にする
    if ([index intValue] % 2) {
        [cell setBackgroundColor:RGBA(240, 240, 240, 1)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableViewCellDidSelectAtIdexPath:indexPath];
}



#pragma mark ------------------------------------------
#pragma mark ------ ContainerCalendarOperation
#pragma mark ------------------------------------------

// カレンダーの再描画
- (void)reloadOperation
{
    [self reload];
}

// "今日"ボタンのオペレーション
- (void)todayButtonOperation
{
    // 選択中の月が今月ではない場合、今月に移動
    if (![[EventManager sharedManager].currentMonthEvent isThisMonth]) {
        
        NSDate *thisMonth = [NSDate localThisMonth];
        
        // 選択月を今月に変更する
        [[EventManager sharedManager] changeCurrentMonth:thisMonth withNotification:YES];
        
        // カレンダー情報をロードする
        [[OperationManager sharedManager].loadingOperation startLoading:thisMonth];
        
    }
    
    // 再描画
    [self reload];
    
    // "今日"にスクロールする
    [self scrollToToday];
}


@end


#pragma mark -

@implementation SectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0.2);
    CGRect r = CGRectMake(0, 21.6, 320, 0.4);
    CGContextAddRect(context,r);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
    CGRect r2 = CGRectMake(0, 0, 320, 0.4);
    CGContextAddRect(context,r2);
    CGContextStrokePath(context);
}

@end