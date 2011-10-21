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

-(IBAction)stretch_parameters_changed:(id)sender
{
    double stretch    = [ stretch_slider doubleValue ] / [ stretch_slider maxValue ];
    double resolution = [ resolution_slider doubleValue ] / [ resolution_slider maxValue ];
    double onset      = [ onset_slider doubleValue ] / [ onset_slider maxValue ];
    int    mode       = 1;

    control.set_stretch_controls( stretch, mode, resolution, onset );
}

-(IBAction)window_type_changed:(id)sender
{
    FFTWindow type = (FFTWindow)[[ sender selectedItem ] tag ];
    control.set_window_type( type );
}

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
            [ position_slider setIntValue:0 ];
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
    NSOpenPanel *dlg = [ NSOpenPanel openPanel ];

    [ dlg setCanChooseFiles:YES ];
    [ dlg setCanChooseDirectories:NO ];
    [ dlg setAllowsMultipleSelection:NO ];
    
    if ( [ dlg runModal ] == NSOKButton )
    {
        NSURL *filename = [[ dlg URLs ] objectAtIndex:0 ];
        [ self open_input_file:filename ];
    }
}

-(void)open_input_file:(NSURL *)filename
{
    NSString *extension = [ filename pathExtension ];
    
    input_type = [ self get_filetype:extension ];
    
    if ( control.set_input_filename( [[ filename path ] UTF8String ], input_type )) {
        
    }
    else {
        NSAlert *err = [ NSAlert alertWithMessageText:@"ERROR"
                                        defaultButton:@"OK" 
                                      alternateButton:nil
                                          otherButton:nil
                            informativeTextWithFormat:@"" ];

        [ err setAlertStyle:NSWarningAlertStyle ];
        [ err runModal ];
    }
}

-(FILE_TYPE)get_filetype:(NSString *)ext
{
    ext = [ ext lowercaseString ];
    if ( [ ext isEqualToString:@"ogg" ] )
        return FILE_VORBIS;
    else if ( [ ext isEqualToString:@"mp3" ] )
        return FILE_MP3;
    else
        return FILE_WAV;
}

-(IBAction)render_audio:(id)sender
{
    NSSavePanel *panel = [ NSSavePanel savePanel ];
    
    if ( [ panel runModal ] == NSOKButton ) {
        NSURL *url = [ panel URL ];

        FILE_TYPE type = [ self get_filetype:[ url pathExtension ]];

        std::string outfilename = [[ url path ] UTF8String ];

        [ NSApp beginSheet:sheet modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil ];
        [ render_progressbar setIndeterminate:NO ];
        [ render_progressbar startAnimation:self ];
        render_timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                         target:self
                                                       selector:@selector(render_tick:) 
                                                       userInfo:nil
                                                        repeats:YES ];

        const char *outstr = control.Render( control.get_input_filename(), outfilename, type, input_type, 0, 1).c_str();
    }
}

-(void)render_tick:(NSTimer *)sender
{
    double percent = control.info.render_percent;
    if ( percent != -1 ) {
        [ render_progressbar setDoubleValue:percent ];
    }
    else {
        [ render_timer invalidate ];
        render_timer = nil;
        
        [ self close_render_sheet:nil ];
    }
}

-(IBAction)close_render_sheet:(id)sender
{
    [ render_progressbar stopAnimation:self ];
    [ sheet orderOut:nil ];
    [ NSApp endSheet:sheet ];
}

-(void)handle_modifier_key_press:(NSEvent *)theEvent
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
