//
//  UsedCar.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 07.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UsedCar.h"
#import "UsedCarData.h"
#import "Tags.h"
#import "SearchCriteria.h"
#import "StringAttribute.h"

@implementation UsedCar

@synthesize gfzNumber;
@synthesize tags;
@synthesize locationIndex;
@synthesize preferenceFit;


-(id)initWithGFZNumber:(NSString *)gfz {
  self = [super init];
  if (self != nil) {
    int n = [[UsedCar attributeIdOrder] count];
    attributes = malloc(sizeof(int)*n);
    memset(attributes, 0, sizeof(int)*n);
    gfzNumber = [gfz retain];
    locationIndex = -1;
    tags = nil;
    preferenceFit = 0.0;
    propertyMatch = malloc(sizeof(float)*NUMBER_OF_PROPERTY_IDS);
    memset(propertyMatch, 0, sizeof(float)*NUMBER_OF_PROPERTY_IDS);
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)coder {
  self = [super init];
  if (self != nil) {
    int n = [[UsedCar attributeIdOrder] count];
    attributes = malloc(sizeof(int)*n);
    memset(attributes, 0, sizeof(int)*n);
    gfzNumber = [[coder decodeObjectForKey:GFZ] retain];
    NSArray *attributeIds = [UsedCar attributeIdOrder];
    for (NSString *attributeId in attributeIds) {
      if ([UsedCar isStringSetAttribute:attributeId]) {
        [self setSetAttribute:attributeId value:[coder decodeObjectForKey:attributeId]];
      } else {
        [self setAttribute:attributeId value:[coder decodeIntForKey:attributeId]];
      }
    }
    //bilder = [[coder decodeObjectForKey:@"IMAGES"] retain];
    locationIndex = (short)[coder decodeIntForKey:@"LOCATION_INDEX"];
    tags = [[coder decodeObjectForKey:TAGS] retain];
    preferenceFit = 0.0;
    propertyMatch = malloc(sizeof(float)*NUMBER_OF_PROPERTY_IDS);
    memset(propertyMatch, 0, sizeof(float)*NUMBER_OF_PROPERTY_IDS);
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:gfzNumber forKey:GFZ];
  NSArray *attributeIds = [UsedCar attributeIdOrder];
  for (NSString *attributeId in attributeIds) {
    if ([UsedCar isStringSetAttribute:attributeId]) {
      [coder encodeObject:[self stringIdSetAttribute:attributeId] forKey:attributeId];
    } else {
      [coder encodeInt:[self attribute:attributeId] forKey:attributeId];
    }
  }
  [coder encodeInt:locationIndex forKey:@"LOCATION_INDEX"];
  //[coder encodeObject:bilder forKey:@"IMAGES"];
  //NSLog(@"gfz: %@, tags:%@", gfzNumber, tags);
  [coder encodeObject:tags forKey:TAGS];
}

-(void)dealloc {
  [gfzNumber release];
  free(attributes);
  [ausstattungsmerkmale release];
  //[bilder release];
  [tags release];
  free(propertyMatch);
  [super dealloc];
}

-(BOOL)isEqual:(UsedCar *)otherUsedCar {
  if (![gfzNumber isEqualToString:otherUsedCar.gfzNumber]) return NO;
  NSArray *attributeIds = [UsedCar attributeIdOrder];
  for (NSString *attributeId in attributeIds) {
    if ([UsedCar isStringSetAttribute:attributeId]) {
      IntSet *i = [self stringIdSetAttribute:attributeId];
      IntSet *j = [otherUsedCar stringIdSetAttribute:attributeId];
      if (![i isEqualToSet:j]) return NO;
    } else {
      int i = [self attribute:attributeId];
      int j = [otherUsedCar attribute:attributeId];
      if (i != j) return NO;
    }
  }
  return YES;
}

-(NSComparisonResult)compare:(UsedCar *)otherUsedCar {
  if (preferenceFit > otherUsedCar.preferenceFit) return -1;
  if (preferenceFit < otherUsedCar.preferenceFit) return 1;
  // ToDo: gewichte berücksichtigen!
  return 0;
}

-(void)trimToSize {
  if (ausstattungsmerkmale != nil) [ausstattungsmerkmale trimToSize];
  if (tags != nil) [tags trimToSize];
}

/*-(BOOL)hasTags {
  return (tags != nil && tags.size > 0);
}*/

/*-(void)setupTags:(Tags *)tgs attributeIndex:(NSDictionary *)attributeIndex {
  //NSLog(@"gfz: %@", gfzNumber);
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSArray *attributeIds = [UsedCar stringAttributeIdOrder];
  IntSet *m = [[IntSet alloc] initWithCapacity:[attributeIds count]+5];
  for (NSString *attributeId in attributeIds) {
    IntSet *set = [self stringIdSetAttribute:attributeId];
    if (set != nil) {
      // need to include the associated tags and not the IDs from the types
      StringAttribute *attribute = [attributeIndex objectForKey:attributeId];
      if (attribute != nil) {
        int l = set.size;
        for (int i = 0; i < l; ++i) {
          NSString *token = [attribute.types objectAtIndex:[set valueAt:i]];
          IntSet *s = [tgs validTags:token];
          if (s != null) [m unionSet:s];
        }
      }
    } else {
      NSString *token = [self stringAttribute:attributeId];
      if (token != nil) {
        IntSet *s = [tgs validTags:token];
        if (s != nil) [m unionSet:s];
      }
    }    
  }
  [tags release];
  tags = m;
  [pool release];
}*/

-(BOOL)hasCertificate {
  return ([[self stringAttribute:GARANTIE] length] > 0);
}

/*-(NSArray *)getBilder {
  if (bilder == nil) return nil;
  NSMutableArray *a = [[[NSMutableArray alloc] initWithCapacity:[bilder count]] autorelease];
  for (NSString *t in bilder) {
    if ([t hasPrefix:@"http://"]) [a addObject:t];
    else if ([t hasPrefix:@"/"]) [a addObject:[BILDER_PREFIX2 stringByAppendingString:t]];
    else [a addObject:[BILDER_PREFIX stringByAppendingString:t]];
  }
  return a;
}

-(void)setBilder:(NSArray *)images {
  [bilder release];
  bilder = [images retain];
}*/

-(float)getPropertyFactor:(int)propertyIndex usedCarData:(UsedCarData *)usedCarData settings:(SettingsData *)settings {
  int factor = [settings value:[UsedCarData getPropertyId:propertyIndex]];
  if (factor == 1) return -1.0f;
  float match = [self getPropertyMatch:propertyIndex];
  if (factor == 0 && match > 0) return 0.0f;
  float best = [usedCarData.maxValuesAttributes getPropertyMatch:propertyIndex];
  if (best > 0.0f) {
    match += 1.0f; best += 1.0f;
    float tf = match/(match+1.0f) * (best+1.0f)/best;
    if (factor == 3) tf *= tf;
    else if (factor == 4) {
      float f = tf*tf;
      tf *= f;
    } else if (factor == 5) {
      tf *= tf; tf *= tf;
    }
    return tf;
  }
  return -1.0f;
}

-(float)getPropertyMatch:(int)propertyIndex {
  return (propertyIndex >= 0 && propertyIndex < NUMBER_OF_PROPERTY_IDS)? propertyMatch[propertyIndex] : 0.0f;
}

-(void)setPropertyMatch:(float *)pMatch {
  memcpy(propertyMatch, pMatch, sizeof(float)*NUMBER_OF_PROPERTY_IDS);
}

-(void)minPropertyMatch:(float *)pMatch {
  for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {
    if (pMatch[i] < propertyMatch[i]) {
      propertyMatch[i] = pMatch[i];
    }
  }
}

-(void)maxPropertyMatch:(float *)pMatch {
  for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {
    if (pMatch[i] > propertyMatch[i]) {
      propertyMatch[i] = pMatch[i];
    }
  }
}

-(NSSet *)getAustattungsmerkmale:(NSDictionary *)attributeIndex {
  StringAttribute *attribute = [attributeIndex objectForKey:AUSSTATTUNGSMERKMALE];
  int l = ausstattungsmerkmale.size;
  NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:l+5] autorelease];
  for (int i = 0; i < l; ++i) {
    [m addObject:[attribute.types objectAtIndex:[ausstattungsmerkmale valueAt:i]]];
  }
  return m;
}

-(void)setAttribute:(NSString *)attributeId value:(int)value {
  int i = [UsedCar attributeIdIndex:attributeId];
  attributes[i] = value;
}

-(int)attribute:(NSString *)attributeId {
  int i = [UsedCar attributeIdIndex:attributeId];
  return attributes[i];
}

-(NSString *)stringAttribute:(NSString *)attributeId {
  if ([attributeId isEqualToString:GFZ]) return gfzNumber;
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
  if (attribute != nil) {
    int i = [self attribute:attributeId];
    if (i >= 0 && i < [attribute.types count]) {
      return [attribute.types objectAtIndex:i];
    } else {
      NSLog(@"ERROR! attributeId:%@  idx:%d  size:%d", attributeId, i, [attribute.types count]);
      exit(1);
    }

  }
  return nil;
}

-(void)setSetAttribute:(NSString *)attributeId value:(IntSet *)value {
  if ([attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) {
    [ausstattungsmerkmale release];
    ausstattungsmerkmale = [value retain];
  } else if ([attributeId isEqualToString:TAGS]) {
    [tags release];
    tags = [value retain];
  }
}

-(IntSet *)stringIdSetAttribute:(NSString *)attributeId {
  if ([attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) {
    return ausstattungsmerkmale;
  } else if ([attributeId isEqualToString:TAGS]) {
    return tags;
  }
  return nil;
}

+(NSString *)attributeName:(NSString *)attributeId { // ToDo
  static NSArray *array = nil;
  if (array == nil) {
    array = [[NSArray alloc] initWithObjects:@"Modell", @"Kaufpreis", @"Kilometerstand", @"Erstzulassung", @"Art", @"Karosserie", @"Motorleistung",
             @"Hubraum", @"Kraftstoff", @"Verbrauch", @"CO2 Emissionen", @"Getriebe", @"Farbe", @"Polster", @"Vorbesitzer", @"Leistungen",
             @"Kontakt", @"Ausstattung", nil];
  }
  int i = [UsedCar attributeIdIndex:attributeId];
  return [array objectAtIndex:i];
}

+(BOOL)isStringAttribute:(NSString *)attributeId {
  static NSSet *set = nil;
  if (set == nil) {
    set = [[NSSet alloc] initWithObjects:GFZ, FAHRZEUGART, KAROSSERIEFORM, KRAFTSTOFFART, GETRIEBE, FARBE, POLSTER, MODELL, GARANTIE, KONTAKT, nil];
  }
  return [set containsObject:attributeId];
}
  
+(BOOL)isStringSetAttribute:(NSString *)attributeId {
  if ([attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) return YES;
  else if ([attributeId isEqualToString:TAGS]) return YES;
  return NO;
}
  
+(BOOL)isIntAttribute:(NSString *)attributeId {
  static NSSet *set = nil;
  if (set == nil) {
    set = [[NSSet alloc] initWithObjects:KILOMETERSTAND, MOTORLEISTUNG, HUBRAUM, KRAFTSTOFFVERBRAUCH, CO2_EMISSIONEN, VORBESITZER, KAUFPREIS, nil];
  }
  return [set containsObject:attributeId];
}

+(BOOL)isDateAttribute:(NSString *)attributeId {
  return ([attributeId isEqualToString:ERSTZULASSUNG]);
}

+(NSArray *)intAttributeIdOrder {
  // ToDo: preferences
  static NSArray *array = nil;
  if (array == nil) {
    array = [[NSArray alloc] initWithObjects:KAUFPREIS, KILOMETERSTAND, ERSTZULASSUNG, MOTORLEISTUNG, HUBRAUM, KRAFTSTOFFVERBRAUCH,
             CO2_EMISSIONEN, VORBESITZER, nil];
  }
  return array;
}

+(NSArray *)stringAttributeIdOrder {
  // ToDo: preferences
  static NSArray *array = nil;
  if (array == nil) {
    array = [[NSArray alloc] initWithObjects:FAHRZEUGART, KRAFTSTOFFART, KAROSSERIEFORM, GETRIEBE, FARBE, POLSTER, MODELL,
             AUSSTATTUNGSMERKMALE, GARANTIE, KONTAKT, nil];
  }
  return array;
}

+(NSArray *)attributeIdOrder {
  // ToDo: preferences
  static NSArray *array = nil;
  if (array == nil) {
    array = [[NSArray alloc] initWithObjects:MODELL, KAUFPREIS, KILOMETERSTAND, ERSTZULASSUNG, FAHRZEUGART, KAROSSERIEFORM, MOTORLEISTUNG,
             HUBRAUM, KRAFTSTOFFART, KRAFTSTOFFVERBRAUCH, CO2_EMISSIONEN, GETRIEBE, FARBE, POLSTER, VORBESITZER, GARANTIE, KONTAKT, AUSSTATTUNGSMERKMALE,
             nil];
  }
  return array;
}

+(int)attributeIdIndex:(NSString *)attributeId {
  // ToDo: preferences
  static NSDictionary *dict = nil;
  if (dict == nil) {
    dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:1],
                                                  [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4],
                                                  [NSNumber numberWithInt:5], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7],
                                                  [NSNumber numberWithInt:8], [NSNumber numberWithInt:9], [NSNumber numberWithInt:10],
                                                  [NSNumber numberWithInt:11], [NSNumber numberWithInt:12], [NSNumber numberWithInt:13],
                                                  [NSNumber numberWithInt:14], [NSNumber numberWithInt:15], [NSNumber numberWithInt:16],
                                                  [NSNumber numberWithInt:17], nil]
                                         forKeys:[NSArray arrayWithObjects:MODELL, KAUFPREIS, KILOMETERSTAND, ERSTZULASSUNG, FAHRZEUGART,
                                                  KAROSSERIEFORM, MOTORLEISTUNG, HUBRAUM, KRAFTSTOFFART, KRAFTSTOFFVERBRAUCH, CO2_EMISSIONEN,
                                                  GETRIEBE, FARBE, POLSTER, VORBESITZER, GARANTIE, KONTAKT, AUSSTATTUNGSMERKMALE,
                                                  nil]];
  }
  NSNumber *n = [dict objectForKey:attributeId];
  return (n != nil)? [n intValue] : 0;
}

+(NSArray *)intAttributeNameOrder {
  NSArray *a = [UsedCar intAttributeIdOrder];
  NSMutableArray *m = [[[NSMutableArray alloc] initWithCapacity:[a count]] autorelease];
  for (NSString *t in a) {
    [m addObject:[UsedCar attributeName:t]];
  }
  return m;
}

+(NSArray *)stringAttributeNameOrder {
  NSArray *a = [UsedCar stringAttributeIdOrder];
  NSMutableArray *m = [[[NSMutableArray alloc] initWithCapacity:[a count]] autorelease];
  for (NSString *t in a) {
    [m addObject:[UsedCar attributeName:t]];
  }
  return m;
}

+(NSString *)convertFileName:(NSString *)gfzNumber {
  return [[gfzNumber stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByReplacingOccurrencesOfString:@"?" withString:@"_"];
}

@end
