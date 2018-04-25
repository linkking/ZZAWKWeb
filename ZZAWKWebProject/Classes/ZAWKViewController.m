//
//  ZAWKViewController.m
//  H5-Demo-wk
//
//  Created by zhulei on 2018/4/9.
//  Copyright © 2018年 zs. All rights reserved.
//

#import "ZAWKViewController.h"
#import <WebKit/WebKit.h>
#import "UtilsMacro.h"
#import "NSString+ZAURL.h"
#import "ZZAURLProtocol.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Aspects.h"
@interface ZAWKViewController()<WKNavigationDelegate,WKUIDelegate,
            WKScriptMessageHandler,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSString *webUrl;
@property (nonatomic,weak) CALayer *progressLayer;
@property (nonatomic,strong) NSString *filePath;

@end

@implementation ZAWKViewController

- (instancetype)initWithURL:(NSString *)loadingURL WithLocalFilePath:(NSString *)filePath
{
    self = [super init];
    if (self) {
        self.webUrl = loadingURL;
        self.filePath = filePath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
    [self setupProgress];
}

- (void)setupWebView
{
    [NSURLProtocol registerClass:[ZZAURLProtocol class]];
    //苹果私有API
    Class cls = NSClassFromString(@"WKBrowsingContextController");
        SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:@"myapp"];
#pragma clang diagnostic pop
        
    }
   
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.selectionGranularity = WKSelectionGranularityDynamic;
    config.allowsInlineMediaPlayback = YES;
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptEnabled = YES;
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preferences;
    
    //实现js互调
    WKUserContentController *user = [[WKUserContentController alloc]init];
    [user addScriptMessageHandler:self name:@"takePicturesByNative"];
    config.userContentController = user;
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) configuration:config];
    [self.view addSubview:self.webView];
    
    if (self.webUrl.length >=1) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[self.webUrl url]]];
    }
    if (self.filePath.length >=1) {
        NSString *htmlString = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)setupProgress {
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 3)];
    progressView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progressView];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = [UIColor greenColor].CGColor;
    [progressView.layer addSublayer:layer];
    
    self.progressLayer = layer;
}

#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if([change[@"new"] floatValue] < [change[@"old"] floatValue]){
            return;
        }
        self.progressLayer.frame = CGRectMake(0, 0, kScreen_Width*[change[@"new"] floatValue], 3);
        if ([change[@"new"] floatValue] == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    }else if ([keyPath isEqualToString:@"title"] )
    {
        self.title = change[@"new"];
    }
}
#pragma mark - WKUIDelegate
/* 在本Webview打开网址,如果返回的是原webview会崩溃 */
-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

//页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    
}

//页面开始返回内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

//页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
}

//页面加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error
{
    
}

//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //不允许跳转
//    decisionHandler(WKNavigationActionPolicyCancel);
}

//在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"URL = %@",navigationResponse.response.URL.absoluteString);
    decisionHandler(WKNavigationResponsePolicyAllow);

}
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"takePicturesByNative"]) {
        [self takePicturesByNative];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSTimeInterval timeInterval = [[NSDate date]timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",timeInterval];
    
    UIImage *image = [info  objectForKey:UIImagePickerControllerOriginalImage];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",timeString]];  //保存到本地
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    NSString *str = [NSString stringWithFormat:@"myapp://%@",filePath];
    [picker dismissViewControllerAnimated:YES completion:^{
        // oc 调用js 并且传递图片路径参数
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"getImg('%@')",str] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
        
    }];
}

#pragma mark - prive method
- (void)takePicturesByNative {
    UIImagePickerController *vc = [[UIImagePickerController alloc]init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
