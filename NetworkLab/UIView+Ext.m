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

#import "UIView+Ext.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Ext)

//+ (id)instanceWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil owner:(id)owner
//{
//    //default values
//    NSString *nibName = nibNameOrNil ?: NSStringFromClass(self);
//    NSBundle *bundle = bundleOrNil ?: [NSBundle mainBundle];
//    
//    //cache nib to prevent unnecessary filesystem access
//    static NSCache *nibCache = nil;
//    if (nibCache == nil)
//    {
//        nibCache = [[NSCache alloc] init];
//    }
//    NSString *pathKey = [NSString stringWithFormat:@"%@.%@", bundle.bundleIdentifier, nibName];
//    UINib *nib = [nibCache objectForKey:pathKey];
//    if (nib == nil)
//    {
//        NSString *nibPath = [bundle pathForResource:nibName ofType:@"nib"];
//        if (nibPath) nib = [UINib nibWithNibName:nibName bundle:bundle];
//        [nibCache setObject:nib ?: [NSNull null] forKey:pathKey];
//    }
//    else if ([nib isKindOfClass:[NSNull class]])
//    {
//        nib = nil;
//    }
//    
//    if (nib)
//    {
//        //attempt to load from nib
//        NSArray *contents = [nib instantiateWithOwner:owner options:nil];
//        UIView *view = [contents count]? [contents objectAtIndex:0]: nil;
//        NSAssert ([view isKindOfClass:self], @"First object in nib '%@' was '%@'. Expected '%@'", nibName, view, self);
//        return view;
//    }
//    
//    //return empty view
//    return [[[self class] alloc] init];
//}

- (float)x {
    return self.frame.origin.x;
}

- (void)setX:(float)newX {
    CGRect frame = self.frame;
    frame.origin.x = newX;
    self.frame = frame;
}

- (float)y {
    return self.frame.origin.y;
}

- (void)setY:(float)newY {
    CGRect frame = self.frame;
    frame.origin.y = newY;
    self.frame = frame;
}

- (CGPoint)position
{
    return CGPointMake(self.x, self.y);
}

- (void)setPosition:(CGPoint)position
{
    self.x = position.x;
    self.y = position.y;
}

-(float) width {
    return self.frame.size.width;
}

-(void) setWidth:(float) newWidth {
    CGRect frame = self.frame;
    frame.size.width = newWidth;
    self.frame = frame;
}

-(float) height {
    return self.frame.size.height;
}

-(void) setHeight:(float) newHeight {
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

- (BOOL)isAnimating {
    return [self.layer.animationKeys count] > 0;
}

- (float)bottom {
    return self.y + self.height;
}

- (void)setBottom:(float)bottom {
    self.y = bottom - self.height;
}

- (float)right {
    return self.x + self.width;
}

- (void)setRight:(float)right {
    self.x = right - self.width;
}

- (BOOL)visible {
    return !self.hidden;
}

- (void)setVisible:(BOOL)visible {
    self.hidden = !visible;
}

- (void)removeSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end




















