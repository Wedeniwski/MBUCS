//
//  InAppSetting.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InAppSetting.h"

@implementation InAppSetting

-(NSString *)getType {
  return [self valueForKey:@"Type"];
}

-(BOOL)isType:(NSString *)type {
  return [[self getType] isEqualToString:type];
}

-(id)valueForKey:(NSString *)key {
  return [settingDictionary objectForKey:key];
}

-(NSString *)cellName {
  return [NSString stringWithFormat:@"%@Cell", [self getType]];
}

-(NSString *)title {
  return [self valueForKey:@"Title"];
}

-(NSString *)key {
  return [self valueForKey:@"Key"];
}

-(id)defaultValue {
  return [self valueForKey:@"DefaultValue"];
}

-(BOOL)isTrueValue:(NSString *)value {
  return [value isEqualToString:[self valueForKey:@"TrueValue"]];
}

-(BOOL)isFalseValue:(NSString *)value {
  return [value isEqualToString:[self valueForKey:@"FalseValue"]];
}

#pragma mark validation

-(BOOL)hasTitle {
  return ([self valueForKey:@"Title"] != nil);
}

-(BOOL)hasKey {
  NSString *key = [self valueForKey:@"Key"];
  return (key != nil && ![key isEqualToString:@""]);
}

-(BOOL)hasDefaultValue {
  return ([self valueForKey:@"DefaultValue"] != nil);
}

#pragma mark init/dealloc

-(id)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self != nil) {
    if (dictionary) {
      settingDictionary = [dictionary retain];
    }
  }
  return self;
}

-(void)dealloc {
  [settingDictionary release];
  settingDictionary = nil;
  [super dealloc];
}

@end
