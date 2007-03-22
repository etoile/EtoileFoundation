/*
 This source is part of UnitKit, a unit test framework for Mac OS X 
 development. You can find more information about UnitKit at:
 
 http://x180.net/Code/UnitKit
 
 Copyright (c)2004 James Duncan Davidson
 
 Contributions by Michael Milvich, Mark Dalrymple
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 The use of the Apache License does not indicate that this project is
 affiliated with the Apache Software Foundation.
 */

#import "UKTestHandler.h"
#import <stdarg.h>

@implementation UKTestHandler

+ (UKTestHandler *)handler
{
    static UKTestHandler *handler;
    if (handler == nil) {
        handler = [[self alloc] init];
    }
    return handler;
}

+ (NSString *) localizedString:(NSString *)key
{
#ifdef GNUSTEP
    NSBundle *bundle = [NSBundle bundleForLibrary: @"UnitKit"];
#else
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#endif
    return NSLocalizedStringFromTableInBundle(key, 
                                              @"UKTestHandler", 
                                              bundle, 
                                              @"");
}

+ (NSString *) displayStringForObject:(id) obj
{
    NSString *description = [obj description];
    if ([description hasPrefix:@"<"] && [description hasSuffix:@">"]) {
        // assume it's <Classname 0x2394920> and return
        if ([description length] < 30) {
            return description;
        } else {
            description = [description substringWithRange:NSMakeRange(0, 26)];
            description = [description stringByAppendingString:@"...>"];
            return description;
        }
    } else if ([description length] > 30) {
        description = [description substringWithRange:NSMakeRange(0, 27)];
        description = [description stringByAppendingString:@"..."];
    } 
    
    return [NSString stringWithFormat:@"\"%@\"", description];
}

- (int) testsPassed
{
    return testsPassed;
}

- (int) testsFailed
{
    return testsFailed;
}

- (void) setDelegate:(id)aDelegate
{
    [delegate autorelease];
    delegate = [aDelegate retain];
}

- (void) setQuiet:(BOOL)isQuiet
{
    quiet = isQuiet;
}

// XXX we need to test these report messages as best as possible. Especially
// with the delegate set or not and responding to selector

- (void) reportStatus:(BOOL)cond inFile:(char *)filename line:(int)line message:(NSString *)msg
{
    /*
     If we have a delegate, then by all means use it. If we don't, then check
     to see if we have any errors which should be reported off to std out.
     */
    if (delegate && 
        [delegate respondsToSelector:@selector(reportStatus:inFile:line:message:)]) 
    {
        [delegate reportStatus:cond inFile:filename line:line message:msg];
        return;
    } else if (cond) {
        testsPassed++;
        if (!quiet) {
            printf("%s:%i %s\n", filename, line, [msg UTF8String]);
        }
    } else {
        testsFailed++;
        printf("%s:%i: warning: %s\n", filename, line, [msg UTF8String]);
    }
}

- (void) reportWarning:(NSString *)msg
{
    /*
     Use a delegate if there. If not, then check
     */
    if (delegate && [delegate respondsToSelector:@selector(reportWarning:)]) {
        [delegate reportWarning:msg];
    } else {
        printf(":: warning: %s\n", [msg UTF8String]);
    }
}

- (void) passInFile:(char *)filename line:(int)line
{
    NSString *msg = [UKTestHandler localizedString:@"msgUKPass"];
    [self reportStatus:YES inFile:filename line:line message:msg];
}

- (void) failInFile:(char *)filename line:(int)line
{
    NSString *msg = [UKTestHandler localizedString:@"msgUKFail"];
    [self reportStatus:NO inFile:filename line:line message:msg];
}

- (void) testTrue:(BOOL)cond inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (cond) {
        msg = [UKTestHandler localizedString:@"msgUKTrue.pass"];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKTrue.fail"];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testFalse:(BOOL)cond inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (!cond) {
        msg = [UKTestHandler localizedString:@"msgUKFalse.pass"];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKFalse.fail"];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testNil:(void *)ref inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (!ref) {
        msg = [UKTestHandler localizedString:@"msgUKNil.pass"];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKNil.fail"];
        // XXX we are *so* assuming that this pointer is an object...
        NSString *s = [UKTestHandler displayStringForObject:ref];
        msg = [NSString stringWithFormat:msg, s]; 
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testNotNil:(void *)ref inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (ref) {
        msg = [UKTestHandler localizedString:@"msgUKNotNil.pass"];        
        // XXX we are *so* assuming that this pointer is an object...
        NSString *s = [UKTestHandler displayStringForObject:ref];
        msg = [NSString stringWithFormat:msg, s]; 
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKNotNil.fail"];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }    
}

- (void) testInt:(int)a equalTo:(int)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (a == b) {
        msg = [UKTestHandler localizedString:@"msgUKIntsEqual.pass"];
        msg = [NSString stringWithFormat:msg, a, b];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKIntsEqual.fail"];
        msg = [NSString stringWithFormat:msg, a, b];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testInt:(int)a notEqualTo:(int)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    if (a != b) {
        msg = [UKTestHandler localizedString:@"msgUKIntsNotEqual.pass"];
        msg = [NSString stringWithFormat:msg, a, b];        
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKIntsNotEqual.fail"];
        msg = [NSString stringWithFormat:msg, a, b];        
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testFloat:(float)a equalTo:(float)b delta:(float)delta inFile:(char *)filename line:(int)line
{
    // XXX need to figure out how to report the numbers in such a way that
    // they are shortened to the degree of precision...
    
    NSString *msg;
    float c = fabs(a - b);
    if (c <= delta) {
        msg = [UKTestHandler localizedString:@"msgUKFloatsEqual.pass"];
        msg = [NSString stringWithFormat:msg, a - delta, a + delta, b];  
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKFloatsEqual.fail"];
        msg = [NSString stringWithFormat:msg, a - delta, a + delta, b];  
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testFloat:(float)a notEqualTo:(float)b delta:(float)delta inFile:(char *)filename line:(int)line
{
    // XXX need to figure out how to report the numbers in such a way that
    // they are shortened to the degree of precision...
    
    NSString *msg;
    float c = fabs(a - b);
    if (c > delta) {
        msg = [UKTestHandler localizedString:@"msgUKFloatsNotEqual.pass"];
        msg = [NSString stringWithFormat:msg, a - delta, a + delta, b];  
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKFloatsNotEqual.fail"];
        msg = [NSString stringWithFormat:msg, a - delta, a + delta, b];  
        [self reportStatus:NO inFile:filename line:line message:msg];    }
}

- (void) testObject:(id)a equalTo:(id)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];

    if ([a isEqualTo:b]) {
        msg = [UKTestHandler localizedString:@"msgUKObjectsEqual.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKObjectsEqual.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testObject:(id)a notEqualTo:(id)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    if (![a isEqualTo:b]) {
        msg = [UKTestHandler localizedString:@"msgUKObjectsNotEqual.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKObjectsNotEqual.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testObject:(id)a sameAs:(id)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    if (a == b) {
        msg = [UKTestHandler localizedString:@"msgUKObjectsSame.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKObjectsSame.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testObject:(id)a notSameAs:(id)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    if (a != b) {
        msg = [UKTestHandler localizedString:@"msgUKObjectsNotSame.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKObjectsNotSame.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testString:(NSString *)a equalTo:(NSString *)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    if ([a isEqualToString:b]) {
        msg = [UKTestHandler localizedString:@"msgUKStringsEqual.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKStringsEqual.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testString:(NSString *)a notEqualTo:(NSString *)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    if (![a isEqualToString:b]) {
        msg = [UKTestHandler localizedString:@"msgUKStringsNotEqual.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKStringsNotEqual.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testString:(NSString *)a contains:(NSString *)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    NSRange r = [a rangeOfString:b];
    if (r.location != NSNotFound) {
        msg = [UKTestHandler localizedString:@"msgUKStringContains.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKStringContains.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) testString:(NSString *)a doesNotContain:(NSString *)b inFile:(char *)filename line:(int)line
{
    NSString *msg;
    NSString *dispA =[UKTestHandler displayStringForObject:a];
    NSString *dispB = [UKTestHandler displayStringForObject:b];
    
    NSRange r = [a rangeOfString:b];
    if (r.location == NSNotFound) {
        msg = 
            [UKTestHandler localizedString:@"msgUKStringDoesNotContain.pass"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = 
            [UKTestHandler localizedString:@"msgUKStringDoesNotContain.fail"];
        msg = [NSString stringWithFormat:msg, dispA, dispB];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }   
}


- (void) raisesException:(NSException*)exception inFile:(char *)filename line:(int)line
{
    NSString    *msg;
    
    if(exception != nil)  {
        msg = [UKTestHandler localizedString:@"msgUKExceptionRaised.pass"];
        msg = [NSString stringWithFormat:msg, [[exception class] description]];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKExecptionRaised.fail"];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}


- (void) doesNotRaisesException:(NSException*)exception inFile:(char *)filename line:(int)line
{
    NSString    *msg;
    
    if(exception == nil) {
        msg = [UKTestHandler localizedString:@"msgUKExceptionNotRaised.pass"];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKExceptionNotRaised.fail"];
        msg = [NSString stringWithFormat:msg, [[exception class] description]];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) raisesException:(NSException*)exception named:(NSString*)expected inFile:(char *)filename line:(int)line;
{
    NSString    *msg;
    
    if(![exception isKindOfClass:[NSException class]]) {
        msg = [UKTestHandler localizedString:@"msgUKSpecificNSExceptionRaised.failNotNSException"];
        msg = [NSString stringWithFormat:msg, [exception description]];
        [self reportStatus:NO inFile:filename line:line message:msg];
    } else if([[exception name] isEqualToString:expected]) {
        msg = [UKTestHandler localizedString:@"msgUKSpecificNSExceptionRaised.pass"];
        msg = [NSString stringWithFormat:msg, expected];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKSpecificNSExceptionRaised.fail"];
        msg = [NSString stringWithFormat:msg, expected, [exception name]];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

- (void) raisesException:(id)raisedObject class:(Class)expectedClass inFile:(char *)filename line:(int)line
{
    NSString    *msg;
    if([raisedObject isKindOfClass:expectedClass]) {
        msg = [UKTestHandler localizedString:@"msgUKRaisesSpecificClass.pass"];
        msg = [NSString stringWithFormat:msg, [expectedClass description]];
        [self reportStatus:YES inFile:filename line:line message:msg];
    } else {
        msg = [UKTestHandler localizedString:@"msgUKRaisesSpecificClass.fail"];
        msg = [NSString stringWithFormat:msg, [expectedClass description], [[raisedObject class] description]];
        [self reportStatus:NO inFile:filename line:line message:msg];
    }
}

@end
