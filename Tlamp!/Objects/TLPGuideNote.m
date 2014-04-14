//
//  TLPGuideNote.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPGuideNote.h"

NSString *const NoteGuide = @"me.ikhsan.tlamp.noteGuide";

@interface TLPGuideNote ()

@property (nonatomic) NSUInteger note;

@end

@implementation TLPGuideNote

+ (instancetype)guideNoteWithNote:(int)n
{
    TLPGuideNote *guideNote = [[TLPGuideNote alloc] init];
    guideNote.name = NoteGuide;
    
    SKSpriteNode *note = [SKSpriteNode spriteNodeWithImageNamed:@"hit.png"];
    note.colorBlendFactor = .7;
    note.color = color(n);
    note.size = CGSizeMake(50., 50.);
    [guideNote addChild:note];
    
    guideNote.note = n;
    
    return guideNote;
}

- (void)playNote
{
    NSString *noteName = [NSString stringWithFormat:@"talempong_pacik_0%d.wav", (int)self.note];
    SKAction *hitNote = [SKAction playSoundFileNamed:noteName waitForCompletion:NO];
    [self runAction:hitNote];
}


@end
