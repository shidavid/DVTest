//
//  LiveTableDataSource.h
//  DVAVKitDemo
//
//  Created by mlgPro on 2020/4/10.
//  Copyright © 2020 DVUntilKit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - <-------------------- Protocol -------------------->
@class LiveTableDataSource;
@protocol LiveTableDelegate <NSObject>

- (void)LiveTable:(LiveTableDataSource *)liveTable didSelectItem:(NSString *)item;

@end


#pragma mark - <-------------------- Class -------------------->
@interface LiveTableDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

#pragma mark - <-- Property -->
@property(nonatomic, weak) UITableView *tableView;

@property(nonatomic, copy, readonly) NSString *identifier;
@property(nonatomic, strong) NSDictionary<NSString *, NSString *> *models;

@property(nonatomic, weak) id<LiveTableDelegate> delegate;


#pragma mark - <-- Initializer -->
- (instancetype)initWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
