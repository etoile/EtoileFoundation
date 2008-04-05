//
//  ETXMLNullHandler.h
//  Jabber
//
//  Created by David Chisnall on 15/05/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ETXMLParser.h"
/**
 * The ETXMLNullHandler class serves two purposes.  First, it is used when
 * parsing to ignore an XML element and all of its children.  It simply 
 * maintains a count of the depth, and ignores everything passed to it.
 *
 * The second use is as a superclass for other XML parser delegates.  The class
 * implements the required functionality for a parser delegate, and so can be
 * easily extended through subclassing.
 */
@interface ETXMLNullHandler : NSObject<ETXMLParserDelegate> {
	unsigned int depth;
	id parser;
	id<NSObject,ETXMLParserDelegate> parent;
	id key;
	id value;
}
/**
 * Create a new handler for the specified parent.  When the next element and 
 * all children have been handled (ignored), control will be returned to the 
 * parent object.  
 *
 * The key is used to pass the parsed object (if not nil) to the parent.  The
 * parent's -add{key}: method will be called with the value of this object's
 * 'value' instance variable when -notifyParent: is called.  This is only
 * relevant to sub-classes.
 */
- (id) initWithXMLParser:(id)aParser parent:(id<NSObject,ETXMLParserDelegate>)aParent key:(id)aKey;
/**
 * Dynamic dispatch method that calls [self add{aChild}:aKey] if the object
 * responds to add{aChild}:.  This is similar to the KVC mechamism, but used
 * instead so subclasses do not have to be fully KVC compliant.
 */
- (void) addChild:(id)aChild forKey:aKey;
/**
 * Pass the instance variable 'value' up to the parent.  
 */
- (void) notifyParent;
@end
