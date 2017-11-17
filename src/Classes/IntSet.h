//
//  IntSet.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 21.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IntSet : NSObject <NSCoding> {
  short size, capacity;
  short *values;
}

-(id)initWithCapacity:(int)initCapacity;
-(id)initWithArray:(NSArray *)array;
-(id)initWithIntSet:(IntSet *)set;

-(short)valueAt:(short)idx;
-(BOOL)isMember:(short)value;
-(BOOL)add:(short)value;
-(void)addWithoutSort:(short)value; // call sort after this call!! Only for batch
-(void)sort;
-(BOOL)remove:(short)value;

-(BOOL)intersectsSet:(IntSet *)otherSet;
-(short)numberOfIntersectsSet:(IntSet *)otherSet;
-(BOOL)isEqualToSet:(IntSet *)otherSet;
//-(BOOL)isSubsetOfSet:(IntSet *)otherSet;
-(void)intersectSet:(IntSet *)otherSet;
-(void)minusSet:(IntSet *)otherSet;
-(void)removeAllObjects;
-(void)unionSet:(IntSet *)otherSet;
-(void)setSet:(IntSet *)otherSet;
-(BOOL)setCapacity:(int)newCapacity;
-(void)trimToSize;
-(NSString *)toString;

/*
 void iterate(int &i) { i = 0; }
 int ok(int& i) { return i < cursize; }
 int next(int& i) { return x[i++]; } 
 */

@property (readonly) short size;
@property (readonly, nonatomic) short* values;

@end
