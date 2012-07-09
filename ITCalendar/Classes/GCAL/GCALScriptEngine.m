//
//  GDScriptEngine.m
//  ITCalendar
//
//  Created by Kenji Furuno on 12/06/19.
//  Copyright (c) 2012年 Kenji Furuno. All rights reserved.
//

#import "GCALScriptEngine.h"
#import "SBJson.h"
#import "GCALResponse.h"
#import <TapkuLibrary/TapkuLibrary.h>
enum ConnectionState {
    kConnectionStateStopped     = 0,
    kConnectionStateConnecting,    // 接続中
    kConnectionStateConnected,     // 接続済み
};

@interface GCALScriptEngine ()
{
 @private
    UIWebView               *_webView;
    NSURL                   *_url;
}

@property (atomic, strong) NSDate *requestMonthDate;            // リクエスト月
@property (atomic) enum ConnectionState connectionState;

// カレンダーを取得するjavascriptをコールする
// YES: 成功
// NO: 失敗(network未接続)
- (BOOL)callJavascriptFunction:(NSDate *)fromDate toDate:(NSDate *)toDate;

// web viewをロードする
- (void)loadWebView;

- (void)didReceivedResponse:(NSURLRequest *)request;
- (void)didReceivedFailResponse:(NSURLRequest *)request;
@end

@implementation GCALScriptEngine

@synthesize delegate = _delegate;
@synthesize requestMonthDate = _requestMonthDate;
@synthesize connectionState = _connectionState;


#pragma mark ------------------------------------------
#pragma mark ------ init
#pragma mark ------------------------------------------
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    // webView settings
    _webView = [[UIWebView alloc] init];
    [_webView setDelegate:self];
    
    
    // ファイルからNSURL作成例
    _url = [NSURL fileURLWithPath:
                  [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"]];
    
    // web viewをロード
    [self loadWebView];
    
    return self;
}

- (void)dealloc
{
    // キー値監視の解除
    [self removeObserver:self forKeyPath:@"connectionState"];
}

#pragma mark ------------------------------------------
#pragma mark ------ private method
#pragma mark ------------------------------------------

// return
// YES: call OK
// NO: network NG
- (BOOL)callJavascriptFunction:(NSDate *)fromDate toDate:(NSDate *)toDate;
{
    
    LOG_METHOD;
    LOG(@"%@", [_webView.request.URL description]);
    
    // javascript functionを呼び出す
    NSString *script = [NSString stringWithFormat:@"loadCalendar('%@', '%@');",
                        [fromDate ITFormatStringOfDate],
                        [toDate ITFormatStringOfDate]];
    
    NSString *returnValue = [_webView stringByEvaluatingJavaScriptFromString:script];
    // "true"以外の場合はネットワーク未接続
    return [returnValue isEqualToString:@"true"];
}

// web viewをロードする
- (void)loadWebView
{
    // リクエストを送信する
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    // 接続中にする
    _connectionState = kConnectionStateConnecting;
    // 状態監視
    [self addObserver:self forKeyPath:@"connectionState" options:0 context:NULL];  
}

#pragma mark ------------------------------------------
#pragma mark ------ UIWebViewDelegate
#pragma mark ------------------------------------------
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"callback"]) {
        // callbackの場合
        [self didReceivedResponse:request];
        return NO;
    } else if ([[[request URL] scheme] isEqualToString:@"error"]) {
        // error
        [self didReceivedFailResponse:request];
        return NO;
    }

    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    LOG_METHOD;
    [self willChangeValueForKey:@"connectionState"];
    _connectionState = kConnectionStateConnected;
    [self didChangeValueForKey:@"connectionState"];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    LOG(@"%@", error.description);
    _connectionState = kConnectionStateStopped;
}
#pragma mark ------------------------------------------
#pragma mark ------ public method
#pragma mark ------------------------------------------
- (void)loadCalendarAtMonth:(NSDate*)monthDate
{
    LOG_METHOD;
    
    // リクエスト月を保持する
    // google calendar requestは、連続して送った場合、途中のリクエストのレスポンスが無い場合があるので
    // 後を優先する
    _requestMonthDate = monthDate;
    
    NSDate *nextMonth = [monthDate nextMonth];
    LOG(@"fromDate: %@ toDate: %@", [monthDate ITFormatStringOfDate], [nextMonth ITFormatStringOfDate]);
    
    // 接続済みの場合
    if (kConnectionStateConnected == _connectionState) {
        // javascript call
        if (![self callJavascriptFunction:monthDate toDate:nextMonth]) {
            // 失敗した場合は未接続にする
            _connectionState = kConnectionStateStopped;
            [self didReceivedFailResponse:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
        }
        return;
    }
    
    // 未接続の場合
    if (kConnectionStateStopped == _connectionState) {
        
        // ロードを開始する
        [self loadWebView];
        return;
    }
    
    
}

// _connectionStateの状態監視
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"connectionState"]) {
        
        // キー値監視の解除
        [self removeObserver:self forKeyPath:@"connectionState"];

        // javascript call
        NSDate *nextMonth = [_requestMonthDate nextMonth];
        // 接続失敗の場合
        if (![self callJavascriptFunction:_requestMonthDate toDate:nextMonth]) {
            _connectionState = kConnectionStateStopped;
            [self didReceivedFailResponse:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
        }
    }
}

#pragma mark ------------------------------------------
#pragma mark ------ GCALScriptEngineDelegate protocol
#pragma mark ------------------------------------------
- (void)didReceivedResponse:(NSURLRequest *)request
{
    
    // 受信した|request|からJSON形式(NSDicrionary)として
    // 結果を取り出して、GCALResponse オブジェクトを作成。
    // delegateを呼び出す

    if ([_delegate respondsToSelector:@selector(gcalScriptEngine:didReceivedResponse:)]) {
        
        // 非同期処理で結果解析
        dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(globalDispatchQueue, ^{
            
            NSString *url = [request URL].description;
            // scheme "callback:"を削除
            NSString *jsonString = [url substringFromIndex:9];
            // UTF-8 decode
            jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // JSONパース
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSError *error;
            NSDictionary *jsonResult = [parser objectWithString:jsonString error:&error];
            GCALResponse *gcalResponse = [[GCALResponse alloc] initWithGCALJson:jsonResult];
            
            // キューから取り出す
            [gcalResponse setRequestMonth:_requestMonthDate];
            
            // delegateへ通知
            [_delegate gcalScriptEngine:self didReceivedResponse:gcalResponse];
        });
    }
}

- (void)didReceivedFailResponse:(NSURLRequest *)request
{
    LOG_METHOD;
    NSString *errorDesription = [request URL].description;
    LOG(@"%@", errorDesription);
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"", errorDesription, nil];
    NSError *error = [[NSError alloc] initWithDomain:@"error" code:0 userInfo:userInfo];

    if ([_delegate respondsToSelector:@selector(gcalScriptEngine:didFailWithError:)]) {
        [_delegate gcalScriptEngine:self didFailWithError:error];
    }

}

@end
