#import "NSTextView_GlyphInput.h"
#import "GlyphInputController.h"

@implementation NSView (GlyphInput)

- (void)insertGlyphRepresentationOfKeyEquivalent:(id)sender
{
    [[GlyphInputController sharedGlyphInputController] showWindowForGlyphInsertion:self];
}

- (void)insertTextualRepresentationOfKeyEquivalent:(id)sender
{
    [[GlyphInputController sharedGlyphInputController] showWindowForTextInsertion:self];
}

@end
