//
//  TagCloud.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 04.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TagCloud.h"
#import "StringQuery.h"
#import "IPadHelper.h"

@implementation TagCloud

+(BOOL)tagIncluded:(NSString *)tag inSearchQuery:(NSArray *)searchTextTokens {
  NSArray *tags = [tag componentsSeparatedByString:@" "];
  for (NSString *t in tags) {
    if ([searchTextTokens indexOfObject:t] == NSNotFound) return NO;
  }
  return YES;
}

+(int)fontSize:(double)baseSize maxValue:(int)maxValue value:(int)val {
  return (int)((baseSize*(1.0+(1.5*val-maxValue/2)/maxValue)));
}

// http://www.tocloud.com/javascript_cloud_generator.html
+(NSString *)create:(int *)tagFrequency tags:(NSArray *)tags allStringAttributeIds:(NSArray *)allStringAttributeIds attributeTypesCount:(int *)attributeTypesCount maxTagsInResult:(int)maxTagsInResult searchText:(NSString *)searchText {
  int size = [tags count];
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:80000] autorelease];
  [s appendString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style></head><body><center>"];
  [s appendString:@"<style type='text/css'>#jscloud a:hover { text-decoration: underline; }</style><div id='jscloud'>"];
  if (size > 0) {
    int maxFrequency = MAX(1, tagFrequency[0]);
    for (int i = 1; i < size; ++i) {
      int v = tagFrequency[i];
      if (v > maxFrequency) maxFrequency = v;
    }
    int *frequency = malloc(sizeof(int)*(maxFrequency+1));
    memset(frequency, 0, sizeof(int)*(maxFrequency+1));
    for (int i = 0; i < size; ++i) {
      int f = tagFrequency[i];
      if (f >= 0) ++frequency[f];
    }
    int minFrequency = maxFrequency;
    int f = frequency[minFrequency];
    for (int i = maxFrequency-1; i > 0; --i) { // don't count tags with no frequency
      int j = f+frequency[i];
      if (j > maxTagsInResult) break;
      f = j; minFrequency = i;
    }
    free(frequency);
    maxFrequency -= minFrequency;
    NSArray *searchTextTokens = [searchText componentsSeparatedByString:@" "];
    double baseSize = [IPadHelper isIPad]? 120.0 : 60.0;
    int minSize = [IPadHelper isIPad]? 60 : 45;
    int k = 0;
    BOOL tableAdded = NO;
    for (int i = 0, j = 0; i < size; ++i, ++j) {
      int f = tagFrequency[i];
      if (f >= minFrequency) {
        int fsize = [TagCloud fontSize:baseSize maxValue:maxFrequency value:(f-minFrequency)];
        if (fsize >= minSize) {
          NSString *t = [tags objectAtIndex:i];
          if ([t length] > 0) {
            NSString *link = [StringQuery encode:t];
            NSRange range = [searchText rangeOfString:link options:NSCaseInsensitiveSearch];
            if (range.length == 0 && ![TagCloud tagIncluded:[StringQuery decode:link] inSearchQuery:searchTextTokens]) {
              if (allStringAttributeIds != nil && attributeTypesCount != NULL && (!tableAdded || j >= attributeTypesCount[k])) {
                if (tableAdded) [s appendString:@"</td></tr></table>"];
                while (j >= attributeTypesCount[k]) {
                  j -= attributeTypesCount[k++];
                }
                [s appendFormat:@"<table><tr><td><center><b>%@</b></center></td></tr><tr><td>", [UsedCar attributeName:[allStringAttributeIds objectAtIndex:k]]];
                tableAdded = YES;
              }
              //NSLog(@"Tag '%@'  size:%d  frequency:%d (%d-%d)", t, fsize, tagFrequency[i], minFrequency, maxFrequency);
              [s appendFormat:@" <nobr><a style='font-size:%d%%;' title='%d' href=\"#%@\">%@</a></nobr>&nbsp;&nbsp;", fsize, tagFrequency[i], link, t];
            }
          }
        }
      }
    }
    if (tableAdded) [s appendString:@"</td></tr></table>"];
  }
  [s appendString:@"</div>"];
  [s appendString:@"</center></body></html>"];
  return s;
}

+(NSString *)create:(NSSet *)tags minus:(NSSet *)selectedTags {
  NSMutableString *s = [[[NSMutableString alloc] initWithString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style></head><body><center>"] autorelease];
  [s appendString:@"<style type='text/css'>#jscloud a:hover { text-decoration: underline; }</style><div id='jscloud'>"];
  NSArray *a = [tags allObjects];
  a = [a sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *tag in a) {
    if ([selectedTags containsObject:tag]) {
      [s appendFormat:@" <nobr><a style='font-size:90%%;' href=\"#%@\">%@</a></nobr>&nbsp;&nbsp;", [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"], tag];
    } else {
      [s appendFormat:@" <nobr><a style='font-size:150%%;' href=\"#%@\">%@</a></nobr>&nbsp;&nbsp;", [tag stringByReplacingOccurrencesOfString:@" " withString:@"+"], tag];
    }
  }
  [s appendString:@"</div>"];
  [s appendString:@"</center></body></html>"];
  return s;
}

@end
