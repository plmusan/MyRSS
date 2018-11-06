//
//  LoginController.m
//  MyPhoto
//
//  Created by x.wang on 2017/10/20.
//  Copyright © 2017年 x.wang. All rights reserved.
//

#import "LoginController.h"
#import "RSS.h"

@interface LoginController ()

@property (nonatomic, strong) UITextField *textfield;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@end

@implementation LoginController

- (UITextField *)textfield {
    if (!_textfield) {
        _textfield = [[UITextField alloc] init];
        _textfield.placeholder = @"";
        _textfield.keyboardType = UIKeyboardTypeDecimalPad;
        _textfield.borderStyle = UITextBorderStyleRoundedRect;
        _textfield.textAlignment = NSTextAlignmentCenter;
        _textfield.secureTextEntry = YES;
    }
    return _textfield;
}

- (NSMutableDictionary *)userInfo {
    if (!_userInfo) {
        id temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLoginControllerUserInfo"];
        if ([temp isKindOfClass:[NSMutableDictionary class]]) {
            _userInfo = temp;
        } else {
            _userInfo = [NSMutableDictionary dictionary];
        }
    }
    return _userInfo;
}

- (void)saveUserInfo {
    [[NSUserDefaults standardUserDefaults] setObject:self.userInfo forKey:@"kLoginControllerUserInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, width-100, 30)];
    label.text = @"输入密码，查看文件";
    label.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:label];
    
    self.textfield.frame = CGRectMake(50, 150, width-100, 30);
    [self.view addSubview:self.textfield];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, width-200, 40)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.cornerRadius = 5;
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *del = [[UIButton alloc] initWithFrame:CGRectMake(width-150, 260, 100, 30)];
    [del setTitle:@"删除密码" forState:UIControlStateNormal];
    [del setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    del.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [del addTarget:self action:@selector(delPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:del];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.userInfo.count == 0) {
        [self showPwd:@"请输入初始密码"];
    }
}

- (void)showPwd:(NSString *)msg {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入密码";
        textField.frame = CGRectMake(0, 0, 300, 40);
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf pwd:alert.textFields];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)pwd:(NSArray<UITextField *> *)textFields {
    NSString *key1 = [textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *key2 = [textFields.lastObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (key1.length>0 && [key1 isEqualToString:key2]) {
        self.userInfo[@"pwd"] = key1;
        [self saveUserInfo];
    } else {
        [self showPwd:@"输入有误，请重新输入！"];
    }
}

- (void)buttonPressed:(id)sender {
    [self.view endEditing:YES];
    if ([self.textfield.text isEqualToString:self.userInfo[@"pwd"]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        self.textfield.text = @"";
    }
}

- (void)delPressed:(id)sender {
    [self.view endEditing:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"删除密码会导致所有文件被删除，确认删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf removePwd];
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)removePwd {
    [self.userInfo removeAllObjects];
    [RSS removeAllRSS];
    [self saveUserInfo];
    [self showPwd:@"请输入初始密码"];
}

@end
