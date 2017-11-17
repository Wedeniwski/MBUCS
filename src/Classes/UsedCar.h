//
//  UsedCar.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 07.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntSet.h"
#import "SettingsData.h"

// ToDo: sync with Java
#define GFZ @"gfz"
#define TAGS @"tags"
#define NUM_ATTRIBUTES @"Numerische Attribute"
#define TEXT_ATTRIBUTES @"Textattribute"
#define ATTRIBUTES_LIST @"Attributliste"

#define ERSTZULASSUNG @"erstzulassung"
#define KILOMETERSTAND @"km"
#define FAHRZEUGART @"art"
#define KAROSSERIEFORM @"karosserie"
#define MOTORLEISTUNG @"ps"
#define HUBRAUM @"hubraum"
#define KRAFTSTOFFART @"kraftstoff"
#define KRAFTSTOFFVERBRAUCH @"verbrauch"
#define CO2_EMISSIONEN @"co2"
#define GETRIEBE @"getriebe"
#define FARBE @"farbe"
#define POLSTER @"polster"
#define VORBESITZER @"vorbesitzer"
#define MODELL @"modell"
#define AUSSTATTUNGSMERKMALE @"ausstattung"
#define KAUFPREIS @"preis"
#define GARANTIE @"garantie"
#define KONTAKT @"kontakt"

#define THUMBNAIL_PREFIX @"http://e-services.mercedes-benz.com/pkw/93x70/"
#define LARGE_IMAGE_PREFIX @"http://e-services.mercedes-benz.com/pkw/640x480/"
#define IMAGE_PREFIX @"http://e-services.mercedes-benz.com/pkw/200x150/"
#define IMAGE_ALT_PREFIX @"http://e-services.mercedes-benz.com/substitutes/pkw"

@class Tags;
@class UsedCarData;

@interface UsedCar : NSObject <NSCoding> {
@private
  NSString *gfzNumber;
  int *attributes;
  IntSet *ausstattungsmerkmale;
  short locationIndex;
  
  //NSArray *bilder;
  IntSet *tags;
  //int tagFactor;
  float preferenceFit;
  float *propertyMatch;
}

-(id)initWithGFZNumber:(NSString *)gfz;
-(BOOL)isEqual:(UsedCar *)otherUsedCar;
-(NSComparisonResult)compare:(UsedCar *)otherUsedCar;
-(void)trimToSize;
//-(BOOL)hasTags;
//-(void)setupTags:(Tags *)tgs attributeIndex:(NSDictionary *)attributeIndex;
-(BOOL)hasCertificate;
//-(NSArray *)getBilder;
//-(void)setBilder:(NSArray *)images;
-(float)getPropertyFactor:(int)propertyIndex usedCarData:(UsedCarData *)usedCarData settings:(SettingsData *)settings;
-(float)getPropertyMatch:(int)propertyIndex;
-(void)setPropertyMatch:(float *)pMatch;
-(void)minPropertyMatch:(float *)pMatch;
-(void)maxPropertyMatch:(float *)pMatch;
-(NSSet *)getAustattungsmerkmale:(NSDictionary *)attributeIndex;
-(void)setAttribute:(NSString *)attributeId value:(int)value;
-(void)setSetAttribute:(NSString *)attributeId value:(IntSet *)value;
-(int)attribute:(NSString *)attributeId;
-(NSString *)stringAttribute:(NSString *)attributeId;
-(IntSet *)stringIdSetAttribute:(NSString *)attributeId;
+(NSString *)attributeName:(NSString *)attributeId;
+(BOOL)isStringAttribute:(NSString *)attributeId;
+(BOOL)isStringSetAttribute:(NSString *)attributeId;
+(BOOL)isIntAttribute:(NSString *)attributeId;
+(BOOL)isDateAttribute:(NSString *)attributeId;
+(NSArray *)intAttributeIdOrder;
+(NSArray *)stringAttributeIdOrder;
+(NSArray *)attributeIdOrder;
+(int)attributeIdIndex:(NSString *)attributeId;
+(NSArray *)intAttributeNameOrder;
+(NSArray *)stringAttributeNameOrder;

+(NSString *)convertFileName:(NSString *)gfzNumber;

@property (readonly, nonatomic) NSString *gfzNumber;
@property (retain, nonatomic) IntSet *tags;
@property short locationIndex;
//@property int tagFactor;
@property float preferenceFit;

@end
