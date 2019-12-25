//
//  SubViewController.m
//  HYNavigation
//
//  Created by whoami on 2019/12/25.
//  Copyright © 2019 Pengcent. All rights reserved.
//

#import "SubViewController.h"

@interface SubViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SubViewController

+ (instancetype)create {
    return [[SubViewController alloc] initWithNibName:@"SubViewController" bundle:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.textColor = UIColor.blackColor;
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end
