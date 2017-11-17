//
//  StringQuery.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntQuery.h"
#import "IntSet.h"

@interface StringQuery : QueryParser {
  IntSet *values;
  //IntSet *associatedTags;
}

-(id)init:(NSString *)attributeId;
-(id)initWithStringQuery:(StringQuery *)stringQuery;
-(void)clear;
+(NSString *)encode:(NSString *)value;
+(NSString *)decode:(NSString *)value;
-(void)append:(NSMutableString *)string;
-(void)add:(int)newValue;
-(BOOL)isEmpty;
-(BOOL)contains:(int)value;
-(int)containsSet:(IntSet *)setOfValues;
-(BOOL)parse:(NSString *)token;
//-(BOOL)recommendation:(UsedCarData *)usedCarData first:(BOOL)firstRec maxOfRecommendations:(int)maxOfRec recommendation:(NSMutableSet *)result;

@property (readonly, nonatomic) IntSet *values;
//@property (readonly, nonatomic) IntSet *associatedTags;

@end
