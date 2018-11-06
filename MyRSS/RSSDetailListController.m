//
//  RSSDetailListController.m
//  MyRSS
//
//  Created by x.wang on 2018/11/6.
//  Copyright © 2018 x.wang. All rights reserved.
//

#import "RSSDetailListController.h"
#import "RSSDetailController.h"
#import "RSS.h"
#import "RSSModel.h"

@interface RSSDetailListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RSSDetailListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _rss.title;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    if (!_rss.item.count) {
        _rss = [RSS modelListWithRSS:_rss];
        [_tableView reloadData];
    }
    
    [RSS refreshRSSData:_rss handler:^{
        [_tableView reloadData];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rss.item.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    RSSItem *rss = _rss.item[indexPath.row];
    cell.textLabel.text = rss.title;
    cell.detailTextLabel.text = rss.lastBuildDate;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSDetailController *dc = [[RSSDetailController alloc] init];
    dc.item = _rss.item[indexPath.row];
    [self.navigationController pushViewController:dc animated:YES];
}

@end
