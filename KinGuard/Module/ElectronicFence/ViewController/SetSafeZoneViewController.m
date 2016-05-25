//
//  SetSafeZoneViewController.m
//  KinGuard
//
//  Created by Rainer on 16/5/24.
//  Copyright © 2016年 RuanSTao. All rights reserved.
//

#import "SetSafeZoneViewController.h"
#import "ElectronicVM.h"
#import "SafeDetailTableViewCell.h"

typedef enum: NSInteger{
    areaName,
    inAreaTime,
    outAreaTime,
    vilableDate
}SafeCellType;

@interface SetSafeZoneViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) NSMutableArray *dataSource;

@property(nonatomic, strong) UITableView *safeTableView;

@end

@implementation SetSafeZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"安全区域";
    [self getData];
    [self initilizeBaseView];
}

- (void)getData
{
    self.dataSource = [ElectronicVM fitterDataWith:self.safeModel];
}

- (void)initilizeBaseView
{
    self.safeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, mScreenWidth, mScreenHeight) style:UITableViewStylePlain];
    self.safeTableView.dataSource = self;
    self.safeTableView.delegate = self;
    self.safeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.safeTableView.tableFooterView = [UIView new];
    self.safeTableView.backgroundColor = [UIColor colorWithRed:244/255.0 green:243/255.0 blue:239/255.0 alpha:1];
    [self.view addSubview:self.safeTableView];
}

#pragma mark ---
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rowArray = [self.dataSource objectAtIndex:section];
    return rowArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SafeDetailTableViewCell *cell = [SafeDetailTableViewCell cellForTableView:tableView];
    NSArray *rowArray = [self.dataSource objectAtIndex:indexPath.section];
    NSDictionary *body = [rowArray objectAtIndex:indexPath.row];
    [cell.labTitle setText:[body objectForKey:@"title"]];
    [cell.labContent setText:[body objectForKey:@"value"]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end