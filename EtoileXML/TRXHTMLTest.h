//
//  TRXHTMLTest.h
//  Jabber
//
//  Created by David Chisnall on 27/08/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface TRXHTMLTest : NSObject {
	IBOutlet NSTextView * inHTML;
	IBOutlet NSTextView * outHTML;	
}
- (IBAction) update:(id)sender;
@end
