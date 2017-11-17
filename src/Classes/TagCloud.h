//
//  TagCloud.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 04.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include <Foundation/Foundation.h>

@interface TagCloud : NSObject {
}

+(BOOL)tagIncluded:(NSString *)tag inSearchQuery:(NSArray *)searchTextTokens;

// HTML
+(NSString *)create:(int *)tagFrequency tags:(NSArray *)tags allStringAttributeIds:(NSArray *)allStringAttributeIds attributeTypesCount:(int *)attributeTypesCount maxTagsInResult:(int)maxTagsInResult searchText:(NSString *)searchText;
+(NSString *)create:(NSSet *)tags minus:(NSSet *)selectedTags;

@end
