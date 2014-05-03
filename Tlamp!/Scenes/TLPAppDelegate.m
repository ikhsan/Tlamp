//
//  TLPAppDelegate.m
//  Tlamp!
//
//  Created by Ikhsan Assaat on 4/12/14.
//  Copyright (c) 2014 Ikhsan Assaat. All rights reserved.
//

#import "TLPAppDelegate.h"
#import "TLPMainScene.h"
#import "IXNXboxDrumpad.h"

//#define _DEBUG_ 1

@interface TLPAppDelegate () <IXNXboxDrumpadDelegate>

@property (strong, nonatomic) IXNXboxDrumpad *drumpad;

@end



@implementation TLPAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkForDevices];
    
    /* Pick a size for the scene */
    SKScene *scene = [TLPMainScene sceneWithSize:CGSizeMake(1280, 800)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [self.skView presentScene:scene];

#ifdef _DEBUG_
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
#else
    self.skView.showsFPS = NO;
    self.skView.showsNodeCount = NO;
#endif
}

- (void)checkForDevices
{
    NSArray *pads = [IXNXboxDrumpad connectedGamepads];
    if (pads.count > 0) {
        GameDevice *firstDevice = [[IXNXboxDrumpad connectedGamepads] firstObject];
        IXNXboxDrumpad *thePad = [IXNXboxDrumpad drumpadWithDevice:firstDevice];
        thePad.delegate = self;
        [thePad triggerLEDEvent:LEDTriggerAllBlink];
        [thePad listen];
        
        self.drumpad = thePad;
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)xboxDrumpad:(IXNXboxDrumpad *)drumpad keyEventPad:(KeyEventPad)padEvent
{
    TLPMainScene *scene = (TLPMainScene *)self.skView.scene;
    switch (padEvent) {
        case KeyEventHitRed:
            [scene noteHit:1];
            break;
        case KeyEventHitYellow:
            [scene noteHit:2];
            break;
        case KeyEventHitGreen:
            [scene noteHit:3];
            break;
        case KeyEventHitBlue:
            [scene noteHit:4];
            break;
        case KeyEventHitOrange:
            [scene noteHit:5];
            break;
            
        default:
            break;
    }
}

@end
