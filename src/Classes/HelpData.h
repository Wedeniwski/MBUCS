//
//  HelpData.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HelpData : NSObject {
  NSString *languagePath;
  NSArray *keys;
  NSDictionary *pages;
  NSDictionary *titles;
}

-(id)init;
-(id)initWithContent:(NSString *)data;
+(HelpData *)getHelpData;

@property (readonly, nonatomic) NSString *languagePath;
@property (readonly, nonatomic) NSArray *keys;
@property (readonly, nonatomic) NSDictionary *pages;
@property (readonly, nonatomic) NSDictionary *titles;

@end
