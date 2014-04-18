//
//  Helpers.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

NSString* loadParticle(NSString *name);
NSArray* loadPatterns();
NSArray* loadGrooves();
SKColor* color(int note);
double beatInterval(double bpm);

CGPoint positionForStartOfLine(int line, CGRect frame);;
CGFloat positionForBaseline(CGRect frame);
CGPoint positionForNoteGivenY(int note, CGFloat y, CGRect frame);
CGPoint positionForNote(int note, CGRect frame);
CGPoint positionForEndOfLine(int line, CGRect frame);

