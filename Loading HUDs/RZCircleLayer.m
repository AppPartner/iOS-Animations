//
//  RZCircleLayer.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZCircleLayer.h"
#import "UIBezierPath+CirclePath.h"

@implementation RZCircleLayer

@dynamic radius;
@dynamic color;

- (id)initWithRadius:(CGFloat)radius color:(UIColor *)color{
    if (self = [super init]){
        self.radius = radius;
        self.color = color;
        self.masksToBounds = NO;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            self.contentsScale = [[UIScreen mainScreen] scale];
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"radius"])
        return YES;
    
    return [super needsDisplayForKey:key];;
}

// Draw a centered, filled circle
- (void)drawInContext:(CGContextRef)ctx
{   
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextAddArc(ctx, center.x, center.y, self.radius, 0, 2*M_PI, YES);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextFillPath(ctx);
}

@end
