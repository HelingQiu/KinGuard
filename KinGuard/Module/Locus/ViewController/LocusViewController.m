//
//  LocusViewController.m
//  KinGuard
//
//  Created by RuanSTao on 16/5/4.
//  Copyright © 2016年 RuanSTao. All rights reserved.
//

#import "LocusViewController.h"
#import "DeviceInfo.h"
#import "RtOutputView.h"
#import "LocationInfo.h"
#import "DeviceAnnotationView.h"

@interface LocusViewController ()<MAMapViewDelegate>

@property (strong, nonatomic) IBOutlet MAMapView *mapView;

@property (nonatomic,strong) NSArray *pids;  // pids 数组

@property (nonatomic,strong) NSArray *info; //所以宝贝信息

@property (nonatomic,assign) NSInteger showIndex; //当前显示宝贝index

@property (strong, nonatomic) IBOutlet UIButton *headerTitle;

@property (nonatomic,strong) LocationInfo *currentLocation;

@end

@implementation LocusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self requestData];
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
- (IBAction)leftButtonAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:Show_LeftMenu object:nil];
}


- (void)initUI
{
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
}

- (void)refreshUI
{
    if (self.info.count > 0) {
        DeviceInfo *info = self.info[self.showIndex];
        [self.headerTitle setTitle:info.asset_name forState:UIControlStateNormal];
        //开始定位
//        [[KinLocationApi sharedKinLocation] startNormalLocation:info.asset_id success:^(NSDictionary *data) {
//            NSLog(@"%@",data);
//        } fail:^(NSString *error) {
//            NSLog(@"%@",error);
//        }];
        
        [[KinLocationApi sharedKinLocation]readLocationInfo:info.asset_id success:^(NSDictionary *data) {
            
            NSLog(@"%@",data);
            self.currentLocation = [LocationInfo mj_objectWithKeyValues:data];
            [self beginLocation];
        } fail:^(NSString *error) {
            
            NSLog(@"%@",error);
        }];
    }
    
}

- (void)requestData
{
    [[KinDeviceApi sharedKinDevice] deviceListSuccess:^(NSDictionary *data) {
        NSLog(@"%@",data);
        self.pids = @[[data objectForKey:@"pids"]?:@[]];
        if (self.pids.count> 0) {
            NSMutableArray *infoArr = [NSMutableArray array];
            for (NSString *pid in self.pids) {
                [self requestDeviceInfo:pid finish:^(DeviceInfo *info) {
                    [infoArr addObject:info];
                    if (infoArr.count == self.pids.count) {
                        self.info = infoArr;
                        [self refreshUI];
                    }
                }];
            }
        }
    } fail:^(NSString *error) {
        NSLog(@"%@",error);
    }];
}

- (void)requestDeviceInfo:(NSString *)pid finish:(void (^)(DeviceInfo *info))block
{
    [[KinDeviceApi sharedKinDevice] deviceInfoPid:pid success:^(NSDictionary *data) {
         NSLog(@"%@",data);
        if (block) {
            block([DeviceInfo mj_objectWithKeyValues:data]);
        }
    } fail:^(NSString *error) {
         NSLog(@"%@",error);
    }];
    
}


#pragma mark - headTItle
- (IBAction)HeadButtonAction:(UIButton *)sender
{
    NSMutableArray *dataArr = [NSMutableArray array];
    for (DeviceInfo *info in self.info) {
        RtCellModel *model = [[RtCellModel alloc] initWithTitle:info.asset_name imageName:@""];
        [dataArr addObject:model];
    }
    CGFloat x = sender.center.x;
    CGFloat y = CGRectGetMaxY(sender.frame) + 20;
    RtOutputView * outputView = [[RtOutputView alloc] initWithDataArray:dataArr origin:CGPointMake(x, y) width:125 height:44 direction:kRtOutputViewDirection_Middle];

    outputView.didSelectedAtIndexPath = ^(NSIndexPath *index){
        self.showIndex = index.row;
        [self refreshUI];
    };
    
    outputView.dismissWithOperation = ^(){
    //设置成nil，以防内存泄露
    };
    [outputView pop];


}

#pragma mark - <MAMapViewDelegate>

- (void)beginLocation
{
//    self.mapView.showsUserLocation = YES;
    
//    DeviceInfo *info = self.info[self.showIndex];
    MAPointAnnotation *pointAnno = [[MAPointAnnotation alloc] init];
    pointAnno.title = self.currentLocation.addr;
    pointAnno.subtitle = [JJSUtil timeDateFormatter:[NSDate dateWithTimeIntervalSince1970:self.currentLocation.timestamp] type:10];
    pointAnno.coordinate = CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude);
    [self.mapView addAnnotation:pointAnno];
    self.mapView.region = MACoordinateRegionMake(CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude), MACoordinateSpanMake(0.1, 0.1));
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.currentLocation.latitude, self.currentLocation.longitude) animated:YES];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    DeviceAnnotationView *annotaionView = [[DeviceAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MainAnotation"];
//    annotaionView.image = [UIImage imageNamed:@"father"];
    annotaionView.canShowCallout = YES;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    UIView *right = [[UIView alloc] init];
    leftView.backgroundColor = [UIColor blueColor];
    right.backgroundColor = [UIColor yellowColor];
    annotaionView.leftCalloutAccessoryView = leftView;
    annotaionView.rightCalloutAccessoryView = right;
    annotaionView.locationInfo = self.currentLocation;
    return annotaionView;
}

#pragma mark - 定位当前位置
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
}
- (IBAction)userLocationAction:(id)sender {
    [self.mapView addAnnotation:self.mapView.userLocation];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}
@end
