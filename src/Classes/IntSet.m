//
//  IntSet.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 21.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IntSet.h"


@implementation IntSet

@synthesize size;
@synthesize values;

-(id)initWithCapacity:(int)initCapacity {
  self = [super init];
  if (self != nil) {
    if (initCapacity > 0) {
      values = malloc(sizeof(short)*initCapacity);
      //memset(values, 0, sizeof(short)*initCapacity);
      capacity = initCapacity;
    } else {
      values = NULL;
      capacity = 0;
    }
    size = 0;
  }
  return self;
}

-(id)initWithArray:(NSArray *)array {
  self = [super init];
  if (self != nil) {
    short l = [array count];
    values = (l > 0)? malloc(sizeof(short)*l) : NULL;
    capacity = l;
    size = 0;
    for (int i = 0; i < l; ++i) {
      [self addWithoutSort:[[array objectAtIndex:i] intValue]];
    }
    [self sort];
  }
  return self;
}

-(id)initWithIntSet:(IntSet *)set {
  self = [super init];
  if (self != nil) {
    short l = set.size;
    if (l > 0) {
      values = malloc(sizeof(short)*l);
      memcpy(values, set.values, sizeof(short)*l);
    } else {
      values = NULL;
    }
    capacity = l;
    size = l;
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
    NSUInteger l = 0;
    const uint8_t *t = [coder decodeBytesForKey:@"VALUES" returnedLength:&l];
    size = capacity = l/sizeof(short);
    values = (l == 0)? NULL : malloc(l);
    memcpy(values, t, l);
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeBytes:(const uint8_t *)values length:sizeof(short)*size forKey:@"VALUES"];
}

-(void)dealloc {
  free(values);
  [super dealloc];
}

-(short)valueAt:(short)idx {
  if (idx >= 0 && idx < size) return values[idx];
  NSLog(@"ERROR! size:%d  capacity:%d  index:%d", size, capacity, idx);
  return -1;
}

-(BOOL)isMember:(short)value {
  short l = 0;
  short h = size-1;
  while (l <= h) {
    short m = (l+h) >> 1;
    short v = values[m];
    if (value < v) h = m-1;
    else if (value > v) l = m+1;
    else return YES;
	}
  return NO;
}

-(BOOL)add:(short)value {
  /*l = size;
  while (++m < l) values[m-1] = values[m];
  values[size-1] = value;
  for (int i = size-1; i > 0 && values[i-1] > values[i]; --i) {
    int t = values[i];
    values[i] = values[i-1];
    values[i-1] = t;
	}
  return YES;*/
  short l = 0;
  short h = size-1;
  while (l <= h) {
    short m = (l+h) >> 1;
    short v = values[m];
    if (value < v) h = m-1;
    else if (value > v) l = m+1;
    else return YES;
	}
  if (++size > capacity) {  // ToDo: optimize incl. insert
    short newCapacity = MAX(capacity << 1, size);
    short *newValues = malloc(sizeof(short)*newCapacity);
    memcpy(newValues, values, sizeof(short)*capacity);
    free(values);
    values = newValues;
    capacity = newCapacity;
  }
  h = size-l-1;
  if (h > 0) memmove(values+l+1, values+l, sizeof(short)*h);
  values[l] = value;
  return YES;
}

-(void)addWithoutSort:(short)value {
  /*short l = 0;
  short h = size-1;
  while (l <= h) {
    short m = (l+h) >> 1;
    short v = values[m];
    if (value < v) h = m-1;
    else if (value > v) l = m+1;
    else {
      NSLog(@"DEBUG ERROR! This case (same value) should not happen!");
      return;
    }
	}
  if (++size > capacity) {
    NSLog(@"DEBUG ERROR! This case (enlarge capacity %d) should not happen!", capacity);
    short newCapacity = MAX(capacity << 1, size);
    short *newValues = malloc(sizeof(short)*newCapacity);
    memcpy(newValues, values, sizeof(short)*capacity);
    free(values);
    values = newValues;
    capacity = newCapacity;
  }
  values[size-1] = value;*/
  values[size++] = value;
}

int shortcmp(const void *v1, const void *v2) {
  return (*(short *)v1 - *(short *)v2);
}

-(void)sort {
  int l = size;
  if (l > 1) {
    short *v = values;
    if (l == 2) {
      short t = v[0];
      if (t > v[1]) {
        v[0] = v[1];
        v[1] = t;
      }
    } else if (l == 3) {
      short a = v[0];
      short b = v[1];
      short c = v[2];
      if (a < b) {
        if (b > c) {
          if (a < c) {
            v[1] = c;
            v[2] = b;
          } else {
            v[0] = c;
            v[1] = a;
            v[2] = b;
          }
        }
      } else if (a < c) {
        v[0] = b;
        v[1] = a;
      } else if (b < c) {
        v[0] = b;
        v[1] = c;
        v[2] = a;
      } else {
        v[0] = c;
        v[2] = a;
      }
    } else {
      qsort(v, l, sizeof(short), shortcmp);
    }
  }
}

-(BOOL)remove:(short)value {
  short l = 0;
  short h = size-1;
  while (l <= h) {
    short m = (l+h) >> 1;
    short v = values[m];
    if (value < v) h = m-1;
    else if (value > v) l = m+1;
    else {
      l = size-m-1;
      if (l > 0) memmove(values+m, values+m+1, sizeof(short)*l);
	    --size;
	    return YES;
    }
	}
  return NO;
}

-(BOOL)intersectsSet:(IntSet *)otherSet {
  const short *v = values;
  for (short i = size-1; i >= 0; --i) {
    if ([otherSet isMember:v[i]]) return YES;
  }
  return NO;
}

-(short)numberOfIntersectsSet:(IntSet *)otherSet {
  short n = 0;
  const short *v = values;
  for (short i = size-1; i >= 0; --i) {
    if ([otherSet isMember:v[i]]) ++n;
  }
  return n;
}

-(BOOL)isEqualToSet:(IntSet *)otherSet {
  const short l1 = size;
  const short l2 = otherSet.size;
  if (l1 != l2) return NO;
  return (l1 == 0 || memcmp(values, otherSet.values, sizeof(short)*l1) == 0);
}

-(void)intersectSet:(IntSet *)otherSet {
  const short *v = values;
  for (short i = size-1; i >= 0; --i) {
    if (![otherSet isMember:v[i]]) {
      [self remove:v[i]];
    }
  }
}

-(void)minusSet:(IntSet *)otherSet {
  const short *v = otherSet.values;
  short l = otherSet.size;
  for (short i = 0; i < l; ++i) {
    [self remove:v[i]];
  }
}

-(void)removeAllObjects {
  size = 0;
}

-(void)unionSet:(IntSet *)otherSet {
  const short *v = otherSet.values;
  short l = otherSet.size;
  for (short i = 0; i < l; ++i) {
    //[self addWithoutSort:v[i]];
    [self add:v[i]];
  }
  //[self sort];
}

-(void)setSet:(IntSet *)otherSet {
  short l = otherSet.size;
  if (l > capacity) {
    free(values);
    values = malloc(sizeof(short)*l);
    capacity = l;
  }
  size = l;
  if (l > 0) memcpy(values, otherSet.values, sizeof(short)*l);
}

-(BOOL)setCapacity:(int)newCapacity {
  if (newCapacity < size) return NO;
  if (newCapacity != capacity) {
    short *newValues = malloc(sizeof(short)*newCapacity);
    memcpy(newValues, values, sizeof(short)*size);
    free(values);
    values = newValues;
    capacity = newCapacity;
  }
  return YES;
}

-(void)trimToSize {
  if (capacity > size) {
    short *newValues = malloc(sizeof(short)*size);
    memcpy(newValues, values, sizeof(short)*size);
    free(values);
    values = newValues;
    capacity = size;
  }
}

-(NSString *)toString {
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:200] autorelease];
  [s appendString:@"["];
  if (size > 0) {
    [s appendFormat:@"%d", values[0]];
    for (int i = 1; i < size; ++i) {
      [s appendFormat:@",%d", values[i]];
    }
  }
  [s appendString:@"]"];
  return s;
}

@end
