//
//  TLPGuideNote.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

extern NSString *const NoteGuide;

@interface TLPGuideNote : SKSpriteNode

@property (nonatomic, readonly) NSUInteger note;

+ (instancetype)guideNoteWithNote:(int)note;
- (void)playNote;

@end
