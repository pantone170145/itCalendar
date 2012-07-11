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


#define kSearchBarRectOfList CGRectMake(0, 0, 78, 44)
#define kSearchbarRectOfCalendar CGRectMake(0, 0, 100, 44)

enum SegmentedControll {
    kSegmentedControllList = 0,
    kSegmentedControllCalendar = 1,
};

@interface ContainerCalendarViewController ()
{
 @private
    UISearchBar                 *_searchBar;
    UIView                      *_searchBackgroundView;             // 検索バー表示中の背景ビュー
    NSString                    *_searchBarText;                    // 検索されたテキスト
    CGRect                      _searchBarOriginRect;
    
    UIImageView                 *_titleView;
    
    UISegmentedControl          *_segmentedControll;
    
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
- (void)layoutSearchBar;

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
    _searchBar = [[UISearchBar alloc] initWithFrame:kSearchbarRectOfCalendar];
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
    // ナビゲーションバー右アイテムに設定
    UIBarButtonItem *barButtonSearchBar = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
    self.navigationItem.rightBarButtonItem = barButtonSearchBar;

    // ヘッダービュー作成
    UIImage *image = [UIImage imageNamed:@"headerView_logo.png"];
    _titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = _titleView;

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
    _segmentedControll = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"リスト", @"月", nil]];
    [_segmentedControll setSelectedSegmentIndex:1];
    [_segmentedControll setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_segmentedControll addTarget:self action:@selector(segmentedValueDidChange:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *barButtonItemSegment = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControll];
    
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

- (void)layoutSearchBar
{
    // 選択中のセグメントに合わせて、検索バーをレイアウトする
    if (kSegmentedControllList == _segmentedControll.selectedSegmentIndex) {
        // リストの場合
        _searchBar.frame = kSearchBarRectOfList;
        return;
    }
    // カレンダーの場合
    _searchBar.frame = kSearchbarRectOfCalendar;
}


#pragma mark ------------------------------------------
#pragma mark ------ event
#pragma mark ------------------------------------------

- (void)segmentedValueDidChange:(id)sender
{
    UISegmentedControl *segmentedControll = (UISegmentedControl*)sender;

    // viewControllerの切り替え
    // および、検索バーのサイズ調整
    
    // selected segmented is list
    if (kSegmentedControllList == [segmentedControll selectedSegmentIndex]) {
        
        [self switchToController:_listCalendar];
        _searchBar.frame = kSearchBarRectOfList;
        return;
    }
    // selected segmented is calendar    
    [self switchToController:_monthCalendar];
    _searchBar.frame = kSearchbarRectOfCalendar;
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
    // サーチバーのサイズを保持する
    _searchBarOriginRect = self.navigationItem.titleView.frame;

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // タイトルビューを非表示
                         _titleView.alpha = 0;
                         _titleView.frame = CGRectMake(-320,
                                                       _searchBarOriginRect.origin.y,
                                                       _searchBarOriginRect.size.width,
                                                       _searchBarOriginRect.size.height);
                         // 検索バーのサイズ調整
                         [_searchBar setFrame:CGRectMake(5, 0, 310, 44)];
                     }
                     completion:NULL];
    
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
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // タイトルビューを表示
                         _titleView.alpha = 1.0;
                         self.navigationItem.titleView.frame = _searchBarOriginRect;
                         // 検索バーのサイズ調整
                         [self layoutSearchBar];
                     }
                     completion:NULL];
    
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
