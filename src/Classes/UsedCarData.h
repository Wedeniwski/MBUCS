//
//  UsedCarData.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCar.h"
#import "Tags.h"
#import "WebData.h"

// ToDo: keep in sync with Java
#define NUMBER_OF_PROPERTY_IDS 7

#define INDEX_FILE_NAME @"UsedCars.data"

@interface UsedCarData : NSObject {
  id<UpdateDelegate> delegate;
  double versionOfData; // timeIntervalSince1970
  int numberOfCars;
  NSMutableDictionary *attributeIndex;
  NSMutableDictionary *usedCars;
  NSMutableArray *latitudeLongitudeOfAddresses;
  UsedCar *minValuesAttributes;
  UsedCar *maxValuesAttributes;
  Tags *tags;
}

//-(void)save;
+(const char*)intSet:(const char *)source target:(IntSet *)target;
-(id)initWithDelegate:(id<UpdateDelegate>)owner;
-(NSString *)getAddressOf:(UsedCar *)usedCar;
-(NSString *)dateOfData;
-(int)count;
+(int)stringArraySearch:(NSString *)key array:(NSArray *)array;
+(int)intSearch:(int)key array:(NSArray *)array;
+(NSString *)getPropertyId:(int)propertyIndex;

@property (readonly) double versionOfData;
@property (readonly, nonatomic) NSDictionary *attributeIndex;
@property (readonly, nonatomic) NSDictionary *usedCars;
@property (readonly, nonatomic) NSArray *latitudeLongitudeOfAddresses;
@property (readonly, nonatomic) UsedCar *minValuesAttributes;
@property (readonly, nonatomic) UsedCar *maxValuesAttributes;
@property (readonly, nonatomic) Tags *tags;

@end
