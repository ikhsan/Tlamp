//
//  TLPMyScene.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/12/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import Carbon;

#import "SKColor+Tlamp.h"
#import "SKAction+Tlamp.h"
#import "SKLabelNode+Tlamp.h"

// objects
#import "TLPSFX.h"
#import "TLPNote.h"
#import "TLPLine.h"
#import "TLPGuideNote.h"
#import "TLPMessenger.h"

#import "TLPMainScene.h"

NSString *const MetroLine = @"me.ikhsan.tlamp.metroLine";
NSString *const BaseLine = @"me.ikhsan.tlamp.baseLine";
NSString *const NoteGuideLine = @"me.ikhsan.tlamp.noteGuideLine";
NSString *const MetroAction = @"me.ikhsan.tlamp.metroAction";

static CGFloat threshold = .5;

CGFloat bpmForTempo(NSInteger tempo) {
    double tempos[] = {60., 90., 120.};
    return tempos[tempo-1];
}

@interface TLPMainScene () {
    BOOL _isTitleVisible;
}

@property (nonatomic) NSInteger ticker;
@property (nonatomic) CGFloat bpm;
@property (nonatomic) NSInteger tempo;

@property (getter = isPlaying) BOOL playing;
@property (getter = isGuidePlaying) BOOL guidePlaying;

@property (nonatomic, getter = isPlayerPlayingOne) BOOL playerPlayingOne;
@property (nonatomic, getter = isPlayerPlayingTwo) BOOL playerPlayingTwo;
@property (strong, nonatomic) TLPMessenger *messenger;

@property (strong, nonatomic) NSArray *patterns;
@property (nonatomic) NSUInteger activePattern;
@property (strong, nonatomic) NSArray *grooves;
@property (nonatomic) NSUInteger activeGrooves;

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
    self.grooves = loadGrooves();
    _activeGrooves = 0;

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
    
    [self.messenger showMessage:[NSString stringWithFormat:@"%.0f bpm", _bpm]];
    [self.messenger showSmallMessage:@"Changing tempo"];
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
    
    // tell user
    [self.messenger showMessage:[NSString stringWithFormat:@"Pattern #%lu", (unsigned long)_activePattern]];
    [self.messenger showSmallMessage:@"Changing playing pattern"];
}

- (void)setActiveGrooves:(NSUInteger)activeGrooves
{
    _activeGrooves = activeGrooves % (self.grooves.count + 1);
    
    NSString *m = (_activeGrooves == 0)?
        @"Using only clicks" :
        [NSString stringWithFormat:@"Rhythm #%lu", (unsigned long)_activeGrooves];
    
    // tell user
    [self.messenger showMessage:m];
    [self.messenger showSmallMessage:@"Changing backing rhythm"];
}

#pragma mark - Titles

- (void)didMoveToView:(SKView *)view
{
    [self.messenger showMessage:@"T L A M P !" withDuration:0];
    [self.messenger showSmallMessage:@"hit anything to start..." withDuration:0];
    _isTitleVisible = YES;

    [self startStopMetronome];
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

- (void)incrementBacksound
{
    self.activeGrooves++;
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

- (void)tickGroove
{
    if (self.activeGrooves == 0) return;
    
    CGFloat beat = beatInterval(self.bpm);
    NSArray *groove = self.grooves[self.activeGrooves-1];
    
    for (int i = 0; i < 2; i++) {
        NSInteger tick = self.ticker * 2;
        
        int gendangHit = (i == GendangHitOpen)? GendangHitOpen : GendangHitClosed;
        if ([groove[i][tick - 2] boolValue]) {
            [[TLPSFX player] playGendang:gendangHit];
        }
        if ([groove[i][tick - 1] boolValue]) {
            SKAction *wait = [SKAction waitForDuration:(beat / 4.04)];
            [self runAction:[SKAction sequence:@[wait, [SKAction runBlock:^{
               [[TLPSFX player] playGendang:gendangHit];
            }]]]];
        }
    }
}

- (void)metronomeTick:(BOOL)even
{
    CGFloat width = positionForStartOfLine(4, self.frame).x - positionForStartOfLine(1, self.frame).x;
    SKColor *color = even? [SKColor tlp_orangeColor] : [[SKColor tlp_orangeColor] colorWithAlphaComponent:.0];
    
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

    
    // play metronome click or the groove
    if (even) [self tick];
    [self performSelector:@selector(tickGroove) withObject:nil afterDelay:0.1];
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
    [[TLPSFX player] playNote:5];
}

#pragma mark - Catching keyboard events

- (void)keyDown:(NSEvent *)theEvent
{    
    switch ([theEvent keyCode]) {
        // note hits (1, 2, 3, 4)
        case kVK_ANSI_1: [self noteHit:1];
            break;
        case kVK_ANSI_2: [self noteHit:2];
            break;
        case kVK_ANSI_3: [self noteHit:3];
            break;
        case kVK_ANSI_4: [self noteHit:4];
            break;
        
        // metronome toggle (spacebar)
        case kVK_Space: [self startStopMetronome];
            break;
            
        // note guide toggle (-, +)
        case kVK_ANSI_Minus:
            self.playerPlayingOne = !self.isPlayerPlayingOne;
            break;
        case kVK_ANSI_Equal:
            self.playerPlayingTwo = !self.isPlayerPlayingTwo;
            break;
        
        // tempo slider (up arrow, down arrow)
        case kVK_UpArrow:
            [self incrementTempo];
            break;
        case kVK_DownArrow:
            [self decrementTempo];
            break;

        // pattern slider (right arrow, left arrow)
        case kVK_RightArrow:
            [self switchRightPattern];
            break;
        case kVK_LeftArrow:
            [self switchLeftPattern];
            break;
            
        // groove vs metronome click
        case kVK_ANSI_0:
            [self incrementBacksound];
            
        default: break;
    }
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    CGFloat y = positionForBaseline(self.frame);
    [[self children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {

        if ([node.name isEqualToString:NoteGuide])
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
