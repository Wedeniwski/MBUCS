//
//  InAppSetting.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InAppSetting : NSObject {
  NSDictionary *settingDictionary;
}

-(NSString *)getType;
-(BOOL)isType:(NSString *)type;
-(id)valueForKey:(NSString *)key;
-(NSString *)cellName;
-(NSString *)title;
-(NSString *)key;
-(id)defaultValue;
-(BOOL)isTrueValue:(NSString *)value;
-(BOOL)isFalseValue:(NSString *)value;
  
-(BOOL)hasTitle;
-(BOOL)hasKey;
-(BOOL)hasDefaultValue;

-(id)initWithDictionary:(NSDictionary *)dictionary;

@end
