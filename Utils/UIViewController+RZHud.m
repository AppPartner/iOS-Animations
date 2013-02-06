//
//  UIViewController+RZHud.m
//  Rue La La
//
//  Created by Nick Donaldson on 3/16/12.
//  Copyright (c) 2012 Raizlabs Corporation. All rights reserved.
//

#import "UIViewController+RZHud.h"
#import <objc/runtime.h>

static char * const kRZHudAssociationKey = "RZHudKey";

@implementation UIViewController (RZHud)

-(void)setHud:(RZHud *)hud
{
    objc_setAssociatedObject(self, kRZHudAssociationKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(RZHud*)hud
{
    return objc_getAssociatedObject(self, kRZHudAssociationKey);
}

-(void) showHUD{
    [self showHUDWithMessage:@"Loading…" inView:self.view];
}

-(void) showHUDOnRoot{
    [self showHUDWithMessageOnRoot:@"Loading…"];
}

-(void) showHUDWithMessage:(NSString *)message{
    [self showHUDWithMessage:message inView:self.view];
}

- (void) showHUDWithMessageOnRoot:(NSString*)message
{
    UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
    [self showHUDWithMessage:message inView:rootView];
}

-(void) showHUDWithMessage:(NSString*)message inView:(UIView*)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxLoading];
    self.hud.labelText = message;
    [self.hud presentInView:view withFold:NO];
}

-(void) showInfoHUDWithMessage:(NSString *)message customView:(UIView *)customView inView:(UIView *)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxInfo];
    self.hud.labelText = message;
    self.hud.customView = customView;
    [self.hud presentInView:view withFold:NO];
}


-(void) showOverlayOnlyHUDOnRoot:(BOOL)root
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    [self hideHUD];
    UIView *hudParent = root ? [[[UIApplication sharedApplication] keyWindow] rootViewController].view : self.view;
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleOverlay];
    [self.hud presentInView:hudParent withFold:NO];
}

-(void) hideHUDWithCompletionBlock:(void (^)())block{
    if (![self respondsToSelector:@selector(setHud:)]){
        block();
        return;
    }
    
    [self.hud dismissWithCompletionBlock:block];
    self.hud = nil;
}

-(void) hideHUD
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self.hud dismiss];
    self.hud = nil;
}

@end
