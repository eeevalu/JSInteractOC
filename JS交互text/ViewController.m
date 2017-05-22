//
//  ViewController.m
//  JS交互text
//
//  Created by Eva on 16/11/24.
//  Copyright © 2016年 Eva. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface ViewController ()<UIWebViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"jsOC1" ofType:@"html"];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    webView.delegate = self;
    [self.view addSubview:webView];
}

//1、获取当前页面的url，。
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    JSContext *jsContext = [webView     valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *jsValue = [jsContext evaluateScript:@"showAppAlertMsg"];
    [jsValue callWithArguments:@[@"这是app本地交互文案"]];
    NSLog(@"currentURL ===%@\ntitle ===%@\njsValue ===%@",currentURL,title,jsValue);
    //定义好JS要调用的方法, share就是调用的share方法名
    jsContext[@"secondClick"] = ^() {
        NSLog(@"+++++++Begin Log+++++++");
        NSArray *args = [JSContext currentArguments];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"方式二" message:@"这是OC原生的弹出窗" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
            [alertView show];
        });
        
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal.toString);
        }
        
        NSLog(@"-------End Log-------");
    };
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL * url = [request URL];
    NSLog(@"urlScheme:%@",[url scheme]);
    if ([[url scheme] isEqualToString:@"firstclick"]) {
        NSArray *params =[url.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (NSString *paramStr in params) {
            NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
            if (dicArray.count > 1) {
                NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [tempDic setObject:decodeValue forKey:dicArray[0]];
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"方式一" message:@"这是OC原生的弹出窗" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"tempDic:%@",tempDic);
        return NO;
    }
    return YES;
}



//2、获取页面title：
//3、修改界面元素的值。

//NSString *js_result = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('q')[0].value='iOS';"];
//4、表单提交：

//NSString *js_result2 = [webView stringByEvaluatingJavaScriptFromString:@"document.forms[0].submit(); "];
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
