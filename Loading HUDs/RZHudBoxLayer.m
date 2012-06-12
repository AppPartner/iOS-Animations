//
//  RZHudBoxLayer.m
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZHudBoxLayer.h"

@implementation RZHudBoxLayer

@dynamic color;
@dynamic boxCornerRadius;
@dynamic boxBorderWidth;
@dynamic boxBorderColor;

- (id)initWithSize:(CGSize)size color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    if (self = [super init])
    {
        self.color = color;
        self.boxCornerRadius = cornerRadius;
        
        self.boxBorderWidth = 0.0;
        self.boxBorderColor = nil;
        
        self.frame = (CGRect){CGPointZero, size};
        
        self.masksToBounds = NO;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
            self.contentsScale = [[UIScreen mainScreen] scale];
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"color"] || [key isEqualToString:@"boxCornerRadius"] ||
        [key isEqualToString:@"boxBorderWidth"] || [key isEqualToString:@"boxBorderColor"])
        return YES;
    
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    // outline path
    UIBezierPath *outlinePath = nil;
    if (self.cornerRadius > 0.0)
        outlinePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.boxCornerRadius];
    else
        outlinePath = [UIBezierPath bezierPathWithRect:self.bounds];

    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextAddPath(ctx, outlinePath.CGPath);
    CGContextFillPath(ctx);
    
    if (self.boxBorderColor && self.boxBorderWidth > 0.0){
        CGContextSetStrokeColorWithColor(ctx, self.boxBorderColor.CGColor);
        CGContextSetLineWidth(ctx, self.boxBorderWidth);
        CGContextAddPath(ctx, outlinePath.CGPath);
        CGContextStrokePath(ctx);
    }
}

@end
