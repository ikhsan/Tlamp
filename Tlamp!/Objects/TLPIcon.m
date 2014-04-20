//
//  TLPIcon.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "SKColor+Tlamp.h"

#import "TLPIcon.h"

NSString *const IconLeft = @"me.ikhsan.tlamp.iconLeft";
NSString *const IconRight = @"me.ikhsan.tlamp.iconRight";

NSString *const IconUser = @"user.png";
NSString *const IconComputer = @"computer.png";

@interface TLPIcon ()

@end

@implementation TLPIcon

+ (instancetype)createIconWithName:(NSString *)name
{
    return [[TLPIcon alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    if (!(self = [super initWithImageNamed:IconComputer])) return nil;
    
    self.name = name;
    self.blendMode = SKBlendModeScreen;
    self.colorBlendFactor = .8;
    self.alpha = 0.0;
    self.color = [SKColor tlp_blueColor];
    
    return self;
}

- (void)setUserActive:(BOOL)userActive
{
    _userActive = userActive;
    
    NSString *image = userActive? @"user.png" : @"computer.png";
    self.texture = [SKTexture textureWithImageNamed:image];
}

@end
