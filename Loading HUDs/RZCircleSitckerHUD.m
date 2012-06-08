//
//  RZCircleSitckerHUD.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZCircleSitckerHUD.h"
#import "RZCircleView.h"
#import "UIView+Utils.h"
#import "UIBezierPath+CirclePath.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultFlipTime            0.15
#define kDefaultSizeTime            0.15
#define kDefaultOverlayTime         0.2
#define kCircleRadiusMultiplier     1.2

@interface RZCircleSitckerHUD ()

@property (strong, nonatomic) UIColor *bgTargetColor;

@property (strong, nonatomic) UIView *hudContainerView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) RZCircleView *circleView;
@property (strong, nonatomic) ControllablePageFlipper *pageFlipper;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (copy, nonatomic) HUDDismissBlock dismissBlock;

@property (assign, nonatomic) BOOL usingFold;
@property (assign, nonatomic) BOOL fullyPresented;
@property (assign, nonatomic) BOOL pendingDismissal;

- (void)setupPageFlipper:(BOOL)open;
- (void)addHudToOverlay;
- (void)popOutCircle:(BOOL)poppingOut;
- (void)animateCircleShadowToPath:(CGPathRef)path 
                     shadowRadius:(CGFloat)shadowRadius 
                            alpha:(CGFloat)alpha
                            curve:(CAMediaTimingFunction*)curve
                         duration:(CFTimeInterval)duration;

- (UIBezierPath*)shadowPathForRadius:(CGFloat)radius raisedState:(BOOL)raised;

@end

@implementation RZCircleSitckerHUD

@synthesize radius = _radius;
@synthesize overlayOnly = _overlayOnly;

@synthesize bgTargetColor = _bgTargetColor;

@synthesize hudContainerView = _hudContainerView;
@synthesize shadowView = _shadowView;
@synthesize circleView = _circleView;
@synthesize pageFlipper = _pageFlipper;
@synthesize spinnerView = _spinnerView;
@synthesize dismissBlock = _dismissBlock;
@synthesize usingFold = _usingFold;
@synthesize fullyPresented = _fullyPresented;
@synthesize pendingDismissal = _pendingDismissal;

#pragma mark - Init and Presentation

- (id)initWithRadius:(CGFloat)radius 
     backgroundColor:(UIColor *)bgColor
            hudColor:(UIColor *)hudColor 
        spinnerColor:(UIColor *)spinnerColor
{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, 768, 1024)]){
        
        self.usingFold = NO;
        
        // clear for now, could add a gradient or something here
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.radius = roundf(radius/kCircleRadiusMultiplier);
        
        self.bgTargetColor = bgColor;
        
        // setup container for hud + shadow views
        self.hudContainerView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake(0, 0, radius*2.5, radius*2.5))];
        self.hudContainerView.backgroundColor = [UIColor clearColor];
        self.hudContainerView.clipsToBounds = NO;
        self.hudContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.hudContainerView.alpha = 0.99;

        // setup hud view and mask
        self.circleView = [[RZCircleView alloc] initWithRadius:self.radius color:hudColor];
        self.circleView.clipsToBounds = NO;
        self.circleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.circleView.frame = self.hudContainerView.bounds;
        [self.hudContainerView addSubview:self.circleView];
        
        // add spinner view to center of circle view
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: radius < 25 ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleWhiteLarge];
        self.spinnerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.spinnerView.hidesWhenStopped = YES;
        self.spinnerView.color = spinnerColor;
        self.spinnerView.backgroundColor = [UIColor clearColor];
        self.spinnerView.center = CGPointMake(self.circleView.bounds.size.width/2,self.circleView.bounds.size.height/2);
        [self.circleView addSubview:self.spinnerView];
        
        // add empty view to host shadow layer
        self.shadowView = [[UIView alloc] initWithFrame:self.hudContainerView.bounds];
        self.shadowView.backgroundColor = [UIColor clearColor];
        self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shadowView.clipsToBounds = NO;
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOpacity = 0.0;
        self.shadowView.layer.shadowRadius = 1.0;
        self.shadowView.layer.shadowPath = [UIBezierPath circlePathWithRadius:self.radius center:self.shadowView.center].CGPath;
        [self.hudContainerView insertSubview:self.shadowView atIndex:0];
        
    }
    return self;
}

- (void)presentInView:(UIView *)view withFold:(BOOL)fold{
    [self presentInView:view withFold:(BOOL)fold afterDelay:0.0];
}

- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay{
    
    if (self.superview) return;
    
    self.usingFold = fold;
    
    self.fullyPresented = NO;
    
    self.frame = view.bounds;
    [view addSubview:self];
    
    double delayInSeconds = delay == 0.0 ? 0.01 : delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self addHudToOverlay];
    });
    }

- (void)dismiss{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated{
    
    BOOL animateDismissal = animated;
    
    // might not need to animate hud out if grace period did not expire
    if (!self.superview || (self.usingFold && !self.pageFlipper)){
        animateDismissal = NO;
    }
    
    // if we can't remove the hud, just perform the block
    if (!animateDismissal){
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }
        return;
    }
    
    if (!self.fullyPresented){
        self.pendingDismissal = YES;
        return;
    }
    
    if (!self.overlayOnly)
        [self.spinnerView stopAnimating];
        
    [UIView animateWithDuration:kDefaultOverlayTime
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.backgroundColor = [UIColor clearColor];
                     }
                     completion:NULL
     ];
    
    if (!self.overlayOnly){
        [self popOutCircle:NO];
    }
    else {
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }
    }
}

- (void)dismissWithCompletionBlock:(HUDDismissBlock)block{
    [self dismissWithCompletionBlock:block animated:YES];
}

- (void)dismissWithCompletionBlock:(HUDDismissBlock)block animated:(BOOL)animated{
    self.dismissBlock = block;
    [self dismissAnimated:animated];
}

#pragma mark - Private

- (void)setupPageFlipper:(BOOL)open{
    self.pageFlipper = [[ControllablePageFlipper alloc] initWithOriginalView:self.superview
                                                                  targetView:self.hudContainerView
                                                                   fromState:open ? kCPF_Open : kCPF_Closed 
                                                                   fromRight:YES];
    self.pageFlipper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.pageFlipper.delegate = self;
    self.pageFlipper.animationTime = kDefaultFlipTime;
    self.pageFlipper.shadowMask = kCPF_NoShadow;
    [self.pageFlipper maskToCircleWithRadius:self.radius];
    self.pageFlipper.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)addHudToOverlay{
    
    if (self.pendingDismissal){
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }
        return;
    }
    
    // make sure the frame is an integral rect, centered
    self.hudContainerView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.hudContainerView.frame = CGRectIntegral(self.hudContainerView.frame);
    
    if (self.usingFold && !self.overlayOnly){
        [self setupPageFlipper:NO];
        [self addSubview:self.pageFlipper];
        [self.pageFlipper animateToState:kCPF_Open];
    }
    else{
        if (!self.overlayOnly){
            self.circleView.alpha = 0.0;
            [self addSubview:self.hudContainerView];
        }
        
        [UIView animateWithDuration:kDefaultOverlayTime
                         animations:^{
                             self.circleView.alpha = 1.0;
                             self.backgroundColor = self.bgTargetColor;
                         }
                         completion:^(BOOL finished) {
                             if (!self.overlayOnly)
                                 [self popOutCircle:YES];
                             else{
                                 self.fullyPresented = YES;
                                 if (self.pendingDismissal){
                                     [self dismiss];
                                 }
                             }

                         }
         ];
    }

}

- (void)popOutCircle:(BOOL)poppingOut
{
    if (poppingOut){
        
        CGFloat newRadius = roundf(self.circleView.radius * kCircleRadiusMultiplier);
        
        [self animateCircleShadowToPath:[self shadowPathForRadius:newRadius raisedState:YES].CGPath
                           shadowRadius:3.0
                                  alpha:0.15
                                  curve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                               duration:kDefaultSizeTime];
        
        
        [self.circleView animateToRadius:newRadius
                               withCurve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                duration:kDefaultSizeTime
                              completion:^{
                                  [self.spinnerView startAnimating];
                                  self.fullyPresented = YES;
                                  if (self.pendingDismissal){
                                      [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
                                  }
                              }];
        
        
        self.radius = newRadius;
    }
    else{
        CGFloat newRadius = self.circleView.radius / kCircleRadiusMultiplier;
        
        [self animateCircleShadowToPath:[self shadowPathForRadius:newRadius raisedState:NO].CGPath
                           shadowRadius:2.0
                                  alpha:0.0
                                  curve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
                               duration:kDefaultSizeTime];
        
        [self.circleView animateToRadius:newRadius
                               withCurve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
                                duration:kDefaultSizeTime
                              completion:^{
                                  if (self.usingFold){
                                      [self setupPageFlipper:YES];
                                      [self.circleView removeFromSuperview];
                                      [self addSubview:self.pageFlipper];
                                      [self.pageFlipper animateToState:kCPF_Closed];
                                  }
                                  else {
                                      [UIView animateWithDuration:kDefaultOverlayTime
                                                       animations:^{
                                                           self.circleView.alpha = 0.0;
                                                       }
                                                       completion:^(BOOL finished){
                                                           [self removeFromSuperview];
                                                           if (self.dismissBlock){
                                                               self.dismissBlock();
                                                               self.dismissBlock = nil;
                                                           }
                                                       }
                                       
                                
                                       ];
                                  }
                              }];
        
        self.radius = newRadius;
    }
}


- (void)animateCircleShadowToPath:(CGPathRef)path
                       shadowRadius:(CGFloat)shadowRadius 
                              alpha:(CGFloat)alpha
                              curve:(CAMediaTimingFunction*)curve
                           duration:(CFTimeInterval)duration
{
    
    [self.shadowView.layer removeAllAnimations];
    
    CABasicAnimation *shadowPathAnim = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    shadowPathAnim.duration = duration;
    shadowPathAnim.timingFunction = curve;
    shadowPathAnim.fromValue = (__bridge id)self.shadowView.layer.shadowPath;
    shadowPathAnim.toValue = (__bridge id)path;
    shadowPathAnim.fillMode = kCAFillModeForwards;
    
    self.shadowView.layer.shadowPath = path;
    [self.shadowView.layer addAnimation:shadowPathAnim forKey:@"shadowPath"];
    
    CABasicAnimation *shadowAlphaAnim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAlphaAnim.duration = duration;
    shadowAlphaAnim.timingFunction = curve;
    shadowAlphaAnim.fromValue = [NSNumber numberWithFloat:self.shadowView.layer.shadowOpacity];
    shadowAlphaAnim.toValue = [NSNumber numberWithFloat:alpha];
    shadowAlphaAnim.fillMode = kCAFillModeForwards;
    
    self.shadowView.layer.shadowOpacity = alpha;
    [self.shadowView.layer addAnimation:shadowAlphaAnim forKey:@"shadowOpacity"];

    
    CABasicAnimation *shadowRadiusAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    shadowRadiusAnim.duration = duration;
    shadowRadiusAnim.timingFunction = curve;
    shadowRadiusAnim.fromValue = [NSNumber numberWithFloat:self.shadowView.layer.shadowRadius];
    shadowRadiusAnim.toValue = [NSNumber numberWithFloat:shadowRadius];
    shadowRadiusAnim.fillMode = kCAFillModeForwards;
    
    self.shadowView.layer.shadowRadius = shadowRadius;
    [self.shadowView.layer addAnimation:shadowRadiusAnim forKey:@"shadowRadius"];
}

- (UIBezierPath*)shadowPathForRadius:(CGFloat)radius raisedState:(BOOL)raised{
    
    CGPoint containerCenter = CGPointMake(self.hudContainerView.bounds.size.width/2, self.hudContainerView.bounds.size.height/2);
    CGRect shadowEllipseRect = CGRectMake(raised ? containerCenter.x - (radius*1.05) : containerCenter.x - radius, 
                                          containerCenter.y - radius, 
                                          raised ? radius * 2.1 : radius*2,
                                          raised ? radius * 2.25 : radius*2);
    
    return [UIBezierPath bezierPathWithOvalInRect:shadowEllipseRect];
}

#pragma mark - properties

// don't change if already presented
- (void)setOverlayOnly:(BOOL)overlayOnly
{
    if (self.superview) return;
    _overlayOnly = overlayOnly;
}

- (UIColor*)hudColor{
    return self.circleView.color;
}

- (void)setHudColor:(UIColor *)hudColor{
    self.circleView.color = hudColor;
}

- (UIColor*)spinnerColor{
    return self.spinnerView.color;
}

- (void)setSpinnerColor:(UIColor *)spinnerColor{
    self.spinnerView.color = spinnerColor;
}

#pragma mark - Controllable page flipper delegate

- (void)didFinishAnimatingToState:(CPFFlipState)state withTargetView:(UIView *)targetView{
    if (state == kCPF_Open)
    {
        [self addSubview:self.hudContainerView];
        
        [UIView animateWithDuration:kDefaultOverlayTime
                         animations:^{
                             self.backgroundColor = self.bgTargetColor;
                         }];
        
        [self popOutCircle:YES];
        
    }
    else {
        self.pageFlipper = nil;
        
        [self removeFromSuperview];
        if (self.dismissBlock){
            self.dismissBlock();
            self.dismissBlock = nil;
        }

    }
}

@end
