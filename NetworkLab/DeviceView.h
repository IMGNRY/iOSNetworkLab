//
//  DeviceView.h
//  NetworkLab
//
//  Created by Fille Åström on 02/06/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceView : UIView

@property (weak, nonatomic) IBOutlet UIView *pinkBar;
@property (weak, nonatomic) IBOutlet UIView *greenBar;
@property (weak, nonatomic) IBOutlet UIView *redBar;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *diffLabel;

- (void)setDiff:(NSTimeInterval)diff;
- (void)resetGreenBar;
- (void)resetRedBar;

@end
