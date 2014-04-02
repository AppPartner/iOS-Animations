//
//  UIViewController+RZHud.m
//
//  Created by Nick Donaldson on 3/16/12.
//  Copyright 2014 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
    [self showHUDWithMessage:nil inView:self.view];
}

-(void) showHUDOnRoot{
    [self showHUDOnRootWithMessage:nil];
}

-(void) showHUDWithMessage:(NSString *)message{
    [self showHUDWithMessage:message inView:self.view];
}

- (void) showHUDOnRootWithMessage:(NSString*)message
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    [self showHUDWithMessage:message inView:rootView];
}

-(void) showHUDWithMessage:(NSString*)message inView:(UIView*)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxLoading];
    if (message != nil){
        self.hud.labelText = message;
    }
    [self.hud presentInView:view withFold:NO];
}

-(void) showInfoHUDOnRootWithMessage:(NSString*)message customView:(UIView*)customView
{
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    [self showInfoHUDWithMessage:message customView:customView inView:rootView];
}

-(void) showInfoHUDWithMessage:(NSString *)message customView:(UIView *)customView inView:(UIView *)view
{
    if (![self respondsToSelector:@selector(setHud:)]) return;
    
    [self hideHUD];
    
    self.hud = [[RZHud alloc] initWithStyle:RZHudStyleBoxInfo];
    if (message != nil){
        self.hud.labelText = message;
    }
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
    
    if (![self respondsToSelector:@selector(setHud:)] || self.hud == nil){
        if (block){
            block();
        }
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
