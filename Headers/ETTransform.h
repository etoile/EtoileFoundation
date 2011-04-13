/**
	<abstract>Double dispatch facility</abstract>

	Copyright (C) 2007 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr>
	Date:  November 2007
	License:  Modified BSD (see COPYING)
 */
 
#import <Foundation/NSObject.h>

/** @group Language Extensions

ETTransform provides a visitor which supports double-dispatch on all
	visited objects without implementing extra methods. Any visited objects 
	can implement -renderOn: to override this double-dispatch provided by 
	ETTransform for free. 
	You can also use this class as a mixin to quickly implement visitor 
	pattern. 
	In addition to that, ETTransform by being a subclass of ETFilter provides
	the possibility to combine several transforms together in a chain. An 
	instance behave then like a transform unit where each transform in the 
	chain is rendered sequentially. A typical use would be implementing a tree 
	transformation chain as commonly done on AST. EtoileUI uses this exact 
	model in a recurrent manner to implement stuff like:
	- AppKit compatibility (building a layout item tree from AppKit window, 
	  view, menu etc.)
	- layout item tree rendering with AppKit as backend
	- UI generation from a model object graph
	- UI generation from a data format
	- UI transformation (UI generation from an existing UI)
	- data format reading, writing, converting and processing
	- composite document format
	In future, we plan to explore with this architecture:
	- synchronization of various concrete UIs derivated from a shared abstract 
	  UI (which is used as a metamodel)

	Because ETTransform and ETFilter shares a common underlying API, you can 
	create hybrid processing chain. In fact, any classes implementing 
	ETRendering protocol can be inserted in such processing chain. */
@interface ETTransform : NSObject
{

}

- (id) tryToPerformSelector: (SEL)selector withObject: (id)object result: (BOOL *)performed;
- (id) render: (id)object;

@end
