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

@property (strong) IBOutlet NSWindow *window;

@end
