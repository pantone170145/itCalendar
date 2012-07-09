//
//  ContainerCalendarViewController.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/17.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "ContainerCalendarViewController.h"
#import "MonthCalendarViewController.h"
#import "ListCalendarViewController.h"
#import "IndicatorView.h"
#import "EventManager.h"
#import "OperationManager.h"

enum SegmentedControll {
    kSegmentedControllList = 0,
    kSegmentedControllCalendar = 1,
};

@interface ContainerCalendarViewController ()
{
 @private
    UISegmentedControl          *_segmentedControll;
    
    UISearchBar                 *_searchBar;
    UIView                      *_searchBackgroundView;             // 検索バー表示中の背景ビュー
    NSString                    *_searchBarText;                    // 検索されたテキスト
    
    IndicatorView               *_indicatorView;

    GCALAsyncLoader             *_gcalAsyncLoader;
    
    // child view
    UIViewController<UISearchBarDelegate, ContainerCalendarOperation> *_currentController;
    MonthCalendarViewController *_monthCalendar;
    ListCalendarViewController  *_listCalendar;
}

// private method
- (void)initNavigationBar;
- (void)initToolbar;
- (void)addSubviewWithOffsetZero:(UIView *)view;
- (void)addSearchBackgroundView;
- (void)switchToController:(UIViewController *)newController;

// event
- (void)segmentedValueDidChange:(id)sender;
- (void)todayButtonDidClicked;
- (void)refleshButtonDidClicked;
- (void)searchBackgroundViewHandleTapGesture:(UITapGestureRecognizer *)sender;
- (void)searchBackgroundViewHandlePanGesture:(UIPanGestureRecognizer *)sender;

@end

@implementation ContainerCalendarViewController

#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------

- (id)init
{
    self = [super initWithNibName:@"ContainerCalendarViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    return self;
}

#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------
- (void)initNavigationBar
{
    // 検索バーを作成する
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    [_searchBar sizeToFit];
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.placeholder = @"検索 (スペース区切りでAND検索)";
    
    // テキストフィールド未入力時も検索ボタンを有効にする
    UITextField *searchTextField ;
    for (UIView *subview in _searchBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchTextField = (UITextField *)subview;
            searchTextField.enablesReturnKeyAutomatically = NO;
            break;
        }
    }
    
    [_searchBar setDelegate:self];
    
    self.navigationItem.titleView = _searchBar;
}

- (void)initToolbar
{
    // 今日--space--更新ボタン--space--segment(リスト/月)--space--アクティビティインジケータ
    
    // "今日"ボタン作成
    UIBarButtonItem *todayBarButton = [[UIBarButtonItem alloc] initWithTitle:@"今日"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(todayButtonDidClicked)];
    // 更新ボタン
    UIBarButtonItem *refleshBarButton = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                         target:self
                                         action:@selector(refleshButtonDidClicked)];
    [refleshBarButton setStyle:UIBarButtonItemStyleBordered];
    
    // space作成
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                              target:nil action:nil];
    
    // segment作成
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"リスト", @"月", nil]];
    [segment setSelectedSegmentIndex:1];
    [segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segment addTarget:self action:@selector(segmentedValueDidChange:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *barButtonItemSegment = [[UIBarButtonItem alloc] initWithCustomView:segment];
    
    // インジケータビュー作成
    _indicatorView = [[IndicatorView alloc] init];
    
    UIBarButtonItem *barButtonItemindicator = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
        
    // toolbarへ設定
    [self setToolbarItems:[NSArray arrayWithObjects:todayBarButton,
                           space,
                           refleshBarButton,
                           space,
                           barButtonItemSegment,
                           space,
                           barButtonItemindicator,
                           nil]
                 animated:NO];

}

- (void)addSubviewWithOffsetZero:(UIView *)view
{
    CGRect frame = view.frame;
    frame.size.height += frame.origin.y;
    frame.origin.y -= frame.origin.y;
    [view setFrame:frame];
    [self.view addSubview:view];
}

- (void)addSearchBackgroundView
{
    // 背景に、半透明のviewを配置する
    // タップ,パンでキーボードをキャンセルする
    _searchBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _searchBackgroundView.backgroundColor = [UIColor blackColor];
    _searchBackgroundView.alpha = 0.8;
    
    // タップ
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchBackgroundViewHandleTapGesture:)];  
    [_searchBackgroundView addGestureRecognizer:tapGesture];
    // パン
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(searchBackgroundViewHandlePanGesture:)];
    [_searchBackgroundView addGestureRecognizer:panGesture]; 
    
    // viewを追加
    [self.view addSubview:_searchBackgroundView];
    // 最前面に表示
    [self.view bringSubviewToFront:_searchBackgroundView];
}

- (void)switchToController:(UIViewController<UISearchBarDelegate, ContainerCalendarOperation> *)newController
{
    if (newController == _currentController) {
        return;
    }
    if (newController) {
        
        [self transitionFromViewController:_currentController
                          toViewController:newController 
                                  duration:0
                                   options:UIViewAnimationOptionTransitionNone 
                                animations:^{
                                    _currentController.view.alpha = 0;
                                    newController.view.alpha = 1.0f;
                                } 
                                completion:^(BOOL finished){
                                    // newViewControllerの追加完了応答
                                    [newController didMoveToParentViewController:self];
                                    _currentController = newController;
                                    [_currentController reloadOperation];
                                }];
        
    }
}


#pragma mark ------------------------------------------
#pragma mark ------ event
#pragma mark ------------------------------------------

- (void)segmentedValueDidChange:(id)sender
{
    UISegmentedControl *segmentedControll = (UISegmentedControl*)sender;
    
    // viewControllerの切り替え
    
    // selected segmented is list
    if (kSegmentedControllList == [segmentedControll selectedSegmentIndex]) {
        
        [self switchToController:_listCalendar];
        return;
    }
    // selected segmented is calendar    
    [self switchToController:_monthCalendar];
}

- (void)todayButtonDidClicked
{
    [_currentController todayButtonOperation];
}

- (void)refleshButtonDidClicked
{
    // 現在の選択月を再取得する
    NSDate *selectedMonthDate = [EventManager sharedManager].currentMonthEvent.monthDate;
    [[OperationManager sharedManager].loadingOperation startLoading:selectedMonthDate];
}

- (void)searchBackgroundViewHandleTapGesture:(UITapGestureRecognizer *)sender
{  
    [self searchBarCancelButtonClicked:_searchBar];
}

- (void)searchBackgroundViewHandlePanGesture:(UIPanGestureRecognizer *)sender
{
    [self searchBarCancelButtonClicked:_searchBar];
}

// currentMonthEvent
// 選択月の監視
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    LOG_METHOD;
    
    if ([keyPath isEqualToString:kCurrentMonthEvent]) {
        
        // メインスレッドから通知する
        dispatch_async(dispatch_get_main_queue(), ^{
            // 再描画
            [_currentController reloadOperation];

        });
    }
}

#pragma mark ------------------------------------------
#pragma mark ------ view life cycle
#pragma mark ------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // navigationbar初期化
    [self initNavigationBar];
    
    // toolbar初期化
    [self initToolbar];
    [[self navigationController] setToolbarHidden:NO];
    
    // childViewController作成
    _monthCalendar = [[MonthCalendarViewController alloc] initWithSunday:YES];
    _listCalendar = [[ListCalendarViewController alloc] init];
    
    // childViewController追加
    [self addChildViewController:_monthCalendar];
    [_monthCalendar didMoveToParentViewController:self];
    [self addChildViewController:_listCalendar];
    [_listCalendar didMoveToParentViewController:self];
    
    // default viewController is MonthCalendarViewController
    _currentController = _monthCalendar;
    [self addSubviewWithOffsetZero:_monthCalendar.view];
        
    // delegate設定
    [OperationManager sharedManager].loadingOperation.delegate = self;
    
    // 選択月イベントを監視
    [[EventManager sharedManager] addObserver:self forKeyPath:kCurrentMonthEvent options:0 context:NULL];
    
    // default 今月を選択する
    [[EventManager sharedManager] changeCurrentMonth:[NSDate localThisMonth] withNotification:YES];
    
    // 読み込み開始
    [[OperationManager sharedManager].loadingOperation startLoading:[NSDate localThisMonth]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // キー値監視の解除
    [self removeObserver:self forKeyPath:kCurrentMonthEvent];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ------------------------------------------
#pragma mark ------ UISearchBarDelegate
#pragma mark ------------------------------------------

// サーチバー検索イベント
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 背景ビューを削除
    [_searchBackgroundView removeFromSuperview];
    
    // 検索
    [[EventManager sharedManager] searchEventForWord:searchBar.text];
    
    // 結果更新
    [_currentController reloadOperation];
    
    // キャンセルボタンを隠す
    [searchBar setShowsCancelButton:NO animated:YES];
    
    // キーボードを隠す
    [searchBar resignFirstResponder];
}

// サーチバー検索キャンセルイベント
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    // キャンセル前の入力内容に戻す
    searchBar.text = _searchBarText;
    // 背景ビューを削除
    [_searchBackgroundView removeFromSuperview];
    
    // キャンセルボタンを隠す
    // memory leak?
    [searchBar setShowsCancelButton:NO animated:YES];
    // キーボードを隠す
    [searchBar resignFirstResponder];
}

// サーチバー編集開始イベント
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // 現在の入力内容を保持
    _searchBarText = searchBar.text;
    
    // キャンセルボタン表示
    [searchBar setShowsCancelButton:YES animated:YES];

    // 背景を追加する
    [self addSearchBackgroundView];
    
    return YES;
}

// サーチバー編集終了イベント
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark ------------------------------------------
#pragma mark ------ LoadingOperationDelegate
#pragma mark ------------------------------------------

- (void)operationWillStartLoading:(LoadingOperation *)operation
{
    // メインスレッドから通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        // ステータスバーのネットワーク接続を表示
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // インジケータビューの表示
        [_indicatorView startAnimation];
    });
}

- (void)operationDidFinishLoading:(LoadingOperation *)operation
{
    // メインスレッドから通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        // ステータスバーのネットワーク接続を非表示
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        // インジケータビューの非表示
        [_indicatorView stopAnimation];
    });
}

- (void)operation:(LoadingOperation *)operation didFailWithError:(NSError *)error
{
    // メインスレッドから通知する
    dispatch_async(dispatch_get_main_queue(), ^{
        // ステータスバーのネットワーク接続を非表示
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        // オフライン表示
        [_indicatorView showOfflineText];
    });
}



@end
