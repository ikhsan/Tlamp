//
//  SKAction+Tlamp.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKAction+Tlamp.h"

@implementation SKAction (Tlamp)

+ (SKAction *)moveTo:(CGPoint)p scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale tempo:(CGFloat)tempo
{
    CGFloat beat = beatInterval(tempo);
    
    SKAction *moveAction = [SKAction moveTo:p duration:(beat * 4)];
    SKAction *scaleAction = [SKAction scaleXBy:xScale y:yScale duration:(beat * 4)];
    SKAction *action = [SKAction group:@[moveAction, scaleAction]];
//    action.timingMode = SKActionTimingEaseIn;
    
    return action;
    
}

+ (SKAction *)moveTo:(CGPoint)p scaleBy:(CGFloat)scale tempo:(CGFloat)tempo;
{
    return [self moveTo:p scaleXBy:scale yBy:scale tempo:tempo];
}

+ (SKAction *)fadesTo:(CGPoint)p scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale tempo:(CGFloat)tempo
{
    CGFloat beat = beatInterval(tempo);
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0. duration:(beat * .66)];
    SKAction *moveFadeOut = [SKAction moveTo:p duration:beat];
    SKAction *scaleFadeOut = [SKAction scaleXBy:xScale y:yScale duration:beat];
    SKAction *fades = [SKAction group:@[fadeOut, moveFadeOut, scaleFadeOut]];
//    fades.timingMode = SKActionTimingEaseIn;
    
    return fades;
}

+ (SKAction *)fadesTo:(CGPoint)p scaleBy:(CGFloat)scale tempo:(CGFloat)tempo
{
    return [self fadesTo:p scaleXBy:scale yBy:scale tempo:tempo];
}

@end
