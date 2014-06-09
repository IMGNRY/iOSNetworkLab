//
//  MPCFCommunicationManager.m
//  NetworkLab
//
//  Created by Fille Åström on 09/06/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import "MPCFCommunicationManager.h"

@interface MPCFCommunicationManager ()

@property (nonatomic) ViewController *vc;

@property (nonatomic) MCPeerID                      *localPeerID;
@property (nonatomic) MCPeerID                      *serverPeerID;
@property (nonatomic) MCSession                     *session;
@property (nonatomic) MCNearbyServiceBrowser        *browser;
@property (nonatomic) MCNearbyServiceAdvertiser     *advertiser;

@end

@implementation MPCFCommunicationManager

- (instancetype)initWithVC:(ViewController *)vc
{
    if (self = [super init]) {
        self.vc = vc;
        
        self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        
        if (IPAD) {
            self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:XXServiceType];
            self.browser.delegate = self;
            [self.browser startBrowsingForPeers];
        }
        else if (IPHONE) {
            self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID discoveryInfo:nil serviceType:XXServiceType];
            self.advertiser.delegate = self;
            [self.advertiser startAdvertisingPeer];
        }
    }
    return self;
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    DeviceView *deviceView = [DeviceView loadInstanceFromNib];
    //    self.deviceView.alpha = 0.5;
    [self.vc.view addSubview:deviceView];
    //    [self.deviceView setDiff:200];
    deviceView.deviceNameLabel.text = peerID.displayName;
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
    
    self.vc.clientPeerIDs[peerID.displayName] = [@{} mutableCopy];
    self.vc.clientPeerIDs[peerID.displayName][@"interval"] = @([[NSDate date] timeIntervalSince1970]);
    self.vc.clientPeerIDs[peerID.displayName][@"sequence"] = @(0);
    self.vc.clientPeerIDs[peerID.displayName][@"deviceView"] = deviceView;
    
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:-1];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    self.serverPeerID = peerID;
    [self.advertiser stopAdvertisingPeer];
    invitationHandler(YES, self.session);
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (IPHONE) {
        
        switch (state) {
            case MCSessionStateNotConnected:
                NSLog(@"MCSessionState NOT Connected!");
                break;
            case MCSessionStateConnecting:
                NSLog(@"MCSessionState Connecting ...");
                break;
            case MCSessionStateConnected: {
                NSLog(@"MCSessionState Connected to peerod: %@", peerID.displayName);
                
                // When server invites client to session, the client will automatically get connected to all other clients.
                // All the peers share the same session. So only if the is the same as the servers PeerID the client will start sending data to it
                
                if ([peerID isEqual:self.serverPeerID]) {
                    // TODO: Start sending data
                    [self startSendingControllerState];
                }
                
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)startSendingControllerState
{
    self.vc.motionManager = [CMMotionManager new];
    [self.vc.motionManager startAccelerometerUpdates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.vc.sendControllerStateTimer = [NSTimer scheduledTimerWithTimeInterval:transmitRateInterval target:self selector:@selector(sendControllerState) userInfo:nil repeats:YES];
        self.vc.sendControllerStateTimer.tolerance = 0;
    });
}

- (void)sendControllerState
{
    NSString *msgString = [NSString stringWithFormat:@"%f:%i:%i:%lu", self.vc.motionManager.accelerometerData.acceleration.y, self.vc.thrust, self.vc.fire, (unsigned long)packetSequenceNumber++];
    NSData *msgData = [msgString dataUsingEncoding:NSUTF8StringEncoding];
    //    unsigned char data = 1;
    
    //    NSData *msgData = [NSData dataWithBytes:&data length:sizeof(data)];
    NSError *error = nil;
    if (![self.session sendData:msgData toPeers:@[self.serverPeerID] withMode:MCSessionSendDataUnreliable error:&error]) {
        NSLog(@"[Error] %@", error);
    }
    
    //    msgData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    //    error = nil;
    //    if (![self.session sendData:msgData toPeers:@[self.serverPeerID] withMode:MCSessionSendDataUnreliable error:&error]) {
    //        NSLog(@"[Error] %@", error);
    //    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *msgParts = [output componentsSeparatedByString:@":"];
        DeviceView *deviceView = [self.vc.clientPeerIDs[peerID.displayName] objectForKey:@"deviceView"];
        
        // Verify packer order
        NSUInteger sequenceNumber = [msgParts[3] integerValue];
        if (sequenceNumber <= [[self.vc.clientPeerIDs[peerID.displayName] objectForKey:@"sequence"] unsignedIntegerValue]) {
            NSLog(@"WARNING: Recieved old packet. Ignoring.");
            AudioServicesPlaySystemSound(1104);
            [deviceView resetRedBar];
            return;
        }
        
        // Monitor interval timings
        NSTimeInterval now = ([[NSDate date] timeIntervalSince1970] * 1000);
        
        NSTimeInterval prev = [[self.vc.clientPeerIDs[peerID.displayName] objectForKey:@"interval"] doubleValue];
        NSTimeInterval diff = now - prev;
        [deviceView resetGreenBar];
        
        
        [deviceView setDiff:diff];
        self.vc.clientPeerIDs[peerID.displayName][@"interval"] = @(now);
        self.vc.clientPeerIDs[peerID.displayName][@"sequence"] = @(sequenceNumber);
        
    });
}

@end
