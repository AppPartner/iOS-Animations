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
@dynamic circleBorderWidth;
@dynamic circleBorderColor;

- (id)initWithRadius:(CGFloat)radius color:(UIColor *)color{
    if (self = [super init]){
        self.radius = radius;
        self.color = color;
        self.circleBorderWidth = 0.0;
        self.circleBorderColor = nil;
        self.masksToBounds = NO;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            self.contentsScale = [[UIScreen mainScreen] scale];
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"radius"] || [key isEqualToString:@"color"] ||
        [key isEqualToString:@"borderWidth"] || [key isEqualToString:@"borderColor"])
        return YES;
    
    return [super needsDisplayForKey:key];;
}

// Draw a centered, filled circle
- (void)drawInContext:(CGContextRef)ctx
{   
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);

    CGContextAddArc(ctx, center.x, center.y, self.radius, 0, 2*M_PI, YES);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    if (self.circleBorderColor && self.circleBorderWidth > 0.0){
        CGContextSetLineWidth(ctx, self.circleBorderWidth);
        CGContextSetStrokeColorWithColor(ctx, self.circleBorderColor.CGColor);
        CGContextAddArc(ctx, center.x, center.y, self.radius, 0, 2*M_PI, YES);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
    }
}

@end
