/*
 
 DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 December 2013
 
 Copyright (C) 2013 Fille Åström <fille@imgnry.com>
 
 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.
 
 DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 
 0. You just DO WHAT THE FUCK YOU WANT TO.
 
 */

#import <UIKit/UIKit.h>

@interface UIView (Ext)

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic) float bottom;
@property (nonatomic) float right;
@property (nonatomic) CGPoint position;

// Instead of hidden, which is just plain stupid
@property (nonatomic) BOOL visible;

//+ (id)instanceWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil owner:(id)owner;
- (BOOL)isAnimating;
- (void)removeSubviews;

@end
