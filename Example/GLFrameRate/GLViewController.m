//
//  GLViewController.m
//  GLFrameRate
//
//  Created by liguoliang on 08/07/2018.
//  Copyright (c) 2018 liguoliang. All rights reserved.
//

#import "GLViewController.h"

@interface GLViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView *tv;
@end

@implementation GLViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.tv.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1000;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CELL"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"row-%ld", indexPath.row];
    return cell;
}

- (UITableView *)tv {
    if(!_tv) {
        _tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tv.delegate = self;
        _tv.dataSource = self;
        [self.view addSubview:_tv];
    }
    return _tv;
}
@end
