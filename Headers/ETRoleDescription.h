/**
    Copyright (C) 2009 Eric Wasylishen

    Date:  July 2009
    License:  Modified BSD (see COPYING)
 */

#import <EtoileFoundation/ETPropertyValueCoding.h>
#import <EtoileFoundation/ETCollection.h>
#import <EtoileFoundation/ETPropertyDescription.h>

@class ETValidationResult;

/** @group Metamodel
@abstract Description of a property's role.

These allow a pluggable, more precise property description. */
@interface ETRoleDescription : NSObject
{
}

@property (nonatomic, readonly) ETPropertyDescription *parent;

- (ETValidationResult *) validateValue: (id)value forKey: (NSString *)key;

@end


/** @group Metamodel
@abstract Description of a relationship's role.  */
@interface ETRelationshipRole : ETRoleDescription
{
    @private
    BOOL _mandatory;
    NSString *_deletionRule;
}

@property (nonatomic, assign, getter=isMandatory) BOOL mandatory;
@property (nonatomic, copy) NSString *deletionRule;

@end


/** @group Metamodel
@abstract Description of a property's role, whose value is restricted to a 
predetermined set. */
@interface ETMultiOptionsRole : ETRoleDescription
{
    @private
    NSArray *_allowedOptions;
}

/** The ETKeyValuePair objects that represent the options.
 
-[ETKeyValuePair value] is expected to return the option value (e.g. a NSNumber 
for an enumeration) and -[ETKeyValuePair key] to return the option name.
 
You can use a localized string as the pair key to present the options in the UI. */
@property (nonatomic, copy) NSArray *allowedOptions;

@end


/** @group Metamodel
@abstract Description of a property's role, whose value is a number. */
@interface ETNumberRole : ETRoleDescription
{
    @private
    NSInteger _minimum;
    NSInteger _maximum;
}

@property (nonatomic, assign) NSInteger minimum;
@property (nonatomic, assign) NSInteger maximum;

@end
