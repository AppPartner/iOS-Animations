//
//  RZCircleLayer.h
//  Raizlabs
//
//  Created by Nick Donaldson on 5/22/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RZCircleLayer : CALayer

@property (assign, nonatomic) CGFloat radius;
@property (retain, nonatomic) UIColor *color;

- (id)initWithRadius:(CGFloat)radius color:(UIColor*)color;

@end
