//
//  psx2AppDelegate.m
//  psx2
//
//  Created by David Semke on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "psx2AppDelegate.h"
#import "globals.h"

@implementation psx2AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

-(IBAction)open_file:(id)sender
{
    NSOpenPanel *dlg = [NSOpenPanel openPanel];

    [dlg setCanChooseFiles:YES];
    [dlg setCanChooseDirectories:NO];
    [dlg setAllowsMultipleSelection:NO];
    
    if ( [dlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        NSURL *filename = [[dlg URLs] objectAtIndex:0];
        [self open_input_file:filename];
    }
}

-(void)open_input_file:(NSURL *)filename
{
    FILE_TYPE intype;
    NSString *extension = [[filename pathExtension] lowercaseString];
    
    if ( [extension isEqualToString:@"ogg"] )
        intype = FILE_VORBIS;
    else if ( [extension isEqualToString:@"mp3"] )
        intype = FILE_MP3;
    else
        intype = FILE_WAV;
    
    if ( control.set_input_filename( [[filename resourceSpecifier] UTF8String], intype ) ) {

    }
    else {
        NSAlert *err = [NSAlert alertWithMessageText:@"ERROR"
                                       defaultButton:@"OK" 
                                     alternateButton:nil
                                         otherButton:nil
                           informativeTextWithFormat:@""];
        
        [err setAlertStyle:NSWarningAlertStyle];
        [err runModal];
    }
}

@end
