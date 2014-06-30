//
//  ConnectionViewController.m
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "ConnectionViewController.h"

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
	[[self.appDelegate mcManager] advertiseSelf:self.swVisible.isOn];
	
	[self.txtName setDelegate:self];
	self.tableConnectedDevices.delegate = self;
	self.tableConnectedDevices.dataSource = self;
	self.arrConnectedDevices = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(peerDidChangeStateWithNotification:)
												 name:@"MCDidChangeStateNotification"
											   object:nil];
	
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
	MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
	NSString *peerDisplayName = peerID.displayName;
	MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
	
	if (state != MCSessionStateConnecting) {
		if (state == MCSessionStateConnected) {
			[self.arrConnectedDevices addObject:peerDisplayName];
		} else if (state == MCSessionStateNotConnected) {
			if ([self.arrConnectedDevices count] > 0) {
				int indexOfPeer = [self.arrConnectedDevices indexOfObject:peerDisplayName];
				[self.arrConnectedDevices removeObjectAtIndex:indexOfPeer];
			}
		}
		
		[self.tableConnectedDevices reloadData];
		
		BOOL peersExist = ([[self.appDelegate.mcManager.session connectedPeers] count] == 0);
		[self.btnDisconnect setEnabled:!peersExist];
		[self.txtName setEnabled:peersExist];
	}
}

#pragma mark - UITableView Delegate & DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.arrConnectedDevices count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"connectedCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = [self.arrConnectedDevices objectAtIndex:indexPath.row];
	
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

#pragma mark - MCBrowserViewController Delegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
	[self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
	[self.appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.txtName resignFirstResponder];
	
	self.appDelegate.mcManager.peerID = nil;
	self.appDelegate.mcManager.session = nil;
	self.appDelegate.mcManager.browser = nil;
	
	if (self.swVisible.isOn) {
		[self.appDelegate.mcManager.advertiser stop];
	}
	
	[self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.txtName.text];
	[self.appDelegate.mcManager setupMCBrowser];
	[self.appDelegate.mcManager advertiseSelf:self.swVisible.isOn];
	
	return YES;
}

- (IBAction)browseForDevices:(id)sender {
	[[self.appDelegate mcManager] setupMCBrowser];
	[[[self.appDelegate mcManager] browser] setDelegate:self];
	[self presentViewController:[[self.appDelegate mcManager] browser] animated:YES completion:nil];
}

- (IBAction)toggleVisibility:(id)sender {
	[self.appDelegate.mcManager advertiseSelf:self.swVisible.isOn];
}

- (IBAction)disconnect:(id)sender {
	[self.appDelegate.mcManager.session disconnect];
	
	self.txtName.enabled = YES;
	[self.arrConnectedDevices removeAllObjects];
	[self.tableConnectedDevices reloadData];
}

@end
