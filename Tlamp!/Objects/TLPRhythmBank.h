//
//  TLPRhythmBank.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import Foundation;

@class TLPRhythmBank;

@protocol TLPRhythmBankDelegate <NSObject>

- (void)rhythmBankDidChangeRhythm:(TLPRhythmBank *)bank;

@end

@interface TLPRhythmBank : NSObject

@property (nonatomic, assign) id<TLPRhythmBankDelegate> delegate;
@property (nonatomic, readonly) NSUInteger activeRhythm;

+ (instancetype)createRhythmBankWithDelegate:(id <TLPRhythmBankDelegate>)delegate;
- (BOOL)shouldPlayNote:(NSUInteger)note atCount:(NSUInteger)count;
- (void)switchRhythm;

@end
