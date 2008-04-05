//
//  ETXMLDeclaration.h
//  Jabber
//
//  Created by Yen-Ju Chen on Thu Jul 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EtoileXML/ETXMLNode.h>

/**
 * The ETXMLDeclaration is a ETXMLNode representing the XML header 
 * in a form of &lt;?xml version="1.0" encoding="UTF-8" ?&gt;.
 * It only take attributes of 'version', 'encoding', 'standalone'
 * and without any CDATA.
 * 
 * NOTE: ETXMLParser does not generate ETXMLDeclaration node.
 * This node is only used for build ETXMLNode tree
 * and write out a string of XML document or serves as a root 
 * for ETXMLParser.
 */

@interface ETXMLDeclaration: ETXMLNode

/* Return a node representing &lt;?xml version="1.0" encoding="UTF-8" ?&gt; */
+ (id) ETXMLDeclaration;

@end

