//
//  ViewController.m
//  Demo
//
//  Created by Jiao Liu on 11/19/13.
//  Copyright (c) 2013 Jiao Liu. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Utility.h"
#import <Parse/Parse.h>
#import "Reachability.h"

#define SCREEN_WIDTH        [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT       [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()
{
    UITextField *textfield;
    UITextField *nameInput;
    UILabel *nameLabel;
    UIButton *send;
    
    UITableView *messageTable;
    NSMutableArray *_chatData;
    
    UILabel *inMsg;
    UILabel *outMsg;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH  - 150, 50, 40, 30)];
    nameLabel.text = @"ID :";
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:nameLabel];
    
    nameInput = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 50, 90, 30)];
    nameInput.layer.borderWidth = 1;
    nameInput.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nameInput.delegate = self;
    [self.view addSubview:nameInput];
    
    textfield = [[UITextField alloc] initWithFrame:CGRectMake(10, nameInput.frame.origin.y + nameInput.frame.size.height + 10, SCREEN_WIDTH - 20, 30)];
    textfield.backgroundColor = [UIColor clearColor];
    textfield.layer.borderWidth = 1;
    textfield.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textfield.layer.cornerRadius = 2;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.delegate = self;
    [self.view addSubview:textfield];
    
    send = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, textfield.frame.origin.y + textfield.frame.size.height + 10, 50, 30)];
    send.backgroundColor = [UIColor lightGrayColor];
    send.layer.borderWidth = 1;
    send.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [send setTitle:@"Send" forState:UIControlStateNormal];
    [send setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [send setBackgroundImage:[UIImage generateColorImage:[UIColor grayColor] size:send.frame.size] forState:UIControlStateNormal];
    [send addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:send];
    
    messageTable = [[UITableView alloc] initWithFrame:CGRectMake(10, send.frame.origin.y + send.frame.size.height + 20, SCREEN_WIDTH - 20, SCREEN_HEIGHT - (send.frame.origin.y + send.frame.size.height + 20) - 10)];
    messageTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    messageTable.delegate = self;
    messageTable.dataSource = self;
    messageTable.scrollEnabled = YES;
    messageTable.rowHeight = 60;
    messageTable.layer.borderWidth = 1;
    messageTable.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:messageTable];
    
    _chatData = [[NSMutableArray alloc] init];
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        NSLog(@"%u",[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify" message:@"Can't connect to Internet" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadChatMsg) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadChatMsg
{
    /*NSString *urlString = @"http://192.168.3.166:8888/";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSData *data;
    NSError *error;
    NSURLResponse *response;
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *finalData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _dict = [[NSDictionary alloc] initWithObjectsAndKeys:finalData, @"msg", @"0", @"index", @"out", @"status",nil];
    NSLog(@"%@",finalData);
    NSLog(@"%@",_dict);
    [messageTable reloadData];*/
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Wechat"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_chatData removeAllObjects];
        [_chatData addObjectsFromArray:objects];
        [messageTable reloadData];
        if (messageTable.contentSize.height > messageTable.frame.size.height) {
            [messageTable setContentOffset:CGPointMake(0, messageTable.contentSize.height - messageTable.frame.size.height) animated:YES];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [nameInput resignFirstResponder];
    [textField resignFirstResponder];
    return YES;
}

- (void)send
{
    if ([nameInput.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notify" message:@"Plz input an ID" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        PFObject *sendObjects = [PFObject objectWithClassName:@"Wechat"];
        [sendObjects setObject:[NSString stringWithFormat:@"%@ : %@", nameInput.text,textfield.text] forKey:@"msg"];
        [sendObjects setObject:nameInput.text forKey:@"name"];
        [sendObjects saveInBackground];
        textfield.text = nil;
        [self textFieldShouldReturn:textfield];
        [messageTable reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chatData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = [NSString stringWithFormat:@"MsgCell%ld",(long)indexPath.row];
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    inMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-40, 40)];
    [inMsg setTextAlignment:NSTextAlignmentRight];
    inMsg.font = [UIFont systemFontOfSize:14];
    inMsg.textColor = [UIColor blueColor];
    [cell.contentView addSubview:inMsg];
    outMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-40, 40)];
    outMsg.textColor = [UIColor grayColor];
    [outMsg setTextAlignment:NSTextAlignmentLeft];
    outMsg.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:outMsg];
    
    if (![nameInput.text isEqualToString:@""]) {
        if ([[[_chatData objectAtIndex:indexPath.row] objectForKey:@"name"] isEqualToString:nameInput.text]) {
        outMsg.text = [[_chatData objectAtIndex:indexPath.row] objectForKey:@"msg"];
    
        }
        else inMsg.text = [[_chatData objectAtIndex:indexPath.row] objectForKey:@"msg"];
    }
    return cell;
}

- (void)dealloc
{
    [messageTable release];
    [_chatData release];
    [inMsg release];
    [outMsg release];
    [textfield release];
    [send release];
    [nameInput release];
    [nameLabel release];
    [super dealloc];
}

@end
