//
//  FirstViewController.m
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	self.txtMessage.delegate = self;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveDataWithNotification:) name:@"MCDidReceiveDataNotification"
											   object:nil];
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendMyMessage {
	NSData *dataToSend = [self.txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *allPeers = self.appDelegate.mcManager.session.connectedPeers;
	NSError *error;
	
	[self.appDelegate.mcManager.session sendData:dataToSend
										 toPeers:allPeers
										withMode:MCSessionSendDataReliable
										   error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[self.tvChat setText:[self.tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", self.txtMessage.text]]];
	[self.txtMessage setText:@""];
	[self.txtMessage resignFirstResponder];
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification {
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	NSString *peerDisplayName = peerID.displayName;
	NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
	NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	[self.tvChat performSelectorOnMainThread:@selector(setText:) withObject:[self.tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]]  waitUntilDone:NO];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self sendMyMessage];
	
	return YES;
}

- (IBAction)sendMessage:(id)sender {
	[self sendMyMessage];
}

- (IBAction)cancelMessage:(id)sender {
	[self.txtMessage resignFirstResponder];
}
@end
