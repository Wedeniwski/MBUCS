//
//  SearchCriteria.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 31.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCarData.h"
#import "IntQuery.h"
#import "DateQuery.h"
#import "StringQuery.h"
#import "Tags.h"

#define DEBUG NO
#define MAX_RECOMMENDATION 100

@protocol SearchCriteriaDelegate
-(BOOL)recommendationResultStillNeeded;
@end

@interface SearchCriteria : NSObject {
  id<SearchCriteriaDelegate> delegate;
  UsedCarData *usedCarData;
  NSString *lastParse;
  NSString *lastModifiedParse;
  NSMutableArray *lastResult;
  NSMutableArray *structuredQueries;
  NSMutableArray *genericTagQuery;
  NSMutableArray *genericTagDistance;
  NSMutableArray *genericUnknownTagQuery;
  NSMutableDictionary *queries;
  Tags *tags;
  //NSMutableDictionary *all3GramTags;
  //NSMutableDictionary *all4GramTags;
  
  // ToDo:umkreis GPS
  // ToDo: beschleunigung, wenn sportlich im profil
  // ToDo: verbrauch, emmission, wenn ekologisch im Profil
  // ToDo: profil abhängig die Modellauswahll anpassen
}

-(id)initWithDelegate:(id<UpdateDelegate, SearchCriteriaDelegate>)owner;
+(BOOL)instanceExist;
+(SearchCriteria *)getInstance:(id<UpdateDelegate, SearchCriteriaDelegate>)owner reload:(BOOL)reload;
+(SearchCriteria *)getInstance:(id<UpdateDelegate, SearchCriteriaDelegate>)owner;
-(void)clear;
-(IntQuery *)intQuery:(NSString *)attributeId;
-(DateQuery *)dateQuery:(NSString *)attributeId;
-(StringQuery *)stringQuery:(NSString *)attributeId;
-(IntQuery *)structuredIntQuery:(NSString *)attributeId;
-(DateQuery *)structuredDateQuery:(NSString *)attributeId;
-(StringQuery *)structuredStringQuery:(NSString *)attributeId;
//-(NSDictionary *)queryAllTags;
//-(NSString *)tagCloudAll;
-(NSString *)tagCloud:(NSString *)freeSearch structured:(NSString *)structuredSearch attributeId:(NSString *)attributeId grouping:(BOOL)grouping maxTagsInResult:(int)maxTagsInResult tmpResultArray:(NSMutableArray *)results;
-(NSString *)toSearchField;
-(BOOL)parse:(NSString *)freeSearch structured:(NSString *)structuredSearch;
-(NSString *)replacement:(NSString *)search allQueries:(NSArray *)allQueries;
-(NSString *)structuredSearchQuery;
-(NSString *)tagSearchQuery;
-(NSString *)unknownTagSearchQuery;
-(IntSet *)associatedSearchTags;
-(void)recommendation:(NSString *)freeSearch structured:(NSString *)structuredSearch maxOfRecommendations:(int)maxOfRec recommendation:(NSMutableArray *)rec;

@property (readonly, nonatomic) id<SearchCriteriaDelegate> delegate;
@property (readonly, nonatomic) UsedCarData *usedCarData;
@property (readonly, nonatomic) NSString *lastParse;
@property (readonly, nonatomic) NSArray *structuredQueries;
@property (readonly, nonatomic) NSArray *genericTagQuery;
@property (readonly, nonatomic) Tags *tags;

@end
