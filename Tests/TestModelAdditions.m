/*
    Copyright (C) 2014 Quentin Mathe

    Date:  June 2014
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "Macros.h"
#import "NSObject+Model.h"
#import "ETHistory.h"
#import "EtoileCompatibility.h"
#include <objc/runtime.h>

@interface TestModelAdditions : NSObject <UKTest>
@end

@implementation TestModelAdditions

- (void) testIsMutable
{
    UKFalse([[NSArray array] isMutable]);
    UKTrue([[NSMutableArray array] isMutable]);
    UKFalse([[NSMutableArray class] isMutable]);
    UKFalse([object_getClass([NSMutableArray class]) isMutable]);
    UKFalse([[ETHistory history] isMutable]);
}

- (void) testIsCollection
{
    UKTrue([[NSArray array] isCollection]);
    UKTrue([[NSMutableArray array] isCollection]);
    UKFalse([[NSMutableArray class] isCollection]);
    UKFalse([object_getClass([NSMutableArray class]) isCollection]);
    UKTrue([[ETHistory history] isCollection]);
}

- (void) testIsPrimitiveCollection
{
    UKTrue([[NSArray array] isPrimitiveCollection]);
    UKTrue([[NSMutableArray array] isPrimitiveCollection]);
    UKFalse([[NSMutableArray class] isPrimitiveCollection]);
    UKFalse([object_getClass([NSMutableArray class]) isPrimitiveCollection]);
    UKFalse([[ETHistory history] isPrimitiveCollection]);
}

@end
