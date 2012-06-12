//
//  RZHudBoxLayer.h
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface RZHudBoxLayer : CALayer

@property (strong) UIColor *color;
@property (assign) CGFloat boxCornerRadius;
@property (assign) CGFloat boxBorderWidth;
@property (strong) UIColor *boxBorderColor;

- (id)initWithSize:(CGSize)size color:(UIColor*)color cornerRadius:(CGFloat)cornerRadius;

@end
