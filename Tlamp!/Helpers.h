//
//  Helpers.h
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/13/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

@import SpriteKit;

NSString* loadParticle(NSString *name);
SKColor* color(int note);
CGPoint positionForStartOfLine(int line, CGRect frame);;
CGPoint positionForEndOfLine(int line, CGRect frame);
CGPoint positionForNote(int note, CGRect frame);

