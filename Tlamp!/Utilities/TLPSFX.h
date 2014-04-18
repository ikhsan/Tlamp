//
//  TLPSFX.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/18/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GendangHit) {
    GendangHitOpen,
    GendangHitClosed
};

@interface TLPSFX : NSObject

+ (instancetype)player;
- (void)playNote:(int)note;
- (void)playGendang:(GendangHit)hit;

@end
