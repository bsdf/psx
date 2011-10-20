//
//  PSXWindow.m
//  paulstretch
//
//  Created by David Semke on 10/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSXWindow.h"

@implementation PSXWindow

- (void)sendEvent:(NSEvent *)theEvent
{
    if ([theEvent type] == NSFlagsChanged) {
        [NSApp sendAction:@selector(handle_modifier_key_press:) to:nil from:theEvent];
    }
    [super sendEvent:theEvent];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

@end
