//
//  SecondViewController.h
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSMutableArray *arrFiles;
@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic) NSInteger selectedRow;

@property (weak, nonatomic) IBOutlet UITableView *tableFiles;

- (void)copySampleFilesToDocDirIfNeeded;
- (NSArray *)getAllDocDirFiles;
- (void)didStartReceivingResourceWithNotification:(NSNotification *)notification;
- (void)updateReceivingResourceWithNotification:(NSNotification *)notification;
- (void)didFinishreceivingResourceNotification:(NSNotification *)notification;

@end
