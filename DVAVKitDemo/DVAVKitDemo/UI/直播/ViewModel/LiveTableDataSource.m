//
//  LiveTableDataSource.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LiveTableDataSource.h"

@interface LiveTableDataSource ()

@property(nonatomic, strong) NSArray<NSString *> *keys;

@end


@implementation LiveTableDataSource

#pragma mark - <-- Initializer -->
- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.identifier];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)dealloc{
    _models = nil;
    _delegate = nil;
    
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}


#pragma mark - <-- Property -->
- (NSString *)identifier {
    return @"cell";
}

- (void)setModels:(NSDictionary<NSString *,NSString *> *)models {
    _models = models;
    _keys = models.allKeys;
    
    if (self.tableView) [self.tableView reloadData];
}


#pragma mark - Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.keys ? self.keys.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier
                                                            forIndexPath:indexPath];
    
    if (cell && self.keys && indexPath.row < self.keys.count) {
        cell.textLabel.text = self.keys[indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.delegate && self.keys && indexPath.row < self.keys.count) {
        NSString *key = self.keys[indexPath.row];
        NSString *value = self.models[key];
        [self.delegate LiveTable:self didSelectItem:value];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

@end
