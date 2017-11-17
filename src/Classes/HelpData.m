//
//  HelpData.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpData.h"
#import "SettingsData.h"

@implementation HelpData

@synthesize languagePath;
@synthesize keys;
@synthesize pages, titles;

-(void)parseData:(NSString *)data {
  NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:20];
  NSMutableDictionary *p = [[NSMutableDictionary alloc] initWithCapacity:20];
  NSMutableDictionary *ttls = [[NSMutableDictionary alloc] initWithCapacity:20];
  if (data != nil) {
    NSArray *sections = [data componentsSeparatedByString:@"<h1><a name=\""];
    for (NSString *pgs in sections) {
      NSArray *a = [pgs componentsSeparatedByString:@"</a></h1>"];
      if ([a count] == 2) {
        NSArray *b = [[a objectAtIndex:0] componentsSeparatedByString:@"\">"];
        if ([b count] == 2) {
          NSString *key = [b objectAtIndex:0];
          [array addObject:key];
          [ttls setObject:[b objectAtIndex:1] forKey:key];
          [p setObject:[a objectAtIndex:1] forKey:key];
        }
      }
    }
  }
  keys = array;
  pages = p;
  titles = ttls;
}

-(id)init {
  self = [super init];
  if (self != nil) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *bPath = [[NSBundle mainBundle] bundlePath];
    languagePath = [[SettingsData currentLanguage] retain];
    NSString *filePath = [[bPath stringByAppendingPathComponent:languagePath] stringByAppendingPathComponent:@"tutorial.txt"];
    NSString *data = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self parseData:data];
    [data release];
    [pool release];
  }
  return self;
}

-(id)initWithContent:(NSString *)data {
  self = [super init];
  if (self != nil) {
    languagePath = [[SettingsData currentLanguage] retain];
    [self parseData:data];
  }
  return self;
}

-(void)dealloc {
  [languagePath release];
  languagePath = nil;
  [keys release];
  keys = nil;
  [pages release];
  pages = nil;
  [titles release];
  titles = nil;
  [super dealloc];
}

+(HelpData *)getHelpData {
  static HelpData *helpData = nil;
  @synchronized([HelpData class]) {
    if (helpData == nil) {
      helpData = [[HelpData alloc] init];
    } else {
      if (![helpData.languagePath isEqualToString:[SettingsData currentLanguage]]) {
        [helpData release];
        helpData = [[HelpData alloc] init];
      }
    }
  }
  return helpData;
}

@end
