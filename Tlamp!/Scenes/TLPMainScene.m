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

NSString *const MetroLine = @"me.ikhsan.tlamp.metroLine";
NSString *const NoteLine = @"me.ikhsan.tlamp.noteLine";
NSString *const NoteGuide = @"me.ikhsan.tlamp.noteGuide";
NSString *const MetroAction = @"me.ikhsan.tlamp.metroAction";
static CGFloat threshold = 1.;

@interface TLPMainScene ()

@property CGFloat bpm;
@property (getter = isPlaying) BOOL playing;

@end

double beatInterval(double bpm) {
    return (60000. / (1 *  bpm)) / 1000.;
}

@implementation TLPMainScene

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    self.bpm = 90.0;
    [self drawTheLines];
    
    for (int i=1; i <= 4; i++) {
        [self noteHit:i];
    }
    [self tick];

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
        if (i == 0) line.name = NoteLine;
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

#pragma mark - Metronome

- (void)startStopMetronome
{
    if (!self.isPlaying)
    {
        SKAction *tickEven = [SKAction runBlock:^{
            [self metronomeTick:YES];
        }];
        SKAction *tickOdd = [SKAction runBlock:^{
            [self metronomeTick:NO];
        }];
        SKAction *wait = [SKAction waitForDuration:beatInterval(self.bpm)];
        SKAction *tickerMetro = [SKAction sequence:@[tickEven, wait, tickOdd, wait, tickOdd, wait, tickOdd, wait]];
        
        SKAction *tickNote = [SKAction runBlock:^{
            [self noteTick:(arc4random_uniform(4)+1)];
        }];
        SKAction *waitNote = [SKAction waitForDuration:beatInterval(self.bpm) / 2.];
        SKAction *tickerNote = [SKAction sequence:@[
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
            tickNote, waitNote,
        ]];
        
        SKAction *ticker = [SKAction group:@[tickerMetro, tickerNote]];
        
        SKAction *metro = [SKAction repeatActionForever:ticker];
        [self runAction:metro withKey:MetroAction];
    }
    else
    {
        [self removeActionForKey:MetroAction];
    }
    
    self.playing = !self.isPlaying;
}

- (void)metronomeTick:(BOOL)even
{
    CGFloat width = positionForStartOfLine(4, self.frame).x - positionForStartOfLine(1, self.frame).x;
    SKColor *color = even? [SKColor tlp_orangeColor] : [[SKColor tlp_orangeColor] colorWithAlphaComponent:.5];
    SKSpriteNode *line = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(width, 6.)];
    line.name = MetroLine;
    line.position = CGPointMake(CGRectGetMidX(self.frame), positionForStartOfLine(1, self.frame).y);
    [self addChild:line];
    
    CGFloat s = (positionForNote(4, self.frame).x - positionForNote(1, self.frame).x) / (line.size.width);
    
    CGFloat beat = beatInterval(self.bpm);
    
    // line's movement
    SKAction *move = [SKAction moveByX:0.
                                     y:(positionForBaseline(self.frame) - positionForStartOfLine(1, self.frame).y)
                              duration:(beat * 4)];
    SKAction *scale = [SKAction scaleXBy:s y:1. duration:(beat * 4)];
    SKAction *moveAndScale = [SKAction group:@[move, scale]];
    moveAndScale.timingMode = SKActionTimingEaseIn;
    
    // line's fade out
    SKAction *fadeOut = [SKAction fadeAlphaTo:0. duration:(beat * .66)];
    SKAction *moveFadeOut = [SKAction moveToY:0.0 duration:beat];
    SKAction *scaleFadeOut = [SKAction scaleXBy:(CGRectGetWidth(self.frame) / s) y:1. duration:beat];
    SKAction *fades = [SKAction group:@[fadeOut, moveFadeOut, scaleFadeOut]];
    
    SKAction *removeMe = [SKAction removeFromParent];
    
    SKAction *metroWalk = [SKAction sequence:@[moveAndScale, fades, removeMe]];
    [line runAction:metroWalk];
}

- (void)noteTick:(int)n
{
    CGFloat beat = beatInterval(self.bpm);
    
    SKSpriteNode *note = [[SKSpriteNode alloc] initWithImageNamed:@"hit.png"];
    note.name = NoteGuide;
    note.colorBlendFactor = .7;
    note.color = color(n);
    note.position = positionForStartOfLine(n, self.frame);
    
    [self addChild:note];
    
    // note's movement
    CGPoint p = positionForNote(n, self.frame);
    SKAction *move = [SKAction moveTo:p duration:(beat * 4)];
    SKAction *scale = [SKAction scaleBy:2. duration:(beat * 4)];
    SKAction *moveAndScale = [SKAction group:@[move, scale]];
    
    // note's fade out
    SKAction *fadeOut = [SKAction fadeAlphaTo:0. duration:(beat * .66)];
    SKAction *moveFadeOut = [SKAction moveTo:positionForEndOfLine(n, self.frame) duration:beat];
    SKAction *scaleFadeOut = [SKAction scaleBy:1.1 duration:beat];
    SKAction *fades = [SKAction group:@[fadeOut, moveFadeOut, scaleFadeOut]];
    fades.timingMode = SKActionTimingEaseIn;

    SKAction *removeMe = [SKAction removeFromParent];
    
    SKAction *noteWalk = [SKAction sequence:@[moveAndScale, fades, removeMe]];
    [note runAction:noteWalk];
}

- (void)tick
{
    [self runAction:[SKAction playSoundFileNamed:@"talempong_pacik_05.wav" waitForCompletion:NO]];
}

- (void)temporary:(int)note
{
    [self runAction:[SKAction playSoundFileNamed:[NSString stringWithFormat:@"talempong_pacik_0%d.wav", note] waitForCompletion:NO]];
}

#pragma mark - Catching keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    switch ([theEvent keyCode]) {
        case 18: [self noteHit:1];
            break;
        case 19: [self noteHit:2];
            break;
        case 20: [self noteHit:3];
            break;
        case 21: [self noteHit:4];
            break;
            
        case 49: [self startStopMetronome];
            break;
            
        default: break;
    }
}


#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    CGFloat y = positionForBaseline(self.frame);
    [[self children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        if ([node.name isEqualToString:MetroLine])
        {
            if (fabs(y - node.position.y) < threshold ) [self tick];
        }
        else if ([node.name isEqualToString:NoteGuide])
        {
            if (fabs(y - node.position.y) < threshold )
            {
                if (fabs( positionForNote(1, self.frame).x - node.position.x ) < 10.)
                    [self temporary:1];
                else if (fabs( positionForNote(2, self.frame).x - node.position.x ) < 10.)
                    [self temporary:2];
                else if (fabs( positionForNote(3, self.frame).x - node.position.x ) < 10.)
                    [self temporary:3];
                else if (fabs( positionForNote(4, self.frame).x - node.position.x ) < 10.)
                    [self temporary:4];

            }
        }
    }];
}



@end
