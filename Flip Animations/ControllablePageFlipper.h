//
//  ControllablePageFlipper.h
//
//  Created by Nick Donaldson on 3/29/12.
//
// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//========================================================
//
// A view with a controllable 'percentOpen' which sets the
// 3D transform on an inner page layer. Can also be animated
// open and closed.
//
// Currently, the right source panel when in the 'open' state
// is transparent. Could be extended to add another page there.
//
//=======================================================

#import <UIKit/UIKit.h>

typedef enum {
    kCPF_Closed,
    kCPF_Open
} CPFFlipState;

typedef enum {
    kCPF_NoShadow       = 0x00,
    kCPF_LeftShadow     = 0x01,
    kCPF_RightShadow    = 0x02,
    kCPF_TopShadow      = 0x04,
    kCPF_BottomShadow   = 0x08,
    kCPF_FullShadow     = 0x0F
} CPFShadowMask;

extern CFTimeInterval const kCPFPageTurnSmoothingTime;
extern CFTimeInterval const kCPFTotalFlipAnimationTime;
extern CGFloat const kCPFPageZDistance;
extern CGFloat const kCPFDropShadowRadius;
extern CGFloat const kCPFDropShadowMaxOpacity;
extern CGFloat const kCPFPageShadowMaxOpacity;
extern CGFloat const kCPFFlipGradientMaxOpacity;


// might want to abstract this into a utility file
extern float normalize(float input, float min, float max);

@protocol CPFlipperDelegate <NSObject>

- (void)didFinishAnimatingToState:(CPFFlipState)state withTargetView:(UIView*)targetView;

@end


@interface ControllablePageFlipper : UIView

@property (weak, nonatomic) UIView *targetView;
@property (assign, nonatomic) NSInteger shadowMask;
@property (assign, nonatomic) CFTimeInterval animationTime;
@property (assign, nonatomic) BOOL opensFromRight;
@property (weak, nonatomic) id<CPFlipperDelegate> delegate;

- (id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage frame:(CGRect)frame fromState:(CPFFlipState)state fromRight:(BOOL)fromRight;;
- (id) initWithOriginalView:(UIView*)originalView targetView:(UIView*)targetView fromState:(CPFFlipState)state fromRight:(BOOL)fromRight;


//  Masks the flip layer so it opens as a semi-circle.
//  Useful when your content is circular (or not)
- (void)maskToCircleWithRadius:(CGFloat)radius;

- (void)setPercentOpen:(CGFloat)percentOpen;
- (void)setPercentOpen:(CGFloat)percentOpen withAnimationTime:(CFTimeInterval)time;
- (void)animateToState:(CPFFlipState)state;

@end
