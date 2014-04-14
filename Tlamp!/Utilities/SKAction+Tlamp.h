//
//  SKAction+Tlamp.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/14/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKAction (Tlamp)

+ (SKAction *)moveTo:(CGPoint)p scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale tempo:(CGFloat)tempo;
+ (SKAction *)moveTo:(CGPoint)p scaleBy:(CGFloat)scale tempo:(CGFloat)tempo;

+ (SKAction *)fadesTo:(CGPoint)p scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale tempo:(CGFloat)tempo;
+ (SKAction *)fadesTo:(CGPoint)p scaleBy:(CGFloat)scale tempo:(CGFloat)tempo;

@end
