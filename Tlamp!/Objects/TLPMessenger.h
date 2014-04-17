//
//  TLPMessenger.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/17/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

@interface TLPMessenger : NSObject

- (instancetype)initWithScene:(SKScene *)scene;

- (void)showMessage:(NSString *)message;
- (void)showMessage:(NSString *)message withDuration:(NSTimeInterval)duration;
- (void)showSmallMessage:(NSString *)message;
- (void)showSmallMessage:(NSString *)message withDuration:(NSTimeInterval)duration;

@end
