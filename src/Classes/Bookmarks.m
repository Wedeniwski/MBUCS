//
//  Bookmarks.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bookmarks.h"

@implementation Bookmarks

@synthesize queryBookmarks, usedCarBookmarks;
@synthesize disclaimerKnown;

-(id)init {
  self = [super init];
  if (self != nil) {
    queryBookmarks = [[NSMutableArray alloc] initWithCapacity:20];
    usedCarBookmarks = [[NSMutableArray alloc] initWithCapacity:20];
    disclaimerKnown = NO;
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
    [queryBookmarks release];
    queryBookmarks = [[coder decodeObjectForKey:@"QUERIES"] retain];
    [usedCarBookmarks release];
    usedCarBookmarks = [[coder decodeObjectForKey:@"FAVORITES"] retain];
    disclaimerKnown = [coder decodeBoolForKey:@"DISCLAIMLER_KNOWN"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:queryBookmarks forKey:@"QUERIES"];
  [coder encodeObject:usedCarBookmarks forKey:@"FAVORITES"];
  [coder encodeBool:disclaimerKnown forKey:@"DISCLAIMLER_KNOWN"];
}

-(void)dealloc {
  [queryBookmarks release];
  [usedCarBookmarks release];
  [super dealloc];
}

-(BOOL)containsQueryBookmark:(NSString *)query {
  return ([queryBookmarks indexOfObject:query] != NSNotFound);
}

-(void)addQueryBookmark:(NSString *)query {
  if (![self containsQueryBookmark:query]) {
    if ([queryBookmarks count] == 0) [queryBookmarks addObject:query];
    else [queryBookmarks insertObject:query atIndex:0];
  }
}

-(void)removeQueryBookmark:(NSString *)query {
  [queryBookmarks removeObject:query];
}

-(void)removeQueryBookmarkAtIndex:(int)i {
  [queryBookmarks removeObjectAtIndex:i];
}

-(BOOL)containsUsedCarBookmark:(UsedCar *)usedCar {
  return ([usedCarBookmarks indexOfObject:usedCar] != NSNotFound);
}

-(void)addUsedCarBookmark:(UsedCar *)usedCar {
  if (![self containsUsedCarBookmark:usedCar]) {
    if ([usedCarBookmarks count] == 0) [usedCarBookmarks addObject:usedCar];
    else [usedCarBookmarks insertObject:usedCar atIndex:0];
  }
}

-(void)removeUsedCarBookmark:(UsedCar *)usedCar {
  [usedCarBookmarks removeObject:usedCar];
}

-(void)removeUsedCarBookmarkAtIndex:(int)i {
  [usedCarBookmarks removeObjectAtIndex:i];
}

-(int)count {
  return [queryBookmarks count] + [usedCarBookmarks count];
}

-(void)clear {
  [queryBookmarks removeAllObjects];
  [usedCarBookmarks removeAllObjects];
}

-(void)clearUsedCarBookmarks {
  [usedCarBookmarks removeAllObjects];
}

+(Bookmarks *)getInstance:(BOOL)reload {
  @synchronized([Bookmarks class]) {
    static Bookmarks *bookmarks = nil;
    if (bookmarks == nil) {
      bookmarks = [[NSKeyedUnarchiver unarchiveObjectWithFile:[[SettingsData documentPath] stringByAppendingPathComponent:@"bookmarks.data"]] retain];
      if (bookmarks == nil) bookmarks = [[Bookmarks alloc] init];
    } else if (reload) {
      [bookmarks release];
      bookmarks = [[NSKeyedUnarchiver unarchiveObjectWithFile:[[SettingsData documentPath] stringByAppendingPathComponent:@"bookmarks.data"]] retain];
      if (bookmarks == nil) bookmarks = [[Bookmarks alloc] init];
    }
    return bookmarks;
  }
}

+(Bookmarks *)getInstance {
  return [Bookmarks getInstance:NO];
}

+(void)save:(Bookmarks *)bookmarks {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSKeyedArchiver archiveRootObject:bookmarks toFile:[[SettingsData documentPath] stringByAppendingPathComponent:@"bookmarks.data"]];
  [pool release];
}

@end
