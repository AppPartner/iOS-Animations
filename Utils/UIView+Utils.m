//
//  UIView+Utils.m
//
//  Created by Craig Spitzkoff on 12/9/11.
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
#import "UIView+Utils.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Utils)

- (UIImage *) imageByRenderingView
{
   return [self imageByRenderingViewWithRetina:YES];
}

- (UIImage *) imageByRenderingViewWithRetina:(BOOL)allowRetina {
	CGFloat oldAlpha = self.alpha;
	
	self.alpha = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && allowRetina)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    else    
        UIGraphicsBeginImageContext(self.bounds.size);
    
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.alpha = oldAlpha;
	
	return resultingImage;
}


+ (CGRect)interpolateRectFrom:(CGRect)sourceRect to:(CGRect)destRect progress:(CGFloat)progress{
    
    CGFloat originX = ((destRect.origin.x - sourceRect.origin.x)*progress) + sourceRect.origin.x;
    CGFloat originY = ((destRect.origin.y - sourceRect.origin.y)*progress) + sourceRect.origin.y;
    CGFloat width = ((destRect.size.width - sourceRect.size.width)*progress) + sourceRect.size.width;
    CGFloat height = ((destRect.size.height - sourceRect.size.height)*progress) + sourceRect.size.height;
    
    return CGRectMake(originX, originY, width, height);
}

@end
