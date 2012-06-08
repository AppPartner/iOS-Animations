//
//  RZCircleView.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZCircleView.h"

typedef void (^RadiusAnimCompletion)();

@interface RZCircleView ()

@property (strong, nonatomic) RZCircleLayer *circleLayer;
@property (copy, nonatomic)   RadiusAnimCompletion radiusCompletion;

- (CGRect)frameForRadius:(CGFloat)radius;

@end

@implementation RZCircleView

@synthesize radius = _radius;
@synthesize color = _color;
@synthesize circleLayer = _circleLayer;
@synthesize radiusCompletion = _radiusCompletion;

- (id)initWithRadius:(CGFloat)radius color:(UIColor *)color{
    if (self = [super initWithFrame:CGRectMake(0, 0, radius*2, radius*2)]){
        _radius = radius;
        self.color = color;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.circleLayer = [[RZCircleLayer alloc] initWithRadius:self.radius color:self.color];
        self.circleLayer.frame = self.bounds;
        [self.layer addSublayer:self.circleLayer];
        [self.circleLayer setNeedsDisplay];
    }
    return self;
    
}

- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    self.frame = [self frameForRadius:radius];
    self.circleLayer.radius = self.radius;
}

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
    _radius = radius;
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
    [super layoutSubviews];
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
