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

-(IBAction)position_slider_changed:(id)sender
{
    float seek_pos = [ position_slider floatValue ] / [position_slider maxValue];
    control.set_seek_pos( seek_pos );
}

-(IBAction)stretch_slider_changed:(id)sender {}
-(IBAction)resolution_slider_changed:(id)sender {}
-(IBAction)onset_slider_changed:(id)sender {}

-(IBAction)press_play:(id)sender
{
    if ( !currently_playing ) {
        [ play_button setTitle:@"❚❚" ];
        
        bool bypass = false;
        if ( [[ NSApp currentEvent ] modifierFlags ] & NSAlternateKeyMask )
            bypass = true;
        
        control.startplay( bypass );
        playback_timer = [ NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(playback_tick:) 
                                                         userInfo:nil
                                                          repeats:YES ];
    }
    else {
        [ play_button setTitle:@"▶" ];
        
        // alt key turns button into stop
        if ( [[ NSApp currentEvent ] modifierFlags ] & NSAlternateKeyMask ) {
            control.stopplay();
        }
        else {
            control.pauseplay();
        }
        
        [ playback_timer invalidate ];
        playback_timer = nil;
    }
    
    currently_playing = !currently_playing;
}

-(void)playback_tick:(NSTimer *)sender
{
    double pos = [ position_slider maxValue ] * control.get_seek_pos();
    [ position_slider setFloatValue:[ position_slider maxValue ] * control.get_seek_pos() ];
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
    
    if ( control.set_input_filename( [[ filename path ] UTF8String ], intype )) {
        
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

- (void)handle_modifier_key_press:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSAlternateKeyMask) {
        if ( currently_playing ) {
            [ play_button setTitle:@"◼" ];
        }
    } else {
        if ( currently_playing ) {
            [ play_button setTitle:@"❚❚" ];
        }
        else {
            [ play_button setTitle:@"▶" ];
        }
    }
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
