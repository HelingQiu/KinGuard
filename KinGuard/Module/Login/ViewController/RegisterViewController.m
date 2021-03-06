//
//  RegisterViewController.m
//  KinGuard
//
//  Created by Rainer on 16/5/4.
//  Copyright © 2016年 RuanSTao. All rights reserved.
//

#import "RegisterViewController.h"
#import "JKCountDownButton.h"
#import "UserModel.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField1;
@property (weak, nonatomic) IBOutlet UITextField *pwdField2;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"注册";
}

- (IBAction)getCode:(JKCountDownButton *)sender
{
    NSString *phone = self.usernameField.text;
    if ([JJSUtil isBlankString:phone]) {
        [JJSUtil showHUDWithMessage:@"请输入手机号码" autoHide:YES];
        return;
    }
    
    if (![self validateMobile:phone]) {
        [JJSUtil showHUDWithMessage:@"请输入正确的手机号码" autoHide:YES];
        return;
    }
    [JJSUtil showHUDWithWaitingMessage:@"正在发送验证码..."];
    [[KinGuartApi sharedKinGuard] catchSmsCodeWithMobile:phone withSmstype:@"0" success:^(NSDictionary *data) {
        [JJSUtil hideHUD];
        [JJSUtil showHUDWithMessage:@"发送成功" autoHide:YES];
        
        //按钮处理
        sender.enabled = NO;
        //button type要 设置成custom 否则会闪动
        [sender startWithSecond:60];
        
        [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
            NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
            return title;
        }];
        [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
            countDownButton.enabled = YES;
            return @"点击重新获取";
            
        }];
        
    } fail:^(NSString *error) {
        [JJSUtil hideHUD];
        [JJSUtil showHUDWithMessage:error autoHide:YES];
    }];
}

- (IBAction)regist:(id)sender
{
    NSString *phone = self.usernameField.text;
    NSString *pwd1 = self.pwdField1.text;
    NSString *pwd2 = self.pwdField2.text;
    NSString *code = self.codeField.text;
    
    if ([JJSUtil isBlankString:phone]) {
        [JJSUtil showHUDWithMessage:@"请输入手机号码" autoHide:YES];
        return;
    }
    if (![JJSUtil isMobileNumber:phone]) {
        [JJSUtil showHUDWithMessage:@"请输入11位手机号码" autoHide:YES];
        return;
    }
    if ([JJSUtil isBlankString:pwd1]) {
        [JJSUtil showHUDWithMessage:@"请输入密码" autoHide:YES];
        return;
    }
    if (pwd1.length < 6 || pwd1.length > 20) {
        [JJSUtil showHUDWithMessage:@"请输入6~20位密码" autoHide:YES];
        return;
    }
    if (![pwd1 isEqualToString:pwd2]) {
        [JJSUtil showHUDWithMessage:@"两次密码输入不一致" autoHide:YES];
        return;
    }
    if ([JJSUtil isBlankString:code]) {
        [JJSUtil showHUDWithMessage:@"请输入验证码" autoHide:YES];
        return;
    }
    
    [JJSUtil showHUDWithWaitingMessage:@"正在注册..."];
    [[KinGuartApi sharedKinGuard] registerAppAccountMobile:phone withPassword:pwd2 withSmscode:code success:^(NSDictionary *data) {
        [JJSUtil hideHUD];
        [JJSUtil showHUDWithMessage:@"注册成功" autoHide:YES];
        
        //登陆
        [self performSelector:@selector(login:) withObject:nil afterDelay:1];
    } fail:^(NSString *error) {
        [JJSUtil hideHUD];
        
        [JJSUtil showHUDWithMessage:error autoHide:YES];
    }];
}

- (void)login:(id)sender
{
    NSString *phone = self.usernameField.text;
    NSString *pwd = self.pwdField2.text;
    
    [[KinGuartApi sharedKinGuard] loginWithMobile:phone withPassword:pwd success:^(NSDictionary *data) {
        [JJSUtil hideHUD];
        [JJSUtil showHUDWithMessage:@"登陆成功" autoHide:YES];
        
        //跳转到主界面
        //存储登录信息
        UserModel *model = [[UserModel alloc] init];
        model.username = phone;
        model.password = pwd;
        model.token = [data objectForKey:@"logintoken"];
        model.isLogined = YES;
        
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:model];
        [JJSUtil storageDataWithObject:userData Key:KinGuard_UserInfo Completion:^(BOOL finish, id obj) {
            if (finish) {
                
                //注册别名推送
                [JPUSHService setAlias:model.username callbackSelector:nil object:nil];
                
                //跳转到主界面
                ViewController *viewController = [[ViewController alloc] init];
                self.view.window.rootViewController = viewController;
            }
        }];
        
    } fail:^(NSString *error) {
        [JJSUtil hideHUD];
        [JJSUtil showHUDWithMessage:error autoHide:YES];
    }];
}

- (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
