/* =============================================================================
	FILE:		NSBezierPathCappedBoxes.h
	PROJECT:	UKDistributedView

    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
                Christoffer Lerno
    
    LICENSES:   GPL, Modified BSD, Commercial (ask for pricing)

	REVISIONS:
		2003-12-19	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//	CappedBoxes category on NSBezierPath:
// -----------------------------------------------------------------------------

@interface NSBezierPath (CappedBoxes)

+(NSBezierPath*)	bezierPathWithCappedBoxInRect: (NSRect)rect;

@end
