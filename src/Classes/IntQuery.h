//
//  IntQuery.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCarData.h"

@interface QueryParser : NSObject {
  NSString *attributeId;
  BOOL indirectThroughReplacement;
}

-(id)init:(NSString *)aId;
-(id)initWithQueryParser:(QueryParser *)queryParser;
-(void)clear;
-(void)append:(NSMutableString *)string;
-(BOOL)parse:(NSString *)token;
-(void)setValue:(NSString *)value idx:(int)idx;

@property (readonly, nonatomic) NSString *attributeId;
@property BOOL indirectThroughReplacement;
@end


@interface IntQuery : QueryParser {
  int von;
  int bis;
  int minWert;
  int maxWert;
  int bevorzugt;
  int bester; // -> 1.0
  int schlechtester; // -> 0.1
  int faktor; // 0...5
  BOOL indirekterFaktor;
  NSString *regex;
}

-(id)init:(NSString *)aId minWert:(int)minW maxWert:(int)maxW;
-(id)initWithIntQuery:(IntQuery *)intQuery;
-(void)clear;
-(BOOL)hasQuery;
-(void)setupFactor;
-(NSString *)format:(int)value;
-(void)append:(NSMutableString *)string;
-(int)convertToInt:(NSString *)name;
-(BOOL)parse:(NSString *)token;
-(void)setValue:(NSString *)value idx:(int)idx;

@property int von, bis, bevorzugt, minWert, maxWert, bester, schlechtester;
@property (readonly) int faktor;
@property (readonly) BOOL indirekterFaktor;

// ToDo: wegen clone
@property (readonly, nonatomic) NSString *regex;

@end
