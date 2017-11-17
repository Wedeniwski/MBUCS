//
//  WebData.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UsedCar.h"

@protocol UpdateDelegate
-(void)status:(NSString *)status percentage:(double)percentage;
-(void)downloaded:(NSString *)number;
@end

@interface WebData : NSObject {
@private
  id<UpdateDelegate> delegate;
  NSURLConnection *connection;
  NSMutableData *data;
  
@public
  double version;  // number of seconds since January 1, 1970, 00:00:00 GMT
  NSString *path;
  int fileSize;
  int uncompressedFileSize;
  int dataCount;
  NSString *hashCode;
}

-(id)init:(NSString *)lineOfData owner:(id<UpdateDelegate>)owner;

+(NSString *)localDataPath;
+(BOOL)initImageCachePath:(double)versionOfData;
+(NSString *)localImageCachePath:(double)versionOfData;
+(void)deleteImageCachePath:(double)versionOfData;
+(NSString *)sourceDataPath;
+(NSString *)sizeToString:(int)size;
+(WebData *)availableUpdates:(id<UpdateDelegate>)owner;
+(BOOL)isUpdateNecessary:(double)versionOfData;
-(void)update;

+(NSString *)isInPageCache:(UsedCar *)usedCar;
+(NSString *)onlinePage:(UsedCar *)usedCar;
+(NSArray *)linksToOriginalImages:(UsedCar *)usedCar;
+(void)deleteLinksToImages:(UsedCar *)usedCar versionOfData:(double)versionOfData;
+(NSArray *)linksToImages:(UsedCar *)usedCar versionOfData:(double)versionOfData checkUpToDateAltImages:(BOOL)checkUpToDateAltImages;
+(NSString *)getImageURL:(NSString *)relativeLink size:(int)size;
+(BOOL)isAltImageURL:(NSString *)relativeLink;
+(BOOL)isValidPage:(UsedCar *)usedCar;
+(BOOL)isValidFirstImage:(UsedCar *)usedCar versionOfData:(double)versionOfData;

@property (readonly) double version;
@property (readonly, nonatomic) NSString *path;
@property (readonly) int fileSize;
@property (readonly) int uncompressedFileSize;
@property (readonly) int dataCount;
@property (readonly, nonatomic) NSString *hashCode;

@end
