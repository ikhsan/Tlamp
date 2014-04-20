//
//  TLPValuator.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/19/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

@interface TLPValuator : SKSpriteNode

@property (nonatomic) CGPoint position;

+ (instancetype)makeValuatorWithMark:(CGFloat)mark;

@end
