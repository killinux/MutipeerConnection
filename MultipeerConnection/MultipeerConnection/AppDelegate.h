//
//  AppDelegate.h
//  MultipeerConnection
//
//  Created by Olivier on 30/06/2014.
//  Copyright (c) 2014 sqli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MCManager *mcManager;

@end
