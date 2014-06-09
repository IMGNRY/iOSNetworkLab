//
//  ViewController.h
//  NetworkLab
//
//  Created by Fille Åström on 30/05/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
@import AudioToolbox;
@import MultipeerConnectivity;
@import CoreMotion;

typedef NS_ENUM(NSUInteger, CommunicationType) {
    CommunicationType_MPCF,
    CommunicationType_CoreBluetooth
};

static NSString * const     XXServiceType           = @"cocktail-cruise";
static NSTimeInterval const transmitRateInterval    = 1.0 / 20.0;
static NSUInteger           packetSequenceNumber;

@interface ViewController : UIViewController

@property (nonatomic, weak) NSTimer                 *sendControllerStateTimer;
@property (nonatomic, weak) NSTimer                 *decreaseHeightOfDeviceViewsTimer;
@property (nonatomic) CMMotionManager               *motionManager;
@property (nonatomic) BOOL                          thrust;
@property (nonatomic) BOOL                          fire;
@property (nonatomic) NSMutableDictionary           *clientPeerIDs;

@property (nonatomic) CommunicationType             communicationType;

@property (weak, nonatomic) IBOutlet UILabel *iPhoneDeviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *iPhoneTransmitRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *iPhonePingbackLatencyLabel;

// Bluetooth (Central/iPad/Arena)
//@property (nonatomic) CBCentralManager              *centralManager;
//@property (nonatomic) NSMutableDictionary           *peripherals;
//
//// Bluetooth (Peripheral/iPhone/Controller)
//@property (nonatomic) CBPeripheralManager           *peripheralManager;
//@property (nonatomic) CBCentral                     *central;
//@property (nonatomic) CBMutableService              *controllerService;
//
//@property (nonatomic) CBUUID                        *tiltCBUUID;
//@property (nonatomic) CBMutableCharacteristic       *tiltCharacteristic;

@end
