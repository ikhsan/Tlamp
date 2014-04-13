//
//  SKColor+Tlamp.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"

CGFloat t(int color) {
    return color / 255.;
}

@implementation SKColor (Tlamp)

+ (SKColor *)tlp_redColor
{
    return [SKColor colorWithRed:t(242) green:t(71) blue:t(63) alpha:1.];
}

+ (SKColor *)tlp_greenColor
{
    return [SKColor colorWithRed:t(77) green:t(226) blue:t(140) alpha:1.];
}

+ (SKColor *)tlp_blueColor
{
    return [SKColor colorWithRed:t(67) green:t(114) blue:t(170) alpha:1.];
}

+ (SKColor *)tlp_yellowColor
{
    return [SKColor colorWithRed:t(229) green:t(227) blue:t(58) alpha:1.];
}

+ (SKColor *)tlp_orangeColor
{
    return [SKColor colorWithRed:t(237) green:t(145) blue:t(33) alpha:1.];
}

@end
