//
//  RZHud.m
//  Raizlabs
//
//  Created by Nick Donaldson on 5/21/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZHud.h"
#import "RZCircleView.h"
#import "RZHudBoxView.h"
#import "UIView+Utils.h"
#import "UIBezierPath+CirclePath.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultFlipTime            0.25
#define kDefaultSizeTime            0.15
#define kDefaultOverlayTime         0.25
#define kPopupMultiplier            1.2

#define kDefaultPNGImageViewFrame   CGRectMake(0, 0, 30, 30)

@interface RZHud ()

@property (assign, nonatomic) RZHudStyle hudStyle;
@property (strong, nonatomic) UIView *hudContainerView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) RZCircleView *circleView;
@property (strong, nonatomic) RZHudBoxView *hudBoxView;
@property (strong, nonatomic) ControllablePageFlipper *pageFlipper;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (copy, nonatomic)   HUDDismissBlock dismissBlock;

@property (assign, nonatomic) BOOL usingFold;
@property (assign, nonatomic) BOOL fullyPresented;
@property (assign, nonatomic) BOOL pendingDismissal;

- (void)setupHudView;
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

@implementation RZHud

@synthesize hudStyle = _hudStyle;

@synthesize customView = _customView;
@synthesize overlayColor = _overlayColor;
@synthesize hudColor = _hudColor;
@synthesize spinnerColor = _spinnerColor;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;

@synthesize shadowAlpha = _shadowAlpha;

@synthesize circleRadius = _circleRadius;

@synthesize cornerRadius = _cornerRadius;
@synthesize labelColor = _labelColor;
@synthesize labelFont = _labelFont;
@synthesize labelText = _labelText;

@synthesize hudContainerView = _hudContainerView;
@synthesize shadowView = _shadowView;
@synthesize hudBoxView = _hudBoxView;
@synthesize circleView = _circleView;
@synthesize pageFlipper = _pageFlipper;
@synthesize spinnerView = _spinnerView;
@synthesize dismissBlock = _dismissBlock;
@synthesize usingFold = _usingFold;
@synthesize fullyPresented = _fullyPresented;
@synthesize pendingDismissal = _pendingDismissal;

#pragma mark - Init and Presentation

- (id)init
{
    return [self initWithStyle:RZHudStyleBoxLoading];
}

- (id)initWithStyle:(RZHudStyle)style
{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, 768, 1024)]){
        
        self.usingFold = NO;
        self.hudStyle = style;
        
        // Avoid using properties here to not disrupt UIAppearance
        _hudColor = [UIColor colorWithWhite:0 alpha:0.9];
        _overlayColor = [UIColor clearColor];
        _spinnerColor = [UIColor whiteColor];
        _borderWidth = 0;
        _shadowAlpha = 0.15;
        _circleRadius = 40.0;
        _cornerRadius = 16.0;
        _labelColor = [UIColor whiteColor];
        _labelFont = [UIFont systemFontOfSize:17];
        _blocksTouches = YES;
        
        // clear for now, could add a gradient or something here
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // default to fade presentation style
        _presentationStyle = RZHudAnimationMaskFade;
        
    }
    return self;
}

- (void)presentInView:(UIView *)view withFold:(BOOL)fold{
    [self presentInView:view withFold:(BOOL)fold afterDelay:0.0];
}

- (void)presentInView:(UIView *)view withFold:(BOOL)fold afterDelay:(NSTimeInterval)delay
{
    if (self.superview) return;
    
    // setup container for hud
    [self setupHudView];
    
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
    
    if (self.hudStyle == RZHudStyleCircle){
        [self popOutCircle:NO];
    }
    else {
        BOOL shouldFade = (self.presentationStyle & RZHudAnimationMaskFade) == RZHudAnimationMaskFade;
        BOOL shouldZoom = (self.presentationStyle & RZHudAnimationMaskZoom) == RZHudAnimationMaskZoom;
        
        [UIView animateWithDuration:kDefaultOverlayTime
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.backgroundColor = [UIColor clearColor];
                             if (shouldFade)
                             {
                                 self.hudBoxView.alpha = 0.0;
                             }
                             if (shouldZoom)
                             {
                                 self.hudBoxView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
                             }
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             if (shouldZoom)
                             {
                                 self.hudBoxView.transform = CGAffineTransformIdentity;
                             }
                             
                             if(self.imageViewAnimationArray != nil && [self.customView isKindOfClass:[UIImageView class]])
                             {
                                 [(UIImageView *)self.customView stopAnimating];
                             }
                             
                             if (self.dismissBlock){
                                 self.dismissBlock();
                                 self.dismissBlock = nil;
                             }
                         }
         ];
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

- (void)setupHudView
{
    if (self.superview) return;
    
    if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo)
    {
        RZHudBoxStyle subStyle = self.hudStyle == RZHudStyleBoxLoading ? RZHudBoxStyleLoading : RZHudBoxStyleInfo;
        self.hudBoxView = [[RZHudBoxView alloc] initWithStyle:subStyle color:self.hudColor cornerRadius:self.cornerRadius];
        self.hudBoxView.borderColor = self.borderColor;
        self.hudBoxView.borderWidth = self.borderWidth;
        self.hudBoxView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.hudBoxView.labelText = self.labelText;
        self.hudBoxView.labelColor = self.labelColor;
        self.hudBoxView.labelFont = self.labelFont;
        self.hudBoxView.spinnerColor = self.spinnerColor;
        self.hudBoxView.customView = self.customView;
        self.hudBoxView.shadowAlpha = self.shadowAlpha;
    }
    else if (self.hudStyle == RZHudStyleCircle)
    {
        CGFloat initialRadius = roundf(self.circleRadius/kPopupMultiplier);
        
        self.hudContainerView = [[UIView alloc] initWithFrame:CGRectIntegral(CGRectMake(0, 0, self.circleRadius*2.5, self.circleRadius*2.5))];
        self.hudContainerView.backgroundColor = [UIColor clearColor];
        self.hudContainerView.clipsToBounds = NO;
        self.hudContainerView.opaque = NO;
        self.hudContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        // setup hud view and mask
        
        self.circleView = [[RZCircleView alloc] initWithRadius:initialRadius color:self.hudColor];
        self.circleView.borderWidth = self.borderWidth;
        self.circleView.borderColor = self.borderColor;
        self.circleView.clipsToBounds = NO;
        self.circleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.circleView.frame = self.hudContainerView.bounds;
        [self.hudContainerView addSubview:self.circleView];
        
        // add spinner view to center of circle view
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: self.circleRadius < 25 ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleWhiteLarge];
        self.spinnerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.spinnerView.hidesWhenStopped = YES;
        self.spinnerView.color = self.spinnerColor;
        self.spinnerView.backgroundColor = [UIColor clearColor];
        self.spinnerView.center = CGPointMake(self.circleView.bounds.size.width/2,self.circleView.bounds.size.height/2);
        [self.circleView addSubview:self.spinnerView];
        
        // add empty view to host shadow layer
        self.shadowView = [[UIView alloc] initWithFrame:self.hudContainerView.bounds];
        self.shadowView.backgroundColor = [UIColor clearColor];
        self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.shadowView.clipsToBounds = NO;
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOpacity = 0.0;
        self.shadowView.layer.shadowRadius = 1.0;
        self.shadowView.layer.shadowPath = [UIBezierPath circlePathWithRadius:initialRadius center:self.shadowView.center].CGPath;
        [self.hudContainerView insertSubview:self.shadowView atIndex:0];
    }
}

- (void)setupPageFlipper:(BOOL)open{
    self.pageFlipper = [[ControllablePageFlipper alloc] initWithOriginalView:self.superview
                                                                  targetView:self.hudContainerView
                                                                   fromState:open ? kCPF_Open : kCPF_Closed 
                                                                   fromRight:YES];
    self.pageFlipper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.pageFlipper.delegate = self;
    self.pageFlipper.animationTime = kDefaultFlipTime;
    self.pageFlipper.shadowMask = kCPF_NoShadow;
    
    CGFloat initialRadius = roundf(self.circleRadius/kPopupMultiplier);
    [self.pageFlipper maskToCircleWithRadius:initialRadius];
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
    UIView *hudView = nil;
    if (self.hudStyle == RZHudStyleCircle)
        hudView = self.hudContainerView;
    else if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo)
        hudView = self.hudBoxView;
    
    hudView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    hudView.frame = CGRectIntegral(hudView.frame);
    
    if (self.usingFold && self.hudStyle != RZHudStyleOverlay){
        [self setupPageFlipper:NO];
        [self addSubview:self.pageFlipper];
        [self.pageFlipper animateToState:kCPF_Open];
    }
    else{
        BOOL shouldFade = (self.presentationStyle & RZHudAnimationMaskFade) == RZHudAnimationMaskFade;
        BOOL shouldZoom = (self.presentationStyle & RZHudAnimationMaskZoom) == RZHudAnimationMaskZoom;
        
        if (self.hudStyle != RZHudStyleOverlay)
        {
            if (shouldFade)
            {
                hudView.alpha = 0.0;
            }
            if (shouldZoom)
            {
                hudView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            }
            [self addSubview:hudView];
        }
        [UIView animateWithDuration:kDefaultOverlayTime
                         animations:^{
                             if (shouldFade)
                             {
                                 hudView.alpha = 1.0;
                             }
                             if (shouldZoom)
                             {
                                 hudView.transform = CGAffineTransformIdentity;
                             }
                             self.backgroundColor = self.overlayColor;
                         }
                         completion:^(BOOL finished) {
                             if (self.hudStyle == RZHudStyleCircle){
                                 [self popOutCircle:YES];
                             }
                             else if (self.hudStyle == RZHudStyleBoxLoading || self.hudStyle == RZHudStyleBoxInfo){
                                 self.fullyPresented = YES;
                                 if (self.pendingDismissal){
                                     [self dismiss];
                                 }
                             }
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
                
        [self animateCircleShadowToPath:[self shadowPathForRadius:self.circleRadius raisedState:YES].CGPath
                           shadowRadius:3.0
                                  alpha:self.shadowAlpha
                                  curve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                               duration:kDefaultSizeTime];
        
        
        [self.circleView animateToRadius:self.circleRadius
                               withCurve:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                duration:kDefaultSizeTime
                              completion:^{
                                  [self.spinnerView startAnimating];
                                  self.fullyPresented = YES;
                                  if (self.pendingDismissal){
                                      [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
                                  }
                              }];
    }
    else{
        
        [self.spinnerView stopAnimating];
        
        CGFloat newRadius = roundf(self.circleRadius / kPopupMultiplier);
        
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
    CGRect shadowEllipseRect = CGRectMake(raised ? containerCenter.x - (radius*1.025) : containerCenter.x - radius, 
                                          raised ? containerCenter.y - (radius*0.97) : containerCenter.y - radius,
                                          raised ? radius * 2.05 : radius*2,
                                          raised ? radius * 2.2 : radius*2);
    
    return [UIBezierPath bezierPathWithOvalInRect:shadowEllipseRect];
}

#pragma mark - Properties

- (void)setBlocksTouches:(BOOL)blocksTouches
{
    _blocksTouches = blocksTouches;
    self.userInteractionEnabled = blocksTouches;
}

- (void)setHudStyle:(RZHudStyle)hudStyle
{
    if (self.superview){
        NSLog(@"Cannot set HUD style after HUD is presented!");
        return;
    }
    
    _hudStyle = hudStyle;
}

- (void)setCircleRadius:(CGFloat)circleRadius
{
    if (self.superview){
        NSLog(@"Cannot set HUD circle radius after HUD is presented!");
        return;
    }
    
    _circleRadius = circleRadius;
}

- (void)setCustomView:(UIView *)customView
{
    _customView = customView;
    self.hudBoxView.customView = customView;
}

- (void)setImageViewAnimationArray:(NSArray *)imageViewAnimationArray
{
    _imageViewAnimationArray = imageViewAnimationArray;
    
    UIImageView *customView = [[UIImageView alloc] init];
    customView.animationImages = imageViewAnimationArray;
    customView.animationDuration = self.imageViewAnimationDuration;
    customView.contentMode = UIViewContentModeScaleAspectFit;
    customView.frame = kDefaultPNGImageViewFrame;
    
    [customView startAnimating];
    
    [self setCustomView:customView];
}

- (void)setImageViewAnimationDuration:(CGFloat)imageViewAnimationDuration
{
    _imageViewAnimationDuration = imageViewAnimationDuration;
    
    if(self.imageViewAnimationArray != nil)
    {
        if([self.customView isKindOfClass:[UIImageView class]] && [(UIImageView *)self.customView animationImages].count > 0)
        {
            [(UIImageView *)self.customView stopAnimating];
            [(UIImageView *)self.customView setAnimationDuration:imageViewAnimationDuration];
            [(UIImageView *)self.customView startAnimating];
        }
    }
}

- (NSString*)labelText
{
    if (_labelText == nil){
        return @"Loading…";
    }
    return _labelText;
}

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    
    // use property here to use default if argument is nil
    self.hudBoxView.labelText = self.labelText;
}

// Most of the below overrides are for UIAppearance to work properly

- (void)setHudColor:(UIColor *)hudColor
{
    switch (self.hudStyle) {
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.color = hudColor;
            break;
            
        case RZHudStyleCircle:
            self.circleView.color = hudColor;
            break;
            
        default:
            break;
    }
    
    _hudColor = hudColor;
}

- (void)setSpinnerColor:(UIColor *)spinnerColor
{
    switch (self.hudStyle) {
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.spinnerColor = spinnerColor;
            break;
            
        case RZHudStyleCircle:
            self.spinnerView.color = spinnerColor;
            break;
            
        default:
            break;
    }
    
    _spinnerColor = spinnerColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    switch (self.hudStyle) {
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.borderColor = borderColor;
            break;
            
        case RZHudStyleCircle:
            self.circleView.borderColor = borderColor;
            break;
            
        default:
            break;
    }
    
    _borderColor = borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    switch (self.hudStyle) {
        case RZHudStyleBoxInfo:
        case RZHudStyleBoxLoading:
            self.hudBoxView.borderWidth = borderWidth;
            break;
            
        case RZHudStyleCircle:
            self.circleView.borderWidth = borderWidth;
            break;
            
        default:
            break;
    }
    
    _borderWidth = borderWidth;
}

- (void)setLabelFont:(UIFont *)labelFont
{
    _labelFont = labelFont;
    self.hudBoxView.labelFont = labelFont;
}

- (void)setLabelColor:(UIColor *)labelColor
{
    _labelColor = labelColor;
    self.hudBoxView.labelColor = labelColor;
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha
{
    _shadowAlpha = shadowAlpha;
    self.hudBoxView.shadowAlpha = shadowAlpha;
    // no need to set on circle view, it will be animated to target
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.hudBoxView.cornerRadius = cornerRadius;
}

#pragma mark - Controllable page flipper delegate

- (void)didFinishAnimatingToState:(CPFFlipState)state withTargetView:(UIView *)targetView{
    if (state == kCPF_Open)
    {
        [self addSubview:self.hudContainerView];
        
        [UIView animateWithDuration:kDefaultOverlayTime
                         animations:^{
                             self.backgroundColor = self.overlayColor;
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
