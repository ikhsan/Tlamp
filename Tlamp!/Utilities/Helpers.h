//
//  Helpers.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

// file loader
NSString* loadParticle(NSString *name);
NSArray* loadPatterns();
NSArray* loadRhythms();

// color picker
SKColor* color(int note);

// tempo
double beatInterval(double bpm);

// line positions
CGPoint positionForStartOfLine(int line, CGRect frame);;
CGPoint positionForEndOfLine(int line, CGRect frame);
CGFloat positionForBaseline(CGRect frame);
CGPoint positionForNote(int note, CGRect frame);
CGPoint positionForValuator(int note, CGRect frame);