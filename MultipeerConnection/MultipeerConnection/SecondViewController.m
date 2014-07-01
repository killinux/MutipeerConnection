//
//  SecondViewController.m
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	self.tableFiles.delegate = self;
	self.tableFiles.dataSource = self;
	
	[self copySampleFilesToDocDirIfNeeded];
	self.arrFiles = [[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
	
	[self.tableFiles reloadData];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
										   selector:@selector(didStartReceivingResourceWithNotification:)
											  name:@"MCDidStartReceivingProgressNotification"
											  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
										   selector:@selector(updateReceivingResourceWithNotification:)
											  name:@"MCReceivingProgressNotification"
											  object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didFinishreceivingResourceNotification:)
												 name:@"didFinishReceivingResourceNotification"
											   object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)copySampleFilesToDocDirIfNeeded {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.documentsDirectory = [[NSString alloc] initWithString:[paths objectAtIndex:0]];
	
	NSString *file1Path = [self.documentsDirectory stringByAppendingPathComponent:@"sample_file1.txt"];
	NSString *file2Path = [self.documentsDirectory stringByAppendingPathComponent:@"sample_file2.txt"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	
	if (![fileManager fileExistsAtPath:file1Path] || ! [fileManager fileExistsAtPath:file2Path]) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file1" ofType:@"txt"]
							 toPath:file1Path
							  error:&error];
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
			return;
		}
		
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"sample_file2" ofType:@"txt"]
							 toPath:file2Path
							  error:&error];
		
		if (error) {
			NSLog(@"%@", [error localizedDescription]);
			return;
		}
	}
	
}

-(NSArray *)getAllDocDirFiles {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:self.documentsDirectory error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
		return nil;
	}
	
	return allFiles;
}

-(void)didStartReceivingResourceWithNotification:(NSNotification *)notification {
	[self.arrFiles addObject:[notification userInfo]];
	[self.tableFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)updateReceivingResourceWithNotification:(NSNotification *)notification {
	NSProgress *progress = [[notification userInfo] objectForKey:@"progress"];
	NSDictionary *dict = [self.arrFiles objectAtIndex:(self.arrFiles.count - 1)];
	NSDictionary *updateDict = @{@"resourceName": [dict objectForKey:@"resourceName"],
								 @"peerID" : [dict objectForKey:@"peerID"],
								 @"progress": progress
								 };
	
	[self.arrFiles replaceObjectAtIndex:self.arrFiles.count-1 withObject:updateDict];
	[self.tableFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)didFinishreceivingResourceNotification:(NSNotification *)notification {
	NSDictionary *dict = [notification userInfo];
	NSURL *localURL = [dict objectForKey:@"localURL"];
	NSString *resourceName = [dict objectForKey:@"resourceName"];
	NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:resourceName];
	NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	
	[fileManager copyItemAtURL:localURL toURL:destinationURL error:&error];
	
	if (error) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[self.arrFiles removeAllObjects];
	self.arrFiles = nil;
	self.arrFiles = [[NSMutableArray alloc] initWithArray:[self getAllDocDirFiles]];
	[self.tableFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.arrFiles count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	
    if ([[_arrFiles objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
		
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
		
        cell.textLabel.text = [_arrFiles objectAtIndex:indexPath.row];
		
        [[cell textLabel] setFont:[UIFont systemFontOfSize:14.0]];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
		
        NSDictionary *dict = [_arrFiles objectAtIndex:indexPath.row];
        NSString *receivedFilename = [dict objectForKey:@"resourceName"];
        NSString *peerDisplayName = [[dict objectForKey:@"peerID"] displayName];
        NSProgress *progress = [dict objectForKey:@"progress"];
		
        [(UILabel *)[cell viewWithTag:100] setText:receivedFilename];
        [(UILabel *)[cell viewWithTag:200] setText:[NSString stringWithFormat:@"from %@", peerDisplayName]];
        [(UIProgressView *)[cell viewWithTag:300] setProgress:progress.fractionCompleted];
    }
	
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self.arrFiles objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
		return 60.0;
	} else {
		return 80.0;
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *selectedFile = [self.arrFiles objectAtIndex:indexPath.row];
	UIActionSheet *confirmSending = [[UIActionSheet alloc] initWithTitle:selectedFile
																delegate:self
													   cancelButtonTitle:nil
												  destructiveButtonTitle:nil
													   otherButtonTitles:nil];
	
	for (int i=0; i<[[self.appDelegate.mcManager.session connectedPeers] count]; i++) {
		[confirmSending addButtonWithTitle:[[[self.appDelegate.mcManager.session connectedPeers] objectAtIndex:i] displayName]];
	}
	
	[confirmSending setCancelButtonIndex:[confirmSending addButtonWithTitle:@"Cancel"]];
	[confirmSending showInView:self.view];
	self.selectedFile = [self.arrFiles objectAtIndex:indexPath.row];
	self.selectedRow = indexPath.row;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [[self.appDelegate.mcManager.session connectedPeers] count]) {
		NSString *filePath = [self.documentsDirectory stringByAppendingPathComponent:self.selectedFile];
		NSString *modifiedName = [NSString stringWithFormat:@"%@%@", self.appDelegate.mcManager.peerID.displayName, self.selectedFile];
		NSURL *resourceURL = [NSURL fileURLWithPath:filePath];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSProgress *progress = [self .appDelegate.mcManager.session sendResourceAtURL:resourceURL
																				 withName:modifiedName
																				   toPeer:[[self.appDelegate.mcManager.session connectedPeers] objectAtIndex:buttonIndex]
																	withCompletionHandler:^(NSError *error){
																		if (error) {
																			NSLog(@"Error: %@", [error localizedDescription]);
																		} else {
																			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MultipeerConnection"
																															message:@"Fichier envoyé avec succès"
																														   delegate:self
																												  cancelButtonTitle:nil
																												  otherButtonTitles:@"Great !", nil];
																			[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
																			[self.arrFiles replaceObjectAtIndex:self.selectedRow withObject:self.selectedFile];
																			[self.tableFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
																		}
																	}];
			[progress addObserver:self
					   forKeyPath:@"fractionCompleted"
						  options:NSKeyValueObservingOptionNew
						  context:nil];
		});
	}
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSString *sendingMessage = [NSString stringWithFormat:@"%@ - Sending %.f%%", self.selectedFile, [(NSProgress *)object fractionCompleted]*100];
	[self.arrFiles replaceObjectAtIndex:self.selectedRow withObject:sendingMessage];
	[self.tableFiles performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
