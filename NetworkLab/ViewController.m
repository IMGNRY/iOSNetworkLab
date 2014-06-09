//
//  ViewController.m
//  NetworkLab
//
//  Created by Fille Åström on 30/05/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import "ViewController.h"
#import "UIView+MHNibLoading.h"
#import "DeviceView.h"
#import "MPCFCommunicationManager.h"
#import "CoreBluetoothCommunicationManager.h"

@interface ViewController ()

@property (nonatomic) id communicationManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IPAD) {
        self.clientPeerIDs = [NSMutableDictionary dictionary];
    }
    else if (IPHONE) {
        self.iPhoneDeviceNameLabel.text = [[UIDevice currentDevice] name];
        self.iPhoneTransmitRateLabel.text = [NSString stringWithFormat:@"%i / sec", (int)(1.0 / transmitRateInterval)];
    }
    
    self.decreaseHeightOfDeviceViewsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(calcDeviceBars) userInfo:nil repeats:YES];
    
    self.communicationType = CommunicationType_CoreBluetooth;
    
    if (self.communicationType == CommunicationType_MPCF) {
        self.communicationManager = [[MPCFCommunicationManager alloc] initWithVC:self];
    }
    else if (self.communicationType == CommunicationType_CoreBluetooth) {
        self.communicationManager = [[CoreBluetoothCommunicationManager alloc] initWithVC:self];
    }
}

- (void)calcDeviceBars
{
    for (id subView in self.view.subviews) {
        if ([subView isKindOfClass:[DeviceView class]]) {
            DeviceView *deviceView = (DeviceView *)subView;
            
            // Package interval latency
            if (deviceView.pinkBar.height > 0.0) {
                deviceView.pinkBar.height -= 1.0;
                
                if (deviceView.pinkBar.height < 1.0) {
                    deviceView.pinkBar.height = 0;
                    deviceView.diffLabel.text = @"";
                }
                
                deviceView.pinkBar.bottom = deviceView.height;
            }
            
            // Package recieved
            if (deviceView.greenBar.height > 0.0) {
                deviceView.greenBar.height -= 1.0;
                
                if (deviceView.greenBar.height < 1.0) {
                    deviceView.greenBar.height = 0;
                }
                
                deviceView.greenBar.bottom = deviceView.height;
            }
            
            // Package old
            if (deviceView.redBar.height > 0.0) {
                deviceView.redBar.height -= 1.0;
                
                if (deviceView.redBar.height < 1.0) {
                    deviceView.redBar.height = 0;
                }
                
                deviceView.redBar.bottom = deviceView.height;
            }
        }
    }
}

@end




























