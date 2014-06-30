//
//  MCManager.h
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;

- (void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
- (void)setupMCBrowser;
- (void)advertiseSelf:(BOOL)shouldAdvertise;

@end
