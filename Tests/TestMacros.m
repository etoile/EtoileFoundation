/*
    Copyright (C) 2016 Eric Wasylishen
 
    Date:  January 2016
    License: Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <UnitKit/UnitKit.h>
#import "Macros.h"
#import "ETUUID.h"
#import "EtoileCompatibility.h"
#include "glibc_hack_unistd.h"

@interface TestMacros : NSObject <UKTest>
@end

@implementation TestMacros

- (void) testSMacro
{
    NSArray *abArray = [NSArray arrayWithObjects: @"a", @"b", nil];
    
    UKObjectsEqual([NSSet set], S());
    UKRaisesException(S(nil));
    UKObjectsEqual([NSSet setWithObject: @"a"], S(@"a"));
    UKObjectsEqual([NSSet setWithArray: abArray], S(@"a", @"b"));
    UKObjectsEqual([NSSet setWithObject: @"a"], S(@"a", @"a"));
}

- (void) testUNIQUESETMacro
{
    NSArray *abArray = [NSArray arrayWithObjects: @"a", @"b", nil];
    
    UKObjectsEqual([NSSet set], UNIQUESET());
    UKRaisesException(UNIQUESET(nil));
    UKObjectsEqual([NSSet setWithObject: @"a"], UNIQUESET(@"a"));
    UKObjectsEqual([NSSet setWithArray: abArray], UNIQUESET(@"a", @"b"));
    UKRaisesException(UNIQUESET(@"a", @"a"));
}


- (void) testAMacro
{
    NSArray *abArray = [NSArray arrayWithObjects: @"a", @"b", nil];
    
    UKObjectsEqual([NSArray array], A());
    UKRaisesException(A(nil));
    UKObjectsEqual([NSArray arrayWithObject: @"a"], A(@"a"));
    UKObjectsEqual(abArray, A(@"a", @"b"));
}

@end
