//
//  Dictionary.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Dictionary.h"
#import "InAppSetting.h"
#import "UsedCar.h"

@implementation Dictionary

@synthesize numericFormats, formulationRules, numericAttributeRules;

-(id)init {
  self = [super init];
  if (self != nil) {
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *listFile = [[bPath stringByAppendingPathComponent:[SettingsData currentLanguage]] stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary *settingsDictionary =  [NSDictionary dictionaryWithContentsOfFile:listFile];
    NSArray *a = [settingsDictionary objectForKey:@"Dictionary"];
    NSUInteger l = [a count];
    replacements = [[NSMutableDictionary alloc] initWithCapacity:l];
    negReplacements = [[NSMutableDictionary alloc] initWithCapacity:l];
    synonyms = [[NSMutableDictionary alloc] initWithCapacity:l];
    attributeValues = [[NSMutableDictionary alloc] initWithCapacity:l];
    attributeTitles = [[NSMutableDictionary alloc] initWithCapacity:l];
    numericFormats = [[NSMutableDictionary alloc] initWithCapacity:l];  //ToDo: optimize, l is too large
    formulationRules = [[NSMutableDictionary alloc] initWithCapacity:l];
    numericAttributeRules = [[NSMutableDictionary alloc] initWithCapacity:l];
    NSString *group = nil;
    for (NSUInteger i = 0; i < l; ++i) {
      InAppSetting *setting = [[InAppSetting alloc] initWithDictionary:[a objectAtIndex:i]];
      if ([setting isType:@"PSGroupSpecifier"]) {
        [group release];
        group = [[setting title] retain];
      } else if (group != nil) {
        if ([setting isType:@"PSTitleValueSpecifier"]) {
          if ([group isEqualToString:@"Akronyme"]) {
            NSString *key = [setting key];
            if (key != nil) {
              NSString *v = [setting defaultValue];
              NSString *title = [setting title];
              [replacements setObject:v forKey:title];
              NSString *nv = [setting valueForKey:@"NegValue"];
              if (nv == nil) {
                nv = @"-";
                nv = [nv stringByAppendingString:v];
              }
              [negReplacements setObject:nv forKey:title];
            }
          }
        } else if ([setting isType:@"PSMultiValueSpecifier"]) {
          if ([group isEqualToString:@"Synonyme"]) {
            NSArray *values = [setting valueForKey:@"Values"];
            NSString *title = [setting title];
            for (NSString *t in values) {
              [synonyms setObject:title forKey:t];
            }
          } else if ([group isEqualToString:@"Attribute"]) {
            NSString *title = [setting title];
            [attributeValues setObject:[setting valueForKey:@"Values"] forKey:title];
            [attributeTitles setObject:[setting valueForKey:@"Titles"] forKey:title];
          } else if ([group isEqualToString:@"Numerische Formate"]) {
            NSString *title = [setting title];
            [numericFormats setObject:[setting valueForKey:@"Values"] forKey:title];
          } else if ([group isEqualToString:@"Numerische Attributregeln"]) {
            NSString *title = [setting title];
            [numericAttributeRules setObject:[setting valueForKey:@"Values"] forKey:title];
          } else if ([group isEqualToString:@"Formulierungsregeln"]) {
            NSString *title = [setting title];
            if ([title isEqualToString:IGNORE_TAGS]) {
              [formulationRules setObject:[NSSet setWithArray:[setting valueForKey:@"Values"]] forKey:title];
            } else {
              [formulationRules setObject:[setting valueForKey:@"Values"] forKey:title];
            }
          }
        }
      }
      [setting release];
    }
    [group release];
  }
  return self;
}

+(Dictionary *)getInstance:(BOOL)reload {
  @synchronized([Dictionary class]) {
    static Dictionary *dictionaryData = nil;
    if (dictionaryData == nil) {
      dictionaryData = [[Dictionary alloc] init];
    } else if (reload) {
      [dictionaryData release];
      dictionaryData = [[Dictionary alloc] init];
    }
    return dictionaryData;
  }
}

+(Dictionary *)getInstance {
  return [Dictionary getInstance:NO];
}

-(void)dealloc {
  [replacements release];
  [negReplacements release];
  [synonyms release];
  [attributeValues release];
  [attributeTitles release];
  [numericFormats release];
  [formulationRules release];
  [numericAttributeRules release];
  [super dealloc];
}

-(BOOL)willReplaceToken:(NSString *)token {
  if ([synonyms objectForKey:token] != nil) return YES;
  return ([replacements objectForKey:token] != nil);
}

-(NSArray *)replaceTokens:(NSArray *)tokens {
  if (tokens == nil) return nil;
  BOOL neg = NO;
  NSMutableArray *m = [[[NSMutableArray alloc] initWithCapacity:[tokens count]] autorelease];
  for (NSString *token in tokens) {
    // ToDo: plist
    if ([token isEqualToString:@"nicht"]) {
      neg = YES;
      continue;
    }
    NSString *rep = [synonyms objectForKey:token];
    if (rep != nil) token = rep;
    rep = [replacements objectForKey:token];
    if (rep != nil) {
      token = (neg)? [negReplacements objectForKey:token] : rep;
      neg = NO;
    }
    neg = NO;
    [m addObject:token];
  }
  return m;
}

@end
