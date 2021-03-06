//
//  UIImage+RetinaUtils.m
//
//  Created by Nick Donaldson on 4/10/12.
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
#import "UIImage+RetinaUtils.h"

@implementation UIImage (RetinaUtils)

- (UIImage*)imageDrawnInRect:(CGRect)rect{
    
    CGRect scaledRect = rect;
    CGFloat imgScale = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0;
    scaledRect.origin.x *= imgScale;
    scaledRect.origin.y *= imgScale;
    scaledRect.size.width *= imgScale;
    scaledRect.size.height *= imgScale;
    CGImageRef scaledImgRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect);
    UIImage *scaledImg = [UIImage imageWithCGImage:scaledImgRef scale:imgScale orientation:self.imageOrientation];
    CGImageRelease(scaledImgRef);
    return scaledImg;
}

@end
