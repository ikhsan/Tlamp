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
#import "TLPValuator.h"
#import "TLPLine.h"
#import "TLPGuideNote.h"
#import "TLPMessenger.h"
#import "TLPMetronome.h"
#import "TLPIcon.h"
#import "TLPPatternBank.h"
#import "TLPRhythmBank.h"

#import "TLPMainScene.h"

NSString *const MetroLine = @"me.ikhsan.tlamp.metroLine";
NSString *const BaseLine = @"me.ikhsan.tlamp.baseLine";
NSString *const NoteGuideLine = @"me.ikhsan.tlamp.noteGuideLine";

static CGFloat Threshold = .5;
static CGFloat PointDistance = 30.;

@interface TLPMainScene () <TLPMetronomeDelegate, TLPPatternBankDelegate, TLPRhythmBankDelegate>

@property (nonatomic, getter = isGuideNotePlaying) BOOL guideNotePlaying;
@property (nonatomic, getter = isTitleVisible) BOOL titleVisible;

@property (nonatomic, getter = isPlayerPlayingOne) BOOL playerPlayingOne;
@property (nonatomic, getter = isPlayerPlayingTwo) BOOL playerPlayingTwo;
@property (strong, nonatomic) TLPMessenger *messenger;
@property (strong, nonatomic) TLPMetronome *metronome;
@property (strong, nonatomic) TLPPatternBank *patternBank;
@property (strong, nonatomic) TLPRhythmBank *rhythmBank;

//@property (strong, nonatomic) NSArray *grooves;
//@property (nonatomic) NSUInteger activeGrooves;

@end

@implementation TLPMainScene

#pragma mark - Initializer, getter and setter

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    // initial property values
    _guideNotePlaying = YES;
    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    
    // setting delegate
    self.messenger = [[TLPMessenger alloc] initWithScene:self];
    [[TLPSFX player] setScene:self];
    
    // load objects (metronome, pattern bank)
    self.metronome = [TLPMetronome createMetronomeWithDelegate:self];
    self.patternBank = [TLPPatternBank createBankWithDelegate:self];
    self.rhythmBank = [TLPRhythmBank createRhythmBankWithDelegate:self];

    return self;
}

- (void)setPlayerPlayingOne:(BOOL)playerPlayingOne
{
    _playerPlayingOne = playerPlayingOne;
    
    [self.messenger showMessage:_playerPlayingOne?
     @"Please try play red & yellow notes" :
     @"Computer will play red & yellow notes for you"];
    [self drawIcons];
}

- (void)setPlayerPlayingTwo:(BOOL)playerPlayingTwo
{
    _playerPlayingTwo = playerPlayingTwo;
    
    [self.messenger showMessage:_playerPlayingTwo?
     @"Please try play green & blue notes" :
     @"Computer will play green & blue notes for you"];
    [self drawIcons];
}

#pragma mark - Scene's method after its ready

- (void)didMoveToView:(SKView *)view
{
    [self.messenger showMessage:@"T L A M P !" withDuration:0];
    [self.messenger showSmallMessage:@"hit anything to start..." withDuration:0];
    self.titleVisible = YES;
    
    [self drawTheLines];
    
    // flash notes
    for (int i=1; i <= 5; i++) [self noteHit:i];
}

#pragma mark - Drawer methods

- (void)drawTheLines
{
    // draw 4 notes / 0th for 'current position' line
    for (int i=0; i < 5; i++) {
        CGPoint p1 = (i != 0)? positionForStartOfLine(i, self.frame) : positionForNote(1, self.frame);
        CGPoint p2 = (i != 0)? positionForEndOfLine(i, self.frame)   : positionForNote(4, self.frame);
        
        TLPLine *line = [TLPLine lineWithColor:color(i) from:p1 to:p2];
        line.name = (i != 0)? NoteGuideLine : BaseLine;
        [self addChild:line];
    }
}

- (void)drawIcons
{
    NSArray *xs = @[@(1.5 * 60.), @(CGRectGetWidth(self.frame) - (1.5 * 60.))];
    NSArray *ys = @[@(CGRectGetHeight(self.frame) - 60.), @(CGRectGetHeight(self.frame) - 60.)];
    NSArray *activePlayer = @[@(self.isPlayerPlayingOne), @(self.isPlayerPlayingTwo)];
    
    [@[IconLeft, IconRight] enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        TLPIcon *icon = (TLPIcon *)[self childNodeWithName:name];
        if (!icon)
        {
            icon = [TLPIcon createIconWithName:name];
            icon.position = CGPointMake([xs[index] doubleValue], [ys[index] doubleValue]);
            [self addChild:icon];
            [icon runAction:[SKAction fadeIn]];
        }
        icon.userActive = [activePlayer[index] boolValue];
    }];
}

#pragma mark - Metronome delegate Methods

- (void)metronomeDidChangeBpm:(TLPMetronome *)metronome
{
    [self.messenger showMessage:[NSString stringWithFormat:@"%.0lu bpm", (unsigned long)metronome.bpm]];
    [self.messenger showSmallMessage:@"Changing tempo"];
}

- (void)metronomeShouldStart:(TLPMetronome *)metronome
{
    __block int count = 4;
    
    SKAction *wait = [SKAction waitForDuration:metronome.beat];
    SKAction *tick = [SKAction runBlock:^{
        if (count == 4) {
            NSString *m = [NSString stringWithFormat:@"pattern %d (%.0fbpm)", (int)self.patternBank.activePattern, metronome.bpm];
            [self.messenger showMessage:m withDuration:(metronome.beat * 3)];
        }
        
        [self.messenger showSmallMessage:[NSString stringWithFormat:@"%d", count] withDuration:metronome.beat];
        count--;
    }];
    
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[tick, wait]] count:count]];
}

- (void)metronome:(TLPMetronome *)metronome tickerAtCount:(NSUInteger)count
{
    [self metronomeTick:(count % 2 == 1)];
    [self tickNotesAtCount:count];
    [self performSelector:@selector(tickGrooveAtCount:) withObject:@(count) afterDelay:0.1];
}

- (void)metronomeDidStop:(TLPMetronome *)metronome
{
    // remove existing note guides
    NSArray *exception = @[BaseLine, NoteGuideLine, IconLeft, IconRight];
    [[self children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        if ([exception containsObject:node.name]) return;
        
        NSArray *actions = @[[SKAction fadeAlphaTo:0. duration:.4], [SKAction removeFromParent]];
        [node runAction:[SKAction sequence:actions]];
    }];
}

#pragma mark - Pattern Bank delegate methods

- (void)patternBankDidChangeActivePattern:(TLPPatternBank *)bank
{
    [self.messenger showMessage:[NSString stringWithFormat:@"Pattern #%lu", (unsigned long)bank.activePattern]];
    [self.messenger showSmallMessage:@"Changing playing pattern"];
}

#pragma mark - Rhythm Bank delegate methods

- (void)rhythmBankDidChangeRhythm:(TLPRhythmBank *)bank
{
    NSString *m = (bank.activeRhythm == 0)? @"Using only clicks" : [NSString stringWithFormat:@"Rhythm #%lu", (unsigned long)bank.activeRhythm];
    [self.messenger showMessage:m];
    [self.messenger showSmallMessage:@"Changing backing rhythm"];
}

#pragma mark - Note hits actions

- (void)noteHit:(int)n
{
    if (n == 5)
    {
        [[TLPSFX player] playNote:5];
        return;
    }
        
    TLPNote *note = [TLPNote makeNote:n withFrame:self.frame];
    [self addChild:note];
    [note playNote];
    
    // valuate note?
    if (self.metronome.isPlaying &&
        ((self.isPlayerPlayingOne && (n == 1 || n == 2)) ||
         (self.isPlayerPlayingTwo && (n == 3 || n == 4)) ))
    {
        [self valuateNote:note];
    }
}

#pragma mark - Valuate notes

- (void)valuateNote:(TLPNote *)valuatedNote
{
   __block CGFloat mark = 0.0;
    
    // find all guide notes
    [[self.scene children] enumerateObjectsUsingBlock:^(TLPGuideNote *guideNote, NSUInteger idx, BOOL *stop) {
        // find corresponding notes
        if ([guideNote.name isEqualToString:NoteGuide] && (valuatedNote.note == guideNote.note))
        {
            CGFloat dx = guideNote.position.x - valuatedNote.position.x;
            CGFloat dy = guideNote.position.y - valuatedNote.position.y;
            CGFloat distance = sqrt((dx * dx) + (dy * dy));
            if (distance < PointDistance)
            {
                CGFloat tempMark = 1. - (distance / PointDistance);
                mark = (tempMark > mark)? tempMark : mark;
            }
        }
    }];
    
    TLPValuator *valuator = [TLPValuator makeValuatorWithMark:mark];
    valuator.position = positionForValuator(valuatedNote.note, self.frame);
    [self addChild:valuator];
}

#pragma mark - Tickers

- (void)tickNotesAtCount:(NSUInteger)count
{
    for (int i=0; i < 4; i++) {
        if (![self.patternBank shouldHitNote:i atCount:count]) continue;
        [self noteTick:(i+1)];
    }
}

- (void)tickGrooveAtCount:(NSNumber *)count
{
    if (self.rhythmBank.activeRhythm == 0) return;
    
    NSArray *hits = @[@(GendangHitOpen), @(GendangHitClosed)];
    [hits enumerateObjectsUsingBlock:^(NSNumber *hit, NSUInteger idx, BOOL *stop) {
        NSUInteger gendangHit = [hit integerValue];
        NSInteger tick = ([count integerValue] - 1) * 2;
        
        if ([self.rhythmBank shouldPlayNote:gendangHit atCount:tick]) [[TLPSFX player] playGendang:gendangHit];
        if ([self.rhythmBank shouldPlayNote:gendangHit atCount:(tick + 1)])
            [[TLPSFX player] playGendang:gendangHit withDelay:(self.metronome.beat / 4.)];
    }];
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
    SKAction *moveAndScale = [SKAction moveTo:p1 scaleXBy:s yBy:1. tempo:self.metronome.bpm];
    
    CGPoint p2 = CGPointMake(CGRectGetMidX(self.frame), -10.0);
    SKAction *fadeOut = [SKAction fadesTo:p2 scaleXBy:1.1 yBy:1. tempo:self.metronome.bpm];
    SKAction *removeMe = [SKAction removeFromParent];
    
    // run
    SKAction *metroWalk = [SKAction sequence:@[moveAndScale, fadeOut, removeMe]];
    [line runAction:metroWalk];

    // play metronome click or the groove
    if (even) [self noteHit:5];
}

- (void)noteTick:(int)n
{
    TLPGuideNote *guideNote = [TLPGuideNote guideNoteWithNote:n];
    guideNote.position = positionForStartOfLine(n, self.frame);
    [self addChild:guideNote];
    
    // note's movement
    SKAction *moveAndScale = [SKAction moveTo:positionForNote(n, self.frame) scaleBy:2. tempo:self.metronome.bpm];
    SKAction *fadeOut = [SKAction fadesTo:positionForEndOfLine(n, self.frame) scaleBy:1.1 tempo:self.metronome.bpm];
    SKAction *removeMe = [SKAction removeFromParent];
    
    // run
    SKAction *noteWalk = [SKAction sequence:@[moveAndScale, fadeOut, removeMe]];
    [guideNote runAction:noteWalk];
}

#pragma mark - Catching keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    if (self.isTitleVisible)
    {
        [self drawIcons];
        [self.messenger clearAllMessage];
        self.titleVisible = NO;
    }
    
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
        case kVK_Space: [self.metronome toggle];
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
            [self.metronome increment];
            break;
        case kVK_DownArrow:
            [self.metronome decrement];
            break;

        // pattern slider (right arrow, left arrow)
        case kVK_RightArrow:
            [self.patternBank switchToRight];
            break;
        case kVK_LeftArrow:
            [self.patternBank switchToLeft];
            break;
            
        // groove vs metronome click
        case kVK_ANSI_0:
            [self.rhythmBank switchRhythm];
            break;
            
        default: break;
    }
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    [[self children] enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {

        if ([node.name isEqualToString:NoteGuide])
        {
            CGFloat y = positionForBaseline(self.frame);
            TLPGuideNote *guideNote = (TLPGuideNote *)node;
            
            // should guide note be played?
            if (self.isGuideNotePlaying && (fabs(y - guideNote.position.y) < Threshold))
            {
                if ((((guideNote.note == 1) || (guideNote.note == 2)) && (!self.isPlayerPlayingOne)) ||
                    (((guideNote.note == 3) || (guideNote.note == 4)) && (!self.isPlayerPlayingTwo)))
                    [self noteHit:(int)guideNote.note];
            }
        }
    }];
}



@end
