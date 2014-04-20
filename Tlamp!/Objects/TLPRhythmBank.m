//
//  TLPRhythmBank.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPSFX.h"

#import "TLPRhythmBank.h"

@interface TLPRhythmBank ()

@property (strong, nonatomic) NSArray *rhythms;
@property (nonatomic) NSUInteger activeRhythm;

@end

@implementation TLPRhythmBank

+ (instancetype)createRhythmBankWithDelegate:(id<TLPRhythmBankDelegate>)delegate
{
    TLPRhythmBank *bank = [TLPRhythmBank new];
    bank.delegate = delegate;
    return bank;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _rhythms = loadRhythms();
    _activeRhythm = 0;
    
    return self;
}

- (void)setActiveRhythm:(NSUInteger)activeRhythm
{
    _activeRhythm = activeRhythm % (self.rhythms.count + 1);
    
    if ([self.delegate respondsToSelector:@selector(rhythmBankDidChangeRhythm:)])
        [self.delegate rhythmBankDidChangeRhythm:self];
}

- (BOOL)shouldPlayNote:(NSUInteger)note atCount:(NSUInteger)count
{
    NSArray *rhythm = self.rhythms[self.activeRhythm - 1];
    
    return [rhythm[note][count] boolValue];    
}

- (void)switchRhythm
{
    self.activeRhythm++;
}

@end
