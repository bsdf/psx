/*  PSXWindow.m  */

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
