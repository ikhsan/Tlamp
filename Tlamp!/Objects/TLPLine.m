//
//  TLPLine.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPLine.h"

@implementation TLPLine

+ (instancetype)lineWithColor:(SKColor *)color from:(CGPoint)p1 to:(CGPoint)p2
{
    SKShapeNode *line = [SKShapeNode node];
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    
    line.path = path;
    CGPathRelease(path);
    
    line.strokeColor = color;
    line.lineWidth = 0.2;
    line.glowWidth = 6.0;
    line.blendMode = SKBlendModeAlpha;
    line.antialiased = YES;
    
    return (TLPLine *)line;
}

@end
