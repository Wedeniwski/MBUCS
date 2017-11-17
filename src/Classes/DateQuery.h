//
//  DateQuery.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCarData.h"
#import "IntQuery.h"

@interface DateQuery : IntQuery {
}

-(id)init:(NSString *)aId minWert:(int)minW maxWert:(int)maxW;
-(id)initWithDateQuery:(DateQuery *)dateQuery;
-(int)convertToInt:(NSString *)name;
+(int)yearToInt:(NSString *)firstRegistration;
+(int)dateToInt:(NSString *)firstRegistration;
+(NSString *)intToDate:(int)date;
-(NSString *)format:(int)value;
-(void)append:(NSMutableString *)string;
-(void)setValue:(NSString *)value idx:(int)idx;

@end
