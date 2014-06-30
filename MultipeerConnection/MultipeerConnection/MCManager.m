//
//  MCManager.m
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager

- (id)init {
	self = [super init];
	
	if (self) {
		_peerID = nil;
		_session = nil;
		_browser = nil;
		_advertiser = nil;
	}
	
	return self;
}

#pragma mark - MCSession Delegate
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
	NSDictionary *dict = @{@"peerID": peerID,
						   @"state": [NSNumber numberWithInt:state]
						   };
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
														object:nil
													  userInfo:dict];
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
	NSDictionary *dict = @{@"data": data,
						   @"peerID": peerID
						   };
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
														object:nil
													  userInfo:dict];
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
	
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
	
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
	
}

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName {
	self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
	self.session = [[MCSession alloc] initWithPeer:self.peerID];
	self.session.delegate = self;
}

-(void)setupMCBrowser {
	self.browser = [[MCBrowserViewController alloc] initWithServiceType:@"chat-files" session:self.session];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise {
	if (shouldAdvertise) {
		self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"chat-files"
															   discoveryInfo:nil
																	 session:self.session];
		[self.advertiser start];
	} else {
		[self.advertiser stop];
		self.advertiser = nil;
	}
}

@end
