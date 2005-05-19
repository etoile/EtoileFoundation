/*
   EtoileCompatibility.h

   Etoile declarations to be compatible with other projects

   Copyright (C) 2005 Quentin Mathe

   Author:  Quentin Mathe <qmathe@club-internet.fr
   Date: 2005

   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

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
