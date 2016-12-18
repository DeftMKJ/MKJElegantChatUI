//
//  ViewController.m
//  JSQChatUI
//
//  Created by MKJING on 2016/12/16.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "ViewController.h"
#import "SettingTableViewCell.h"
#import "SettingModel.h"
#import "MKJChatViewcontroller.h"

#define kScreen_Witdh [UIScreen mainScreen].bounds.size.width
#define kScreen_Height [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *settingDatas;

@end

static NSString * identifySettingID = @"SettingTableViewCell";
static NSString * identifyPushID = @"PushChatCell";


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Witdh, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:identifySettingID bundle:nil] forCellReuseIdentifier:identifySettingID];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifyPushID];
    
    [self configData];
}


- (void)configData
{
    NSArray *settings = @[@"发送长文本消息",@"右侧AssoryButon已停用",@"开启接受消息头像",@"开启发送消息头像",@"动态Bubbles"];
    for (NSInteger i = 0; i < 5; i ++)
    {
        SettingModel *model = [[SettingModel alloc] init];
        model.title = settings[i];
        if (i == 2 || i == 3)
        {
            model.isOpen = YES;
        }
        else
        {
            if (i == 0)
            {
                model.isOpen = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kLongMessages"] boolValue];
            }
            else if (i ==1)
            {
                model.isOpen = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kRightMediaButton"] boolValue];
            }
            else
            {
                model.isOpen = [[[NSUserDefaults standardUserDefaults] valueForKey:@"kDynamic"] boolValue];
            }
            
        }
        [self.settingDatas addObject:model];
    }
    [self.tableView reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        return 5;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingModel *model = self.settingDatas[indexPath.row];
    
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifyPushID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Go to Elegant chat UI";
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }
    else
    {
        
        SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifySettingID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.rightSwitch.userInteractionEnabled = NO;
        cell.settingLabel.text = model.title;
        [cell.rightSwitch setOn:model.isOpen animated:YES];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingModel *model = self.settingDatas[indexPath.row];
    if (indexPath.section == 0)
    {
        MKJChatViewcontroller *chat = [[MKJChatViewcontroller alloc] init];
        [self.navigationController pushViewController:chat animated:YES];
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                model.isOpen = !model.isOpen;
                [[NSUserDefaults standardUserDefaults] setBool:model.isOpen forKey:@"kLongMessages"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                break;
            case 1:
                model.isOpen = !model.isOpen;
                [[NSUserDefaults standardUserDefaults] setBool:model.isOpen forKey:@"kRightMediaButton"];
                break;
            case 2:
                model.isOpen = YES;
                [[NSUserDefaults standardUserDefaults] setBool:model.isOpen forKey:@"kRevMessage"];
                break;
            case 3:
                model.isOpen = YES;
                [[NSUserDefaults standardUserDefaults] setBool:model.isOpen forKey:@"kSendMessage"];
                break;
            case 4:
                model.isOpen = !model.isOpen;
                [[NSUserDefaults standardUserDefaults] setBool:model.isOpen forKey:@"kDynamic"];
                break;
                
            default:
                break;
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];
    }
}



- (NSMutableArray *)settingDatas
{
    if (_settingDatas == nil) {
        _settingDatas = [[NSMutableArray alloc] init];
    }
    return _settingDatas;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
