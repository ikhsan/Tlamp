//
//  TLPMetronome.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TLPMetronome;
@class SKScene;

@protocol TLPMetronomeDelegate <NSObject>

- (void)metronomeDidChangeBpm:(TLPMetronome *)metronome;
- (void)metronomeShouldStart:(TLPMetronome *)metronome;
- (void)metronome:(TLPMetronome *)metronome tickerAtCount:(NSUInteger)count;
- (void)metronomeDidStop:(TLPMetronome *)metronome;


@end

@interface TLPMetronome : NSObject

@property (nonatomic) CGFloat bpm;
@property (nonatomic, getter = isPlaying) BOOL playing;
@property (nonatomic, assign) SKScene<TLPMetronomeDelegate>* delegate;
@property (nonatomic, readonly) CGFloat beat;

+ (instancetype)createMetronomeWithDelegate:(SKScene <TLPMetronomeDelegate>*)delegate;
- (void)toggle;
- (void)start;
- (void)stop;
- (void)increment;
- (void)decrement;

@end
