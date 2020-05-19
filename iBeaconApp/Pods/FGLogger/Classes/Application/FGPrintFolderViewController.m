//
//  FGPrintFolderViewController.m
//  LMToolsKit
//
//  Created by MAC on 2018/1/5.
//  Copyright © 2018年 zhouhaoran. All rights reserved.
//

#import "FGPrintFolderViewController.h"
#import "FGFileContext.h"
#import "FGLoggerComponent.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface FGPrintFolderViewController () <UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *contexts;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *lastPath;
@property (strong, nonatomic) NSString *genPath;
@end

@implementation FGPrintFolderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.subject = @"ios缓存文件目录";
    if (@available(iOS 11, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableView];
    [self send];
    [self layoutNavigationBar];
    [self clear];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    [self reloadPath];
}

- (void)printPath:(NSString *)path
{
    _path = path;
    _lastPath = nil;
    _genPath = path;
    [self reloadPath];
}

- (void)btnClickBackToPrevPage {
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)reloadPath
{
    self.navigationItem.rightBarButtonItem = nil;
    if(!self.lastPath)
    {
        self.send.hidden = YES;
    }
    else
    {
        self.send.hidden = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.clear];
    
    if(![self.refreshControl isRefreshing])
        [self.refreshControl beginRefreshing];
    self.contexts = [self logsContext];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)clearFolder:(id)sender
{
    NSMutableArray *contexts = [self logsContext];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (FGFileContext *context in contexts) {
        [fileManager removeItemAtPath:context.filePath error:nil];
    }
    [self reloadPath];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0)
    {
        if(self.lastPath.length > 1 &&self.lastPath)
        {
            return 1;
        }
        return 0;
    }
    
    return self.contexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.section == 0)
    {
        cell.textLabel.text = @"......";
        cell.detailTextLabel.text = @"返回上一级";
        cell.textLabel.textColor = [UIColor blueColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        FGFileContext *context = self.contexts[indexPath.row];
        cell.textLabel.text = context.fileName;
        cell.textLabel.textColor = [UIColor blackColor];
        if (context.fileType&&[context.fileType isEqualToString:@"dic"])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            float filesize = [FGFileContext folderSizeAtPath:context.filePath];
            if(filesize<0)
            {
                cell.detailTextLabel.text = @"没有权限";
            }
            else
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [FGFileContext fileSizeDescription:filesize]];
            }
            
        } else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [FGFileContext fileSizeDescription:(NSUInteger)(context.fileSize)]];
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        if(self.lastPath.length > 1 &&self.lastPath)
        {
            self.path = [self.lastPath mutableCopy];
            self.lastPath = [self.lastPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",self.lastPath.lastPathComponent] withString:@""];
            
            if([self.path isEqualToString:self.genPath]||[[NSString stringWithFormat:@"%@/",self.path] isEqualToString:self.genPath])
            {
                self.lastPath = nil;
            }
            [self reloadPath];
        }
        return;
    }
    
    FGFileContext *context = self.contexts[indexPath.row];
    if (context.fileType&&[context.fileType isEqualToString:@"dic"])
    {
        self.lastPath = [self.path mutableCopy];
        self.path = context.filePath;
        [self reloadPath];
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:context.filePath];
    UIDocumentInteractionController *_docVc = [UIDocumentInteractionController interactionControllerWithURL:url];
    _docVc.delegate = self;
    [_docVc presentPreviewAnimated:YES];
    
}


#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}


- (UITableView *)tableView
{
    if(!_tableView)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, statusBarHeight+44, frame.size.width, frame.size.height - statusBarHeight - 44 - 44) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(reloadPath) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:self.refreshControl];
    }
    
    return _tableView;
}


- (void)layoutNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.title = @"查看文件夹";
}

- (NSMutableArray *)logsContext
{
    NSMutableArray *logsContext = [[NSMutableArray alloc]init];
    NSFileManager *fileManger=[NSFileManager defaultManager];
    NSArray *directory = [fileManger contentsOfDirectoryAtPath:self.path error:nil];
    
    NSArray *sortArray = [directory sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        return [obj2 compare:obj1];
    }];
    
    for (NSString *path in sortArray) {
        if([path isEqualToString:@".DS_Store"])
        {
            continue;
        }
        FGFileContext *context =[[FGFileContext alloc]init];
        context.fileName = path;
        context.filePath = [self.path stringByAppendingPathComponent:path];
        BOOL isdic = NO;
        [fileManger fileExistsAtPath:context.filePath isDirectory:&isdic];
        if(isdic)
        {
            context.fileType = @"dic";
        }
        [logsContext addObject:context];
    }
    
    return logsContext;
}

- (NSMutableArray *)sendLogsContext:(NSString *)searchPath
{
    NSMutableArray *logsContext = [[NSMutableArray alloc]init];
    NSFileManager *fileManger=[NSFileManager defaultManager];
    NSArray *directory = [fileManger contentsOfDirectoryAtPath:searchPath error:nil];
    
    for (NSString *path in directory) {
        if([path isEqualToString:@".DS_Store"])
        {
            continue;
        }
        NSString *fullPath = [searchPath stringByAppendingPathComponent:path];
        BOOL isdic = NO;
        [fileManger fileExistsAtPath:fullPath isDirectory:&isdic];
        if(isdic)
        {
            NSMutableArray *array = [self sendLogsContext:fullPath];
            [logsContext addObjectsFromArray:array];
        }
        else
        {
            [logsContext addObject:fullPath];
        }
    }
    
    return logsContext;
}

- (void)send:(UIButton *)sender
{
    if(![MFMailComposeViewController canSendMail]){
        [sender setBackgroundColor:[UIColor darkGrayColor]];
        return;
    }
    NSMutableArray *logs = [self sendLogsContext:self.path];
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:self.subject];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [controller setMessageBody:[NSString stringWithFormat:@"目录：%@， 发送时间%@",[self.path lastPathComponent],[df stringFromDate:[NSDate date]]] isHTML:NO];
    for (NSString *filePath in logs) {
        [controller addAttachmentData:[NSData dataWithContentsOfFile:filePath] mimeType:@"text/plain" fileName:[filePath lastPathComponent]];
        
    }
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (UIButton *)send
{
    if(!_send)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        UIButton *send = [[UIButton alloc]init];
        send.frame = CGRectMake(0, frame.size.height - 44, frame.size.width, 44);
        [send setBackgroundColor:[UIColor blueColor]];
        [send addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
        [send setTitle:@"发送到邮箱" forState:UIControlStateNormal];
        [send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:send];
        _send = send;
    }
    
    return _send;
}

- (UIButton *)clear
{
    if(!_clear)
    {
        UIButton *clear = [UIButton buttonWithType:UIButtonTypeCustom];
        [clear setFrame:CGRectMake(0,0, 44, 40)];
        [clear setTitle:@"清空" forState:UIControlStateNormal];
        [clear setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [clear addTarget:self action:@selector(clearFolder:) forControlEvents:UIControlEventTouchUpInside];
        _clear = clear;
    }
    return _clear;
}

@end

