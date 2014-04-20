//
//  TLPPatternBank.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPPatternBank.h"

@interface TLPPatternBank ()

@property (nonatomic, strong) NSArray *patterns;
@property (nonatomic) NSUInteger activePattern;

@end

@implementation TLPPatternBank

+ (instancetype)createBankWithDelegate:(id<TLPPatternBankDelegate>)delegate
{
    TLPPatternBank *bank = [TLPPatternBank new];
    bank.delegate = delegate;
    
    return bank;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _patterns = loadPatterns();
    _activePattern = 1;
    
    return self;
}

- (void)setActivePattern:(NSUInteger)activePattern
{
    if (activePattern < 1 || activePattern > (self.patterns.count)) return;
    
    _activePattern = activePattern;
    
    if ([self.delegate respondsToSelector:@selector(patternBankDidChangeActivePattern:)])
    {
        [self.delegate patternBankDidChangeActivePattern:self];
    }
}

- (BOOL)shouldHitNote:(NSUInteger)note atCount:(NSUInteger)count;
{
    NSArray *pattern = self.patterns[self.activePattern-1];
    return [pattern[note][count - 1] boolValue];
}

- (void)switchToRight
{
    self.activePattern++;
}

- (void)switchToLeft
{
    self.activePattern--;
}


@end
