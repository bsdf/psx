/*  psx2AppDelegate.h  */

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

#import <Cocoa/Cocoa.h>
#import "Control.h"

@interface psx2AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *_window;
    
    Control   control;
    FILE_TYPE input_type;
    
    BOOL      currently_playing;
    NSTimer  *playback_timer;
    NSTimer  *render_timer;

    IBOutlet NSPanel       *sheet;
    IBOutlet NSSlider      *position_slider;
    IBOutlet NSSlider      *stretch_slider;
    IBOutlet NSSlider      *resolution_slider;
    IBOutlet NSSlider      *onset_slider;
    IBOutlet NSButton      *play_button;
    IBOutlet NSPopUpButton *window_type;
    
    IBOutlet NSProgressIndicator *render_progressbar;
}

-(IBAction)open_file:(id)sender;
-(IBAction)press_play:(id)sender;
-(IBAction)position_slider_changed:(id)sender;
-(IBAction)stretch_slider_changed:(id)sender;
-(IBAction)resolution_slider_changed:(id)sender;
-(IBAction)onset_slider_changed:(id)sender;

-(IBAction)stretch_parameters_changed:(id)sender;
-(IBAction)window_type_changed:(id)sender;

-(IBAction)render_audio:(id)sender;
-(IBAction)close_render_sheet:(id)sender;

-(void)open_input_file:(NSURL *)filename;

-(FILE_TYPE)get_filetype:(NSString *)ext;

@property (strong) IBOutlet NSWindow *window;

@end
