//
//  SettingsData.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 06.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsData : NSObject {
@private
  NSMutableDictionary *properties;
  NSMutableDictionary *propertyNames;
  NSMutableDictionary *valueTitles;
}

-(id)init;
+(SettingsData *)getInstance:(BOOL)reload;
+(SettingsData *)getInstance;
-(NSArray *)propertyIdOrder;
-(NSArray *)propertyNameOrder;
-(int)value:(NSString *)propertyId;
-(NSString *)valueTitle:(NSString *)propertyId;
-(NSString *)propertyId:(NSString *)name;
-(NSString *)name:(NSString *)propertyId;
+(NSString *)documentPath;
+(NSString *)appVersion;
+(NSString *)currentLanguage;

@end
