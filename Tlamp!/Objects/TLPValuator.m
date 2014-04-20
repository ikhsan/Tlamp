//
//  TLPValuator.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/19/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPValuator.h"

@interface TLPValuator ()

@property (weak, nonatomic) SKEmitterNode *emitter;

@end


SKColor* valuatorColor(CGFloat mark)
{
//    CGFloat r = .94 - (.64 * mark);
//    CGFloat g = .20 + (.68 * mark);
//    CGFloat b = .24 + (.30 * mark);
    CGFloat r = 1. - mark;
    CGFloat g = mark;
    CGFloat b = 0.;
    
    
    return [SKColor colorWithRed:r green:g blue:b alpha:1.];
}

@implementation TLPValuator

+ (instancetype)makeValuatorWithMark:(CGFloat)mark
{
    return [[self alloc] initWithMark:mark];
}

- (instancetype)initWithMark:(CGFloat)mark
{
    if (!(self = [super init])) return nil;
    
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:loadParticle(@"ValuatorParticle")];
    emitter.numParticlesToEmit = 10;
    emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[valuatorColor(mark)] times:@[@0]];
    [self addChild:emitter];
    self.emitter = emitter;
    
    return self;
}

- (CGPoint)position
{
    return self.emitter.position;
}

- (void)setPosition:(CGPoint)position
{
    self.emitter.position = position;
}

@end
