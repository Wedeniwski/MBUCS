//
//  DateQuery.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DateQuery.h"
#import "UsedCar.h"
#import "Dictionary.h"

#define MIN_ERSTZULASSUNG 1970

@implementation DateQuery

-(id)init:(NSString *)aId minWert:(int)minW maxWert:(int)maxW {
  return [super init:aId minWert:minW maxWert:maxW];
}

-(id)initWithDateQuery:(DateQuery *)dateQuery {
  return [super initWithIntQuery:dateQuery];
}

-(void)dealloc {
  [super dealloc];
}

-(int)convertToInt:(NSString *)name {
  return [DateQuery dateToInt:name];
}

+(int)yearToInt:(NSString *)firstRegistration {
  if ([firstRegistration length] < 4) return 0;
  return 12*([firstRegistration intValue]-MIN_ERSTZULASSUNG);
}

+(int)dateToInt:(NSString *)firstRegistration {
  int l = [firstRegistration length];
  if (l == 4) return [DateQuery yearToInt:firstRegistration];
  if (l < 7) return 0;
  return [[firstRegistration substringToIndex:2] intValue]-1 + 12*([[firstRegistration substringFromIndex:3] intValue]-MIN_ERSTZULASSUNG);
}

+(NSString *)intToDate:(int)date {
  if (date == 0) return @"";
  date += MIN_ERSTZULASSUNG*12;
  int month = date%12;
  NSString *attributeName = [UsedCar attributeName:ERSTZULASSUNG]; // ToDo: configure
  Dictionary *dictionary = [Dictionary getInstance];
  NSArray *formats = [dictionary.numericFormats objectForKey:attributeName];
  if (formats != nil) {
    int l = [formats count];
    if (l >= 1) {
      return [NSString stringWithFormat:[formats objectAtIndex:0], month+1, (date-month)/12];
    }
  }
  return [NSString stringWithFormat:@"%02d/%4d", month+1, (date-month)/12];
}

-(NSString *)format:(int)value {
  return [DateQuery intToDate:value];
}

-(void)append:(NSMutableString *)string {
  if (bis > 0) {
    [string appendFormat:@"%@:%@-%@;%@// ", attributeId, [DateQuery intToDate:von], [DateQuery intToDate:bis], [DateQuery intToDate:bevorzugt]];
  } else if (bevorzugt > 0) {
    [string appendFormat:@"%@:%@// ", attributeId, [DateQuery intToDate:bevorzugt]];
  }
}

-(void)setValue:(NSString *)value idx:(int)idx {
  if (value != nil) {
    if (idx == 0) {
      von = [DateQuery dateToInt:value];
      if (bis < von) bis = maxWert;
      if (bevorzugt > 0 && bevorzugt < von) bevorzugt = von;
    } else if (idx == 1) {
      bis = [DateQuery dateToInt:value];
      if (von > bis) von = minWert;
      if (bevorzugt > bis) bevorzugt = bis;
    } else if (idx == 2) {
      bevorzugt = [DateQuery dateToInt:value];
      if (bevorzugt > 0) {
        if (von > bevorzugt) von = bevorzugt;
        if (bis < bevorzugt) bis = bevorzugt;
      }
    } else if (idx == 3) {
      [regex release];
      regex = [value retain];
    }
  }
}

@end
