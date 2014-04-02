//
//  RZCircleLayer.m
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
        [key isEqualToString:@"circleBorderWidth"] || [key isEqualToString:@"circleBorderColor"])
        return YES;
    
    return [super needsDisplayForKey:key];;
}

// Draw a centered, filled circle
- (void)drawInContext:(CGContextRef)ctx
{   
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextSetLineWidth(ctx, self.circleBorderWidth);
    CGContextSetStrokeColorWithColor(ctx, self.circleBorderColor ? self.circleBorderColor.CGColor : [UIColor clearColor].CGColor);

    CGContextAddArc(ctx, center.x, center.y, self.radius - self.circleBorderWidth/2, 0, 2*M_PI, YES);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end
