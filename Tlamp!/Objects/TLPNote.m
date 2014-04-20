//
//  TLPNote.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPSFX.h"

#import "TLPNote.h"

@interface TLPNote ()

@property (nonatomic) int note;
@property (weak, nonatomic) SKEmitterNode *emitter;

@end

@implementation TLPNote

+ (instancetype)makeNote:(int)note withFrame:(CGRect)frame
{
    return [[self alloc] initWithNote:note withFrame:frame];
}

- (instancetype)initWithNote:(int)note withFrame:(CGRect)frame
{
    if (!(self = [super init])) return nil;
    
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:loadParticle(@"HitParticle")];
    emitter.numParticlesToEmit = 1;
    [emitter advanceSimulationTime:1000];
    emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[color(note)] times:@[@0]];
    emitter.particleColorBlendFactor = 1.0;
    [self addChild:emitter];
    self.position = positionForNote(note, frame);
    
    self.emitter = emitter;
    
    self.note = note;
    
    return self;
}

- (void)playNote
{
    [[TLPSFX player] playNote:self.note];
}


@end
