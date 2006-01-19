/***
    EtoileCompatibility.h

    Etoile declarations to be compatible with other projects

    Copyright (C) 2005 Quentin Mathe

    Author:  Quentin Mathe <qmathe@club-internet.fr
    Date: 2005

    This file may be used under the terms of either GNU Lesser General Public
    License Version 2.1 (or later), GNU General Public License Version 2 (or
    later), BSD modified license or Apache License Version 2.
 ***/

#define __ETOILE__


/* GCC version test code by Kazunobu Kuriyama */
#ifndef GCC_VERSION
#if __GNUC__ > 3
#define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCH_LEVEL__)
#else
#define GCC_VERSION (__GNUC__ * 10000 + __GNUC_MINOR__ * 100)
#endif
#endif // GCC_VERSION


#ifdef GNUSTEP

// Hack to fix invalid truncf function result when FSF GCC is used on Darwin 
// (observed with FSF GCC 3.3.5).
#if defined(__MACH__) && defined(__APPLE__)
#define truncf(x) (int)((x))
#endif

// #define truncf(x) truncf((float)( (x) ))

#endif // GNUSTEP
