//
//  CHMFunctionController.m
//  MiniChat
//
//  Created by 陈华谋 on 2018/5/9.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMFunctionController.h"
#import <WebKit/WebKit.h>

@interface CHMFunctionController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CHMFunctionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"功能介绍";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"introduce" ofType:@"html"];
    NSURL *url = [NSURL URLWithString:filePath];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
