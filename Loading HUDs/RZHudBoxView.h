//
//  RZHudBoxView.h
//  Rue La La
//
//  Created by Nick Donaldson on 6/12/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RZHudBoxView : UIView

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) UIColor *color;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;

@property (nonatomic, assign) NSString *labelText;
@property (nonatomic, assign) UIColor *labelColor;
@property (nonatomic, assign) UIFont *labelFont;

- (id)initWithColor:(UIColor*)color cornerRadius:(CGFloat)cornerRadius;

@end
