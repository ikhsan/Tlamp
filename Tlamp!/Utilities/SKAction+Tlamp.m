//
//  SKAction+Tlamp.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKAction+Tlamp.h"

CGFloat const fadeDuration = .2;

@implementation SKAction (Tlamp)

+ (SKAction *)moveTo:(CGPoint)p scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale tempo:(CGFloat)tempo
{
    CGFloat beat = beatInterval(tempo);
    
    SKAction *moveAction = [SKAction moveTo:p duration:(beat * 4)];
    SKAction *scaleAction = [SKAction scaleXBy:xScale y:yScale duration:(beat * 4)];
    SKAction *action = [SKAction group:@[moveAction, scaleAction]];
    
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
    
    return fades;
}

+ (SKAction *)fadesTo:(CGPoint)p scaleBy:(CGFloat)scale tempo:(CGFloat)tempo
{
    return [self fadesTo:p scaleXBy:scale yBy:scale tempo:tempo];
}

+ (SKAction *)fadeIn
{
    SKAction *fade = [SKAction fadeAlphaTo:1. duration:fadeDuration];
    fade.timingMode = SKActionTimingEaseIn;
    return fade;
}

+ (SKAction *)fadeOut
{
    SKAction *fade = [SKAction fadeAlphaTo:0. duration:fadeDuration];
    fade.timingMode = SKActionTimingEaseIn;
    return fade;
}

+ (SKAction *)flashWithDuration:(NSTimeInterval)duration
{
    SKAction *fadeIn = [SKAction fadeAlphaTo:1. duration:fadeDuration];
    fadeIn.timingMode = SKActionTimingEaseIn;
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0. duration:fadeDuration];
    fadeOut.timingMode = SKActionTimingEaseIn;
    
    SKAction *wait = [SKAction waitForDuration:duration];
    
    SKAction *removeMe = [SKAction removeFromParent];
    
    return [SKAction sequence:@[fadeIn, wait, fadeOut, removeMe]];
}

//+ (SKAction *)playNote:(int)note
//{
//    NSString *noteName = [NSString stringWithFormat:@"talempong_pacik_0%d.wav", note];
//    return [SKAction playSoundFileNamed:noteName waitForCompletion:NO];
//}

//+ (SKAction *)playGendang:(GendangHit)hit
//{
//    NSString *noteName;
//    switch (hit) {
//        case GendangHitClosed:
//            noteName = @"gendang_closed.wav";
//            break;
//        case GendangHitOpen:
//            noteName = @"gendang_open.wav";
//            break;
//            
//        default:
//            break;
//    }
//    
//    return [SKAction playSoundFileNamed:noteName waitForCompletion:NO];
//}

@end
