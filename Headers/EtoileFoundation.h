/*
    Copyright (C) 2007 David Chisnall

    Date:  September 2007
    License:  Modified BSD (see COPYING)
 */

/* EtoileFoundation core */

#import <EtoileFoundation/ETByteSizeFormatter.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETCollection+HOM.h>
#import <EtoileFoundation/ETGetOptionsDictionary.h>
#import <EtoileFoundation/ETHistory.h>
#import <EtoileFoundation/ETKeyValuePair.h>
#import <EtoileFoundation/ETPlugInRegistry.h>
#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETReflection.h>
#import <EtoileFoundation/ETSocket.h>
#import <EtoileFoundation/ETStackTraceRecorder.h>
#import <EtoileFoundation/ETUTI.h>
#import <EtoileFoundation/ETUUID.h>
#import <EtoileFoundation/EtoileCompatibility.h>
#import <EtoileFoundation/Macros.h>
#import <EtoileFoundation/NSArray+Etoile.h>
#import <EtoileFoundation/NSData+Hash.h>
#import <EtoileFoundation/NSDictionary+Etoile.h>
#import <EtoileFoundation/NSFileManager+TempFile.h>
#import <EtoileFoundation/NSFileHandle+Socket.h>
#import <EtoileFoundation/NSIndexPath+Etoile.h>
#import <EtoileFoundation/NSIndexSet+Etoile.h>
#import <EtoileFoundation/NSInvocation+Etoile.h>
#import <EtoileFoundation/NSMapTable+Etoile.h>
#import <EtoileFoundation/NSObject+DoubleDispatch.h>
#import <EtoileFoundation/NSObject+Etoile.h>
#import <EtoileFoundation/NSObject+HOM.h>
#import <EtoileFoundation/NSObject+Model.h>
#import <EtoileFoundation/NSObject+Trait.h>
#import <EtoileFoundation/NSString+Etoile.h>
// FIXME: Cannot be enabled because it breaks if imported multiple times.
//#import <EtoileFoundation/ObjCXXHelpers.h>

/* Model Description */

#import <EtoileFoundation/ETAdaptiveModelObject.h>
#import <EtoileFoundation/ETModelDescriptionRepository.h>
#import <EtoileFoundation/ETModelElementDescription.h>
#import <EtoileFoundation/ETEntityDescription.h>
#import <EtoileFoundation/ETPackageDescription.h>
#import <EtoileFoundation/ETPropertyDescription.h>
#import <EtoileFoundation/ETRoleDescription.h>
#import <EtoileFoundation/ETValidationResult.h>

/* Viewpoints */

#import <EtoileFoundation/ETCollectionViewpoint.h>
#import <EtoileFoundation/ETIndexValuePair.h>
#import <EtoileFoundation/ETMutableObjectViewpoint.h>
#import <EtoileFoundation/ETUnionViewpoint.h>
#import <EtoileFoundation/ETViewpoint.h>

#ifdef GNUSTEP
#import <EtoileFoundation/ETCArray.h>
#import <EtoileFoundation/NSObject+Prototypes.h>
#endif
