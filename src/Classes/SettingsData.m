//
//  SettingsData.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 06.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsData.h"
#import "InAppSetting.h"
#import "PSTitleValueSpecifierCell.h"

@implementation SettingsData

-(id)init {
  properties = nil;
  self = [super init];
  if (self != nil) {
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    NSString *listFile = [[bPath stringByAppendingPathComponent:[SettingsData currentLanguage]] stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary *settingsDictionary =  [NSDictionary dictionaryWithContentsOfFile:listFile];
    NSArray *a = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    NSUInteger l = [a count];
    properties = [[NSMutableDictionary alloc] initWithCapacity:l];
    propertyNames = [[NSMutableDictionary alloc] initWithCapacity:l];
    valueTitles = [[NSMutableDictionary alloc] initWithCapacity:l];
    for (NSUInteger i = 0; i < l; ++i) {
      InAppSetting *setting = [[InAppSetting alloc] initWithDictionary:[a objectAtIndex:i]];
      NSString *key = [setting key];
      if (key != nil) {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        NSNumber *n = [d valueForKey:key];
        if (n == nil) n = [setting defaultValue];
        [properties setObject:n forKey:key];
        [propertyNames setObject:[setting title] forKey:key];
        NSArray *titles = [setting valueForKey:@"Titles"];
        NSArray *values = [setting valueForKey:@"Values"];
        if (titles == nil) titles = values;
        if (values != nil) {
          NSInteger l = [titles count];
          if (l > 0 && l == [values count]) {
            NSInteger i = [n intValue];
            if (i >= 0 && i < l) {
              [valueTitles setObject:[[titles objectAtIndex:i] substringFromIndex:2] forKey:key];
            }
          }
        }
      }
      [setting release];
    }
  }
  return self;
}

+(SettingsData *)getInstance:(BOOL)reload {
  @synchronized([SettingsData class]) {
    static SettingsData *settingsData = nil;
    if (settingsData == nil) {
      settingsData = [[SettingsData alloc] init];
    } else if (reload) {
      [settingsData release];
      settingsData = [[SettingsData alloc] init];
    }
    return settingsData;
  }
}

+(SettingsData *)getInstance {
  return [SettingsData getInstance:NO];
}

-(void)dealloc {
  [properties release];
  [propertyNames release];
  [valueTitles release];
  [super dealloc];
}

-(NSArray *)propertyIdOrder {
  NSMutableArray *m = [[[NSMutableArray alloc] initWithCapacity:[properties count]] autorelease];
  for (NSString *propertyId in properties) {
    int v = [self value:propertyId];
    int j = 0;
    while (j < [m count] && v < [self value:[m objectAtIndex:j]]) ++j;
    [m insertObject:propertyId atIndex:j];
  }
  return m;
}

-(NSArray *)propertyNameOrder {
  NSArray *a = [self propertyIdOrder];
  NSMutableArray *m = [[[NSMutableArray alloc] initWithCapacity:[a count]] autorelease];
  for (NSString *t in a) {
    [m addObject:[propertyNames objectForKey:t]];
  }
  return m;
}

-(int)value:(NSString *)propertyId {
  NSNumber *n = (propertyId == nil)? nil : [properties objectForKey:propertyId];
  return (n == nil)? 0 : [n intValue];
}

-(NSString *)valueTitle:(NSString *)propertyId {
  return [valueTitles objectForKey:propertyId];
}

-(NSString *)propertyId:(NSString *)name {
  NSArray *a = (name == nil)? nil : [propertyNames allKeysForObject:name];
  return (a == nil || [a count] != 1)? nil : [a objectAtIndex:0];
}

-(NSString *)name:(NSString *)propertyId {
  return [propertyNames objectForKey:propertyId];
}

+(NSString *)documentPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

+(NSString *)appVersion {
  return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
}

+(NSString *)currentLanguage {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
  NSString *currentLanguage = ([languages count] == 0)? @"German" : [languages objectAtIndex:0];
  currentLanguage = ([currentLanguage isEqualToString:@"en"] || [currentLanguage isEqualToString:@"English"])? @"English" : @"German";
  NSLog(@"language: %@", currentLanguage);
  return [currentLanguage stringByAppendingString:@".lproj"];
}

@end
