//
//  CoreBluetoothManager.m
//  NetworkLab
//
//  Created by Fille Åström on 09/06/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import "CoreBluetoothCommunicationManager.h"

static NSString * const     tiltUUID            = @"0001";
static NSString * const     fireUUID            = @"0002";
static NSString * const     thrustUUID          = @"0003";
static NSString * const     controllerUUID      = @"0004";

@interface CoreBluetoothCommunicationManager ()

@property (nonatomic) ViewController                *vc;

@property (nonatomic) NSString                      *playerID;

// Bluetooth (Central/iPad/Arena)
@property (nonatomic) CBCentralManager              *centralManager;
@property (nonatomic) NSMutableDictionary           *peripherals;

// Bluetooth (Peripheral/iPhone/Controller)
@property (nonatomic) CBPeripheralManager           *peripheralManager;
@property (nonatomic) CBCentral                     *central;
@property (nonatomic) CBMutableService              *controllerService;

@property (nonatomic) CBUUID                        *tiltCBUUID;
@property (nonatomic) CBMutableCharacteristic       *tiltCharacteristic;

@property (nonatomic) NSTimer                       *sendControllerStateTimer;
@property (nonatomic) CMMotionManager               *motionManager;

@end

@implementation CoreBluetoothCommunicationManager

- (instancetype)initWithVC:(ViewController *)vc
{
    if (self = [super init]) {
        
        self.vc = vc;
        
        self.playerID = [[UIDevice currentDevice] name];
        self.tiltCBUUID = [CBUUID UUIDWithString:tiltUUID];
        
        if (IPAD) {
            self.peripherals = [NSMutableDictionary dictionary];
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        }
        else if (IPHONE) {
            self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        }
    }
    return self;
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            NSLog(@"CBPeripheralManagerStateUnknown");
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"CBPeripheralManagerStateResetting");
            break;
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"CBPeripheralManagerStateUnsupported");
            break;
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"CBPeripheralManagerStateUnauthorized");
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"CBPeripheralManagerStatePoweredOff");
            break;
        case CBPeripheralManagerStatePoweredOn: {
            NSLog(@"CBPeripheralManagerStatePoweredOn");
            self.tiltCharacteristic = [[CBMutableCharacteristic alloc] initWithType:self.tiltCBUUID
                                                                         properties:CBCharacteristicPropertyNotify
                                                                              value:nil
                                                                        permissions:0];
            
            CBUUID *controllerCBUUID = [CBUUID UUIDWithString:controllerUUID];
            self.controllerService = [[CBMutableService alloc] initWithType:controllerCBUUID primary:YES];
            self.controllerService.characteristics = @[self.tiltCharacteristic];
            
            [self.peripheralManager addService:self.controllerService];
            break;
        }
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didAddService: %@", service);
    if (error) {
        NSLog(@"Error publishing service: %@", error.localizedDescription);
    }
    else {
        [peripheral startAdvertising:@{
                                       CBAdvertisementDataLocalNameKey: [[UIDevice currentDevice] name],
                                       CBAdvertisementDataServiceUUIDsKey : @[self.controllerService.UUID]
                                       }];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    NSLog(@"peripheralManagerDidStartAdvertising: %@", peripheral);
    if (error) {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn: {
            NSLog(@"CBCentralManagerStatePoweredOn");
            
            //            [self delay:3 block:^{
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            //            }];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@", peripheral);
    
    // TODO: Make sure scanning stops when all players have joined
    //    [self.centralManager stopScan];
    //    NSLog(@"Scanning stopped");
    
//    if ([advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString:@"Controller"]) {
        self.peripherals[peripheral.identifier] = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
//    }
    
    DeviceView *deviceView = [DeviceView loadInstanceFromNib];
    //    self.deviceView.alpha = 0.5;
    [self.vc.view addSubview:deviceView];
    //    [self.deviceView setDiff:200];
    deviceView.deviceNameLabel.text = advertisementData[CBAdvertisementDataLocalNameKey];
    NSUInteger deviceNumber = 0;
    
    for (id subView in self.vc.view.subviews) {
        if ([subView isKindOfClass:[DeviceView class]]) {
            deviceNumber++;
        }
    }
    switch (deviceNumber) {
        case 1:
            break;
        case 2:
            deviceView.x = deviceView.width;
            break;
        case 3:
            deviceView.y = deviceView.frame.size.height;
            break;
        case 4:
            deviceView.x = deviceView.width;
            deviceView.y = deviceView.frame.size.height;
            break;
            
        default:
            break;
    }
    
    self.vc.clientPeerIDs[peripheral.identifier.UUIDString] = [@{} mutableCopy];
    self.vc.clientPeerIDs[peripheral.identifier.UUIDString][@"interval"] = @([[NSDate date] timeIntervalSince1970]);
    self.vc.clientPeerIDs[peripheral.identifier.UUIDString][@"sequence"] = @(0);
    self.vc.clientPeerIDs[peripheral.identifier.UUIDString][@"deviceView"] = deviceView;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral connected");
    //    self.peripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        NSLog(@"Reading value for characteristic %@", characteristic);
        if ([characteristic.UUID isEqual:self.tiltCBUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        //        [self.peripheral readValueForCharacteristic:characteristic];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    NSLog(@"Central subscribed to characteristic %@", characteristic);
    
    [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:central];
    
    // TODO: Start updating tilt value
    if (!self.sendControllerStateTimer) {
        
        self.motionManager = [CMMotionManager new];
        [self.motionManager startAccelerometerUpdates];
        self.sendControllerStateTimer = [NSTimer scheduledTimerWithTimeInterval:transmitRateInterval target:self selector:@selector(sendControllerState) userInfo:nil repeats:YES];
        
    }
    //    NSData *updatedValue = nil; // TODO: fetch the characteristic's new value
    //    BOOL didSendValue = [self.peripheralManager updateValue:updatedValue forCharacteristic:characteristic onSubscribedCentrals:nil];
}

- (void)sendControllerState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString *msgString = [NSString stringWithFormat:@"%f:%i:%i:%lu", self.vc.motionManager.accelerometerData.acceleration.y, self.vc.thrust, self.vc.fire, (unsigned long)packetSequenceNumber++];
    NSData *msgData = [msgString dataUsingEncoding:NSUTF8StringEncoding];
    //    unsigned char data = 1;
    
    //    NSData *msgData = [NSData dataWithBytes:&data length:sizeof(data)];
    
    [self.peripheralManager updateValue:msgData forCharacteristic:self.tiltCharacteristic onSubscribedCentrals:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *output = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSArray *msgParts = [output componentsSeparatedByString:@":"];
        DeviceView *deviceView = [self.vc.clientPeerIDs[peripheral.identifier.UUIDString] objectForKey:@"deviceView"];
        
        NSString *playerId = msgParts[0];
        
        // Verify packer order
        NSUInteger sequenceNumber = [msgParts[3] integerValue];
        if (sequenceNumber <= [[self.vc.clientPeerIDs[playerId] objectForKey:@"sequence"] unsignedIntegerValue]) {
            NSLog(@"WARNING: Recieved old packet. Ignoring.");
            AudioServicesPlaySystemSound(1104);
            [deviceView resetRedBar];
            return;
        }
        
        // Monitor interval timings
        NSTimeInterval now = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        NSTimeInterval prev = [[self.vc.clientPeerIDs[peripheral.identifier.UUIDString] objectForKey:@"interval"] doubleValue];
        NSTimeInterval diff = now - prev;
        [deviceView resetGreenBar];
        
        
        [deviceView setDiff:diff];
        self.vc.clientPeerIDs[peripheral.identifier.UUIDString][@"interval"] = @(now);
        self.vc.clientPeerIDs[peripheral.identifier.UUIDString][@"sequence"] = @(sequenceNumber);
        
    });
}

@end
