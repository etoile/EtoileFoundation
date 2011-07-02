/*
	Etoile declarations to be compatible with other projects

	Copyright (C) 2005 Quentin Mathe

	Author:  Quentin Mathe <qmathe@club-internet.fr
	Date: 2005
	
	This file may be used under the terms of either GNU Lesser General Public 
	License Version 2.1 (or later), GNU General Public License Version 2 (or
	later), BSD modified license or Apache License Version 2.
 */

#define __ETOILE__

/* Logging Hacks */

// FIXME: Temporary hack until ETLog class is available
#define ETLog NSLog
#ifndef GNUSTEP
/* NSDebugLog and similar macros are not available with Cocoa, please avoid to 
   use them. */
#  define NSDebugLog NSLog
#endif

/* GCC version test code by Kazunobu Kuriyama */

#ifndef GCC_VERSION
#  if __GNUC__ > 3
#    define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCH_LEVEL__)
#  else
#    define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100)
#  endif
#endif

/* How to get GNUstep.h */

#ifdef GNUSTEP
#  import <GNUstepBase/GNUstep.h>
#else
#  import <EtoileFoundation/GNUstep.h>
#endif

/*  Compatibility with non-clang compilers */

#ifndef __has_feature
#	define __has_feature(x) 0
#endif

/* ARC macros taken from Headers/GNUstepBase/Preface.h.in
   Note: Apple GCC + GC supports __weak and __strong qualifiers */

#ifndef __weak
#  if !defined(__clang__) || !__has_feature(objc_arc)
#    if __OBJC_GC__
#      define __weak __attribute__((objc_gc(weak)))
#    elif defined(GNUSTEP)
#      define __weak 
#    endif
#  endif
#endif

#ifndef __strong
#  if !defined(__clang__) || !__has_feature(objc_arc)
#    if __OBJC_GC__
#      define __strong __attribute__((objc_gc(strong)))
#    elif defined(GNUSTEP)
#      define __strong 
#    endif
#  endif
#endif

#ifndef __unsafe_unretained
#  if !defined(__clang__) || !__has_feature(objc_arc)
#    define __unsafe_unretained
#  endif
#endif

#ifndef __bridge
#  if !defined(__clang__) || !__has_feature(objc_arc)
#    define __bridge
#  endif
#endif
