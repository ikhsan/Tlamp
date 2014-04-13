//
//  TLPNote.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPNote.h"
#import "Helpers.h"

@interface TLPNote ()

@property (weak, nonatomic) SKEmitterNode *emitter;
@property int note;

@end

@implementation TLPNote

+ (instancetype)makeNote:(int)note withFrame:(CGRect)frame
{
    TLPNote *noteNode = [[TLPNote alloc] initWithNote:note];
    noteNode.position = positionForNote(note, frame);
    
    return noteNode;
}

- (instancetype)initWithNote:(int)note
{
    if (!(self = [super init])) return nil;
    
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:loadParticle(@"HitParticle")];
    emitter.numParticlesToEmit = 1;
    [emitter advanceSimulationTime:1000];
    emitter.particleColorSequence = [[SKKeyframeSequence alloc] initWithKeyframeValues:@[color(note)] times:@[@0]];
    emitter.particleColorBlendFactor = 1.0;
    [self addChild:emitter];
    
    self.emitter = emitter;
    self.note = note;
    
    return self;
}

- (void)playNote
{
    NSString *noteName = [NSString stringWithFormat:@"talempong_pacik_0%d.wav", self.note];
    SKAction *hitNote = [SKAction playSoundFileNamed:noteName waitForCompletion:NO];
    [self runAction:hitNote];
}

@end
