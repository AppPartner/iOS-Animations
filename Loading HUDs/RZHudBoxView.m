//
//  RZHudBoxView.m
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "RZHudBoxView.h"

#define kDefaultHUDSize CGSizeMake(120, 80)

@interface RZHudBoxView ()

@property (nonatomic, strong) RZHudBoxLayer *hudBoxLayer;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation RZHudBoxView

@synthesize labelText = _labelText;
@synthesize labelFont = _labelFont;
@synthesize labelColor = _labelColor;

@synthesize hudBoxLayer = _hudBoxLayer;
@synthesize messageLabel = _messageLabel;

- (id)initWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius
{
    if (self = [super initWithFrame:(CGRect){CGPointZero, kDefaultHUDSize}])
    {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        self.hudBoxLayer = [[RZHudBoxLayer alloc] initWithSize:kDefaultHUDSize color:color cornerRadius:cornerRadius];
        [self.layer addSublayer:self.hudBoxLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    self.hudBoxLayer.frame = self.bounds;
    if (self.messageLabel){
        
    }
}

#pragma mark - Properties

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    
    if (!self.messageLabel){
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    
    self.messageLabel.text = labelText;
    
    if (labelText.length && !self.messageLabel.superview){
        [self addSubview:self.messageLabel];
    }
    else {
        [self.messageLabel removeFromSuperview];
    }
}

- (void)setLabelColor:(UIColor *)labelColor
{
    _labelColor = labelColor;
    
    if (!self.messageLabel){
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    
}

- (void)setLabelFont:(UIFont *)labelFont
{
    if (!self.messageLabel){
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    
    
}

- (UIColor*)color
{
    return self.hudBoxLayer.color;
}

- (void)setColor:(UIColor *)color
{
    self.hudBoxLayer.color = color;
}

- (CGFloat)cornerRadius
{
    return self.hudBoxLayer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.hudBoxLayer.cornerRadius = cornerRadius;
}

- (CGFloat)borderWidth
{
    return self.hudBoxLayer.boxBorderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.hudBoxLayer.boxBorderWidth = borderWidth;
}

- (UIColor*)borderColor
{
    return self.hudBoxLayer.boxBorderColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.hudBoxLayer.boxBorderColor = borderColor;
}


@end
