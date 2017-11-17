//
//  TagCluster.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 02.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagCluster.h"
#import "UsedCarData.h"

@implementation TagCluster

@synthesize name;
@synthesize factor;
@synthesize tags;

-(id)initWithName:(NSString *)n factor:(int)f tags:(IntSet *)tgs {
  self = [super init];
  if (self != nil) {
    name = [n retain];
    factor = f;
    tags = [tgs retain];
    nextLevel = nil;
  }
  return self;
}

-(void)dealloc {
  [name release];
  [tags release];
  [nextLevel release];
  [super dealloc];
}

-(void)add:(IntSet *)tgs {
  [tags unionSet:tgs];
}

-(void)addLevel:(TagCluster *)cluster {
  if (nextLevel == nil) {
    nextLevel = [[NSMutableArray alloc] initWithCapacity:5];
  }
  [nextLevel addObject:cluster];
}

// ToDo: only one source of implementation and not also at UsedCarData
static const char* stringValue(const char *source, char *target, int MAX_CSTRING) {
  int i = 0;
  if (*source == '\"') {
    do {
      char c = *++source;
      if (!c) break;
      if (c == '\"' && *(source-1) != '\\') {
        ++source;
        break;
      }
      target[i] = c;
    } while (++i < MAX_CSTRING);
  }
  target[i] = '\x0';
  return source;
}

static const char* intValue(const char *source, int *value) {
  int x = 0;
  BOOL neg = FALSE;
  if (*source == '-') {
    ++source;
    neg = TRUE;
  }
  while (TRUE) {
    char c = *source;
    if (c >= '0' && c <= '9') {
      x *= 10; x += (int)(c - '0');
    } else {
      *value = (neg)? -x : x;
      return source;
    }
    ++source;
  }
}

-(NSString *)toString {
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:10000] autorelease];
  [s appendString:@"["];
  if (name != nil) {
    [s appendString:@"\""];
    [s appendString:name];
    [s appendString:@"\""];
  }
  [s appendFormat:@"%d[", factor];
  BOOL first = YES;
  int l = tags.size;
  for (int i = 0; i < l; ++i) {
    [s appendFormat:(first)? @"%d" : @",%d", i];
    first = NO;
  }
  [s appendString:@"]"];
  for (TagCluster *t in nextLevel) {
    [s appendString:[t toString]];
  }
  [s appendString:@"]"];
  return s;  
}

-(const char *)parse:(const char*)source {
  if (*source != '[') {
    NSLog(@"Wrong start character '%c' of tag cluster", *source);
    return NULL;
  }
  if (*++source == '\"') {
    const int MAX_CSTRING = 500;
    char tmp[MAX_CSTRING+1];
    source = stringValue(source, tmp, MAX_CSTRING);
    name = [[NSString alloc] initWithUTF8String:tmp];
  }
  source = intValue(source, &factor);
  if (*source != '[') {
    NSLog(@"Wrong separation '%c' in tag cluster", *source);
    return NULL;
  }
  source = [UsedCarData intSet:source target:tags];
  if (source == NULL) {
    NSLog(@"Wrong unknown end separation in tag cluster");
    return NULL;
  }
  while (*source == '[') {
    IntSet *intSet = [[IntSet alloc] initWithCapacity:50];
    TagCluster *cluster = [[TagCluster alloc] initWithName:nil factor:1 tags:intSet];
    [intSet release];
    source = [cluster parse:source];
    if (source != NULL) [self addLevel:cluster];
    [cluster release];
  }
  if (*source != ']') {
    NSLog(@"Wrong end separation '%c' in tag cluster", *source);
    return NULL;
  }
  return source+1;
}

@end
