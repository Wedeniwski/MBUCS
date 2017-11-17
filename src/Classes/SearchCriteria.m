//
//  SearchCriteria.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 31.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchCriteria.h"
#import "SettingsData.h"
#import "UsedCar.h"
#import "StringAttribute.h"
#import "TagCloud.h"
#import "Dictionary.h"
#import "Bookmarks.h"
#import "RegexKitLite.h"

@implementation SearchCriteria

@synthesize delegate;
@synthesize usedCarData;
@synthesize lastParse;
@synthesize structuredQueries, genericTagQuery;
@synthesize tags;

-(id)initWithDelegate:(id<UpdateDelegate, SearchCriteriaDelegate>)owner {
  self = [super init];
  if (self != nil) {
    delegate = owner;
    usedCarData = [[UsedCarData alloc] initWithDelegate:owner];
    tags = [usedCarData.tags retain];
    //all3GramTags = [[self createGramTags:3] retain];
    //all4GramTags = [[self createGramTags:4] retain];
    structuredQueries = [[NSMutableArray alloc] initWithCapacity:20];
    genericTagQuery = [[NSMutableArray alloc] initWithCapacity:20];
    genericTagDistance = [[NSMutableArray alloc] initWithCapacity:20];
    genericUnknownTagQuery = [[NSMutableArray alloc] initWithCapacity:20];
    queries = [[NSMutableDictionary alloc] initWithCapacity:20];
    UsedCar *minValue = usedCarData.minValuesAttributes;
    UsedCar *maxValue = usedCarData.maxValuesAttributes;
    NSArray *a = [UsedCar attributeIdOrder];
    for (NSString *attributeId in a) {
      if ([UsedCar isStringAttribute:attributeId] || [UsedCar isStringSetAttribute:attributeId]) {
        StringQuery *stringQuery = [[StringQuery alloc] init:attributeId];
        [queries setObject:stringQuery forKey:attributeId];
        [stringQuery release];
      } else if ([UsedCar isIntAttribute:attributeId]) {
        IntQuery *intQuery = [[IntQuery alloc] init:attributeId minWert:[minValue attribute:attributeId] maxWert:[maxValue attribute:attributeId]];
        [queries setObject:intQuery forKey:attributeId];
        [intQuery release];
      } else if ([UsedCar isDateAttribute:attributeId]) {
        //NSLog(@"date %@  min %d  max %d", attributeId, [minValue attribute:attributeId], [maxValue attribute:attributeId]);
        DateQuery *dateQuery = [[DateQuery alloc] init:attributeId minWert:[minValue attribute:attributeId] maxWert:[maxValue attribute:attributeId]];
        [queries setObject:dateQuery forKey:attributeId];
        [dateQuery release];
      }
    }
    lastParse = nil;
    lastModifiedParse = nil;
    lastResult = [[NSMutableArray alloc] initWithCapacity:MAX_RECOMMENDATION];
    [self clear];
  }
  return self;
}

static SearchCriteria *searchCriteria = nil;
+(BOOL)instanceExist {
  return (searchCriteria != nil);
}

-(void)setDelegate:(id<SearchCriteriaDelegate>)owner {
  delegate = owner;
}

+(SearchCriteria *)getInstance:(id<UpdateDelegate, SearchCriteriaDelegate>)owner reload:(BOOL)reload {
  @synchronized([SearchCriteria class]) {
    if (searchCriteria == nil) {
      searchCriteria = [[SearchCriteria alloc] initWithDelegate:owner];
    } else if (reload) {
      [searchCriteria release];
      searchCriteria = [[SearchCriteria alloc] initWithDelegate:owner];
    }
    if (owner != nil) searchCriteria.delegate = owner;
    return searchCriteria;
  }
}

+(SearchCriteria *)getInstance:(id<UpdateDelegate, SearchCriteriaDelegate>)owner {
  return [SearchCriteria getInstance:owner reload:NO];
}

-(void)dealloc {
  [self clear];
  [tags release];
  //[all3GramTags release];
  //[all4GramTags release];
  [usedCarData release];
  [structuredQueries release];
  [genericTagQuery release];
  [genericTagDistance release];
  [genericUnknownTagQuery release];
  [queries release];
  [lastParse release];
  [lastModifiedParse release];
  [lastResult release];
  [super dealloc];
}

/*-(NSMutableDictionary *)createGramTags:(int)nGram {
  int n = [tags.allTags count];
  NSMutableDictionary *gram = [[[NSMutableDictionary alloc] initWithCapacity:5*n] autorelease];
  for (NSString *tag in tags.allTags) {
    for (int i = [tag length]-nGram; i >= 0; --i) {
      NSRange range = NSMakeRange(i, nGram);
      NSString *key = [tag substringWithRange:range];
      id object = [gram objectForKey:key];
      if (object == nil) {
        [gram setObject:tag forKey:key];
      } else if ([object isKindOfClass:[NSString class]]) {
        if (![tag isEqualToString:object]) {
          NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:4];
          [set addObject:object];
          [set addObject:tag];
          [gram setObject:set forKey:key];
          [set release];
        }
      } else if ([object isKindOfClass:[NSMutableSet class]]) {
        NSMutableSet *set = object;
        [set addObject:tag];
      } else {
        NSLog(@"Wrong error in gram dictionary")
      }
    }
  }
  return gram;
}*/

-(void)clear {
  NSLog(@"Clear queries");
  NSArray *a = [queries allValues];
  for (id q in a) {
    [q clear];
  }
  [lastParse release];
  lastParse = @"";
  [lastModifiedParse release];
  lastModifiedParse = @"";
  [lastResult removeAllObjects];
  [structuredQueries removeAllObjects];
  [genericTagQuery removeAllObjects];
  [genericTagDistance removeAllObjects];
  [genericUnknownTagQuery removeAllObjects];
}

-(IntQuery *)intQuery:(NSString *)attributeId {
  id query = [queries objectForKey:attributeId];
  return ([UsedCar isIntAttribute:attributeId])? query : nil;
}

-(DateQuery *)dateQuery:(NSString *)attributeId {
  id query = [queries objectForKey:attributeId];
  return ([UsedCar isDateAttribute:attributeId])? query : nil;
}

-(StringQuery *)stringQuery:(NSString *)attributeId {
  id query = [queries objectForKey:attributeId];
  return ([UsedCar isStringAttribute:attributeId] || [UsedCar isStringSetAttribute:attributeId])? query : nil;
}

-(IntQuery *)structuredIntQuery:(NSString *)attributeId {
  for (QueryParser *query in structuredQueries) {
    if ([query isKindOfClass:[IntQuery class]] && [query.attributeId isEqualToString:attributeId]) {
      return (IntQuery *)query;
    }
  }
  return [self intQuery:attributeId];
}

-(DateQuery *)structuredDateQuery:(NSString *)attributeId {
  for (QueryParser *query in structuredQueries) {
    if ([query isKindOfClass:[DateQuery class]] && [query.attributeId isEqualToString:attributeId]) {
      return (DateQuery *)query;
    }
  }
  return [self dateQuery:attributeId];
}

-(StringQuery *)structuredStringQuery:(NSString *)attributeId {
  for (QueryParser *query in structuredQueries) {
    if ([query isKindOfClass:[StringQuery class]] && [query.attributeId isEqualToString:attributeId]) {
      return (StringQuery *)query;
    }
  }
  return [self stringQuery:attributeId];
}


//-(NSDictionary *)queryAllTags {
  /*NSMutableArray *gram4 = nil;
  NSMutableArray *gram3 = nil;
  int l = [token length];
  if (l > 4) {
    gram4 = [[NSMutableArray alloc] initWithCapacity:l-3];
    for (int i = l-4; i >= 0; --i) {
      NSRange range = NSMakeRange(i, 4);
      [gram4 addObject:[token substringWithRange:range]];
    }
  }
  if (l > 3) {
    gram3 = [[NSMutableArray alloc] initWithCapacity:l-2];
    for (int i = l-3; i >= 0; --i) {
      NSRange range = NSMakeRange(i, 3);
      [gram3 addObject:[token substringWithRange:range]];
    }
  }
  // closest tag cluster
  [gram4 release];
  [gram3 release];*/
  /*NSMutableDictionary *allTags = [[[NSMutableDictionary alloc] initWithCapacity:[genericTagQuery count]] autorelease];
  int l = [tags.allTags count];
  for (NSString *tag in genericTagQuery) {
    IntSet *tagMatch = [[IntSet alloc] initWithCapacity:5];
    int j = [tag length];
    for (int i = 0; i < l; ++i) {
      NSString *t = [tags.allTags objectAtIndex:i];
      int k = [t length];
      if (j < k) {  // ToDo: n-gram search
        
        if ([t hasPrefix:@"mercedes_benz_"]) continue;  // ToDo: not FIX!
        if (j == 3) {
          if ([t hasPrefix:tag] || [t hasSuffix:tag]) {
            [tagMatch add:i];
          }
        } else if (j > 3) {
          NSRange r = [t rangeOfString:tag];
          if (r.length > 0) {
            [tagMatch add:i];
          }
        }
      } else if (j > k) {
        if ([t hasPrefix:@"mercedes_benz_"]) continue;  // ToDo: not FIX!
        NSRange r = [tag rangeOfString:t];
        if (r.length > 0) {
          [tagMatch add:i];
        }
      } else if ([tag isEqualToString:t]) { // known tags
        [tagMatch add:i];
      }
    }
    [allTags setObject:tagMatch forKey:tag];
    [tagMatch release];
  }
  return allTags;
}*/

/*-(NSString *)tagCloudAll {
  StringAttribute *a = [usedCarData.attributeIndex objectForKey:AUSSTATTUNGSMERKMALE]; // ToDo: ?? Nur ausstattungsmerkmale ??
  int l = [a.types count];
  int *tagFrequency = malloc(sizeof(int)*l);
  memset(tagFrequency, 0, sizeof(int)*l);
  int n = [a indexCount];
  for (int i = 0; i < n; ++i) {
    int j = [a atIndex:i];
    if (j >= 0) ++tagFrequency[j];
  }
  NSString *t = [TagCloud create:tagFrequency tags:a.types maxTagsInResult:60];
  free(tagFrequency);
  return [NSString stringWithString:t];
}*/

-(NSString *)tagCloud:(NSString *)freeSearch structured:(NSString *)structuredSearch attributeId:(NSString *)attributeId grouping:(BOOL)grouping maxTagsInResult:(int)maxTagsInResult tmpResultArray:(NSMutableArray *)rec {
  NSString *result = nil;
  int n = [usedCarData count];
  [self recommendation:freeSearch structured:structuredSearch maxOfRecommendations:n recommendation:rec];
  if ([rec count] == 0) return @"";
  if (attributeId == nil) {
    NSMutableArray *allStringAttributeIds = [[NSMutableArray alloc] initWithArray:[usedCarData.attributeIndex allKeys]];
    [allStringAttributeIds removeObject:KONTAKT];
    [allStringAttributeIds removeObject:AUSSTATTUNGSMERKMALE];
    [allStringAttributeIds removeObject:MODELL];
    [allStringAttributeIds addObject:AUSSTATTUNGSMERKMALE];
    [allStringAttributeIds addObject:MODELL];
    int *attributeTypesCount = malloc(sizeof(int)*[allStringAttributeIds count]);
    int l = 0;
    int i = 0;
    NSMutableArray *allAttributeTypes = [[NSMutableArray alloc] initWithCapacity:3000];
    for (NSString *aId in allStringAttributeIds) {
      StringAttribute *attribute = [usedCarData.attributeIndex objectForKey:aId];
      l += attributeTypesCount[i] = [attribute.types count];
      [allAttributeTypes addObjectsFromArray:attribute.types];
      ++i;
    }
    int *tagFrequency = malloc(sizeof(int)*l);
    memset(tagFrequency, 0, sizeof(int)*l);
    int j = 0;
    int k = 0;
    for (NSString *aId in allStringAttributeIds) {
      IntSet *set = [[rec objectAtIndex:0] stringIdSetAttribute:aId];
      if (set == nil) {
        for (UsedCar *u in rec) {
          int i = [u attribute:aId];
          if (i >= 0) tagFrequency[i+j] += (int)(u.preferenceFit*3);
        }
      } else {
        for (UsedCar *u in rec) {
          set = [u stringIdSetAttribute:aId];
          int l = set.size;
          int f = (int)(u.preferenceFit*4);
          for (int i = 0; i < l; ++i) {
            tagFrequency[[set valueAt:i]+j] += f;
          }
        }
      }
      j += attributeTypesCount[k];
      ++k;
    }
    result = [TagCloud create:tagFrequency tags:allAttributeTypes allStringAttributeIds:(grouping)? allStringAttributeIds : nil attributeTypesCount:(grouping)? attributeTypesCount : NULL maxTagsInResult:maxTagsInResult searchText:freeSearch];
    free(attributeTypesCount);
    [allAttributeTypes release];
    free(tagFrequency);
    [allStringAttributeIds release];
  } else {
    StringAttribute *attribute = [usedCarData.attributeIndex objectForKey:attributeId];
    int l = [attribute.types count];
    int *tagFrequency = malloc(sizeof(int)*l);
    StringQuery *stringQuery = [self stringQuery:attributeId];
    // Gewichtungsfunktion für Tag Anzeige beim Suchen: <Faktor Vorlieben für Tags aus Zuordnung>^2*<Tag Häufigkeit in Empfehlungen>
    int r = [rec count];
    if (r == n || r == 0) {
      for (int i = 0; i < l; ++i) {
        tagFrequency[i] = ([stringQuery contains:i])? -1 : [attribute frequencyAll:i];
      }
    } else {
      memset(tagFrequency, 0, sizeof(int)*l);
      IntSet *set = [[rec objectAtIndex:0] stringIdSetAttribute:attributeId];
      if (set == nil) {
        for (UsedCar *u in rec) {
          //int i = [UsedCarData stringArraySearch:[u stringAttribute:attributeId] array:attribute.types];
          int i = [u attribute:attributeId];
          if (i >= 0) tagFrequency[i] += (int)(u.preferenceFit*4);
        }
      } else {
        for (UsedCar *u in rec) {
          set = [u stringIdSetAttribute:attributeId];
          int l = set.size;
          int f = (int)(u.preferenceFit*3);
          for (int i = 0; i < l; ++i) {
            tagFrequency[[set valueAt:i]] += f;
          }
        }
      }
      for (int i = 0; i < l; ++i) {
        if ([stringQuery contains:i]) {
          tagFrequency[i] = -1;
        }
      }
    }
    /*ToDo:for (int i = 0; i < l; ++i) {
     NSString *t = [attribute.types objectAtIndex:i];
     int f = [tags factor:t]+1;
     tagFrequency[i] *= f*f;
     }*/
    result = [TagCloud create:tagFrequency tags:attribute.types allStringAttributeIds:nil attributeTypesCount:NULL maxTagsInResult:maxTagsInResult searchText:freeSearch];
    free(tagFrequency);
  }
  return result;//[NSString stringWithString:result];
}

-(NSString *)toSearchField {
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:500] autorelease];
  NSArray *a = [queries allValues];
  for (QueryParser *query in a) {
    [query append:s];
  }
  BOOL first = YES;
  for (NSString *t in genericTagQuery) {
    if (!first) [s appendString:@" "];
    [s appendString:t];
    first = NO;
  }
  // ToDo:umkreis GPS
  // ToDo: beschleunigung, wenn sportlich im profil
  // ToDo: profil abhängig die Modellauswahll anpassen
  return s;
}

-(BOOL)parse:(NSString *)freeSearch structured:(NSString *)structuredSearch {
  NSString *searchField = [NSString stringWithFormat:@"%@ %@", freeSearch, structuredSearch];
  if (lastModifiedParse != nil && [lastModifiedParse isEqualToString:searchField]) return NO;
  [lastModifiedParse release];
  lastModifiedParse = [searchField retain];
  [structuredQueries removeAllObjects];
  [genericTagQuery removeAllObjects];
  [genericTagDistance removeAllObjects];
  [genericUnknownTagQuery removeAllObjects];
  NSArray *allQueryParsers = [queries allValues];
  NSRange range = [structuredSearch rangeOfString:@" "];
  NSArray *tokens = (range.length == 0)? [NSArray arrayWithObject:structuredSearch] : [structuredSearch componentsSeparatedByString:@" "];
  int l = [tokens count];
  for (int i = 0; i < l; ++i) {
    NSString *token = [tokens objectAtIndex:i];
    for (QueryParser *query in allQueryParsers) {
      if ([query parse:token]) {
        /*if ([query isKindOfClass:[StringQuery class]]) {
          StringQuery *sq = (StringQuery *)query;
          NSSet *s = [tags tagNames:sq.values];
          for (NSString *tag in s) {
            [genericTagQuery addObject:tag];
            [genericTagDistance addObject:[NSNumber numberWithFloat:1.0]];
          }
        }*/
        break;
      } else if (i+1 < l && [query.attributeId isEqualToString:token]) {
        NSString *s = [NSString stringWithFormat:@"%@ %@", token, [tokens objectAtIndex:i+1]];
        if ([query parse:s]) {
          ++i;
          break;
        }
      }
    }
  }
  range = [freeSearch rangeOfString:@" "];
  tokens = (range.length == 0)? [NSArray arrayWithObject:freeSearch] : [freeSearch componentsSeparatedByString:@" "];
  l = [tokens count];
  for (int i = 0; i < l; ++i) {
    NSString *token = [tokens objectAtIndex:i];
    for (QueryParser *query in allQueryParsers) {
      if ([query parse:token] || i == l-1 && [query.attributeId isEqualToString:token]) {
        /*if ([query isKindOfClass:[StringQuery class]]) {
          StringQuery *sq = (StringQuery *)query;
          NSSet *s = [tags tagNames:sq.values];
          for (NSString *tag in s) {
            [genericTagQuery addObject:tag];
            [genericTagDistance addObject:[NSNumber numberWithFloat:1.0]];
          }
        }*/
        token = nil;
        break;
      } else if (i+1 < l && [query.attributeId isEqualToString:token]) {
        NSString *s = [NSString stringWithFormat:@"%@ %@", token, [tokens objectAtIndex:i+1]];
        if ([query parse:s]) {
          ++i;
          token = nil;
          break;
        }
      }
    }
    if (token != nil) {
      NSString *tag = [tags closestTag:token];
      if (tag != nil) {
        if ([genericTagQuery indexOfObject:tag] == NSNotFound) {
          [genericTagQuery addObject:tag];
          [genericTagDistance addObject:[NSNumber numberWithFloat:[tags getDistanceGram:2 source:[token UTF8String] target:[tag UTF8String]]]];
        }
        token = nil;
      } else {
        NSRange range = [token rangeOfString:@"-"];
        if (range.length > 0) {
          Dictionary *dictionary = [Dictionary getInstance];
          NSArray *tagsInToken = [dictionary replaceTokens:[token componentsSeparatedByString:@"-"]];
          for (tag in tagsInToken) {
            NSString *closestTag = [tags closestTag:tag];
            if (closestTag != nil) {
              if ([genericTagQuery indexOfObject:closestTag] == NSNotFound) {
                [genericTagQuery addObject:closestTag];
                [genericTagDistance addObject:[NSNumber numberWithFloat:[tags getDistanceGram:2 source:[tag UTF8String] target:[closestTag UTF8String]]]];
                token = nil;
              }
            }
          }
        }
      }
    }
    if (token != nil) {
      NSArray *separatedTags = [Tags separateNumber:token];
      if (separatedTags != nil && [separatedTags count] == 2) {
        Dictionary *dictionary = [Dictionary getInstance];
        separatedTags = [dictionary replaceTokens:separatedTags];
        if ([separatedTags count] == 2) {
          NSString *tag1 = [tags closestTag:[separatedTags objectAtIndex:0]];
          NSString *tag2 = [tags closestTag:[separatedTags objectAtIndex:1]];
          if (tag1 != nil && tag2 != nil) {
            [genericTagQuery addObject:tag1];
            [genericTagDistance addObject:[NSNumber numberWithFloat:[tags getDistanceGram:2 source:[[separatedTags objectAtIndex:0] UTF8String] target:[tag1 UTF8String]]]];
            [genericTagQuery addObject:tag2];
            [genericTagDistance addObject:[NSNumber numberWithFloat:[tags getDistanceGram:2 source:[[separatedTags objectAtIndex:1] UTF8String] target:[tag2 UTF8String]]]];
            token = nil;
          }
        }
      }
    }
    if (token != nil) {
      token = [token stringByReplacingOccurrencesOfRegex:@"[>=< .]*" withString:@""];
      if (i+1 < l) {
        NSString *token2 = [tokens objectAtIndex:i+1];
        NSString *tag2 = [tags closestTag:token2];
        if (tag2 != nil) {
          NSString *token3 = [NSString stringWithFormat:@"%@-%@", token, token2];
          NSString *tag3 = [tags closestTag:token3];
          if (tag3 != nil) {
            float f2 = [tags getDistanceGram:2 source:[token2 UTF8String] target:[tag2 UTF8String]];
            float f3 = [tags getDistanceGram:2 source:[token3 UTF8String] target:[tag3 UTF8String]];
            if (f3 > f2 || f2 == f3 && f2 == 1.0f) {
              [genericTagQuery addObject:tag3];
              [genericTagDistance addObject:[NSNumber numberWithFloat:f3]];
              ++i;
              token = nil;
            }
          }
        }
      }
    }
    if (token != nil && [token length] > 0 && [genericUnknownTagQuery indexOfObject:token] == NSNotFound) {
      [genericUnknownTagQuery addObject:token];
    }
  }
  return YES;
}

-(NSString *)replacement:(NSString *)search allQueries:(NSArray *)allQueries {
  // Ersetzungs- & Formulierungsregeln
  NSArray *tokens = [search componentsSeparatedByRegex:@"\\s+"];
  BOOL tokensToReplace = NO;
  Dictionary *dictionary = [Dictionary getInstance];
  for (NSString *token in tokens) {
    token = [Tags simplifyToken:token];
    if (token != nil) {
      if (!tokensToReplace && [dictionary willReplaceToken:token]) tokensToReplace = YES;
    }
  }
  if (tokensToReplace) tokens = [dictionary replaceTokens:tokens];
  tokensToReplace = NO;
  NSMutableString *replacedSearch = [[[NSMutableString alloc] initWithCapacity:[search length]] autorelease];
  for (NSString *token in tokens) {
    if (tokensToReplace) [replacedSearch appendString:@" "];
    [replacedSearch appendString:token];
    tokensToReplace = YES;
  }
  search = [replacedSearch stringByAppendingString:@" ."];
  for (QueryParser *query in allQueries) {
    if ([query isKindOfClass:[IntQuery class]]) { // do not replace structured queries
      IntQuery *intQuery = (IntQuery *)query;
      if (!intQuery.indirekterFaktor && (intQuery.von > 0 || intQuery.bis > 0 || intQuery.bevorzugt > 0)) continue;
    }
    NSString *attributeId = query.attributeId;
    NSArray *rules = [dictionary.formulationRules objectForKey:[UsedCar attributeName:attributeId]];
    if (rules != nil && [rules count] >= 3) {
      for (int i = 0; i < 3; ++i) { // !!!! ONLY THE FIRST 3!!!!
        NSString *regex = [rules objectAtIndex:i];
        NSString *matchString = [search stringByMatching:regex capture:1L];
        if (matchString != nil) {
          if (i == 2 && [query isKindOfClass:[IntQuery class]]) {
            IntQuery *intQuery = (IntQuery *)query;
            if (intQuery.bis == 0) intQuery.bis = intQuery.maxWert;
          }
          [query setValue:matchString idx:i];
          search = [search stringByReplacingOccurrencesOfRegex:regex withString:@" "];
          NSLog(@"match: '%@'  '%@'  '%@'", regex, matchString, search);
        }
      }
    }
  }
  return search;//[search stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

-(NSString *)structuredSearchQuery {
  NSMutableString *m = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
  NSArray *allQueryParsers = [queries allValues];
  for (QueryParser *query in allQueryParsers) {
    [query append:m];
  }
  return m;
}

-(NSString *)tagSearchQuery {
  if ([genericTagQuery count] == 0) return nil;
  NSMutableString *m = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
  int i = 0;
  for (NSString *tag in genericTagQuery) {
    if (i > 0) [m appendString:@"  "];
    [m appendFormat:@"%@ (%.3f)", tag, [[genericTagDistance objectAtIndex:i] floatValue] * [tag length]];
    ++i;
  }
  return m;
}

-(NSString *)unknownTagSearchQuery {
  if ([genericUnknownTagQuery count] == 0) return nil;
  NSMutableString *m = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
  int i = 0;
  for (NSString *tag in genericUnknownTagQuery) {
    if (i > 0) [m appendString:@"  "];
    [m appendFormat:@"%@ (%d)", tag, [tag length]];
    ++i;
  }
  return m;
}

-(IntSet *)associatedSearchTags {
  IntSet *m = [[[IntSet alloc] initWithCapacity:10] autorelease];
  for (NSString *tag in genericTagQuery) {
    [m unionSet:[tags validTags:tag]];
  }
  return m;
}

-(void)internalFirstPass:(NSArray *)array allIntRangeQueries:(NSArray *)allIntRangeQueries allIntNonRangeQueries:(NSArray *)allIntNonRangeQueries allStringQueries:(NSArray *)allStringQueries result:(NSMutableArray *)firstResult {
  SettingsData *settings = [SettingsData getInstance];
  // ToDo: associated tags in the tag hierarchy
  int maxTagFactor = 0;
  for (NSString *tag in genericTagQuery) maxTagFactor += [tag length];
  if (maxTagFactor > 0) for (NSString *tag in genericUnknownTagQuery) maxTagFactor += [tag length];
  /*int *tagMatch = malloc(sizeof(int)*(maxTagFactor+1));
   int *tagFactor = malloc(sizeof(int)*(maxTagFactor+1));
   memset(tagMatch, 0, sizeof(int)*(maxTagFactor+1));
   for (int i = 0; i < maxTagFactor; ++i) { // ToDo: blocks for better performance
   NSString *tag = [genericTagQuery objectAtIndex:i];
   
   IntSet *t = [genericTagQuery objectAtIndex:i];
   NSArray *a = [queryTags allKeysForObject:t];
   int f = 1;
   if (a == nil || [a count] != 1) {
   NSLog(@"ERROR: find query tags key %@", a);
   } else {
   NSString *name = [a objectAtIndex:0];
   f = [tags factor:name];
   //if (f == 1) f = 25;  // ToDo: not FIX
   //else f *= f;
   f *= f;
   //f *= [tags tagFactor:name]; // ToDo: standard 1
   NSLog(@"free text: %@  factor:%d", name, f);
   NSSet *names = [tags tagNames:t];
   for (NSString *s in names) {
   NSLog(@"- associated tags: %@", s);
   }
   }
   tagFactor[i] = f;
   }*/
  //Bookmarks *bookmarks = (DEBUG)? [Bookmarks getInstance] : nil;
  for (UsedCar *u in array) {
    u.preferenceFit = 1.0;
    for (IntQuery *intQuery in allIntRangeQueries) {
      int value = [u attribute:intQuery.attributeId];
      if (value == 0 || value < intQuery.von || value > intQuery.bis) {
        u.preferenceFit = 0.0;
        break;
      }
    }
    if (u.preferenceFit == 0.0) continue;
    for (StringQuery *stringQuery in allStringQueries) {
      if ([UsedCar isStringSetAttribute:stringQuery.attributeId]) { // ToDo: simplify
        IntSet *set = [u stringIdSetAttribute:stringQuery.attributeId];
        u.preferenceFit *= ([stringQuery containsSet:set]+1.0)/(stringQuery.values.size+1.0); // ToDo: not only AND relation!
      } else {
        int value = [u attribute:stringQuery.attributeId];
        if (![stringQuery contains:value]) {
          IntSet *set1 = stringQuery.values; //associatedTags;
          IntSet *set2 = [tags validTags:[u stringAttribute:stringQuery.attributeId]];
          int n = (set2 == nil)? 0 : [set1 numberOfIntersectsSet:set2];
          u.preferenceFit *= (n+1.0)/(set1.size+1.0); // ToDo: not only AND relation!
        }
      }
    }
    if (u.preferenceFit < 0.05) continue;
    double preferenceFitTagFactor = 1.0;
    if (maxTagFactor > 0) {
      float tf = 0.0f;
      int i = 0;
      for (NSString *tag in genericTagQuery) {
        if ([u.tags isMember:[tags convertTagToId:tag]]) {  // ToDo: Performance, genericTagQuery short values init in array
          tf += [[genericTagDistance objectAtIndex:i] floatValue] * [tag length];
        }
        ++i;
      }
      tf /= tf+2.0f;
      tf *= (maxTagFactor+2.0)/maxTagFactor;
      preferenceFitTagFactor = tf;
      //u.preferenceFit *= tf;
      //if (u.preferenceFit < 0.005) continue;
      //tf *= 25.0f;  // ToDo: not FIX: tags from free text search have always weight 5
      
      //f = [tags factor:tag];
      //u.tagFactor = tf;
      //NSLog(@"Found: %@  %@  %d", [u stringAttribute:MODELL], [genericTagQuery objectAtIndex:0], [tags convertTagToId:[genericTagQuery objectAtIndex:0]]);
      //NSLog(@"%@", [u.tags toString]);
    }
    if (preferenceFitTagFactor < 0.1) {
      u.preferenceFit = 0.0;
      continue;
    }
    // consider buyer property preferences
    double preferenceFactor = 0.0;
    int n = 0;
    for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {  // ToDo: Performance
      float f = ABS([u getPropertyFactor:i usedCarData:usedCarData settings:settings]);
      if (f >= 0.0f && f < 1.0f) {
        //u.preferenceFit *= f;
        preferenceFactor += f*f;
        ++n;
        //if (u.preferenceFit < 0.005) break;
      }
    }
    double preferenceFitPropertyFactor = (n == 0)? 1.0 : sqrt(preferenceFactor/n);  // Root mean square
    //if (n > 0) u.preferenceFit *= sqrt(preferenceFactor/n); // Root mean square
    /*if (DEBUG && [bookmarks containsUsedCarBookmark:u]) {
      NSLog(@"GFZ: %@  preferenceFitTagFactor: %f   preferenceFitPropertyFactor: %f\ntags:%@", u.gfzNumber, preferenceFitTagFactor, preferenceFitPropertyFactor, [tags tagNames:u.tags]);
    }*/
    u.preferenceFit *= (3*preferenceFitTagFactor+preferenceFitPropertyFactor)/4;
    if (u.preferenceFit >= 0.05) {
      for (IntQuery *intQuery in allIntNonRangeQueries) {
        int value = [u attribute:intQuery.attributeId];
        if (value == 0) {
          if (intQuery.indirekterFaktor) continue;  // ignore if it is an indirect query and value is not defined
          u.preferenceFit = 0.0;
          break;
        }
        int d = ABS(intQuery.bevorzugt-value);
        if (intQuery.schlechtester < 0) intQuery.bester = intQuery.schlechtester = d;
        else if (d < intQuery.bester) intQuery.bester = d;
        else if (d > intQuery.schlechtester) intQuery.schlechtester = d;
      }
      if (u.preferenceFit >= 0.05) [firstResult addObject:u];
    }
  }
  /*maxTagFactor = 0;
   for (int i = 0; i < l; ++i) {
   maxTagFactor += tagFactor[i]*tagMatch[i];
   }*/
}

-(void)internalSecondPass:(NSArray *)firstResult allIntNonRangeQueries:(NSArray *)allIntNonRangeQueries result:(NSMutableArray *)result {
  for (UsedCar *u in firstResult) {
    for (IntQuery *intQuery in allIntNonRangeQueries) {
      if (intQuery.faktor > 1 || !intQuery.indirekterFaktor) {
        int b = intQuery.schlechtester-intQuery.bester;
        if (b > 0) {
          int value = [u attribute:intQuery.attributeId];
          int d = ABS(intQuery.bevorzugt-value);
          double f = ((double)(intQuery.schlechtester-d))/b; // d = bester -> 1.0, d = schlechtester -> 0.0
          double df = f; // 1.0;
          for (int i = intQuery.faktor-1; i > 0; --i) df *= f;  // ToDo: Performance!
          /*if (DEBUG && [bookmarks containsUsedCarBookmark:u]) {
            NSLog(@"GFZ: %@  distanceFactor: %f", u.gfzNumber, df);
          }*/
          u.preferenceFit *= (intQuery.indirekterFaktor)? (2.0+df)/3.0 : df;
          if (u.preferenceFit < 0.05) break;
        }
      }
    }
    if (u.preferenceFit >= 0.05) [result addObject:u];
  }
}

-(void)recommendation:(NSString *)freeSearch structured:(NSString *)structuredSearch maxOfRecommendations:(int)maxOfRec recommendation:(NSMutableArray *)rec {
  // add float* matchCount (array of propertyId) at UsedCar - count only category level 1 (i.e. weight 1); level 2 would be weight 0.5, etc...
  // add min/max matchCount to min/max UsedCar
  // tags from free text search has always weight 5 if they exactly match, otherwise the distance of the closest tag
  // multiplied by 5 is the weight factor
  //             4gram match has weight 3 and 3gram match has weight 1 (similar matches (i.e. associated tags) only inside tag cluster the level and the levels above but not peers or levels below)
  // formula for preference fit of a product: (sum of each property <propery factor>^2 * <pre-calculated associated match count>) + <free text weight>^2 * <match count>
  //                                    divided by (sum of each property <propery factor>^2 * <(max-min) associated match count>) + <free text weight>^2 * <(max-min)match count>
  // better formula : <associated tags>/(<associated tags>+1) * (<(max-min) associated match count>+1)/<(max-min) associated match count>
  // ToDo: use also closest tag for replacements (e.g. "gelande")
  // Struktur:
  // Pool of products
  // structured (numerical and textual) and unstructured information associated to the products
  // create set of tags out of the unstructured information (e.g. features, contact)
  // create set of tags out of the textual structured information (e.g. model, color)
  // remove synonyms inside the set of tags
  // put the set of tags and the structured information in the index of the products
  // create an overall set of tags for the complete pool of products
  // create relations between the tags and the profile properties (e.g. tag "abs" for property safety)
  // create rules between the numerical structured information and the profile properties
  //Gewichtungsfunktion für Empfehlungen:
  //1. Berücksichtige Bereichsvorgaben, z.b. Km, Entfernung des Händlers (0 falls nicht angegeben) einfache entfernungsfunktion über Postleitzahl?
  //2. Bestimme die maximal vorkommende Anzahl von Tags in Empfehlungen. Gewichtungsfaktor: ausgewählte Tag*Faktor^2, Tag aus Zuordnung*Faktor,ausgewählte Tags die nicht in Zuordnung vorkommen werden mit (max Faktor?)^2 multipliziert
  //3. Multipliziere alle Empfehlungen mit <Tag Gewichtungsfaktor>/<Tag maximaler Gewichtungsfaktor>, wie mit null umgehen?
  // ToDo: cls max 30000EUR max 90000km
  // 1. Dictionary replacements
  // 2. Regular Expressions um numerische Attribute (von, bevorzugt, bis) zu finden
  // 3. numerische Attribute Bereiche berücksichtigen (von, bis)
  // 4. textuelle Attribute gewichten (quadratisch, wenn explizit angegeben; einfach, wenn in Zuordnung; sonst Gewicht 1)
  // 5. Abstandsgewichtung für numerische Attribute (bevorzugt)
  //[self clear];
  if (![delegate recommendationResultStillNeeded]) return;
  NSArray *allQueries = [queries allValues];
  for (QueryParser *query in allQueries) {
    [query clear];
    if ([query isKindOfClass:[IntQuery class]]) {
      IntQuery *intQuery = (IntQuery *)query;
      [intQuery setupFactor];
    }
  }
  NSLog(@"original search free: '%@'  structured: '%@'", freeSearch, structuredSearch);
  NSString *modifiedFreeSearch = [Tags removingAccents:freeSearch];
  structuredSearch = [Tags removingAccents:structuredSearch];
  modifiedFreeSearch = [Tags removingSpaces:modifiedFreeSearch];
  NSLog(@"standardized search free: '%@'  structured: '%@'", modifiedFreeSearch, structuredSearch);
  if (![delegate recommendationResultStillNeeded]) {
    [self clear];
    return;
  }
  modifiedFreeSearch = [self replacement:modifiedFreeSearch allQueries:allQueries];
  structuredSearch = [self structuredSearchQuery];
  NSLog(@"replaced search free: '%@'  structured: '%@'", modifiedFreeSearch, structuredSearch);
  if (![delegate recommendationResultStillNeeded]) {
    [self clear];
    return;
  }
  if (![self parse:modifiedFreeSearch structured:structuredSearch]) {
    if (maxOfRec >= [lastResult count]) {
      [rec setArray:lastResult];
    } else {
      [rec removeAllObjects];
      for (int i = 0; i < maxOfRec; ++i) {
        [rec addObject:[lastResult objectAtIndex:i]];
      }
    }
    return;
  }
  if (![delegate recommendationResultStillNeeded]) {
    [self clear];
    return;
  }
  [lastParse release];
  lastParse = [freeSearch retain];
  [lastResult removeAllObjects];
  NSLog(@"tag search: %@", [self tagSearchQuery]);
  NSLog(@"unknown tags in search: %@", [self unknownTagSearchQuery]);
  //BOOL first = YES;
  //NSLog(@"search after transformation: '%@'", search);
  NSMutableArray *allIntRangeQueries = [[NSMutableArray alloc] initWithCapacity:[allQueries count]];
  NSMutableArray *allIntNonRangeQueries = [[NSMutableArray alloc] initWithCapacity:[allQueries count]];
  NSMutableArray *allStringQueries = [[NSMutableArray alloc] initWithCapacity:[allQueries count]];
  int numberIndirectIntQueries = 0;
  for (QueryParser *query in allQueries) {
    if ([query isKindOfClass:[IntQuery class]]) {
      BOOL relevant = NO;
      IntQuery *intQuery = (IntQuery *)query;
      if (intQuery.von > 0 || intQuery.bis > 0) {
        [allIntRangeQueries addObject:intQuery];
        if ([intQuery isKindOfClass:[DateQuery class]]) {
          DateQuery *q = [[DateQuery alloc] initWithDateQuery:(DateQuery *)intQuery];
          [structuredQueries addObject:q];
          [q release];
        } else {
          IntQuery *q = [[IntQuery alloc] initWithIntQuery:intQuery];
          [structuredQueries addObject:q];
          [q release];
        }
        relevant = YES;
      }
      if (intQuery.bevorzugt > 0) {
        intQuery.bester = intQuery.schlechtester = -1;
        [allIntNonRangeQueries addObject:intQuery];
        if (!relevant) {
          if ([intQuery isKindOfClass:[DateQuery class]]) {
            DateQuery *q = [[DateQuery alloc] initWithDateQuery:(DateQuery *)intQuery];
            [structuredQueries addObject:q];
            [q release];
          } else {
            IntQuery *q = [[IntQuery alloc] initWithIntQuery:intQuery];
            [structuredQueries addObject:q];
            [q release];
          }
        }
        relevant = YES;
      }
      if (intQuery.indirekterFaktor) {
        ++numberIndirectIntQueries;
        relevant = YES;
      }
      if (relevant) {
        NSLog(@"IntQuery (%@) von %d bis %d bevorzugt %d indirect %d", intQuery.attributeId, intQuery.von, intQuery.bis, intQuery.bevorzugt, intQuery.indirekterFaktor);
      }
    } else if ([query isKindOfClass:[StringQuery class]]) {
      StringQuery *stringQuery = (StringQuery *)query;
      if (![stringQuery isEmpty]) {
        [allStringQueries addObject:stringQuery];
        NSLog(@"StringQuery (%@) %@", stringQuery.attributeId, [stringQuery.values toString]);
        StringQuery *q = [[StringQuery alloc] initWithStringQuery:stringQuery];
        [structuredQueries addObject:q];
        [q release];
      }
    }
  }
  NSLog(@"#car pool:%d  #tags:%d  #unknown tags:%d  #range queries:%d  #preference queries:%d (%d)  #text queries:%d", [usedCarData.usedCars count], [genericTagQuery count], [genericUnknownTagQuery count], [allIntRangeQueries count], [allIntNonRangeQueries count], numberIndirectIntQueries, [allStringQueries count]);
  if ([genericTagQuery count] == 0 && [allIntRangeQueries count] == 0 && [allIntNonRangeQueries count] == numberIndirectIntQueries && [allStringQueries count] == 0) {
    [allIntRangeQueries release];
    [allStringQueries release];
    [allIntNonRangeQueries release];
    [rec removeAllObjects];
    [lastResult removeAllObjects];
    return;
  }
  BOOL recommendationResultStillNeeded = [delegate recommendationResultStillNeeded];
  NSArray *array = [usedCarData.usedCars allValues];  // ToDo: Performance?
  NSMutableArray *firstResult = [[NSMutableArray alloc] initWithCapacity:[array count]];
  if (recommendationResultStillNeeded) {
    [self internalFirstPass:array allIntRangeQueries:allIntRangeQueries allIntNonRangeQueries:allIntNonRangeQueries allStringQueries:allStringQueries result:(NSMutableArray *)firstResult];
    NSLog(@"#genericTagQuery:%d  #first results:%d", [genericTagQuery count], [firstResult count]);
  }
  [allIntRangeQueries release];
  [allStringQueries release];
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[firstResult count]];
  if (recommendationResultStillNeeded) recommendationResultStillNeeded = [delegate recommendationResultStillNeeded];
  if (recommendationResultStillNeeded) {
    if ([allIntNonRangeQueries count] > 0) {
      [self internalSecondPass:firstResult allIntNonRangeQueries:allIntNonRangeQueries result:result];
    } else {
      [result addObjectsFromArray:firstResult];
    }
  }
  [firstResult release];
  [allIntNonRangeQueries release];
  [rec removeAllObjects];
  if (recommendationResultStillNeeded) recommendationResultStillNeeded = [delegate recommendationResultStillNeeded];
  if (recommendationResultStillNeeded) {
    NSArray *a = [result sortedArrayUsingSelector:@selector(compare:)];
    int l = MIN([a count], maxOfRec);
    float bestPreferenceFit = 1.0;
    if (l > 0) {
      UsedCar *u = [a objectAtIndex:0];
      bestPreferenceFit = u.preferenceFit;
    }
    int i = 0;
    for (UsedCar *u in a) {
      if (++i <= l && bestPreferenceFit < 2.0f*u.preferenceFit) [rec addObject:u];
      [lastResult addObject:u];
    }
  }
  [result release];
  if (recommendationResultStillNeeded) NSLog(@"number of search results: %d", [rec count]);
  else [self clear];
}

@end
