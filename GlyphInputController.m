#import "GlyphInputController.h"
#import <stdlib.h>
#import "MethodSwizzle.h"

const int CommandGlyphValue       = 0x2318;
const int ShiftGlyphValue         = 0x21E7;
const int SpaceGlyphValue         = 0x2423;
const int LeftArrowGlyphValue     = 0x2190;
const int RightArrowGlyphValue    = 0x2192;
const int UpArrowGlyphValue       = 0x2191;
const int DownArrowGlyphValue     = 0x2193;
const int HomeGlyphValue          = 0x2196;
const int EndGlyphValue           = 0x2198;
const int PageUpGlyphValue        = 0x21DE;
const int PageDownGlyphValue      = 0x21DF;
const int EscapeGlyphValue        = 0x238B;
const int TabGlyphValue           = 0x21E5;
const int EnterGlyphValue         = 0x21A9;
const int ReturnGlyphValue        = 0x2305;
const int ControlGlyphValue       = 0x2303;
const int OptionGlyphValue        = 0x2325;
const int DeleteGlyphValue        = 0x232B;
const int ForwardDeleteGlyphValue = 0x2326;

@implementation GlyphInputController
+ (id)sharedGlyphInputController {
    static GlyphInputController *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[GlyphInputController alloc] init];
    }
    return sharedInstance;
}

+ (void)initialize
{
	if ([[NSApplication class] respondsToSelector:@selector(mySendEvent:)]) return;
	MethodSwizzle([NSApplication class], @selector(sendEvent:), @selector(mySendEvent:));
}

- (id)init {
	hotKeyModeToken = 0;
	if (self = [super initWithWindowNibName:@"GlyphInputPanel" owner:self]) {
		[[self window] setDelegate:self];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
	if (hotKeyModeToken != 0)
		PopSymbolicHotKeyMode(hotKeyModeToken);
	hotKeyModeToken = 0;
}

- (void)showWindowIfNeeded:(id)sender;
{
	NSWindow *searchWindow = [self window];
	if(![searchWindow isVisible]) {
		NSView *view = [sender enclosingScrollView];
		if (view == nil) view = sender;
		NSRect textFieldRect = [view convertRect: [view bounds] toView: nil];
		NSWindow *textFieldWindow = [view window];
		textFieldRect.origin = [textFieldWindow convertBaseToScreen: textFieldRect.origin];
		[searchWindow setFrameTopLeftPoint: textFieldRect.origin];
		NSRect visibleFrame = [[textFieldWindow screen] visibleFrame];
		if (!NSContainsRect(visibleFrame, [searchWindow frame])) {
			NSPoint textFieldTopLeft = { textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height};
			[searchWindow setFrameOrigin: textFieldTopLeft];
		}
	}
	[self showWindow:self];
	lastModifierFlags = 0;
	if (hotKeyModeToken == 0)
		hotKeyModeToken = PushSymbolicHotKeyMode(kHIHotKeyModeAllDisabled);
}

- (IBAction)showWindowForGlyphInsertion:(id)sender{
	[self showWindowIfNeeded: sender];
	[self setTextualMode:NO];
}

- (IBAction)showWindowForTextInsertion:(id)sender{
	[self showWindowIfNeeded: sender];
	[self setTextualMode:YES];
}

- (BOOL)textualMode
{
	return textualMode;
}

- (void)setTextualMode:(BOOL)isTextual
{
	textualMode = isTextual;
}

- (void)setLastModifierFlags:(unsigned int)modifierFlags
{
	lastModifierFlags = modifierFlags;
}

- (unsigned int)lastModifierFlags
{
	return lastModifierFlags;
}

@end

@implementation NSApplication (KeyInterception)
- (NSMutableString *)stringRepresentingModifierFlags:(unsigned int)modifierFlags
{
	NSMutableString *glyphs = [NSMutableString string];
	if (modifierFlags & NSControlKeyMask) {
		if (![[GlyphInputController sharedGlyphInputController] textualMode])
			[glyphs appendString:[NSString stringWithFormat:@"%C",ControlGlyphValue]];
		else
			[glyphs appendString:@"Control-"];
	}
	if (modifierFlags & NSAlternateKeyMask) {
		if (![[GlyphInputController sharedGlyphInputController] textualMode])
			[glyphs appendString:[NSString stringWithFormat:@"%C",OptionGlyphValue]];
		else
			[glyphs appendString:@"Option-"];
	}
	if (modifierFlags & NSShiftKeyMask) {
		if (![[GlyphInputController sharedGlyphInputController] textualMode])
			[glyphs appendString:[NSString stringWithFormat:@"%C",ShiftGlyphValue]];
		else
			[glyphs appendString:@"Shift-"];
	}
	if (modifierFlags & NSCommandKeyMask) {
		if (![[GlyphInputController sharedGlyphInputController] textualMode])
			[glyphs appendString:[NSString stringWithFormat:@"%C",CommandGlyphValue]];
		else
			[glyphs appendString:@"Command-"];
	}
	return glyphs;
}

- (void)insertTextAndClose:(NSString *)text
{
	[[[NSApp mainWindow] firstResponder] insertText:text];
	[[GlyphInputController sharedGlyphInputController] close];
}

- (BOOL)hasNoModifiers:(unsigned int)modifierFlags
{
	return !(modifierFlags & NSShiftKeyMask || modifierFlags & NSControlKeyMask || modifierFlags & NSAlternateKeyMask || modifierFlags & NSCommandKeyMask);
}

- (void)mySendEvent:(NSEvent *)event
{
	if ([event type] == NSKeyDown && [[[GlyphInputController sharedGlyphInputController] window] isVisible]) {
		char charCode;
		GetEventParameter((EventRef)[event eventRef], kEventParamKeyMacCharCodes, typeChar, NULL, sizeof(char), NULL, &charCode);
		unichar key = 0;

		NSMutableString *glyphs = [self stringRepresentingModifierFlags:[event modifierFlags]];
		if (![[GlyphInputController sharedGlyphInputController] textualMode]) {
			switch ([[event charactersIgnoringModifiers] characterAtIndex:0]) {
				case NSLeftArrowFunctionKey:	key = LeftArrowGlyphValue; break;
				case NSRightArrowFunctionKey:	key = RightArrowGlyphValue; break;
				case NSUpArrowFunctionKey:		key = UpArrowGlyphValue; break;
				case NSDownArrowFunctionKey:	key = DownArrowGlyphValue; break;
				case NSPageDownFunctionKey:	key = PageDownGlyphValue; break;
				case NSPageUpFunctionKey:		key = PageUpGlyphValue; break;
				case NSHomeFunctionKey:			key = HomeGlyphValue; break;
				case NSEndFunctionKey:			key = EndGlyphValue; break;
				case NSTabCharacter:				key = TabGlyphValue; break;
				case 32:								key = SpaceGlyphValue; break;
				case 13:								key = EnterGlyphValue; break;
				case NSEnterCharacter:			key = ReturnGlyphValue; break;
				case 27:								key = EscapeGlyphValue; break;
				case 127:							key = DeleteGlyphValue; break;
				case 63272:							key = ForwardDeleteGlyphValue; break;
			}
			if(key)
				[glyphs appendString:[[NSString stringWithFormat:@"%C",key] uppercaseString]];
			else
				[glyphs appendString:[[NSString stringWithFormat:@"%c",charCode] uppercaseString]];
		} else {
			NSString *string = nil;//[[NSString stringWithFormat:@"%C",key] uppercaseString];
			switch ([[event charactersIgnoringModifiers] characterAtIndex:0]) {
				case NSLeftArrowFunctionKey:	string = @"Left"; break;
				case NSRightArrowFunctionKey:	string = @"Right"; break;
				case NSUpArrowFunctionKey:		string = @"Up"; break;
				case NSDownArrowFunctionKey:	string = @"Down"; break;
				case NSPageDownFunctionKey:	string = @"Page-Down"; break;
				case NSPageUpFunctionKey:		string = @"Page-Up"; break;
				case NSHomeFunctionKey:			string = @"Home"; break;
				case NSEndFunctionKey:			string = @"End"; break;
				case NSTabCharacter:				string = @"Tab"; break;
				case 32:								string = @"Space"; break;
				case 13:								string = @"Return"; break;
				case NSEnterCharacter:			string = @"Enter"; break;
				case 27:								string = @"Escape"; break;
				case 127:							string = @"Delete"; break;
				case 63272:							string = @"Forward-Delete"; break;
			}
			if(string)
				[glyphs appendString:string];
			else
				[glyphs appendString:[[NSString stringWithFormat:@"%c",charCode] uppercaseString]];
		}
		[self insertTextAndClose:glyphs];
	} else if ([event type] == NSFlagsChanged && [[[GlyphInputController sharedGlyphInputController] window] isVisible]) {
		if (![self hasNoModifiers:[[GlyphInputController sharedGlyphInputController] lastModifierFlags]] &&
			[self hasNoModifiers:[event modifierFlags]]) {
			[self insertTextAndClose:[self stringRepresentingModifierFlags:[[GlyphInputController sharedGlyphInputController] lastModifierFlags]]];
			return;
		}
		[[GlyphInputController sharedGlyphInputController] setLastModifierFlags:[event modifierFlags]];
	} else {
		[self mySendEvent:event];
	}
}
@end
