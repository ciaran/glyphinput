#import <AppKit/AppKit.h>

@interface NSView (GlyphInput)
- (void)insertGlyphRepresentationOfKeyEquivalent:(id)sender;
- (void)insertTextualRepresentationOfKeyEquivalent:(id)sender;
@end
