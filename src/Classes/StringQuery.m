//
//  StringQuery.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StringQuery.h"
#import "SearchCriteria.h"
#import "StringAttribute.h"
#import "Tags.h"

@implementation StringQuery

@synthesize values;//, associatedTags;

-(id)init:(NSString *)aId {
  self = [super init:aId];
  if (self != nil) {
    values = [[IntSet alloc] initWithCapacity:10];
    //associatedTags = [[IntSet alloc] initWithCapacity:10];
    [self clear];
  }
  return self;
}

-(id)initWithStringQuery:(StringQuery *)stringQuery {
  self = [super initWithQueryParser:stringQuery];
  if (self != nil) {
    values = [[IntSet alloc] initWithIntSet:stringQuery.values];
    //associatedTags = [[IntSet alloc] initWithIntSet:stringQuery.associatedTags];
  }
  return self;
}

-(void)dealloc {
  [values release];
  //[associatedTags release];
  [super dealloc];
}

-(void)clear {
  [super clear];
  [values removeAllObjects];
  //[associatedTags removeAllObjects];
}

+(NSString *)encode:(NSString *)value {
  return [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

+(NSString *)decode:(NSString *)value {
  NSString *t = [value stringByReplacingOccurrencesOfString:@"%C3%BC" withString:@"ü"];
  t = [t stringByReplacingOccurrencesOfString:@"%C3%A4" withString:@"ä"];
  t = [t stringByReplacingOccurrencesOfString:@"%C3%B6" withString:@"ö"];
  t = [t stringByReplacingOccurrencesOfString:@"%C3%A9" withString:@"é"];
  t = [t stringByReplacingOccurrencesOfString:@"%C3%9F" withString:@"ß"];
  t = [t stringByReplacingOccurrencesOfString:@"%C2%AE" withString:@""];
  t = [t stringByReplacingOccurrencesOfString:@"%22" withString:@"\""];
  return [t stringByReplacingOccurrencesOfString:@"+" withString:@" "];
  //return [Tags removingAccents:t];
}

-(void)append:(NSMutableString *)string {
  int l = values.size;
  if (l > 0) {
    SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
    StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
    [string appendString:attributeId];
    [string appendString:@":"];
    [string appendString:[attribute.types objectAtIndex:[values valueAt:0]]];
    for (int i = 1; i < l; ++i) {
      [string appendString:@","];
      [string appendString:[attribute.types objectAtIndex:[values valueAt:i]]];
    }
    [string appendString:@" "];
  }
}

-(void)add:(int)newValue {
  if (newValue >= 0) {
    [values add:newValue];
  }
  /*SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
  if (attribute != nil) {
    NSString *token = [attribute.types objectAtIndex:newValue];
    IntSet *set = [searchCriteria.tags validTags:token];
    if (set != nil) [associatedTags unionSet:set];
  }*/
}

-(BOOL)isEmpty {
  return (values.size == 0);
}

-(BOOL)contains:(int)value {
  return [values isMember:value];
}

-(int)containsSet:(IntSet *)setOfValues {
  return [values numberOfIntersectsSet:setOfValues];
}

-(BOOL)parse:(NSString *)token {
  if ([token length]-1 <= [attributeId length]) return FALSE;
  // ToDo: check for '-<attributerId>:'
  NSString *t1 = [attributeId stringByAppendingString:@":"];
  NSString *t2 = [attributeId stringByAppendingString:@" "];
  if ([token hasPrefix:t1] || [token hasPrefix:t2]) {
    NSArray *tokens = [[token substringFromIndex:[t1 length]] componentsSeparatedByString:@","];
    SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
    //StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
    for (NSString *t in tokens) {
      NSArray *tokens2 = [[StringQuery decode:t] componentsSeparatedByString:@" "];
      for (NSString *s in tokens2) {
        s = [Tags simplifyToken:s];
        if (s != nil) [self add:[searchCriteria.tags convertTagToId:s]];
      }
      /*int i = [UsedCarData stringArraySearch:s array:attribute.types];
      if (i >= 0) [self add:i];
      else {
        i = [searchCriteria.tags convertTagToId:[Tags simplifyToken:s]];
        if (i >= 0) {
          int j = 0;
          for (NSString *token in attribute.types) {
            IntSet *set2 = [searchCriteria.tags validTags:token];
            if (set2 != nil && [set2 isMember:i]) [self add:j];
            ++j;
          }
        }
      }*/

      /*s = [Tags simplifyToken:s];
      if (s != nil) {
        NSRange range = [s rangeOfString:@" "];
        if (range.length == 0) {
          i = [searchCriteria.tags convertTagToId:s];
          if (i >= 0) [self add:i];
        } else {
          NSArray *tags = [s componentsSeparatedByString:@" "];
          for (NSString *tag in tags) {
            i = [searchCriteria.tags convertTagToId:tag];
            if (i >= 0) [self add:i];
          }
        }
      }*/
    }
    return TRUE;
  }
  return FALSE;
}

/*-(IntSet *)associatedTags {
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
  if (attribute == nil) return nil;
  IntSet *m = [[[IntSet alloc] initWithCapacity:10] autorelease];
  int l = values.size;
  for (int i = 0; i < l; ++i) {
    NSString *token = [attribute.types objectAtIndex:[values valueAt:i]];
    IntSet *set = [searchCriteria.tags validTags:token];
    if (set != nil) [m unionSet:set];
  }
  return m;
}*/

/*-(BOOL)recommendation:(UsedCarData *)usedCarData first:(BOOL)firstRec maxOfRecommendations:(int)maxOfRec recommendation:(NSMutableSet *)result {
  StringAttribute *attribute = [usedCarData.attributeIndex objectForKey:attributeId];
  int length = [usedCarData count];
  if (length == 0) return NO;
  NSDictionary *d = usedCarData.usedCars;
  NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:maxOfRec];
  NSArray *a = [valuesToLower allObjects];
  for (NSString *wert in a) {
    VonBis vb = [usedCarData stringSearch:wert attributeId:attributeId];
    if (vb.von >= 0) {
      for (int i = vb.von; i < vb.bis; ++i) {
        UsedCar *u = [d objectForKey:[usedCarData.gfzNumbers objectAtIndex:[attribute atIndex:i]]];
        if (u != nil) {
          if (firstRec) u.preferenceFit = 1.0;
          [set addObject:u];
        }
      }
    }
  }
  if ([set count] == 0) {
    [set release];
    return NO;
  }
  if (firstRec) [result unionSet:set];
  else [result intersectSet:set];
  [set release];
  return YES;
}*/

@end
