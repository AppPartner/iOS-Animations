//
//  UIViewController+RZHud.h
//  Rue La La
//
//  Created by Nick Donaldson on 3/16/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZHud.h"

@interface UIViewController (RZHud)

//! Show HUD with default message on current view
-(void) showHUD;

//! Show HUD with custom message on current view
-(void) showHUDWithMessage:(NSString*)message;

//! Show HUD with custom message on specified view
-(void) showHUDWithMessage:(NSString *)message inView:(UIView*)view;

//! Show HUD with default message on root view controller
-(void) showHUDOnRoot;

//! Show loading HUD on root view controller
-(void) showHUDOnRootWithMessage:(NSString*)message;

//! Shows informational HUD with optional accessory view
-(void) showInfoHUDWithMessage:(NSString*)message customView:(UIView*)customView inView:(UIView*)view;

//! Blocks all touches in app using transparent view
-(void) showOverlayOnlyHUDOnRoot:(BOOL)root;

//! Hide any hud that is being displayed
-(void) hideHUD;

//! Hide any hud that is being displayed with an optional completion block
-(void) hideHUDWithCompletionBlock:(void (^)())block;

//! The HUD currently being shown by this view controller, if any
@property (nonatomic, retain) RZHud* hud;

@end
