//
//  SKLabelNode+Tlamp.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKLabelNode+Tlamp.h"
#import "SKColor+Tlamp.h"

@implementation SKLabelNode (Tlamp)

+ (SKLabelNode *)labelHUDWithMessage:(NSString *)message
{
    SKLabelNode *label = [self labelNodeWithFontNamed:@"Avenir-Heavy"];
    label.fontSize = 48.0;
    label.text = message;
    label.fontColor = [SKColor colorWithWhite:1. alpha:.8];
    label.blendMode = SKBlendModeAdd;

    return label;
}

+ (SKLabelNode *)smallLabelWithMessage:(NSString *)message
{
    SKLabelNode *label = [self labelHUDWithMessage:message];
    label.fontSize = 24.0;
    label.fontName = @"Avenir-Medium";
    label.fontColor = [SKColor tlp_blueColor];
    
    return label;
}

@end
