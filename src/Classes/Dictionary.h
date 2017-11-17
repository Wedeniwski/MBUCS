//
//  Dictionary.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IGNORE_TAGS @"Ignorieren"

@interface Dictionary : NSObject {
  NSMutableDictionary *replacements;
  NSMutableDictionary *negReplacements;
  NSMutableDictionary *synonyms;
  NSMutableDictionary *attributeValues;
  NSMutableDictionary *attributeTitles;
  NSMutableDictionary *numericFormats;
  NSMutableDictionary *formulationRules;
  NSMutableDictionary *numericAttributeRules;
}

-(id)init;
+(Dictionary *)getInstance:(BOOL)reload;
+(Dictionary *)getInstance;
-(BOOL)willReplaceToken:(NSString *)token;
-(NSArray *)replaceTokens:(NSArray *)tokens;

@property (readonly, nonatomic) NSDictionary *numericFormats;
@property (readonly, nonatomic) NSDictionary *formulationRules;
@property (readonly, nonatomic) NSDictionary *numericAttributeRules;

@end
