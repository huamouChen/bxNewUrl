//
//  CHMTableViewController.m
//  MiniChat
//
//  Created by 陈华谋 on 01/05/2018.
//  Copyright © 2018 陈华谋. All rights reserved.
//

#import "CHMTableViewController.h"

@interface CHMTableViewController ()

@end

@implementation CHMTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭iOS11默认开启的self sizing
    [self closeSelfSizing];
}
- (void)closeSelfSizing {
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

@end
