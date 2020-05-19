//
//  FGPrintFolderViewController.h
//  LMToolsKit
//
//  Created by MAC on 2018/1/5.
//  Copyright © 2018年 zhouhaoran. All rights reserved.
//

#import <UIKit/UIKit.h> 

@interface FGPrintFolderViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *send;
@property (strong, nonatomic) UIButton *clear;
@property (strong, nonatomic) NSString *subject;

- (void)printPath:(NSString *)path;
- (void)reloadPath;
- (void)clearFolder:(id)sender;

@end
