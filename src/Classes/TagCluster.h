//
//  TagCluster.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 02.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntSet.h"

@interface TagCluster : NSObject {
  NSString *name;
  int factor;
  IntSet *tags;
  NSMutableArray *nextLevel;
}

-(id)initWithName:(NSString *)n factor:(int)f tags:(IntSet *)tgs;
-(void)add:(IntSet *)tgs;
-(void)addLevel:(TagCluster *)cluster;
-(NSString *)toString;

-(const char *)parse:(const char*)source;

@property (readonly, nonatomic) NSString *name;
@property (readonly) int factor;
@property (readonly, nonatomic) IntSet *tags;

@end
