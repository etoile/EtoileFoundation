/* =============================================================================
	FILE:		NSBezierPathCappedBoxes.m
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

#import "NSBezierPathCappedBoxes.h"


@implementation NSBezierPath (CappedBoxes)

// -----------------------------------------------------------------------------
//	bezierPathWithCappedBoxInRect:
//		This creates a bezier path for the specified rectangle where the left
//		and right sides of the box are halves of a circle.
//	
//	REVISIONS:
//      2004-11-20  UK  Changed to use arcs instead of bezier paths as per a
//                      submission from Christoffer Lerno.
//		2004-01-17  UK  Documented.
// -----------------------------------------------------------------------------

+(NSBezierPath*) bezierPathWithCappedBoxInRect: (NSRect)rect
{
    NSBezierPath* bezierPath = [NSBezierPath bezierPath];
    float cornerSize = rect.size.height / 2;
    
    // Corners:
    NSPoint leftTop = NSMakePoint(NSMinX(rect) + cornerSize, NSMaxY(rect));
    NSPoint rightTop = NSMakePoint(NSMaxX(rect) - cornerSize, NSMaxY(rect));
    NSPoint rightBottom = NSMakePoint(NSMaxX(rect) - cornerSize, NSMinY(rect));
    NSPoint leftBottom = NSMakePoint(NSMinX(rect) + cornerSize, NSMinY(rect));
    
    // Create our capped box:
    // Top edge:
    [bezierPath moveToPoint:leftTop]; 
    [bezierPath lineToPoint:rightTop];
    // Right cap:
    [bezierPath appendBezierPathWithArcWithCenter:NSMakePoint(rightTop.x,(NSMaxY(rect)+NSMinY(rect))/2)  
					   radius:cornerSize startAngle:90 endAngle:-90 clockwise:YES];
    // Bottom edge:
    [bezierPath lineToPoint: rightBottom];
    [bezierPath lineToPoint: leftBottom];
    // Left cap:
    [bezierPath appendBezierPathWithArcWithCenter:NSMakePoint(leftTop.x,(NSMaxY(rect)+NSMinY(rect))/2)  
					   radius:cornerSize startAngle:-90 endAngle:90 clockwise:YES];
    
    [bezierPath closePath]; // Just to be safe.
    
    return bezierPath;
}


@end
