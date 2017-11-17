//
//  Bookmarks.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCar.h"

@interface Bookmarks : NSObject <NSCoding> {
  BOOL disclaimerKnown;
  NSMutableArray *queryBookmarks;
  NSMutableArray *usedCarBookmarks;
}

-(BOOL)containsQueryBookmark:(NSString *)query;
-(void)addQueryBookmark:(NSString *)query;
-(void)removeQueryBookmark:(NSString *)query;
-(void)removeQueryBookmarkAtIndex:(int)i;
-(BOOL)containsUsedCarBookmark:(UsedCar *)usedCar;
-(void)addUsedCarBookmark:(UsedCar *)usedCar;
-(void)removeUsedCarBookmark:(UsedCar *)usedCar;
-(void)removeUsedCarBookmarkAtIndex:(int)i;
-(int)count;
-(void)clear;
-(void)clearUsedCarBookmarks;

+(Bookmarks *)getInstance:(BOOL)reload;
+(Bookmarks *)getInstance;
+(void)save:(Bookmarks *)bookmarks;

@property BOOL disclaimerKnown;
@property (readonly, nonatomic) NSArray *queryBookmarks;
@property (readonly, nonatomic) NSArray *usedCarBookmarks;

@end
