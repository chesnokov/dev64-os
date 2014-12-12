#ifndef _CONSOLE_TYPES_H_
#define _CONSOLE_TYPES_H_

#include <kern/types.h>

#define CONSOLE_WINDOW_MAX_OFFSET (25*80*2 - 2)
#define CONSOLE_MAX_COL 80-1
#define CONSOLE_MAX_ROW 25-1

typedef struct
{
  kuint16 windowOffset;
  kuint16 cursorOffset;
  kuint8 row;
  kuint8 col;
  kuint8 attr;
} vty_data;

#endif
