//
//  LiveView.m
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import "LiveListView.h"

@implementation LiveListView

#pragma mark - <--  -->
- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}


@end
