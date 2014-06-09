//
//  MPCFCommunicationManager.h
//  NetworkLab
//
//  Created by Fille Åström on 09/06/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "UIView+MHNibLoading.h"
#import "DeviceView.h"

@import MultipeerConnectivity;
@import CoreMotion;

@interface MPCFCommunicationManager : NSObject<MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>

- (instancetype)initWithVC:(ViewController *)vc;

@end
