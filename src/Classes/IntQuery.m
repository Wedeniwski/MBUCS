//
//  IntQuery.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 03.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IntQuery.h"
#import "SearchCriteria.h"
#import "Dictionary.h"
#import "RegexKitLite.h"
#import "SettingsData.h"
#import "Dictionary.h"

@implementation QueryParser

@synthesize attributeId;
@synthesize indirectThroughReplacement;

-(id)init:(NSString *)aId {
  self = [super init];
  if (self != nil) {
    attributeId = [aId retain];
    indirectThroughReplacement = NO;
  }
  return self;
}

-(id)initWithQueryParser:(QueryParser *)queryParser {
  self = [self init:queryParser.attributeId];
  if (self != nil) {
    indirectThroughReplacement = queryParser.indirectThroughReplacement;
  }
  return self;
}

-(void)dealloc {
  [attributeId release];
  [super dealloc];
}

-(void)clear {
}

-(void)append:(NSMutableString *)string {
}

-(BOOL)parse:(NSString *)token {
  return YES;
}

-(void)setValue:(NSString *)value idx:(int)idx {
}

@end


@implementation IntQuery

@synthesize von, bis, bevorzugt, minWert, maxWert, bester, schlechtester, faktor, indirekterFaktor;
@synthesize regex;

-(id)init:(NSString *)aId minWert:(int)minW maxWert:(int)maxW {
  self = [super init:aId];
  if (self != nil) {
    [self clear];
    minWert = minW;
    maxWert = maxW;
    regex = @"%@|[:\\-;][0-9]+(,[0-9]*)??";
    faktor = 0;
    indirekterFaktor = NO;
  }
  return self;
}

-(id)initWithIntQuery:(IntQuery *)intQuery {
  self = [super initWithQueryParser:intQuery];
  if (self != nil) {
    von = intQuery.von;
    bis = intQuery.bis;
    bevorzugt = intQuery.bevorzugt;
    bester = intQuery.bester;
    schlechtester = intQuery.schlechtester;
    faktor = intQuery.faktor;
    indirekterFaktor = intQuery.indirekterFaktor;
    regex = intQuery.regex;
  }
  return self;
}

-(void)dealloc {
  [regex release];
  [super dealloc];
}

-(void)clear {
  [super clear];
  von = bis = bevorzugt = bester = schlechtester = faktor = 0;
  indirekterFaktor = NO;
}

-(BOOL)hasQuery {
  return (von > 0 || bis > 0 || bevorzugt > 0);
}

-(void)setupFactor {
  Dictionary *dictionary = [Dictionary getInstance];
  __block int maxFactor = 0;
  __block int minFactor = 5;  // ToDo: not fix
  __block NSString *numericRule = nil;
  __block NSString *identifier = [NSString stringWithFormat:@"%@:", attributeId];
  [dictionary.numericAttributeRules enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
    NSArray *rules = object;
    for (NSString *rule in rules) {
      //NSLog(@"rule: %@  id: %@", rule, identifier);
      if ([rule hasPrefix:identifier]) {
        NSString *preferenceName = key;
        SettingsData *settings = [SettingsData getInstance];
        NSString *preferenceId = [settings propertyId:preferenceName];
        if (preferenceId != nil) {
          int i = [settings value:preferenceId];
          //NSLog(@"name: %@  id: %@  value: %d", preferenceName, preferenceId, i);
          if (i > maxFactor) {
            [numericRule release];
            numericRule = [rule retain];
            maxFactor = i;
          }
          if (i < minFactor) minFactor = i;
          if (i == maxFactor && numericRule != nil && ![numericRule isEqualToString:rule]) {
            maxFactor = minFactor = 0;
            [numericRule release];
            numericRule = nil;
            break;  // ToDo: maybe not correct if one rule is associated to more than 2 attributes
          }
        }
      }
    }
  }];
  if (numericRule != nil && minFactor > 1 && maxFactor-minFactor < 5 && von == 0 && bis == 0 && bevorzugt == 0) {
    NSLog(@"IntQuery factor %d-%d  parse %@", minFactor, maxFactor, numericRule);
    [self parse:numericRule];
    [numericRule release];
    indirekterFaktor = YES;
  }
  faktor = (maxFactor == minFactor)? maxFactor : maxFactor-minFactor;
}

-(NSString *)format:(int)value {
  NSString *attributeName = [UsedCar attributeName:attributeId];
  Dictionary *dictionary = [Dictionary getInstance];
  NSArray *formats = [dictionary.numericFormats objectForKey:attributeName];
  if (formats != nil) {
    int l = [formats count];
    if (l == 1) {
      // ToDo: configure
      if ([attributeId isEqualToString:MOTORLEISTUNG]) return [NSString stringWithFormat:[formats objectAtIndex:0], (int)(value/1.3636363636), value];
      if ([attributeId isEqualToString:KRAFTSTOFFVERBRAUCH]) return [NSString stringWithFormat:[formats objectAtIndex:0], value/10.0];
      return [NSString stringWithFormat:[formats objectAtIndex:0], value];
    } else if (l == 2) {
      if (value >= 1000) {
        return [NSString stringWithFormat:[formats objectAtIndex:0], (value/1000), (value%1000)];
      } else {
        return [NSString stringWithFormat:[formats objectAtIndex:1], value];
      }
    }
  }
  return [NSString stringWithFormat:@"%d", value];
}

-(void)append:(NSMutableString *)string {
  if (bis > 0) {
    [string appendFormat:@"%@:%d-%d;%d// ", attributeId, von, bis, bevorzugt];
  } else if (bevorzugt > 0) {
    [string appendFormat:@"%@:%d// ", attributeId, bevorzugt];
  }
}

-(int)convertToInt:(NSString *)name {
  return [name intValue];
}

-(BOOL)parse:(NSString *)token {
  if ([token length]-1 <= [attributeId length]) return NO;
  // ToDo: check for '-<attributerId>:'
  NSString *billig = [NSString stringWithFormat:@"%@:-", attributeId];  // ToDo: in regex integrieren
  if ([billig isEqualToString:token]) {
    von = bis = 0;
    bevorzugt = minWert;
    faktor = 5;
    indirekterFaktor = NO;
    return YES;
  }
  NSString *teuer = [NSString stringWithFormat:@"%@:+", attributeId];  // ToDo: in regex integrieren
  if ([teuer isEqualToString:token]) {
    von = bis = 0;
    bevorzugt = maxWert;
    faktor = 5;
    indirekterFaktor = NO;
    return YES;
  }
  NSArray *matchArray = [token componentsMatchedByRegex:regex];
  if (matchArray == nil || [matchArray count] < 2 || ![attributeId isEqualToString:[matchArray objectAtIndex:0]]) return NO;
  int l = [matchArray count];
  if (l == 2) {
    NSString *value = [matchArray objectAtIndex:1];
    if ([value length] >= 2 && [value hasPrefix:@":"]) {
      bevorzugt = [self convertToInt:[value substringFromIndex:1]];
      von = bis = 0;
      faktor = 5;
      indirekterFaktor = NO;
      return YES;
    }
  } else if (l >= 3) {
    von = bis = bevorzugt = 0;
    NSString *value = [matchArray objectAtIndex:1];
    if ([value length] >= 2 && [value hasPrefix:@":"]) {
      von = [self convertToInt:[value substringFromIndex:1]];
    }
    value = [matchArray objectAtIndex:2];
    if ([value length] >= 2 && [value hasPrefix:@"-"]) {
      bis = [self convertToInt:[value substringFromIndex:1]];
    }
    if (l > 3) {
      value = [matchArray objectAtIndex:3];
      if ([value length] >= 2 && [value hasPrefix:@";"]) {
        bevorzugt = [self convertToInt:[value substringFromIndex:1]];
      }
    }
    if (bevorzugt == bis && bevorzugt == von) von = bis = 0;
    if (bevorzugt > 0 || bis > 0 || von > 0) {
      faktor = 5;
      indirekterFaktor = NO;
      return YES;
    }
  }
  return FALSE;
}

-(void)setValue:(NSString *)value idx:(int)idx {
  if (value != nil) {
    // ToDo: only valid for Germany!
    value = [value stringByReplacingOccurrencesOfString:@"." withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@"," withString:@"."];
    if (idx == 0) {
      von = [value intValue];
      if (bis < von) bis = maxWert;
      if (bevorzugt > 0 && bevorzugt < von) bevorzugt = von;
    } else if (idx == 1) {
      bis = [value intValue];
      if (von > bis) von = minWert;
      if (bevorzugt > bis) bevorzugt = bis;
    } else if (idx == 2) {
      bevorzugt = [value intValue];
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
