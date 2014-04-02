//
//  RZCircleView.m
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
#import "RZCircleView.h"

typedef void (^RadiusAnimCompletion)();

@interface RZCircleView ()

@property (strong, nonatomic) RZCircleLayer *circleLayer;
@property (copy, nonatomic)   RadiusAnimCompletion radiusCompletion;

- (CGRect)frameForRadius:(CGFloat)radius;

@end

@implementation RZCircleView

@synthesize circleLayer = _circleLayer;
@synthesize radiusCompletion = _radiusCompletion;

- (id)initWithRadius:(CGFloat)radius color:(UIColor *)color{
    if (self = [super initWithFrame:CGRectMake(0, 0, radius*2, radius*2)]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        
        self.circleLayer = [[RZCircleLayer alloc] initWithRadius:radius color:color];
        self.circleLayer.frame = self.bounds;
        [self.layer addSublayer:self.circleLayer];
        [self.circleLayer setNeedsDisplay];
    }
    return self;
    
}

#pragma mark - Properties

- (CGFloat)radius
{
    return self.circleLayer.radius;
}

- (void)setRadius:(CGFloat)radius{
    self.frame = [self frameForRadius:radius];
    self.circleLayer.radius = self.radius;
}

- (UIColor*)color
{
    return self.circleLayer.color;
}

- (void)setColor:(UIColor *)color
{
    self.circleLayer.color = color;
}

- (CGFloat)borderWidth
{
    return self.circleLayer.circleBorderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.circleLayer.circleBorderWidth = borderWidth;
}

- (UIColor*)borderColor
{
    return self.circleLayer.circleBorderColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.circleLayer.circleBorderColor = borderColor;
}

#pragma mark - Layout and animation

- (CGRect)frameForRadius:(CGFloat)radius{
    CGPoint center = self.center;
    CGRect frame = self.frame;
    frame.origin.x = center.x - radius;
    frame.origin.y = center.y - radius;
    frame.size = CGSizeMake(radius*2, radius*2);
    return frame;
}

- (void)animateToRadius:(CGFloat)radius
              withCurve:(CAMediaTimingFunction *)curve
               duration:(CFTimeInterval)duration
             completion:(void (^)())completion
{
    self.radiusCompletion = completion;
        
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"radius"];
    anim.duration = duration;
    anim.timingFunction = curve;
    anim.fromValue = [NSNumber numberWithDouble:self.circleLayer.radius];
    anim.toValue = [NSNumber numberWithDouble:radius];
    anim.fillMode = kCAFillModeForwards;
    anim.delegate = self;
    
    self.circleLayer.radius = radius;
    [self.circleLayer addAnimation:anim forKey:@"animateRadius"];
}

- (void)layoutSubviews{
    self.circleLayer.frame = self.bounds;
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    if (![anim isKindOfClass:[CABasicAnimation class]]) return;
    
    if ([[(CABasicAnimation*)anim keyPath] isEqualToString:@"radius"] && flag){
        if (self.radiusCompletion){
            self.radiusCompletion();
            self.radiusCompletion = nil;
        }
    }
}

@end
