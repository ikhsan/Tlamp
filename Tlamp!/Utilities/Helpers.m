//
//  Helpers.c
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "Helpers.h"
#import "SKColor+Tlamp.h"

NSString* loadParticle(NSString *name)
{
    return [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
}

SKColor* color(int note)
{
    NSArray *colors = @[
        [SKColor orangeColor],
        [SKColor tlp_redColor],
        [SKColor tlp_yellowColor],
        [SKColor tlp_greenColor],
        [SKColor tlp_blueColor]
    ];
    return colors[note];
}

CGPoint positionForStartOfLine(int line, CGRect frame)
{
//    return CGPointMake(CGRectGetMidX(frame), CGRectGetHeight(frame) * .9);
    return CGPointMake((CGRectGetWidth(frame) * .2) * line, CGRectGetHeight(frame) - 4.0);
}

CGPoint positionForEndOfLine(int line, CGRect frame)
{
    return CGPointMake((CGRectGetWidth(frame) / 3.) * (line-1), 0.);
}

CGPoint positionForNoteGivenY(int note, CGFloat y, CGRect frame)
{
    // find gradient
    CGPoint p1 = positionForStartOfLine(note, frame);
    CGPoint p2 = positionForEndOfLine(note, frame);
    CGFloat m = (p2.y - p1.y) / (p2.x - p1.x);

    // find x from equation (y - y1) = m (x - x1)
    CGFloat x = ((y - p1.y) / m) + p1.x;
    return CGPointMake(x, y);
}

CGFloat positionForBaseline(CGRect frame)
{
    return CGRectGetHeight(frame) * .2;
}

CGPoint positionForNote(int note, CGRect frame)
{
    CGFloat y = positionForBaseline(frame);
    return positionForNoteGivenY(note, y, frame);
}

