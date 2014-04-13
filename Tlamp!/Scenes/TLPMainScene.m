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

NSString *const KeyMetroLine = @"me.ikhsan.tlamp.metroLine";

@interface TLPMainScene ()

@property CGFloat bpm;

@end

double beatInterval(double bpm) {
    return (60000. / (1 *  bpm)) / 1000.;
}

@implementation TLPMainScene

- (instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) return nil;

    self.backgroundColor = [SKColor colorWithWhite:.05 alpha:1.0];
    self.bpm = 120.0;
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
        case 18: [self noteHit:1];
            break;
        case 19: [self noteHit:2];
            break;
        case 20: [self noteHit:3];
            break;
        case 21: [self noteHit:4];
            break;
            
        case 49: [self metronomeTick];
            break;
            
        default: break;
    }
}


- (void)metronomeTick
{
    CGPoint p = positionForStartOfLine(1, self.frame);
    CGFloat s = positionForNote(4, self.frame).x - positionForNote(1, self.frame).x;
    
    SKSpriteNode *line = [[SKSpriteNode alloc] initWithColor:[SKColor tlp_orangeColor] size:CGSizeMake(4., 8.)];
    line.name = KeyMetroLine;
    line.position = p;
    [self addChild:line];
    
    CGFloat duration = beatInterval(self.bpm) * 4;
    SKAction *move = [SKAction moveByX:0. y:-(CGRectGetHeight(self.frame) * .65) duration:duration];
    SKAction *scale = [SKAction scaleXBy:s/4. y:1. duration:duration];
    SKAction *moveAndScale = [SKAction group:@[move, scale]];
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0. duration:duration/6.];
    SKAction *moveFadeOut = [SKAction moveToY:0.0 duration:duration/4.];
    SKAction *scaleFadeOut = [SKAction scaleXBy:(CGRectGetWidth(self.frame)/s) y:1. duration:duration/4.];
    SKAction *fades = [SKAction group:@[fadeOut, moveFadeOut, scaleFadeOut]];
    fades.timingMode = SKActionTimingEaseIn;
    
    SKAction *done = [SKAction removeFromParent];
    SKAction *metroWalk = [SKAction sequence:@[moveAndScale, fades, done]];
    [line runAction:metroWalk];
}

- (void)tick
{
    [self runAction:[SKAction playSoundFileNamed:@"talempong_pacik_05.wav" waitForCompletion:NO]];
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime
{
    CGFloat y = CGRectGetHeight(self.frame) * .25;
    [self enumerateChildNodesWithName:KeyMetroLine usingBlock:^(SKNode *node, BOOL *stop) {
        if (fabs(y - node.position.y) < 0.1 )
        {
            [self tick];
        }
    }];
}



@end
