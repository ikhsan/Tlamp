//
//  TLPSFX.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/18/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import AudioToolbox;

#import "TLPSFX.h"

@interface TLPSFX ()

@property (nonatomic) SystemSoundID note1;
@property (nonatomic) SystemSoundID note2;
@property (nonatomic) SystemSoundID note3;
@property (nonatomic) SystemSoundID note4;
@property (nonatomic) SystemSoundID note5;
@property (nonatomic) SystemSoundID gendangOpen;
@property (nonatomic) SystemSoundID gendangClosed;

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
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"talempong_pacik_01"), &_note1);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"talempong_pacik_02"), &_note2);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"talempong_pacik_03"), &_note3);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"talempong_pacik_04"), &_note4);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"talempong_pacik_05"), &_note5);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"gendang_open"), &_gendangOpen);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)URLForWav(@"gendang_closed"), &_gendangClosed);
    
    return self;
}

- (void)playNote:(int)note
{
    switch (note) {
        case 1: AudioServicesPlaySystemSound(self.note1); break;
        case 2: AudioServicesPlaySystemSound(self.note2); break;
        case 3: AudioServicesPlaySystemSound(self.note3); break;
        case 4: AudioServicesPlaySystemSound(self.note4); break;
        case 5: AudioServicesPlaySystemSound(self.note5); break;
            
        default:
            break;
    }
}

- (void)playGendang:(GendangHit)hit
{
    switch (hit) {
        case GendangHitOpen:
            AudioServicesPlaySystemSound(self.gendangOpen);
            break;
        case GendangHitClosed:
            AudioServicesPlaySystemSound(self.gendangClosed);
            break;
            
        default:
            break;
    }
}


@end
