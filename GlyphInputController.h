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
