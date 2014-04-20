//
//  TLPPatternBank.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import Foundation;

@class TLPPatternBank;

@protocol TLPPatternBankDelegate <NSObject>

- (void)patternBankDidChangeActivePattern:(TLPPatternBank *)bank;

@end

@interface TLPPatternBank : NSObject

@property (nonatomic, readonly) NSUInteger activePattern;
@property (nonatomic, assign) id<TLPPatternBankDelegate> delegate;

+ (instancetype)createBankWithDelegate:(id<TLPPatternBankDelegate>)delegate;
- (BOOL)shouldHitNote:(NSUInteger)note atCount:(NSUInteger)count;
- (void)switchToRight;
- (void)switchToLeft;

@end
