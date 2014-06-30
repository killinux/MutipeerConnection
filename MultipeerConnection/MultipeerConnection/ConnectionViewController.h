//
//  ConnectionViewController.h
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "AppDelegate.h"

@interface ConnectionViewController : UIViewController <MCBrowserViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UISwitch *swVisible;
@property (weak, nonatomic) IBOutlet UITableView *tableConnectedDevices;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification;

- (IBAction)browseForDevices:(id)sender;
- (IBAction)toggleVisibility:(id)sender;
- (IBAction)disconnect:(id)sender;

@end
