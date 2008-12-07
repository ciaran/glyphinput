/* ISIMIncrementalSearchPanelController.h

Written 2004, Michael McCracken.

 This class controls an I-search panel that acts like the EMACS minibuffer to support incremental search forward and backward.

This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/1.0/ 
or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
*/

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>

@interface GlyphInputController : NSWindowController {
	BOOL textualMode;
	unsigned int lastModifierFlags;
	void *hotKeyModeToken;
}
- (BOOL)textualMode;
- (void)setTextualMode:(BOOL)isTextual;

- (unsigned int)lastModifierFlags;
- (void)setLastModifierFlags:(unsigned int)modifierFlags;


+ (id)sharedGlyphInputController;

- (IBAction)showWindowForGlyphInsertion:(id)sender;
- (IBAction)showWindowForTextInsertion:(id)sender;
@end
