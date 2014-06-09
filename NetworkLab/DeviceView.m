//
//  DeviceView.m
//  NetworkLab
//
//  Created by Fille Åström on 02/06/14.
//  Copyright (c) 2014 IMGNRY International AB. All rights reserved.
//

#import "DeviceView.h"

@implementation DeviceView

- (void)awakeFromNib
{
    self.layer.borderWidth = 1;
}

- (void)setDiff:(NSTimeInterval)diff
{
    CGFloat height = self.height * (diff / 300);
    if (height > self.pinkBar.height) {
        self.pinkBar.height = MIN(self.height, height);
        self.pinkBar.bottom = self.height;
        self.diffLabel.text = [NSString stringWithFormat:@"%i", (int)diff];
    }
}

- (void)resetGreenBar
{
    self.greenBar.height = self.height;
    self.greenBar.bottom = self.height;
}

- (void)resetRedBar
{
    self.redBar.height = self.height;
    self.redBar.bottom = self.height;
}

@end
