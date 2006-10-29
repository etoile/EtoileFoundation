/* =============================================================================
	FILE:		UKFinderIconCell.m
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

#import "UKFinderIconCell.h"
#import "NSBezierPathCappedBoxes.h"
#import "NSImage+NiceScaling.h"

// -----------------------------------------------------------------------------
//  Private Methods:
// -----------------------------------------------------------------------------

@interface UKFinderIconCell (UKPrivateMethods)

-(void) setFlipped: (BOOL)a;    // Is reset each time cell is drawn in a view.

-(void) makeAlignmentConformImagePosition;

@end


@implementation UKFinderIconCell

// -----------------------------------------------------------------------------
//  Designated initializer:
// -----------------------------------------------------------------------------

-(id)   initTextCell: (NSString*)txt
{
	self = [super initTextCell: txt];
	if( self )
	{
		flags.selected = NO;
		image = [[NSImage imageNamed: @"NSApplicationIcon"] retain];
		nameColor = [[NSColor controlBackgroundColor] retain];
		//boxColor = [[NSColor secondarySelectedControlColor] retain];
		boxColor = [[NSColor selectedControlColor] retain];
		//selectionColor = [[NSColor alternateSelectedControlColor] retain];
		selectionColor = [[NSColor selectedControlColor] retain];
		imagePosition = NSImageAbove;
        truncateMode = NSLineBreakByTruncatingMiddle;
        alpha = 1.0;
		[self makeAlignmentConformImagePosition];
	}
	
	return self;
}

-(id)   initImageCell: (NSImage*)img
{
	self = [self initTextCell: @"UKDVUKDT"];
	
	if( self )
		[self setImage: img];
	
	return self;
}


/* -----------------------------------------------------------------------------
	initWithCoder:
		Persistence constructor needed for IB palette.
	
	REVISIONS:
        2004-12-03	UK	Created.
   -------------------------------------------------------------------------- */

-(id)   initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	
    flags.selected = NO;
    truncateMode = NSLineBreakByTruncatingMiddle;
    
    if( [decoder allowsKeyedCoding] )
    {
        image = [[decoder decodeObjectForKey: @"UKFICimage"] retain];
        nameColor = [[decoder decodeObjectForKey: @"UKFICnameColor"] retain];
        boxColor = [[decoder decodeObjectForKey: @"UKFICboxColor"] retain];
        selectionColor = [[decoder decodeObjectForKey: @"UKFICselectionColor"] retain];
        bgColor = [[decoder decodeObjectForKey: @"UKFICbgColor"] retain];
        imagePosition = [decoder decodeIntForKey: @"UKFICimagePosition"];
        truncateMode = [decoder decodeIntForKey: @"UKFICtruncateMode"];
        alpha = [decoder decodeFloatForKey: @"UKFICalpha"];
    }
    else
    {
        image = [[decoder decodeObject] retain];
        nameColor = [[decoder decodeObject] retain];
        boxColor = [[decoder decodeObject] retain];
        selectionColor = [[decoder decodeObject] retain];
        bgColor = [[decoder decodeObject] retain];
        [decoder decodeValueOfObjCType:@encode(int) at: &imagePosition];
        [decoder decodeValueOfObjCType:@encode(int) at: &truncateMode];
        [decoder decodeValueOfObjCType:@encode(float) at: &alpha];
    }

    if( !image )
        image = [[NSImage imageNamed: @"NSApplicationIcon"] retain];
    if( !nameColor )
        nameColor = [[NSColor controlBackgroundColor] retain];
    if( !boxColor )
        //boxColor = [[NSColor secondarySelectedControlColor] retain];
		boxColor = [[NSColor selectedControlColor] retain];
    if( !selectionColor )
        //selectionColor = [[NSColor alternateSelectedControlColor] retain];
		selectionColor = [[NSColor selectedControlColor] retain];
    [self makeAlignmentConformImagePosition];
    
    return self;
}


/* -----------------------------------------------------------------------------
	encodeWithCoder:
		Save this cell to a file. Used by IB.
	
	REVISIONS:
        2004-12-03	UK	Created.
   -------------------------------------------------------------------------- */

-(void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	
    if( [coder allowsKeyedCoding] )
    {
        [coder encodeObject: image forKey: @"UKFICimage"];
        [coder encodeObject: nameColor forKey: @"UKFICnameColor"];
        [coder encodeObject: boxColor forKey: @"UKFICboxColor"];
        [coder encodeInt: imagePosition forKey: @"UKFICimagePosition"];
        [coder encodeObject: selectionColor forKey: @"UKFICselectionColor"];
        [coder encodeObject: bgColor forKey: @"UKFICbgColor"];
        [coder encodeInt: truncateMode forKey: @"UKFICtruncateMode"];
        [coder encodeFloat: alpha forKey: @"UKFICalpha"];
    }
    else
    {
        [coder encodeObject: image];
        [coder encodeObject: nameColor];
        [coder encodeObject: boxColor];
        [coder encodeObject: selectionColor];
        [coder encodeObject: bgColor];
        [coder encodeValueOfObjCType:@encode(int) at: &imagePosition];
        [coder encodeValueOfObjCType:@encode(int) at: &truncateMode];
        [coder encodeValueOfObjCType:@encode(float) at: &alpha];
    }
}


// -----------------------------------------------------------------------------
//  Initializer for us lazy ones:
// -----------------------------------------------------------------------------

-(id)   init
{
	return [self initTextCell: @"UKDVUliDaniel"];
}


// -----------------------------------------------------------------------------
//  Destructor:
// -----------------------------------------------------------------------------

-(void) dealloc
{
	[image release];
	image = nil;
	[nameColor release];
	nameColor = nil;
	[boxColor release];
	boxColor = nil;
	[selectionColor release];
	selectionColor = nil;
	[bgColor release];
	bgColor = nil;
	
	[super dealloc];
}


/* -----------------------------------------------------------------------------
	copyWithZone:
		Implement the NSCopying protocol (IB requires this, and some cell-based
        classes may, as well).
	
	REVISIONS:
        2004-12-23	UK	Documented.
   -------------------------------------------------------------------------- */

-(id)   copyWithZone: (NSZone*)zone
{
    UKFinderIconCell	*cell = (UKFinderIconCell*) [super copyWithZone: zone];

    cell->image = [image retain];
	cell->nameColor = [nameColor retain];
	cell->boxColor = [boxColor retain];
	cell->selectionColor = [selectionColor retain];
	cell->bgColor = [bgColor retain];

    return cell;
}


// -----------------------------------------------------------------------------
//  Reset boxColor, nameColor and selectionColor to the defaults:
// -----------------------------------------------------------------------------

-(void) resetColors
{
	[self setNameColor: [NSColor controlBackgroundColor]];
	//[self setBoxColor: [NSColor secondarySelectedControlColor]];
	[self setBoxColor: [NSColor selectedControlColor]];
	//[self setSelectionColor: [NSColor alternateSelectedControlColor]];
	[self setSelectionColor: [NSColor selectedControlColor]];
	[self setBgColor: nil];
}


// -----------------------------------------------------------------------------
//  Mutator for cell selection state:
// -----------------------------------------------------------------------------

-(void) setHighlighted: (BOOL)isSelected
{
	flags.selected = isSelected;
}


-(BOOL)             isHighlighted
{
    return flags.selected;
}



// -----------------------------------------------------------------------------
//  Accessor for cell flipped state (cached from last drawing):
//      Mutator is in private methods.
// -----------------------------------------------------------------------------

-(BOOL)             isFlipped
{
    return flags.flipped;
}



// -----------------------------------------------------------------------------
//  Mutator for separator at top of cell:
// -----------------------------------------------------------------------------

-(void) setDrawSeparator: (BOOL)isSelected
{
	flags.drawSeparator = isSelected;
}


-(BOOL)     drawSeparator
{
    return flags.drawSeparator;
}



// -----------------------------------------------------------------------------
//  Draws everything you see of the cell:
// -----------------------------------------------------------------------------

-(void) drawWithFrame: (NSRect)box inView: (NSView*)aView
{
	NSRect				imgBox = box,
						textBox = box,
						textBgBox = box;
	NSDictionary*		attrs = nil;
	NSColor*			txBgColor = nil;
	NSString*			displayTitle = [self title];
	NSCellImagePosition imagePos = imagePosition;
    flags.flipped = [aView isFlipped];
	
    /*
    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSFont systemFontOfSize: 12], NSFontAttributeName,
                    [[NSColor alternateSelectedControlTextColor] colorWithAlphaComponent: alpha], NSForegroundColorAttributeName,
                    nil];*/
    
    if( bgColor )
    {
        [bgColor set];
        [NSBezierPath fillRect: box];
    }
    if( flags.drawSeparator )
    {
        [NSBezierPath setDefaultLineWidth: 2];
        [NSBezierPath setDefaultLineCapStyle: NSRoundLineCapStyle];
        [[NSColor lightGrayColor] set];
        [NSBezierPath strokeLineFromPoint: NSMakePoint(box.origin.x, box.origin.y +box.size.height -1)
                        toPoint: NSMakePoint(box.origin.x +box.size.width, box.origin.y +box.size.height -1)];
        [NSBezierPath setDefaultLineWidth: 1];
        [NSBezierPath setDefaultLineCapStyle: NSSquareLineCapStyle];
    }
    
	if( flags.flipped )
	{
		switch( imagePosition )
		{
			case NSImageAbove:
				imagePos = NSImageBelow;
				break;
			
			case NSImageBelow:
				imagePos = NSImageAbove;
				break;
			
			case NSNoImage:		// Just to shut up compiler warnings.
			case NSImageOnly:
			case NSImageLeft:
			case NSImageRight:
			case NSImageOverlaps:
				break;
		}
	}
	
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect: box];   // Make sure we don't draw outside our cell.
	
	// Set up text attributes for title:
	if( flags.selected )
	{
		attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont systemFontOfSize: 12], NSFontAttributeName,
						/*[[NSColor alternateSelectedControlTextColor] colorWithAlphaComponent: alpha], NSForegroundColorAttributeName,
						nil];*/
						[[NSColor selectedControlTextColor] colorWithAlphaComponent: alpha], NSForegroundColorAttributeName,
						nil];
		txBgColor = [selectionColor colorWithAlphaComponent: alpha];
	}
	else
	{
		attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont systemFontOfSize: 12], NSFontAttributeName,
						[[NSColor controlTextColor] colorWithAlphaComponent: alpha], NSForegroundColorAttributeName,
						nil];
		txBgColor = [nameColor colorWithAlphaComponent: alpha];
	}
	
    // Calculate area left for title beside image:
	NSSize			txSize = [displayTitle sizeWithAttributes: attrs];
    int             titleHReduce = 0;   // How much to make title narrower to allow for icon next to it.
	NSSize          imgSize = { 0,0 };
    
    imgSize = [NSImage scaledSize: [image size] toFitSize: box.size];
    
    if( imagePos == NSImageLeft || imagePos == NSImageRight )
        titleHReduce = imgSize.width +(UKFIC_SELBOX_HORZMARGIN +UKFIC_SELBOX_OUTLINE_WIDTH) *2;
    
	// Truncate string if needed:
	displayTitle = UKStringByTruncatingStringWithAttributesForWidth( displayTitle, attrs,
							(box.size.width -titleHReduce -txSize.height -(2* UKFIC_TEXT_HORZMARGIN)), truncateMode );  // Removed - - here.

	// Calculate rectangle for text:
	txSize = [displayTitle sizeWithAttributes: attrs];
	
	if( imagePos == NSImageAbove		// Finder icon view (big, title below image).
		|| imagePos == NSImageBelow )  // Title *above* image.
	{
		textBox.size = txSize;
		textBox.origin.x += truncf((box.size.width -txSize.width) / 2);  // Center our text at cell's bottom.
		if( imagePos == NSImageAbove )
			textBox.origin.y += UKFIC_TEXT_VERTMARGIN;
		else
			textBox.origin.y = box.origin.y +box.size.height -txSize.height -UKFIC_TEXT_VERTMARGIN;
		textBgBox = NSInsetRect( textBox, -UKFIC_TEXT_HORZMARGIN -truncf(txSize.height /2),
									-UKFIC_TEXT_VERTMARGIN );		// Give us some room around our text.
	}
	else if( imagePos == NSImageLeft
			|| imagePos == NSImageRight )
	{
		textBox.size = txSize;
		textBox.origin.y += truncf((box.size.height -txSize.height) / 2);  // Center our text vertically in cell.
		if( imagePos == NSImageLeft )
			textBox.origin.x += UKFIC_TEXT_HORZMARGIN;
		else
			textBox.origin.x = box.origin.x +box.size.width -txSize.width -UKFIC_TEXT_HORZMARGIN;
		textBgBox = NSInsetRect( textBox, -UKFIC_TEXT_HORZMARGIN *2, -UKFIC_TEXT_VERTMARGIN /*-truncf(txSize.height /2)*/ );		// Give us some room around our text.
	}
		
	// Prepare image and image highlight rect:
	switch( imagePos )
	{
		case NSImageAbove:
			imgBox.origin.y += textBgBox.size.height;
			imgBox.size.height -= textBgBox.size.height;
			break;
			
		case NSImageBelow:
			imgBox.size.height -= textBgBox.size.height;
			break;
		
		// TODO: Sidewards titles are broken.
		case NSImageLeft:
			imgBox.size.width -= textBgBox.size.width;
			break;
			
		case NSImageRight:
			imgBox.size.width -= textBgBox.size.width;
			break;
		
		case NSNoImage:
		case NSImageOnly:
		case NSImageOverlaps:
			NSLog(@"UKFinderIconCell - Unsupported image position mode.");
			break;
	}
	
	if( imagePos == NSImageRight
		|| imagePos == NSImageLeft )
		imgBox = NSInsetRect( imgBox, UKFIC_SELBOX_VERTMARGIN +UKFIC_SELBOX_OUTLINE_WIDTH,
										UKFIC_SELBOX_HORZMARGIN +UKFIC_SELBOX_OUTLINE_WIDTH );
	else
		imgBox = NSInsetRect( imgBox, UKFIC_SELBOX_HORZMARGIN +UKFIC_SELBOX_OUTLINE_WIDTH,
										UKFIC_SELBOX_VERTMARGIN +UKFIC_SELBOX_OUTLINE_WIDTH );
	
	// Make sure icon box is pretty and square:
	if( imgBox.size.height < imgBox.size.width )
	{
		float   diff = imgBox.size.width -imgBox.size.height;
		
		imgBox.size.width = imgBox.size.height; // Force width to be same as height.
		if( imagePos == NSImageAbove
			|| imagePos == NSImageBelow )
			imgBox.origin.x += truncf(diff/2);		// Center narrower box in cell.
	}
	
	if( imagePos == NSImageLeft )
	{
		textBox.origin.x += imgBox.size.width +(UKFIC_TEXT_VERTMARGIN *3);
		textBgBox.origin.x += imgBox.size.width +(UKFIC_TEXT_VERTMARGIN *3);
	}
	else if( imagePos == NSImageRight )
	{
		imgBox.origin.x = box.origin.x +box.size.width -imgBox.size.width -UKFIC_SELBOX_HORZMARGIN;
		textBox.origin.x -= imgBox.size.width +(UKFIC_TEXT_VERTMARGIN *3);
		textBgBox.origin.x -= imgBox.size.width +(UKFIC_TEXT_VERTMARGIN *3);
	}
	
	// Draw text background either with white, or with "selected" color:
	[txBgColor set];
	[[NSBezierPath bezierPathWithCappedBoxInRect: textBgBox] fill];   // draw text bg.
	
	// Draw actual text:
	if( !flags.currentlyEditing )
		[displayTitle drawInRect: textBox withAttributes: attrs];
	
	// If selected, draw image highlight rect:
	if( flags.selected )
	{
		// Set up line for selection outline:
		NSLineJoinStyle svLjs = [NSBezierPath defaultLineJoinStyle];
		[NSBezierPath setDefaultLineJoinStyle: NSRoundLineJoinStyle];
		float			svLwd = [NSBezierPath defaultLineWidth];
		[NSBezierPath setDefaultLineWidth: UKFIC_SELBOX_OUTLINE_WIDTH];
		
		// Draw selection outline:
		NSColor*	scc = [boxColor colorWithAlphaComponent: alpha];
		[[scc colorWithAlphaComponent: 0.7] set];			// Slightly transparent body first.
		[NSBezierPath fillRect: imgBox];
		[scc set];											// Opaque rounded boundaries next.
		[NSBezierPath strokeRect: imgBox];
		
		// Clean up:
		[NSBezierPath setDefaultLineJoinStyle: svLjs];
		[NSBezierPath setDefaultLineWidth: svLwd];
		[[NSColor blackColor] set];
	}
	
	// Calculate box for icon:
	NSSize		actualSize = [image size];
	imgBox = NSInsetRect( imgBox, UKFIC_IMAGE_HORZMARGIN, UKFIC_IMAGE_VERTMARGIN );
	
	/*imgBox.origin.x += (imgBox.size.width -actualSize.width) /2;	// Center icon image in icon box.
	imgBox.origin.y += (imgBox.size.height -actualSize.height) /2;*/

        // Make sure we're drawing on whole pixels, not between them:
    imgBox.origin.x = truncf(imgBox.origin.x);
    imgBox.origin.y = truncf(imgBox.origin.y);
	//imgBox.size.width = actualSize.width;
	//imgBox.size.height = actualSize.height;
    imgBox.size = [NSImage scaledSize: actualSize toFitSize: imgBox.size];

	// Draw it!
    NSRect  imgRect = { { 0,0 }, { 0,0 } };
    imgRect.size = actualSize;
	if( flags.flipped )
    {
        imgBox.origin.y += imgBox.size.height;
		[image drawInRect:imgBox fromRect:imgRect operation: NSCompositeSourceOver fraction: alpha];
    }
	else
		[image drawInRect:imgBox fromRect:imgRect operation: NSCompositeSourceOver fraction: alpha];
	/*if( flags.flipped )
		[image compositeToPoint: NSMakePoint(imgBox.origin.x,imgBox.origin.y +actualSize.height) operation: NSCompositeSourceOver fraction: alpha];
	else
		[image compositeToPoint: imgBox.origin operation: NSCompositeSourceOver fraction: alpha];*/
	
	[NSGraphicsContext restoreGraphicsState];
}


// -----------------------------------------------------------------------------
//  Accessor for cell icon:
// -----------------------------------------------------------------------------

-(NSImage*)	image
{
	return image;
}


// -----------------------------------------------------------------------------
//  Mutator for cell icon:
// -----------------------------------------------------------------------------

-(void)			setImage: (NSImage*)tle
{
	if( tle != image )
	{
		[image release];
		image = [tle retain];
	}
}


// -----------------------------------------------------------------------------
//  Mutator for name background color:
// -----------------------------------------------------------------------------

-(void)		setNameColor: (NSColor*)col
{
	[col retain];
	[nameColor release];
	nameColor = col;
}


// -----------------------------------------------------------------------------
//  Accessor for name background color:
// -----------------------------------------------------------------------------

-(NSColor*) nameColor
{
	return nameColor;
}


// -----------------------------------------------------------------------------
//  Mutator for icon highlight box color:
// -----------------------------------------------------------------------------

-(void)		setBoxColor: (NSColor*)col
{
	[col retain];
	[boxColor release];
	boxColor = col;
}


// -----------------------------------------------------------------------------
//  Accessor for icon highlight box color:
// -----------------------------------------------------------------------------

-(NSColor*) boxColor
{
	return boxColor;
}


// -----------------------------------------------------------------------------
//  Mutator for cell background color:
// -----------------------------------------------------------------------------

-(void)		setBgColor: (NSColor*)col
{
	[col retain];
	[bgColor release];
	bgColor = col;
}


// -----------------------------------------------------------------------------
//  Accessor for cell background color:
// -----------------------------------------------------------------------------

-(NSColor*) bgColor
{
	return bgColor;
}


// -----------------------------------------------------------------------------
//  Mutator for name highlight color:
// -----------------------------------------------------------------------------

-(void)		setSelectionColor: (NSColor*)col;
{
	[col retain];
	[selectionColor release];
	selectionColor = col;
}


// -----------------------------------------------------------------------------
//  Accessor for name highlight color:
// -----------------------------------------------------------------------------

-(NSColor*) selectionColor;
{
	return selectionColor;
}


// -----------------------------------------------------------------------------
//  Accessors/Mutators for image positioning relative to title:
// -----------------------------------------------------------------------------

-(NSCellImagePosition)  imagePosition
{
    return imagePosition;
}

-(void) setImagePosition: (NSCellImagePosition)newImagePosition
{
   imagePosition = newImagePosition;
   [self makeAlignmentConformImagePosition];
}


// -----------------------------------------------------------------------------
//  Size we'd want for cell:
// -----------------------------------------------------------------------------

-(NSSize)   cellSize
{
	NSSize		theSize = [super cellSize];
	
	theSize.height += (image) ? ([image size].height +(UKFIC_SELBOX_VERTMARGIN *2) +(UKFIC_IMAGE_VERTMARGIN *2)) : 0;
	
	return theSize;
}


// -----------------------------------------------------------------------------
//	editWithFrame:inView:editor:delegate:event:
//		Start inline-editing.
//	
//	REVISIONS:
//        2004-12-23	UK	Documented.
// -----------------------------------------------------------------------------

-(void) editWithFrame:(NSRect)aRect inView:(NSView *)aView editor:(NSText *)textObj
            delegate:(id)anObject event:(NSEvent *)theEvent
{
    NSRect textFrame, imageFrame;
	
	NSDictionary*   attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont systemFontOfSize: 12], NSFontAttributeName,
						[NSColor controlTextColor], NSForegroundColorAttributeName,
						nil];
	NSSize			txSize = [[self title] sizeWithAttributes: attrs];
	
	flags.flipped = [aView isFlipped];
    NSDivideRect (aRect, &textFrame, &imageFrame, (UKFIC_TEXT_VERTMARGIN *2) + txSize.height, flags.flipped ? NSMaxYEdge : NSMinYEdge);
	
    flags.currentlyEditing = YES;
	[super editWithFrame: textFrame inView: aView editor:textObj delegate:anObject event: theEvent];
}


// -----------------------------------------------------------------------------
//	endEditing:
//		Finish inline-editing.
//	
//	REVISIONS:
//        2004-12-23	UK	Documented.
// -----------------------------------------------------------------------------

-(void) endEditing:(NSText *)textObj
{
    flags.currentlyEditing = NO;
    [super endEditing: textObj];
}


// -----------------------------------------------------------------------------
//	selectWithFrame:inView:editor:delegate:start:length:
//		Alternate way to start inline-editing.
//	
//	REVISIONS:
//        2004-12-23	UK	Documented.
// -----------------------------------------------------------------------------

-(void) selectWithFrame:(NSRect)aRect inView:(NSView *)aView editor:(NSText *)textObj
            delegate:(id)anObject start:(int)selStart length:(int)selLength
{
    NSRect textFrame, imageFrame;
	
	NSDictionary*   attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont systemFontOfSize: 12], NSFontAttributeName,
						[NSColor controlTextColor], NSForegroundColorAttributeName,
						nil];
	
	NSSize			txSize = [[self title] sizeWithAttributes: attrs];
	
	flags.flipped = [aView isFlipped];
    NSDivideRect (aRect, &textFrame, &imageFrame, (UKFIC_TEXT_VERTMARGIN *2) + txSize.height, flags.flipped ? NSMaxYEdge : NSMinYEdge);
   
    flags.currentlyEditing = YES;
	[super selectWithFrame: textFrame inView: aView editor:textObj delegate:anObject start:selStart length:selLength];
}


// -----------------------------------------------------------------------------
//	Accessor/Mutator for how to truncate title string:
// -----------------------------------------------------------------------------

-(void)             setTruncateMode: (NSLineBreakMode)m
{
    truncateMode = m;
}


-(NSLineBreakMode)  truncateMode
{
    return truncateMode;
}


// -----------------------------------------------------------------------------
//	Accessor/Mutator for opacity of cell drawing:
// -----------------------------------------------------------------------------

-(void)             setAlpha: (float)a
{
    alpha = a;
}


-(float)            alpha
{
    return alpha;
}


// -----------------------------------------------------------------------------
//	Querying where the title is displayed:
// -----------------------------------------------------------------------------

-(NSRect)   titleRectForBounds: (NSRect)aRect
{
    NSRect textFrame, imageFrame;
	NSDictionary*   attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont systemFontOfSize: 12], NSFontAttributeName,
						[NSColor controlTextColor], NSForegroundColorAttributeName,
						nil];
	
	NSSize			txSize = [[self title] sizeWithAttributes: attrs];
	
    NSDivideRect( aRect, &textFrame, &imageFrame, (UKFIC_TEXT_VERTMARGIN *2) + txSize.height,
						flags.flipped ? NSMaxYEdge : NSMinYEdge);
    
    return textFrame;
}

@end

@implementation UKFinderIconCell (UKPrivateMethods)

// -----------------------------------------------------------------------------
//	Adjust text alignment for drawing so it goes nicely with the image display
//      position:
// -----------------------------------------------------------------------------

-(void) makeAlignmentConformImagePosition
{
   if( imagePosition == NSImageAbove
		|| imagePosition == NSImageBelow )
		[self setAlignment: NSCenterTextAlignment];
}


// -----------------------------------------------------------------------------
//	Mutator for flipped drawing:
// -----------------------------------------------------------------------------

-(void)             setFlipped: (BOOL)a // Is reset every time you draw this into a view.
{
    flags.flipped = a;
}

@end


// -----------------------------------------------------------------------------
//  Returns a truncated version of the specified string that fits a width:
//		Appends/Inserts three periods as an "ellipsis" to/in the string to
//      indicate when and where it was truncated.
// -----------------------------------------------------------------------------

NSString*   UKStringByTruncatingStringWithAttributesForWidth( NSString* s, NSDictionary* attrs,
                                                                float wid, NSLineBreakMode truncateMode )
{
	NSSize				txSize = [s sizeWithAttributes: attrs];
    
    if( txSize.width <= wid )   // Don't do anything if it fits.
        return s;
    
	NSMutableString*	currString = [NSMutableString string];
	NSRange             rangeToCut = { 0, 0 };
    
    if( truncateMode == NSLineBreakByTruncatingTail )
    {
        rangeToCut.location = [s length] -1;
        rangeToCut.length = 1;
    }
    else if( truncateMode == NSLineBreakByTruncatingHead )
    {
        rangeToCut.location = 0;
        rangeToCut.length = 1;
    }
    else    // NSLineBreakByTruncatingMiddle
    {
        rangeToCut.location = [s length] / 2;
        rangeToCut.length = 1;
    }
    
	while( txSize.width > wid )
	{
		if( truncateMode != NSLineBreakByTruncatingHead && rangeToCut.location <= 1 )
			return @"...";
        
        [currString setString: s];
        [currString replaceCharactersInRange: rangeToCut withString: @"..."];
		txSize = [currString sizeWithAttributes: attrs];
        rangeToCut.length++;
        if( truncateMode == NSLineBreakByTruncatingHead )
            ;   // No need to fix location, stays at start.
        else if( truncateMode == NSLineBreakByTruncatingTail )
            rangeToCut.location--;  // Fix location so range that's one longer still lies inside our string at end.
        else if( (rangeToCut.length & 1) != 1 )     // even? NSLineBreakByTruncatingMiddle
            rangeToCut.location--;  // Move location left every other time, so it grows to right and left and stays centered.
        
        if( rangeToCut.location < 0 || (rangeToCut.location +rangeToCut.length) > [s length] )
            return @"...";
	}
	
	return currString;
}
