/* =============================================================================
	FILE:		UKFinderIconCell.h
	PROJECT:	UKDistributedView

    COPYRIGHT:  (c) 2003 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   GPL, Commercial (ask for pricing)

	REVISIONS:
		2003-12-19	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//  Constants:
// -----------------------------------------------------------------------------

#define UKFIC_TEXT_VERTMARGIN		1		// How many pixels is selection supposed to extend above and below the title?
#define UKFIC_TEXT_HORZMARGIN		3		// How many pixels is selection supposed to extend to the left and right of the title?
#define UKFIC_SELBOX_VERTMARGIN		1		// How much distance do you want between top of cell/title and icon's highlight box?
#define UKFIC_SELBOX_HORZMARGIN		1		// How much distance do you want between right/left edges of cell and icon's highlight box?
#define UKFIC_SELBOX_OUTLINE_WIDTH  2		// Width of outline of selection box around icon.
#define UKFIC_IMAGE_VERTMARGIN		2		// Distance between maximum top/bottom edges of image and highlight box.
#define UKFIC_IMAGE_HORZMARGIN		2		// Distance between maximum left/right edges of image and highlight box.


// -----------------------------------------------------------------------------
//  Data Structures:
// -----------------------------------------------------------------------------

typedef union UKFICFlags
{
    struct {
        unsigned int    selected:1;         // Is this cell currently selected?
        unsigned int    flipped:1;          // Cached isFlipped from the view we're drawn in.
        unsigned int    currentlyEditing:1; // Currently being inline-edited?
        unsigned int    drawSeparator:1;    // Draw a separator line at the top of this cell?
        unsigned int    unusedFlags:28;
    };
    int     allFlags;
} UKFICFlags;


// -----------------------------------------------------------------------------
//  Class declaration:
// -----------------------------------------------------------------------------

@interface UKFinderIconCell : NSTextFieldCell
{
	NSString*			info;			// Description text to display under image. (NYI)
	NSImage*			image;			// Icon to display for this item.
	NSColor*			nameColor;		// Color to use for name. Defaults to white.
	NSColor*			boxColor;		// Color to use for the box around the icon (when highlighted). Defaults to grey.
	NSColor*			selectionColor; // Color to use for background of the highlighted name. Defaults to blue.
	NSColor*			bgColor;        // Color to use for background of the cell. Defaults to none.
	NSCellImagePosition imagePosition;  // Image position relative to title.
    NSLineBreakMode     truncateMode;   // Truncate string left, middle or right if it's wider than cell?
    float               alpha;          // Opacity.
	UKFICFlags          flags;          // Boolean flags and properties of this cell.
    id                  reserved1;
    id                  reserved2;
    id                  reserved3;
    id                  reserved4;
}

-(id)		init;
-(id)		initTextCell: (NSString*)img;
//-(id)		initImageCell: (NSImage*)img;	// Designated initializer.

-(void)		setHighlighted: (BOOL)isSelected;
-(BOOL)     isHighlighted;

-(void)		drawWithFrame: (NSRect)box inView: (NSView*)aView;

-(void)		setNameColor: (NSColor*)col;
-(NSColor*) nameColor;

-(void)		setBoxColor: (NSColor*)col;
-(NSColor*) boxColor;

-(void)		setSelectionColor: (NSColor*)col;
-(NSColor*) selectionColor;

-(void)		setBgColor: (NSColor*)col;
-(NSColor*) bgColor;

-(void)		resetColors;

-(void)             setTruncateMode: (NSLineBreakMode)m;
-(NSLineBreakMode)  truncateMode;

-(void)             setAlpha: (float)a;
-(float)            alpha;

-(BOOL)             isFlipped;

-(void)             setDrawSeparator: (BOOL)isSelected;
-(BOOL)             drawSeparator;


// Accessing image:
//setImage: and image are inherited from NSCell.
-(NSCellImagePosition)  imagePosition;
-(void)					setImagePosition: (NSCellImagePosition)newImagePosition;	// Currently, only "above" and "below" work.

@end


// -----------------------------------------------------------------------------
//  Functions:
// -----------------------------------------------------------------------------

// Truncate a string by inserting an ellipsis ("..."). truncateMode can be NSLineBreakByTruncatingHead, NSLineBreakByTruncatingMiddle or NSLineBreakByTruncatingTail.
NSString*   UKStringByTruncatingStringWithAttributesForWidth( NSString* s,
                                                                NSDictionary* attrs,
                                                                float wid,
                                                                NSLineBreakMode truncateMode );
