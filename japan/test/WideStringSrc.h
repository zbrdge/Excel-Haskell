
#ifndef __WIDESTRING_H__
#define __WIDESTRING_H__

#ifndef WCHAR
/* I don't know why require this header now. */
#include <wchar.h>
#define WCHAR wchar_t
#endif

extern
int
primStringToWide ( char* str
                 , unsigned int len
		 , WCHAR* wstr
		 , unsigned int wlen
		 );
extern
int
wideToString ( WCHAR* wstr, char** pstr );

extern
unsigned int wideStringLen (char* str);

extern
int lenWideString (WCHAR* str);

#endif
