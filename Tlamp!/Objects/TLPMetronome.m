//
//  TLPMetronome.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

#import "TLPMetronome.h"

NSString *const MetroAction = @"me.ikhsan.tlamp.metroAction";

@interface TLPMetronome ()

@property (nonatomic) NSInteger ticker;
@property (nonatomic) NSInteger tempo;

@end

CGFloat bpmForTempo(NSInteger tempo) {
    double tempos[] = {60., 90., 120.};
    return tempos[tempo-1];
}

@implementation TLPMetronome

+ (instancetype)createMetronomeWithDelegate:(SKScene <TLPMetronomeDelegate>*)delegate
{
    TLPMetronome *m = [self new];
    m.delegate = delegate;
    
    return m;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _tempo = 1;
    _bpm = bpmForTempo(_tempo);
    
    return self;
}

- (void)setBpm:(CGFloat)bpm
{
    _bpm = bpm;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(metronomeDidChangeBpm:)])
    {
        [self.delegate metronomeDidChangeBpm:self];
    }
}

- (void)setTicker:(NSInteger)ticker
{
    if (ticker < 9)
        _ticker = ticker;
    else
        _ticker = (ticker % 8);
}

- (void)setTempo:(NSInteger)tempo
{
    if (tempo < 1 || tempo > 3) return;
    
    _tempo = tempo;
    
    if (_playing)
    {
        [self stop];
        _bpm = bpmForTempo(_tempo);
        [self start];
    }
    else
    {
        self.bpm = bpmForTempo(_tempo);
    }
}

- (CGFloat)beat
{
    return beatInterval(_bpm);
}

#pragma mark - Start/stop metronome

- (void)toggle
{
    if (!self.isPlaying)
    {
        [self start];
    }
    else
    {
        [self stop];
    }
}

- (void)start
{
    if (!self.delegate) return;
    
    if ([self.delegate respondsToSelector:@selector(metronomeShouldStart:)])
        [self.delegate metronomeShouldStart:self];
    
    // tick every beat
    SKAction *advanceTicker = [SKAction runBlock:^{
        self.ticker++;
    }];
    
    // tick metro & note
    SKAction *tick = [SKAction sequence:@[[SKAction runBlock:^{
        if ([self.delegate respondsToSelector:@selector(metronome:tickerAtCount:)])
            [self.delegate metronome:self tickerAtCount:self.ticker];
    }], [SKAction waitForDuration:beatInterval(self.bpm) / 2.]]];
    
    // play metro & guide
    SKAction *moveTicker = [SKAction sequence:@[advanceTicker, tick]];
    SKAction *metro = [SKAction repeatActionForever:moveTicker];
    [self.delegate runAction:metro withKey:MetroAction];
    
    self.playing = YES;
}

- (void)stop
{    
    self.playing = NO;
    
    // reset ticker
    self.ticker = 0;
    
    // remove existing actions
    [self.delegate removeActionForKey:MetroAction];
    
    if ([self.delegate respondsToSelector:@selector(metronomeDidStop:)])
        [self.delegate metronomeDidStop:self];
}

- (void)increment
{
    self.tempo++;
}

- (void)decrement
{
    self.tempo--;
}

@end
