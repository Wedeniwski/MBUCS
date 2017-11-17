//
//  Tags.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntSet.h"
#import "TagCluster.h"

@interface Tags : NSObject {
@private
  // ToDo: include and exclude list?
  // ToDo: personal preferences
  NSMutableSet *ignoreTags;
  NSMutableDictionary *attributeTags;
  //NSMutableDictionary *categoryTags;
  NSMutableArray *allTags;
  NSMutableDictionary *allTagsStartsWith;
  NSMutableDictionary *validTagsList;
  NSMutableArray *dendrogramOfTags;  // array of TagCluster
}

-(float)getDistanceGram:(int)n source:(const char *)source target:(const char *)target;
-(NSString *)closestTag:(NSString *)tag;
+(NSString *)removingAccents:(NSString *)text;
+(NSString *)removingSpaces:(NSString *)text;
+(NSString *)simplifyToken:(NSString *)token;
+(NSArray *)separateNumber:(NSString *)token;
//+(NSString *)removeSimpleXMLTags:(NSString *)token;
//-(NSSet *)internalValidTags:(NSString *)token;
-(IntSet *)validTags:(NSString *)token;
//-(IntSet *)convertTagsToIds:(NSSet *)tags;
-(int)convertTagToId:(NSString *)tag;
-(NSSet *)tagNamesInArray:(NSArray *)tags;
-(NSSet *)tagNames:(IntSet *)tags;
-(id)init;
//-(void)reset:(BOOL)loadData;
//-(void)save;
-(int)factor:(NSString *)tag;  // Faktor Vorlieben für Tags aus Zuordnung
-(void)addTagCluster:(TagCluster *)cluster;
//-(BOOL)match:(NSString *)name categoryId:(NSString *)categoryId;
-(void)setupAllTags;
-(void)addAttributeTags:(NSSet *)tags attributeId:(NSString *)attributeId;
-(NSSet *)attributeTags:(NSString *)attributeId;
-(NSSet *)propertyTags:(NSString *)propertyId clusterLevel:(int)level;
-(void)addAttribute:(NSString *)tag attributeTag:(NSString *)attributeId;
-(void)addPropertyTag:(NSString *)tag propertyId:(NSString *)propertyId;
-(void)removeAttribute:(NSString *)tag attributeTag:(NSString *)attributeId;
-(void)removeProperyTag:(NSString *)tag propertyId:(NSString *)propertyId;
-(void)minusSetAttribute:(NSSet *)set attributeTag:(NSString *)attributeId;
-(void)minusProperyTags:(NSSet *)tags propertyId:(NSString *)propertyId;
-(NSString *)toString;

@property (readonly, nonatomic) NSMutableSet *ignoreTags;
@property (readonly, nonatomic) NSArray *allTags;
@property (readonly, nonatomic) NSMutableDictionary *validTagsList;

@end
