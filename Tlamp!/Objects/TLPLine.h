//
//  TLPLine.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TLPLine : SKShapeNode

+ (instancetype)lineWithColor:(SKColor *)color from:(CGPoint)p1 to:(CGPoint)p2;

@end
