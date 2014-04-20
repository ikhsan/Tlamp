//
//  TLPIcon.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/20/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

extern NSString *const IconLeft;
extern NSString *const IconRight;

@interface TLPIcon : SKSpriteNode

@property (nonatomic, getter = isUserActive) BOOL userActive;

+ (instancetype)createIconWithName:(NSString *)name;

@end
