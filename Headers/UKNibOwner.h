/* =============================================================================
	FILE:		UKNibOwner.h
	PROJECT:	CocoaTADS

    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Modified BSD

	REVISIONS:
		2004-11-13	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Classes:
// -----------------------------------------------------------------------------

@interface UKNibOwner : NSObject
{
    NSMutableArray*     topLevelObjects;
}

-(NSString*)    nibFilename;    // Defaults to name of the class.

@end
