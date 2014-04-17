//
//  TLPMessenger.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/17/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"
#import "SKAction+Tlamp.h"
#import "SKLabelNode+Tlamp.h"

#import "TLPMessenger.h"

NSString *const LabelKey = @"me.ikhsan.tlamp.label";
NSString *const SmallLabelKey = @"me.ikhsan.tlamp.smallLabel";
NSTimeInterval const FlashDuration = 1.0;

@interface TLPMessenger ()

@property (nonatomic, assign) SKScene *scene;

@end

@implementation TLPMessenger

- (instancetype)initWithScene:(SKScene *)scene
{
    if (!(self = [super init])) return nil;
    
    self.scene = scene;
    
    return self;
}

#pragma mark - Main method

- (void)showMessage:(NSString *)message small:(BOOL)isSmall duration:(NSTimeInterval)duration
{
    if (!self.scene) return;
    
    // remove message if there is any
    NSString *name = !isSmall? LabelKey : SmallLabelKey;
    [self clearMessageWithName:name];
    
    // print message
    SKLabelNode *labelNode = (!isSmall)? [SKLabelNode labelHUDWithMessage:message] : [SKLabelNode smallLabelWithMessage:message];
    labelNode.name = name;
    labelNode.alpha = 0.0;
    labelNode.position = CGPointMake(CGRectGetMidX(self.scene.frame), CGRectGetMidY(self.scene.frame) + (isSmall? -20 : 20));
    [self.scene addChild:labelNode];
    
    if (duration != 0)
        [labelNode runAction:[SKAction flashWithDuration:duration]];
    else
        [labelNode runAction:[SKAction fadeInWithDuration:duration]];
}

- (void)clearMessageWithName:(NSString *)name
{
    SKNode *existingLabel = [self.scene childNodeWithName:name];
    if (existingLabel)
    {
        [existingLabel runAction:[SKAction fadeOutWithDuration:.05] completion:^{
            [existingLabel removeFromParent];
        }];
    }
}

#pragma mark - Public Method

- (void)showMessage:(NSString *)message
{
    [self showMessage:message small:NO duration:FlashDuration];
}

- (void)showMessage:(NSString *)message withDuration:(NSTimeInterval)duration
{
    [self showMessage:message small:NO duration:duration];
}

- (void)showSmallMessage:(NSString *)message
{
    [self showMessage:message small:YES duration:FlashDuration];
}

- (void)showSmallMessage:(NSString *)message withDuration:(NSTimeInterval)duration
{
    [self showMessage:message small:YES duration:duration];
}

- (void)clearAllMessage
{
    [self clearMessageWithName:LabelKey];
    [self clearMessageWithName:SmallLabelKey];
}

@end
