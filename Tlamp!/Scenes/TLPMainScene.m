//
//  TLPMyScene.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/12/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"
#import "SKAction+Tlamp.h"

#import "TLPNote.h"
#import "TLPLine.h"
#import "TLPGuideNote.h"

#import "TLPMainScene.h"

NSString *const MetroLine = @"me.ikhsan.tlamp.metroLine";
NSString *const BaseLine = @"me.ikhsan.tlamp.baseLine";
NSString *const NoteGuideLine = @"me.ikhsan.tlamp.noteGuideLine";
NSString *const MetroAction = @"me.ikhsan.tlamp.metroAction";
static CGFloat threshold = .5;

@interface TLPMainScene ()

@property NSInteger ticker;
@property CGFloat bpm;

@property (getter = isPlaying) BOOL playing;
@property (getter = isGuidePlaying) BOOL guidePlaying;

@property (nonatomic, getter = isPlayerPlayingOne) BOOL playerPlayingOne;
@property (nonatomic, getter = isPlayerPlayingTwo) BOOL playerPlayingTwo;
@property (strong, nonatomic) NSArray *pattern;

@end

@implementation TLPMainScene

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    self.bpm = 120.0;
    self.guidePlaying = YES;
    [self drawTheLines];
    
    for (int i=1; i <= 4; i++) {
        [self noteHit:i];
    }
    [self tick];
    
//    self.pattern1 = @[
//        @[@0, @0, @0, @1, @0, @0, @1, @0],
//        @[@0, @0, @0, @0, @0, @0, @0, @0],
//        @[@1, @1, @0, @0, @1, @0, @0, @0],
//        @[@0, @0, @1, @0, @1, @0, @1, @1]
//    ];

    self.pattern = @[
        @[@0, @0, @1, @0, @0, @0, @0, @0],
        @[@0, @0, @0, @1, @1, @0, @1, @0],
        @[@0, @0, @0, @0, @1, @0, @1, @1],
        @[@1, @1, @0, @0, @0, @0, @0, @0]
    ];

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
        line.name = (i != 0)? NoteGuideLine : BaseLine;
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

- (void)startMetro
{
    SKAction *wait = [SKAction waitForDuration:beatInterval(self.bpm) / 2.];
    
    SKAction *advanceTicker = [SKAction runBlock:^{
        self.ticker++;
        if (self.ticker >= 9) self.ticker = 1;
    }];
    
    SKAction *tickerMetro = [SKAction sequence:@[[SKAction runBlock:^{
        [self metronomeTick:(self.ticker % 2 == 1)];
    }], wait]];
    SKAction *tickerNote = [SKAction sequence:@[[SKAction runBlock:^{
        [self tickNote];
    }], wait]];
    
    SKAction *moveTicker = [SKAction sequence:@[advanceTicker, [SKAction group:@[tickerMetro, tickerNote]]]];
    
    SKAction *metro = [SKAction repeatActionForever:moveTicker];
    [self runAction:metro withKey:MetroAction];
}

- (void)stopMetro
{
    // remove existing note guides
    [[self children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        if (![node.name isEqualToString:BaseLine] && ![node.name isEqualToString:NoteGuideLine])
        {
            [node runAction:[SKAction fadeAlphaTo:0. duration:.4] completion:^{
                [node removeFromParent];
            }];
        }
    }];
    
    // remove existing actions
    [self removeActionForKey:MetroAction];
    
    // reset ticker
    self.ticker = 0;
}

- (void)startStopMetronome
{
    if (!self.isPlaying)
        [self startMetro];
    else
        [self stopMetro];
    
    self.playing = !self.isPlaying;
}

#pragma mark - Tickers

- (void)tickNote
{
    for (int i=0; i < 4; i++) {
        if (![self.pattern[i][self.ticker - 1] boolValue]) continue;
        [self noteTick:(i+1)];
    }
}

- (void)metronomeTick:(BOOL)even
{
    CGFloat width = positionForStartOfLine(4, self.frame).x - positionForStartOfLine(1, self.frame).x;
    SKColor *color = even? [SKColor tlp_orangeColor] : [[SKColor tlp_orangeColor] colorWithAlphaComponent:.2];
    
    SKSpriteNode *line = [[SKSpriteNode alloc] initWithColor:color size:CGSizeMake(width, 6.)];
    line.name = even? MetroLine : @"";
    line.position = CGPointMake(CGRectGetMidX(self.frame), positionForStartOfLine(1, self.frame).y);
    [self addChild:line];
    
    // metro line's movement
    CGFloat s = (positionForNote(4, self.frame).x - positionForNote(1, self.frame).x) / (line.size.width);
    CGPoint p1 = CGPointMake(line.position.x, positionForBaseline(self.frame));
    SKAction *moveAndScale = [SKAction moveTo:p1 scaleXBy:s yBy:1. tempo:self.bpm];
    
    CGPoint p2 = CGPointMake(CGRectGetMidX(self.frame), -10.0);
    SKAction *fadeOut = [SKAction fadesTo:p2 scaleXBy:1.1 yBy:1. tempo:self.bpm];
    SKAction *removeMe = [SKAction removeFromParent];
    
    // run
    SKAction *metroWalk = [SKAction sequence:@[moveAndScale, fadeOut, removeMe]];
    [line runAction:metroWalk];
}

- (void)noteTick:(int)n
{
    TLPGuideNote *guideNote = [TLPGuideNote guideNoteWithNote:n];
    guideNote.position = positionForStartOfLine(n, self.frame);
    [self addChild:guideNote];
    
    // note's movement
    SKAction *moveAndScale = [SKAction moveTo:positionForNote(n, self.frame) scaleBy:2. tempo:self.bpm];
    SKAction *fadeOut = [SKAction fadesTo:positionForEndOfLine(n, self.frame) scaleBy:1.1 tempo:self.bpm];
    SKAction *removeMe = [SKAction removeFromParent];
    
    // run
    SKAction *noteWalk = [SKAction sequence:@[moveAndScale, fadeOut, removeMe]];
    [guideNote runAction:noteWalk];
}

- (void)tick
{
    [self runAction:[SKAction playSoundFileNamed:@"talempong_pacik_05.wav" waitForCompletion:NO]];
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
            
        case 27:
            self.playerPlayingOne = !self.isPlayerPlayingOne;
            NSLog(@"player 1: %d", self.isPlayerPlayingOne);
            break;
        case 24:
            self.playerPlayingTwo = !self.isPlayerPlayingTwo;
            NSLog(@"player 2: %d", self.isPlayerPlayingTwo);
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
            if (fabs(y - node.position.y) < threshold )
                [self tick];
        }
        else if ([node.name isEqualToString:NoteGuide])
        {
            TLPGuideNote *guideNote = (TLPGuideNote *)node;
            if (fabs(y - guideNote.position.y) < threshold )
            {
                if (self.isGuidePlaying)
                {
                    if ((((guideNote.note == 1) || (guideNote.note == 2)) && (!self.isPlayerPlayingOne)) ||
                        (((guideNote.note == 3) || (guideNote.note == 4)) && (!self.isPlayerPlayingTwo)))
                        [guideNote playNote];
                }
            }
        }
    }];
}



@end
