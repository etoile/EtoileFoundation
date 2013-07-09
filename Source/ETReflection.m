/*
	Mirror-based reflection API for Etoile.
 
	Copyright (C) 2009 Eric Wasylishen
 
	Author:  Eric Wasylishen <ewasylishen@gmail.com>
	Date:  June 2009
	License: Modified BSD (see COPYING)
 */

#import "ETReflection.h"
#import "ETClassMirror.h"
#import "ETInstanceVariableMirror.h"
#import "ETObjectMirror.h"
#import "ETProtocolMirror.h"
#import "Macros.h"
#import "EtoileCompatibility.h"


@implementation ETReflection

+ (id <ETObjectMirror>) reflectObject: (id)anObject
{
	return [ETObjectMirror mirrorWithObject: anObject];
}

+ (id <ETClassMirror>) reflectClass: (Class)aClass
{
	return [ETClassMirror mirrorWithClass: aClass];
}

+ (id <ETClassMirror>) reflectClassWithName: (NSString *)className
{
	id class = objc_getClass([className UTF8String]);
	if (class != nil)
	{
		return [ETClassMirror mirrorWithClass: (Class)class];
	}
	return nil;
}

+ (id <ETProtocolMirror>) reflectProtocolWithName: (NSString *)protocolName
{
	Protocol *protocol = objc_getProtocol([protocolName UTF8String]);
	if (protocol != nil)
	{
		return [ETProtocolMirror mirrorWithProtocol: protocol];
	}
	return nil;
}

+ (id <ETProtocolMirror>) reflectProtocol: (Protocol *)aProtocol
{
	if (aProtocol != nil)
	{
		return [ETProtocolMirror mirrorWithProtocol: aProtocol];
	}
	return nil;
}
+ (NSArray*) reflectAllRootClasses
{
	unsigned int classCount;
	Class *classList = objc_copyClassList(&classCount);
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (int i=0 ; i<classCount ; i++)
	{
		if (Nil == class_getSuperclass(classList[i]))
		{
			[array addObject: [self reflectClass: classList[i]]];
		}
	}
	free(classList);
	return [array autorelease];
}

@end

static inline BOOL ETGetInstanceVariableValueForKeyWithIvar(id object, id *value, NSString *aKey, Ivar ivar)
{
	assert(ivar != NULL);

	ptrdiff_t offset = ivar_getOffset(ivar);
	const char *type = ivar_getTypeEncoding(ivar);

	if (type == NULL)
    {
		return NO;
    }

	switch (*type)
	{
		case _C_ID:
		case _C_CLASS:
		{
			id *var = (id *)((char *)object + offset);
			*value = *var;
			break;
		}	
		case _C_CHR:
		{
			char *var = (char *)((char *)object + offset);
			*value = [NSNumber numberWithChar: *var];
			break;
		}
		case _C_UCHR:
		{
			unsigned char *var = (unsigned char *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedChar: *var];
			break;
		}
		case _C_SHT:
		{
			short *var = (short *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedChar: *var];
			break;
		}	
		case _C_USHT:
		{
			unsigned short *var = (unsigned short *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedShort: *var];
			break;
		}
		case _C_INT:
		{
			int *var = (int *)((char *)object + offset);
			*value = [NSNumber numberWithInt: *var];
			break;
		}	
		case _C_UINT:
		{
			unsigned int *var = (unsigned int *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedInt: *var];
			break;
		}
		case _C_LNG:
		{
			long *var = (long *)((char *)object + offset);
			*value = [NSNumber numberWithLong: *var];
			break;
		}	
		case _C_ULNG:
		{
			unsigned long *var = (unsigned long *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedLong: *var];
			break;
		}
#ifdef _C_LNG_LNG
		case _C_LNG_LNG:
		{
			long long *var = (long long *)((char *)object + offset);
			*value = [NSNumber numberWithLongLong: *var];
			break;
		}
#endif
#ifdef	_C_ULNG_LNG
		case _C_ULNG_LNG:
		{
			unsigned long long *var = (unsigned long long *)((char *)object + offset);
			*value = [NSNumber numberWithUnsignedLongLong: *var];
			break;
		}
#endif
		case _C_FLT:
		{
			float *var = (float *)((char *)object + offset);
			*value = [NSNumber numberWithFloat: *var];
			break;
		}
		case _C_DBL:
		{
			double *var = (double *)((char *)object + offset);
			*value = [NSNumber numberWithDouble: *var];
			break;
		}
		case _C_STRUCT_B:
		{
			/* For NSRect on Mac OS X, the type can be equal to:
			 
			     #ifdef __x86_64__ 

			     {_NSRect=\"origin\"{_NSPoint=\"x\"d\"y\"d}\"size\"{_NSSize=\"width\"d\"height\"d}}
			     {_NSRect={_NSPoint=dd}{_NSSize=dd}}
			     {_NSRect}

			     #else
			      
			     {_NSRect=\"origin\"{_NSPoint=\"x\"f\"y\"f}\"size\"{_NSSize=\"width\"f\"height\"f}}
			     {_NSRect={_NSPoint=ff}{_NSSize=ff}}
			     {_NSRect}
			 
			     #endif

			   but @encode(NSRect) is evaluated to 

			     {_NSRect={_NSPoint=ff}{_NSSize=ff}} or {_NSRect={_NSPoint=dd}{_NSSize=dd}}
			 
			     #endif

			   The same holds for the other ObjC structs supported by the runtime.
			   For reference, https://github.com/nevyn/NuRemoting/blob/master/Examples/Support/objc/Nu.m

			   Moreover recent Mac OS X versions such as 10.7 now returns a 
			   CoreGraphics type such as

			   {CGRect="origin"{CGPoint="x"d"y"d}"size"{CGSize="width"d"height"d}}

			   for the ivar type encoding when the ivar was declared as NSRect.
	
			   To determine the ivar type, we must compare the type prefixes. */

			if (strncmp(type, "{_NSPoint=", 10) == 0 || strncmp(type, "{CGPoint=", 9) == 0)
			{
				NSPoint *var = (NSPoint *)((char *)object + offset);
				*value = [NSValue valueWithPoint: *var];
			}
			else if (strncmp(type, "{_NSRange=", 10) == 0)
			{
				NSRange *var = (NSRange *)((char *)object + offset);
				*value = [NSValue valueWithRange: *var];
			}
			else if (strncmp(type, "{_NSRect=", 9) == 0 || strncmp(type, "{CGRect=", 8) == 0)
			{
				NSRect *var = (NSRect *)((char *)object + offset);
				*value = [NSValue valueWithRect: *var];
			}
			else if (strncmp(type, "{_NSSize=", 9) == 0 || strncmp(type, "{CGSize=", 8) == 0)
			{
				NSSize *var = (NSSize *)((char *)object + offset);
				*value = [NSValue valueWithSize: *var];
			}
			break;
		}
		default:
			return NO;
	}

	return YES;
}

BOOL ETGetInstanceVariableValueForKey(id object, id *value, NSString *key)
{
	assert(object != nil);
	assert(key != nil);

	const char *baseName = [key UTF8String];
	int baseLength = strlen(baseName);
	char name[baseLength + 4];
	const char *ivarName;

	/* Case '_variable' */
	name[2] = '_';
	strncpy(&name[3], baseName, baseLength);
	name[baseLength + 3] = '\0';

	ivarName = &(name[2]);
	Ivar ivar = object_getInstanceVariable(object, ivarName, NULL);

	/* Case '_isVariable' */
	if (ivar == NULL)
	{
		name[0] = '_';
		name[1] = 'i';
		name[2] = 's';
		name[3] = toupper(name[3]);

		ivarName = name;
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}

	/* Case 'variable' */
	if (ivar == NULL)
	{
		name[3] = tolower(name[3]);

		ivarName = &(name[3]);
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}
	
	/* Case 'isVariable' */
	if (ivar == NULL)
	{
		name[3] = toupper(name[3]);

		ivarName = &(name[1]);
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}

	if (ivar == NULL)
		return NO;

 	return ETGetInstanceVariableValueForKeyWithIvar(object, value, key, ivar);
}

static inline BOOL ETSetInstanceVariableValueForKeyWithIvar(id object, id value, NSString *aKey, Ivar ivar)
{
	assert(ivar != NULL);

	ptrdiff_t offset = ivar_getOffset(ivar);
	const char *type = ivar_getTypeEncoding(ivar);

	if (type == NULL)
    {
		return NO;
    }

	switch (*type)
	{
		case _C_ID:
		case _C_CLASS:
		{
			id *var = (id *)((char *)object + offset);
			ASSIGN(*var, value);
			break;
		}	
		case _C_CHR:
		{
			char *var = (char *)((char *)object + offset);
			*var = [value charValue];
			break;
		}
		case _C_UCHR:
		{
			unsigned char *var = (unsigned char *)((char *)object + offset);
			*var = [value unsignedCharValue];
			break;
		}
		case _C_SHT:
		{
			short *var = (short *)((char *)object + offset);
			*var = [value shortValue];
			break;
		}	
		case _C_USHT:
		{
			unsigned short *var = (unsigned short *)((char *)object + offset);
			*var = [value unsignedShortValue];
			break;
		}
		case _C_INT:
		{
			int *var = (int *)((char *)object + offset);
			*var = [value intValue];
			break;
		}	
		case _C_UINT:
		{
			unsigned int *var = (unsigned int *)((char *)object + offset);
			*var = [value unsignedIntValue];
			break;
		}
		case _C_LNG:
		{
			long *var = (long *)((char *)object + offset);
			*var = [value longValue];
			break;
		}	
		case _C_ULNG:
		{
			unsigned long *var = (unsigned long *)((char *)object + offset);
			*var = [value unsignedLongValue];
			break;
		}
#ifdef _C_LNG_LNG
		case _C_LNG_LNG:
		{
			long long *var = (long long *)((char *)object + offset);
			*var = [value longLongValue];
			break;
		}
#endif
#ifdef	_C_ULNG_LNG
		case _C_ULNG_LNG:
		{
			unsigned long long *var = (unsigned long long *)((char *)object + offset);
			*var = [value unsignedLongLongValue];
			break;
		}
#endif
		case _C_FLT:
		{
			float *var = (float *)((char *)object + offset);
			*var = [value floatValue];
			break;
		}
		case _C_DBL:
		{
			double *var = (double *)((char *)object + offset);
			*var = [value doubleValue];
			break;
		}
		case _C_STRUCT_B:
		{
			/* For NSRect on Mac OS X, the type is equal to
			     {_NSRect=\"origin\"{_NSPoint=\"x\"f\"y\"f}\"size\"{_NSSize=\"width\"f\"height\"f}}

			   but @encode(NSRect) is evaluated to 
			     {_NSRect={_NSPoint=ff}{_NSSize=ff}}
			   
			   So we use -objCType on the value to get the type, whose encoding  
			   matches @encode. See also the more detailed comment in 
			   ETGetInstanceVariableValueForKeyWithIvar(). */
			const char *valueType = NULL;

			if ([value respondsToSelector: @selector(objCType)])
			{
				valueType = [value objCType];
			}

			if (strcmp(@encode(NSPoint), valueType) == 0)
			{
				NSPoint *var = (NSPoint *)((char *)object + offset);
				*var = [value pointValue];
			}
			else if (strcmp(@encode(NSRange), valueType) == 0)
			{
				NSRange *var = (NSRange *)((char *)object + offset);
				*var = [value rangeValue];
			}
			else if (strcmp(@encode(NSRect), valueType) == 0)
			{
				NSRect *var = (NSRect *)((char *)object + offset);
				*var = [value rectValue];
			}
			else if (strcmp(@encode(NSSize), valueType) == 0)
			{
				NSSize *var = (NSSize *)((char *)object + offset);
				*var = [value sizeValue];
			}
			break;
		}
		default:
			return NO;
	}

	return YES;
}

BOOL ETSetInstanceVariableValueForKey(id object, id value, NSString *key)
{
	assert(object != nil);
	assert(key != nil);

	const char *baseName = [key UTF8String];
	int baseLength = strlen(baseName);
	char name[baseLength + 4];
	const char *ivarName;

	/* Case '_variable' */
	name[2] = '_';
	strncpy(&name[3], baseName, baseLength);
	name[baseLength + 3] = '\0';

	ivarName = &(name[2]);
	Ivar ivar = object_getInstanceVariable(object, ivarName, NULL);

	/* Case '_isVariable' */
	if (ivar == NULL)
	{
		name[0] = '_';
		name[1] = 'i';
		name[2] = 's';
		name[3] = toupper(name[3]);

		ivarName = name;
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}

	/* Case 'variable' */
	if (ivar == NULL)
	{
		name[3] = tolower(name[3]);

		ivarName = &(name[3]);
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}
	
	/* Case 'isVariable' */
	if (ivar == NULL)
	{
		name[3] = toupper(name[3]);

		ivarName = &(name[1]);
		ivar = object_getInstanceVariable(object, ivarName, NULL);
	}

	if (ivar == NULL)
		return NO;

 	return ETSetInstanceVariableValueForKeyWithIvar(object, value, key, ivar);
}
