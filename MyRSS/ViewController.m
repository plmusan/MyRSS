//
//  ViewController.m
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import "ViewController.h"
#import "RSSDetailListController.h"
#import "RSS.h"
#import "RSSModel.h"
#import "RSSDao.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<RSSModel *> *datasource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _datasource = [NSMutableArray array];
    NSArray *arr = [RSS localRSSList];
    if (arr) {
        [_datasource addObjectsFromArray:arr];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (IBAction)addBtnClick:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加RSS订阅" message:@"请输入URL，然后点击确定按钮" preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *text = nil;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入URL";
        text = textField;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [RSS addRSSWithURL:url handler:^(RSSModel *rss) {
            if (rss) {
                if ([weakSelf.datasource containsObject:rss]) {
                    [weakSelf.datasource removeObject:rss];
                }
                [weakSelf.datasource insertObject:rss atIndex:0];
                [weakSelf.tableView reloadData];
            } else {
                
            }
        }];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    RSSModel *rss = _datasource[indexPath.row];
    cell.textLabel.text = rss.title;
    cell.detailTextLabel.text = rss.lastBuildDate;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSDetailListController *dc = [[RSSDetailListController alloc] init];
    dc.rss = _datasource[indexPath.row];
    [self.navigationController pushViewController:dc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RSSModel *mod = _datasource[indexPath.row];
        if ([RSS removeRSS:mod]) {
            [_datasource removeObject:mod];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
