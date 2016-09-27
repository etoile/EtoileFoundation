/**
    Copyright (C) 2009 Eric Wasylishen

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <Foundation/Foundation.h>

/**
 * @group Metamodel
 * @abstract A model validation result returned by the metamodel.
 *
 * Helper class used as the return value of a validation, rather than passing
 * pointers to objects and modifying them.
 */
@interface ETValidationResult : NSObject
{
    @private
    id _value;
    NSString *_error;
    BOOL _isValid;
}


/** @taskunit Initialization */


+ (id) validResult: (id)value;
+ (id) invalidResultWithError: (NSString *)error;
+ (id) validationResultWithValue: (id)value
                         isValid: (BOOL)isValid
                           error: (NSString *)error;
- (id) initWithValue: (id)value
             isValid: (BOOL)isValid
               error: (NSString *)error;


/** @taskunit Validation Status */


@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly) NSString *error;

@end
