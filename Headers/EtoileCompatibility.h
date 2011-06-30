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

// FIXME: Temporary hack until ETLog class is available
#define ETLog NSLog
#ifndef GNUSTEP
/* NSDebugLog and similar macros are not available with Cocoa, please avoid to 
   use them. */
#define NSDebugLog NSLog
#endif // GNUSTEP


/* GCC version test code by Kazunobu Kuriyama */
#ifndef GCC_VERSION
#if __GNUC__ > 3
#define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCH_LEVEL__)
#else
#define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100)
#endif
#endif // GCC_VERSION

#ifdef GNUSTEP
#import <GNUstepBase/GNUstep.h>
#else
#import <EtoileFoundation/GNUstep.h>
#endif // GNUstep


/* ARC macros taken from Headers/GNUstepBase/Preface.h.in */

// Strong has different semantics in GC and ARC modes, so we need to have a
// macro that picks the correct one.
#if __OBJC_GC__
#  define GS_GC_STRONG __strong
#else
#  define GS_GC_STRONG
#endif

#if !__has_feature(objc_arc)
#  if __OBJC_GC__
#    define __strong __attribute__((objc_gc(strong)))
#    define __weak __attribute__((objc_gc(weak)))
#  else
#    define __strong 
#    define __weak 
#  endif
#endif

#ifndef __unsafe_unretained
#  if !__has_feature(objc_arc)
#    define __unsafe_unretained
#  endif
#endif
