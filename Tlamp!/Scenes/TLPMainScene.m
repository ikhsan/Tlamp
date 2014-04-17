//
//  TLPMyScene.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/12/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"
#import "SKAction+Tlamp.h"
#import "SKLabelNode+Tlamp.h"

// objects
#import "TLPNote.h"
#import "TLPLine.h"
#import "TLPGuideNote.h"
#import "TLPMessenger.h"

#import "TLPMainScene.h"

NSString *const MetroLine = @"me.ikhsan.tlamp.metroLine";
NSString *const BaseLine = @"me.ikhsan.tlamp.baseLine";
NSString *const NoteGuideLine = @"me.ikhsan.tlamp.noteGuideLine";
NSString *const MetroAction = @"me.ikhsan.tlamp.metroAction";

NSString *const TitleKey = @"me.ikhsan.tlamp.title";
NSString *const SubtitleKey = @"me.ikhsan.tlamp.subtitle";

static CGFloat threshold = .5;

CGFloat bpmForTempo(NSInteger tempo) {
    double tempos[] = {60., 90., 120.};
    return tempos[tempo-1];
}

@interface TLPMainScene ()

@property (nonatomic) NSInteger ticker;
@property (nonatomic) CGFloat bpm;
@property (nonatomic) NSInteger tempo;

@property (getter = isPlaying) BOOL playing;
@property (getter = isGuidePlaying) BOOL guidePlaying;

@property (nonatomic, getter = isPlayerPlayingOne) BOOL playerPlayingOne;
@property (nonatomic, getter = isPlayerPlayingTwo) BOOL playerPlayingTwo;
@property (strong, nonatomic) NSArray *patterns;
@property (nonatomic) NSUInteger activePattern;
@property (strong, nonatomic) TLPMessenger *messenger;

@end

@implementation TLPMainScene

#pragma mark - Initializer, getter and setter

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    _tempo = 1;
    _bpm = bpmForTempo(_tempo);
    _guidePlaying = YES;
    self.messenger = [[TLPMessenger alloc] initWithScene:self];
    
    // draw background and lines
    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    [self drawTheLines];
    
    // flash notes
    for (int i=1; i <= 4; i++) [self noteHit:i];
    [self tick];
    
    // load guide and backing patterns
    self.patterns = loadPatterns();
    _activePattern = 1;

    return self;
}

- (void)setPlayerPlayingOne:(BOOL)playerPlayingOne
{
    _playerPlayingOne = playerPlayingOne;
    
    [self.messenger showMessage:_playerPlayingOne?
     @"Please try play red & yellow notes" :
     @"Computer will play red & yellow notes for you"];
}

- (void)setPlayerPlayingTwo:(BOOL)playerPlayingTwo
{
    _playerPlayingTwo = playerPlayingTwo;
    
    [self.messenger showMessage:_playerPlayingTwo?
     @"Please try play green & blue notes" :
     @"Computer will play green & blue notes for you"];
}

- (void)setBpm:(CGFloat)bpm
{
    _bpm = bpm;
    
    [self.messenger showSmallMessage:[NSString stringWithFormat:@"tempo changed to %.0f", _bpm]];
}

- (void)setTempo:(NSInteger)tempo
{
    if (tempo < 1 || tempo > 3) return;
    
    _tempo = tempo;
    
    if (self.isPlaying)
    {
        [self stopMetro];
        self.bpm = bpmForTempo(_tempo);
        [self startMetro];
    }
    else
    {
        self.bpm = bpmForTempo(_tempo);
    }
}

- (void)setActivePattern:(NSUInteger)activePattern
{
    if (activePattern < 1 || activePattern > (self.patterns.count)) return;
    
    _activePattern = activePattern;
    [self.messenger showMessage:[NSString stringWithFormat:@"pattern %lu", (unsigned long)_activePattern]];
}

#pragma mark - Titles

- (void)didMoveToView:(SKView *)view
{
    [self.messenger showMessage:@"T L A M P !" withDuration:0];
    [self.messenger showSmallMessage:@"hit anything to start..." withDuration:0];
}

#pragma mark - Line drawers

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

- (void)startStopMetronome
{
    if (!self.isPlaying)
    {
        [self startCountdown];
        [self startMetro];
    }
    else
    {
        [self stopMetro];
    }
    
    self.playing = !self.isPlaying;
}

- (void)startCountdown
{
    CGFloat beat = beatInterval(self.bpm);
    NSString *m = [NSString stringWithFormat:@"pattern %d (%.0fbpm)", (int)self.activePattern, self.bpm];
    [self.messenger showMessage:m withDuration:(beat * 3)];
    
    SKAction *wait = [SKAction waitForDuration:beat];
    
    __block int count = 4;
    SKAction *countAction = [SKAction sequence:@[[SKAction runBlock:^{
        [self.messenger showSmallMessage:[NSString stringWithFormat:@"%d", count] withDuration:beat];
        count--;
    }], wait]];
    [self runAction:[SKAction repeatAction:countAction count:count]];
    
}

- (void)startMetro
{
    SKAction *wait = [SKAction waitForDuration:beatInterval(self.bpm) / 2.];
    
    // tick every beat
    SKAction *advanceTicker = [SKAction runBlock:^{
        self.ticker++;
        if (self.ticker >= 9) self.ticker = 1;
    }];
    
    // tick metro & note
    SKAction *tickerMetro = [SKAction sequence:@[[SKAction runBlock:^{
        [self metronomeTick:(self.ticker % 2 == 1)];
    }], wait]];
    SKAction *tickerNote = [SKAction sequence:@[[SKAction runBlock:^{
        [self tickNote];
    }], wait]];
    
    // play metro & guide
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

- (void)incrementTempo
{
    self.tempo++;
}

- (void)decrementTempo
{
    self.tempo--;
}

- (void)switchRightPattern
{
    self.activePattern++;
}

- (void)switchLeftPattern
{
    self.activePattern--;
}

#pragma mark - Tickers

- (void)tickNote
{
    NSArray *pat = self.patterns[self.activePattern-1];
    for (int i=0; i < 4; i++) {
        if (![pat[i][self.ticker - 1] boolValue]) continue;
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
    [self.messenger clearAllMessage];

    
    switch ([theEvent keyCode]) {
        // note hits (1, 2, 3, 4)
        case 18: [self noteHit:1];
            break;
        case 19: [self noteHit:2];
            break;
        case 20: [self noteHit:3];
            break;
        case 21: [self noteHit:4];
            break;
        
        // metronome toggle (spacebar)
        case 49: [self startStopMetronome];
            break;
            
        // note guide toggle (-, +)
        case 27:
            self.playerPlayingOne = !self.isPlayerPlayingOne;
            break;
        case 24:
            self.playerPlayingTwo = !self.isPlayerPlayingTwo;
            break;
        
        // tempo slider (up arrow, down arrow)
        case 126:
            [self incrementTempo];
            break;
        case 125:
            [self decrementTempo];
            break;

        // tempo slider (up arrow, down arrow)
        case 124:
            [self switchRightPattern];
            break;
        case 123:
            [self switchLeftPattern];
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
            if ((fabs(y - guideNote.position.y) < threshold) && self.isGuidePlaying)
            {
                if ((((guideNote.note == 1) || (guideNote.note == 2)) && (!self.isPlayerPlayingOne)) ||
                    (((guideNote.note == 3) || (guideNote.note == 4)) && (!self.isPlayerPlayingTwo)))
                    [self noteHit:(int)guideNote.note];
            }
        }
    }];
}



@end
