/*  psx2AppDelegate.m  */

/*  Copyright (C) 2011 bsdf

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "psx2AppDelegate.h"
#import "globals.h"
#import "operations.h"

@implementation psx2AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ _window center ];
}

-(IBAction)position_slider_changed:(id)sender
{
    float seek_pos = [ position_slider floatValue ] / [position_slider maxValue];
    control.set_seek_pos( seek_pos );
}

-(IBAction)stretch_slider_changed:(id)sender
{
    [ stretch_label setStringValue:[ self get_stretch_label ]];
}

-(NSString *)get_stretch_label
{
    double stretch_s = [ stretch_slider doubleValue ] / [ stretch_slider maxValue ];
    double stretch   = pow( 10.0, stretch_s * 4.0 );
    NSString *out    = [ NSString stringWithFormat:@"%.3fx", stretch, nil ];

    return out;
}

-(IBAction)resolution_slider_changed:(id)sender
{
    [ resolution_label setStringValue:[ self get_resolution_label ]];
}

-(NSString *)get_resolution_label
{
    NSString *out;
    
    double fftsize_s = [ resolution_slider doubleValue ];
    fftsize_s = pow( fftsize_s, 1.5 );
    
	int fftsize = (int)( pow( 2.0, fftsize_s * 12.0 ) * 512.0 );
	fftsize = optimizebufsize( fftsize );
	
    if ( fftsize < 1024.0 ) {
        out = [ NSString stringWithFormat:@"%d", fftsize, nil ];
    }
	else if ( fftsize < ( 1024.0 * 1024.0 ) ) {
        out = [ NSString stringWithFormat:@"%.4gK", fftsize/1024.0, nil ];
    }
	else if (fftsize < ( 1024.0 * 1024.0 * 1024.0 ) ) {
        out = [ NSString stringWithFormat:@"%.4gM", fftsize/(1024.0 * 1024.0), nil ];
    }
	else {
        out = [ NSString stringWithFormat:@"%.7gG", fftsize/(1024.0 * 1024.0 * 1024.0), nil ];
    }

	return out;
}

-(IBAction)onset_slider_changed:(id)sender
{	
    [ onset_label setStringValue:[ NSString stringWithFormat:@"%f", [ onset_slider doubleValue ], nil ]];
}

-(IBAction)stretch_parameters_changed:(id)sender
{
    double stretch    = [ stretch_slider doubleValue ] / [ stretch_slider maxValue ];
    double resolution = [ resolution_slider doubleValue ] / [ resolution_slider maxValue ];
    double onset      = [ onset_slider doubleValue ] / [ onset_slider maxValue ];
    int    mode       = 0;

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
    
    [ dlg beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if ( result == NSFileHandlingPanelOKButton ) {
            NSURL *filename = [[ dlg URLs ] objectAtIndex:0 ];
            [ self open_input_file:filename ];
        }
    } ];
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
    [ panel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
        if ( result == NSFileHandlingPanelOKButton ) {
            NSURL *url = [ panel URL ];
            
            FILE_TYPE type = [ self get_filetype:[ url pathExtension ]];
            
            std::string outfilename = [[ url path ] UTF8String ];
            
            // remove save sheet
            [ panel orderOut:nil ];
            [ NSApp endSheet:panel ];
            
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
        else {
            // remove save sheet
            [ panel orderOut:nil ];
            [ NSApp endSheet:panel ];
        }
    } ];
}

-(void)render_tick:(NSTimer *)sender
{
    double percent = control.info.render_percent;
    if ( percent != -1 ) {
        [ render_progressbar setDoubleValue:percent ];
    }
    else {
        [ render_progressbar setDoubleValue:0.0 ];
        [ render_progressbar setIndeterminate:YES ];
        [ render_progressbar startAnimation:self ];
        [ render_timer invalidate ];
        render_timer = nil;
        
        [ self performSelector:@selector(close_render_sheet:) withObject:nil afterDelay:2 ];
    }
}

-(IBAction)close_render_sheet:(id)sender
{
    // if this is coming from the UI, the user clicked cancel
    if ( sender != nil )
        control.info.cancel_render = true;

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
