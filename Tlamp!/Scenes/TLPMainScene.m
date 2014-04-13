//
//  TLPMyScene.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/12/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"
#import "Helpers.h"

#import "TLPNote.h"
#import "TLPLine.h"

#import "TLPMainScene.h"

@interface TLPMainScene ()

@end

@implementation TLPMainScene

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    [self drawTheLines];

    return self;
}

- (void)drawTheLines
{
    // draw 4 notes / 0th for 'current position' line
    for (int i=0; i < 5; i++) {
        CGPoint p1, p2;
        if (i != 0)
        {
            p1 = positionForStartOfLine(i, self.frame);
            p2 = positionForEndOfLine(i, self.frame);
        }
        else
        {
            CGFloat d = 2.0;
            p1 = positionForNote(1, self.frame);
            p1.x += d;
            p2 = positionForNote(4, self.frame);
            p2.x -= d;
        }
        
        TLPLine *line = [TLPLine lineWithColor:color(i) from:p1 to:p2];
        [self addChild:line];
    }
}

#pragma mark - Note hits actions

- (void)noteHit:(int)n
{
    TLPNote *note = [TLPNote makeNote:n withFrame:self.frame];
    [self addChild:note];
    [note playNote];
}

#pragma mark - Catching keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    switch ([theEvent keyCode]) {
        case 18: [self noteHit:1]; break;
        case 19: [self noteHit:2]; break;
        case 20: [self noteHit:3]; break;
        case 21: [self noteHit:4]; break;
            
        default: break;
    }
}



@end
