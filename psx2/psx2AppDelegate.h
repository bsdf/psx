//
//  psx2AppDelegate.h
//  psx2
//
//  Created by David Semke on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Control.h"

@interface psx2AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
    Control   control;
}

-(IBAction)open_file:(id)sender;

-(void)open_input_file:(NSURL *)filename;

@property (strong) IBOutlet NSWindow *window;

@end
