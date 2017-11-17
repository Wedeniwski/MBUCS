//
//  StringAttribute.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 09.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StringAttribute.h"

@implementation StringAttribute

@synthesize types;

-(id)init:(NSArray *)typ frequency:(NSArray *)f {
  self = [super init];
  if (self != nil) {
    types = [typ retain];
    frequency = [f retain];
  }
  return self;
}

/*-(id)initWithData:(NSString *)typ frequency:(NSString *)f {
  self = [super init];
  if (self != nil) {
    if ([typ hasPrefix:@"types:"]) {
      types = [[StringAttribute parseStringList:[typ substringFromIndex:6]] retain];
    }
    if ([f hasPrefix:@"frequency:"]) {
      frequency = [[StringAttribute parseIntList:[f substringFromIndex:10]] retain];
    }
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
    types = [[coder decodeObjectForKey:@"TYPES"] retain];
    frequency = [[coder decodeObjectForKey:@"FREQUENCY"] retain];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:types forKey:@"TYPES"];
  [coder encodeObject:frequency forKey:@"FREQUENCY"];
}*/

-(void)dealloc {
  [types release];
  [frequency release];
  [super dealloc];
}

/*-(id)value:(int)posInGfzArray {
  if (index != nil) {
    int l = [index count];
    for (int i = 0; i < l; ++i) {
      NSNumber *n = [index objectAtIndex:i];
      if ([n intValue] == posInGfzArray) {
        for (int j = [types count]-1; j >= 0; --j) { // ToDo: optimize binarySearch
          n = [pos objectAtIndex:j];
          if (i >= [n intValue]) {
            return [types objectAtIndex:j];
          }
        }
      }
    }
  } else if (index2 != nil) {
    // pos2 is position in index2 (indicates how many used cars contains this attribute)
    NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:20] autorelease];
    int l = [index2 count];
    int j = 0;
    int nextPos = [[pos objectAtIndex:0] intValue];
    for (int i = 0; i < l; ++i) {
      if (i == nextPos) nextPos = [[pos objectAtIndex:++j] intValue];
      if ([[index2 objectAtIndex:i] intValue] == posInGfzArray) {
        [m addObject:[types objectAtIndex:j]];
      }
    }
    return m;
  }
  NSLog(@"posInGfzArray %d NOT found in StringAttribute values", posInGfzArray);
  return nil;
}
*/
-(int)frequencyAll:(int)idx {
  if (idx >= 0 && idx < [frequency count]) {
    return [[frequency objectAtIndex:idx] intValue];
  }
  return -1;
}

/*-(int)indexCount {
  if (index != nil) return [index count];
  else if (index2 != nil) return [index2 count];
  return -1;
}

-(int)atIndex:(int)idx {
  if (index != nil) return [[index objectAtIndex:idx] intValue];
  else if (index2 != nil) return [[index2 objectAtIndex:idx] intValue];
  return -1;
}
*/

/*+(NSArray *)parseIntList:(NSString *)val {
  NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:10000] autorelease];
  const char *s = [val UTF8String]; // faster, less memory
  int x = 0;
  BOOL neg = FALSE;
  while (true) {
    char c = *s;
    if (!c || c == ',') {
      if (neg) [array addObject:[NSNumber numberWithInt:-x]];
      else [array addObject:[NSNumber numberWithInt:x]];
      x = 0;
      neg = FALSE;
      if (!c) break;
    } else if (c == '-') {
      neg = TRUE;
    } else if (c >= '0' && c <= '9') {
      x *= 10; x += (int)(c - '0');
    } else {
      NSLog(@"Internal ERROR! Invalid int '%c' value in %@.", c, val);
      UIAlertView *selectionDialog;
      selectionDialog = [[UIAlertView alloc]
                         initWithTitle:@"Internal Error!"
                         message:@"Invalid int values (see log)."
                         delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
      [selectionDialog show];
      [selectionDialog release];
    }
    ++s;
  }
  return array;
}

+(NSArray *)parseStringList:(NSString *)val {
  const int MAX_CSTRING = 250;
  char tmp[MAX_CSTRING+1];
  NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:10000] autorelease];
  const char *s = [val UTF8String]; // faster, less memory
  while (true) {
    char c = *s;
    if (!c) break;
    if (c == '\"') {
      int i = 0;
      do {
        c = *++s;
        if (!c || c == '\"' && *(s-1) != '\\') break;
        tmp[i] = c;
      } while (++i < MAX_CSTRING);
      tmp[i] = '\x0';
      NSString *t = [NSString stringWithUTF8String:tmp];
      if (!c || i == MAX_CSTRING && s[1] != '\"') {
        NSLog(@"Internal ERROR! Invalid string %@", t);
        UIAlertView *selectionDialog;
        selectionDialog = [[UIAlertView alloc]
                           initWithTitle:@"Internal Error!"
                           message:@"Invalid string (see log)."
                           delegate:self
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [selectionDialog show];
        [selectionDialog release];
      }
      [array addObject:t];
    }
    ++s;
  }
  return array;
}
*/
@end
