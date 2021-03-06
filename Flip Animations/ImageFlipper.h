//
//  ImageFlipper.h
//
//  Created by Craig Spitzkoff on 1/26/12.
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

#import <Foundation/Foundation.h>

extern NSString* const kRightAnimKey;
extern NSString* const kLeftAnimKey;
extern CFTimeInterval const kFlipperDuration;
extern CFTimeInterval const kFlipperPageSpacing;
extern CGFloat const kFlipperMaxShadowOpacity;
extern CGFloat const kFlipperMaxGradientOpacity;

@class ImageFlipper;

@protocol ImageFlipperDelegate <NSObject>

-(void) imageFlipperComplete:(ImageFlipper*)flipper; 

@end

@interface ImageFlipper : UIView

@property (nonatomic, assign) CFTimeInterval duration;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages;

-(id) initWithOriginalImage:(UIImage*)originalImage targetImage:(UIImage*)targetImage delegate:(id<ImageFlipperDelegate>)delegate frame:(CGRect)frame pages:(NSInteger)nPages allowRetina:(BOOL)allowRetina;

-(void) flip;
-(void) flipWithDelay:(CFTimeInterval)delay;
-(void) flipWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration;

-(void) flipBack;
-(void) flipBackWithDelay:(CFTimeInterval)delay;
-(void) flipBackWithDelay:(CFTimeInterval)delay duration:(CFTimeInterval)duration;

-(UIImage*)originalImage;
-(UIImage*)targetImage;

@end
