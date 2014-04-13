//
//  TLPNote.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TLPNote : SKEmitterNode

+ (instancetype)makeNote:(int)note withFrame:(CGRect)frame;
- (void)playNote;

@end
