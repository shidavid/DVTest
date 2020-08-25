//
//  LiveViewController.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LiveListViewController.h"
#import "LiveListView.h"
#import "LiveListViewModel.h"
#import "LiveTableDataSource.h"

@interface LiveListViewController () <LiveTableDelegate>

@property(nonatomic, strong) LiveListView *listView;

@property(nonatomic, strong) LiveListViewModel *listViewModel;
@property(nonatomic, strong) LiveTableDataSource *tableDataSource;

@end

@implementation LiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self initViews];
    [self initModels];
    [self loadData];
}


#pragma mark - <-- Init -->
- (void)initViews {
    self.listView = (LiveListView *)self.view;
}

- (void)initModels {
    self.listViewModel = [[LiveListViewModel alloc] init];
    
    self.tableDataSource = [[LiveTableDataSource alloc] initWithTableView:self.listView.tableView];
    self.tableDataSource.delegate = self;
}

- (void)loadData {
    self.tableDataSource.models = self.listViewModel.tableItems;
    
//    self.listView.liveURLText.text = @"rtmp://192.168.3.57:1935/live/stream";
//    self.listView.liveURLText.text = @"rtmp://192.168.3.57:1935/live/pc";
//    self.listView.liveURLText.text = @"rtsp://192.168.5.24:11554/chn=1/type=0";
    self.listView.liveURLText.text = @"rtmp://mdvr.meiligao.org:27010/live/0861585042696425_CH1_AV_LIVE";
}


#pragma mark - <-- Delegate -->
- (void)LiveTable:(LiveTableDataSource *)liveTable didSelectItem:(NSString *)item {
    
    Class class = NSClassFromString(item);
    if (!class) return;
    
    __kindof UIViewController *vc = [[class alloc] init];
    [vc setValue:self.listView.liveURLText.text forKey:@"url"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
