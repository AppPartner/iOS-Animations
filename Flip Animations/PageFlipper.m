//
//  PageFlipper.m
//
//  Created by Craig Spitzkoff on 1/24/12.
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
#import "PageFlipper.h"
#import "ImageFlipper.h"

@interface PageFlipper()

// target and host views for manipulations after the animations complete. 
@property (nonatomic, strong) UIView* targetView;
@property (nonatomic, strong) UIView* hostView;
@property (nonatomic, strong) ImageFlipper* imageFlipperView;
@property (nonatomic, strong) UIImage* defaultPartialImage;
@property (nonatomic, assign) BOOL closeFlip;
- (void)setupImageFlipper;

@end

@implementation PageFlipper

@synthesize targetView = _targetView;
@synthesize hostView = _hostView;
@synthesize imageFlipperView = _imageFlipperView;
@synthesize defaultPartialImage = _defaultPartialImage;
@synthesize delegate = _delegate;
@synthesize closeFlip = _closeFlip;
@synthesize backgroundView = _backgroundView;
@synthesize flipDuration = _flipDuration;

-(id) initWithHostView:(UIView*)hostView targetView:(UIView*)targetView
{
    self = [super init];
    
    if(self)
    {
        self.targetView = targetView;
        self.hostView = hostView;
        self.flipDuration = CGFLOAT_MAX;
    }
    
    return self;
}

- (void)setupImageFlipper
{
    CGRect frame = self.targetView.frame;
    self.closeFlip = NO;
    // capture left and right images for the host view within the target frame and the target view
    UIImage* fullHostImage = [self.hostView imageByRenderingView];
    CGImageRef partialHostImageRef = CGImageCreateWithImageInRect(fullHostImage.CGImage, frame);
    UIImage* partialHostImage = [UIImage imageWithCGImage:partialHostImageRef];
    
    //If this is our first setup.  Save the default view Image
    if (self.defaultPartialImage == nil)
        self.defaultPartialImage = partialHostImage;
    
    CGImageRelease(partialHostImageRef);
    
    UIImage* targetImage = [self.targetView imageByRenderingView];
    
    self.imageFlipperView = [[ImageFlipper alloc] initWithOriginalImage:partialHostImage targetImage:targetImage delegate:self frame:frame];
    
    if (self.flipDuration != CGFLOAT_MAX) {
        self.imageFlipperView.duration = self.flipDuration;
    } else {
        self.imageFlipperView.duration = kFlipperDuration;
    }
    
    [self.hostView addSubview:self.imageFlipperView];
}


-(void)setupImageFlipperForClose
{
    CGRect frame = self.targetView.frame;
    self.closeFlip = YES;
    UIImage* partialHostImage;
    //If we have a default background View.  Use that to get the background.  Otherwise Use our saved Image.
    if (self.backgroundView) 
    {
        UIImage* fullHostImage = [self.backgroundView imageByRenderingView];
        CGImageRef partialHostImageRef = CGImageCreateWithImageInRect(fullHostImage.CGImage, frame);
        partialHostImage = [UIImage imageWithCGImage:partialHostImageRef];
        CGImageRelease(partialHostImageRef);
    }
    else
    {
        partialHostImage = self.defaultPartialImage;
    }
    
    UIImage* targetImage = [self.targetView imageByRenderingView];
    self.imageFlipperView = [[ImageFlipper alloc] initWithOriginalImage:targetImage targetImage:partialHostImage delegate:self frame:frame];
    
    if (self.flipDuration != CGFLOAT_MAX) {
        self.imageFlipperView.duration = self.flipDuration;
    }
    
    [self.hostView addSubview:self.imageFlipperView];
    [self.targetView removeFromSuperview];
}

-(void) flip
{
    [self setupImageFlipper];
    [self.imageFlipperView flip];
}

-(void) flipBack
{
    [self setupImageFlipper];
    [self.imageFlipperView flipBack];
}

-(void) flipWithDelay:(CFTimeInterval)delay
{
    [self setupImageFlipper];
    [self.imageFlipperView flipWithDelay:delay];
}

-(void) flipBackWithDelay:(CFTimeInterval)delay
{
    [self setupImageFlipper];
    [self.imageFlipperView flipBackWithDelay:delay];
}

-(void) imageFlipperComplete:(ImageFlipper *)flipper
{
    //If we are closing, we dont want to add the targetView at the end.
    if(!self.closeFlip)
    {
        [self.hostView addSubview:self.targetView];
    }
    [flipper removeFromSuperview];
    [self.delegate didFinishPageFlipWithTargetView:self.targetView wasCloseFlip:self.closeFlip];
}

-(void) closeFlipViewBackDirection:(BOOL)back
{
    [self setupImageFlipperForClose];
    if (!back) 
        [self.imageFlipperView flip];
    else
        [self.imageFlipperView flipBack];
}


@end
