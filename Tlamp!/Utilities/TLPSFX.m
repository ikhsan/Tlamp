//
//  TLPSFX.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/18/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

#import "TLPSFX.h"

@interface TLPSFX ()

@property (nonatomic, strong) SKAction *note1;
@property (nonatomic, strong) SKAction *note2;
@property (nonatomic, strong) SKAction *note3;
@property (nonatomic, strong) SKAction *note4;
@property (nonatomic, strong) SKAction *note5;

@property (nonatomic, strong) SKAction *gendangOpen;
@property (nonatomic, strong) SKAction *gendangClosed;


@end

NSURL* URLForWav(NSString *filename)
{
    return [[NSBundle mainBundle] URLForResource:filename withExtension:@"wav"];
}

@implementation TLPSFX

+ (instancetype)player
{
    static TLPSFX *sfx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sfx = [TLPSFX new];
    });
    
    return sfx;
}

- (instancetype)init
{
    if (!(self = [super init])) return nil;
    
    _note1 = [SKAction playSoundFileNamed:@"talempong_pacik_01.wav" waitForCompletion:NO];
    _note2 = [SKAction playSoundFileNamed:@"talempong_pacik_02.wav" waitForCompletion:NO];
    _note3 = [SKAction playSoundFileNamed:@"talempong_pacik_03.wav" waitForCompletion:NO];
    _note4 = [SKAction playSoundFileNamed:@"talempong_pacik_04.wav" waitForCompletion:NO];
    _note5 = [SKAction playSoundFileNamed:@"talempong_pacik_05.wav" waitForCompletion:NO];
    
    _gendangOpen = [SKAction playSoundFileNamed:@"gendang_open.wav" waitForCompletion:NO];
    _gendangClosed = [SKAction playSoundFileNamed:@"gendang_closed.wav" waitForCompletion:NO];
    
    return self;
}

- (void)playNote:(int)note
{
    if (!self.scene) return;
    
    SKAction *action;
    switch (note) {
        case 1: action = self.note1; break;
        case 2: action = self.note2; break;
        case 3: action = self.note3; break;
        case 4: action = self.note4; break;
        case 5: action = self.note5; break;
            
        default: break;
    }
    
    [self.scene runAction:action];
}

- (void)playGendang:(GendangHit)hit
{
    if (!self.scene) return;
    
    switch (hit) {
        case GendangHitOpen:    [self.scene runAction:self.gendangOpen]; break;
        case GendangHitClosed:  [self.scene runAction:self.gendangClosed]; break;
            
        default: break;
    }
}

- (void)playGendang:(GendangHit)hit withDelay:(NSTimeInterval)delay
{
    if (!self.scene) return;
    
    [self.scene runAction:[SKAction sequence:@[
        [SKAction waitForDuration:delay],
        ((hit == GendangHitOpen)? self.gendangOpen : self.gendangClosed)
    ]]];
}


@end
