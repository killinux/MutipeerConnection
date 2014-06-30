//
//  FirstViewController.h
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface FirstViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITextView *tvChat;

- (void)sendMyMessage;
- (void)didReceiveDataWithNotification:(NSNotification *)notification;

- (IBAction)sendMessage:(id)sender;
- (IBAction)cancelMessage:(id)sender;

@end
