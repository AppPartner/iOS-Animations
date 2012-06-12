//
//  RZHudBoxView.m
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RZHudBoxView.h"

#define kDefaultHUDSizeIpad CGSizeMake(140, 120)
#define kMaxWidthIpad       280
#define kLabelPadding       15

@interface RZHudBoxView ()

@property (nonatomic, strong) UILabel *messageLabel;

- (UIBezierPath*)boxMaskPath;
- (void)layoutBoxForMessageLabelWithMessage:(NSString*)message animated:(BOOL)animated;

@end

@implementation RZHudBoxView

@synthesize color = _color;
@synthesize cornerRadius = _cornerRadius;
@synthesize borderColor = _borderColor;
@synthesize borderWidth = _borderWidth;

@synthesize messageLabel = _messageLabel;

- (id)initWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    if (self = [super initWithFrame:(CGRect){CGPointZero, kDefaultHUDSizeIpad}])
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.color = color;
        self.cornerRadius = cornerRadius;
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.messageLabel.backgroundColor = [UIColor clearColor];
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.messageLabel.adjustsFontSizeToFitWidth = NO;
        self.messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.messageLabel.textAlignment = UITextAlignmentCenter;
        self.messageLabel.font = [UIFont systemFontOfSize:18];
        self.messageLabel.shadowColor = [UIColor clearColor];
        
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 0.15;
    }
    return self;
}

- (void)layoutSubviews
{
    self.layer.shadowPath = [self boxMaskPath].CGPath;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // outline path
    UIBezierPath *outlinePath = [self boxMaskPath];
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.borderColor ? self.borderColor.CGColor : [UIColor clearColor].CGColor);
    CGContextSetLineWidth(ctx, self.borderWidth);
    CGContextAddPath(ctx, outlinePath.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

- (void)layoutBoxForMessageLabelWithMessage:(NSString*)message animated:(BOOL)animated
{
    
    CGSize labelSize = [message sizeWithFont:self.labelFont constrainedToSize:CGSizeMake(kMaxWidthIpad - 2*kLabelPadding, 50000)];

    
    CGRect theframe = self.frame;
    CGFloat newWidth = labelSize.width + 2.0*kLabelPadding;
    CGFloat oldWidth = theframe.size.width;
    theframe.size.width = newWidth;
    theframe.origin.x -= (newWidth - oldWidth)/2.0;
    
    CGRect newMessageFrame = (CGRect){CGPointZero, labelSize};
    newMessageFrame.origin.x = kLabelPadding;
    newMessageFrame.origin.y = (theframe.size.height*3/4) - labelSize.height/2;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.frame = theframe;
                             self.messageLabel.frame = newMessageFrame;
                         }];
        [UIView transitionWithView:self.messageLabel
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.messageLabel.text = message;
                        } 
                        completion:NULL
         ];

    }
    else
    {
        self.frame = theframe;
        self.messageLabel.frame = newMessageFrame;
        self.messageLabel.text = message;
    }
}

- (UIBezierPath*)boxMaskPath
{
    // outline path
    CGRect insetBounds = CGRectInset(self.bounds, self.borderWidth/2, self.borderWidth/2);
    if (self.cornerRadius > 0.0)
        return [UIBezierPath bezierPathWithRoundedRect:insetBounds cornerRadius:self.cornerRadius];
    else
        return [UIBezierPath bezierPathWithRect:insetBounds];
}

#pragma mark - Properties

- (NSString*)labelText
{
    return self.messageLabel.text;
}

- (void)setLabelText:(NSString *)labelText
{    
    
    if (labelText.length != 0 && !self.messageLabel.superview){
        [self addSubview:self.messageLabel];
    }
    
    if (labelText.length == 0 && self.messageLabel.superview){
        [self.messageLabel removeFromSuperview];
    }
    
    [self layoutBoxForMessageLabelWithMessage:labelText animated:(self.messageLabel.superview && self.superview)];
    
}

- (UIColor*)labelColor
{    
    return self.messageLabel.textColor;
}

- (void)setLabelColor:(UIColor *)labelColor
{
    self.messageLabel.textColor = labelColor;
}

- (UIFont*)labelFont
{
    return self.messageLabel.font;
}

- (void)setLabelFont:(UIFont *)labelFont
{
    self.messageLabel.font = labelFont;
    [self layoutBoxForMessageLabelWithMessage:self.labelText animated:(self.messageLabel.superview && self.superview)];
}

@end
