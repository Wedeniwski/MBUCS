//
//  StringAttribute.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 09.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringAttribute : NSObject /*<NSCoding>*/ {
  NSArray *types;
  NSArray *frequency;
}

-(id)init:(NSArray *)typ frequency:(NSArray *)f;
//-(id)initWithData:(NSArray *)typ frequency:(NSString *)f;
-(int)frequencyAll:(int)idx;
//+(NSArray *)parseIntList:(NSString *)val;
//+(NSArray *)parseStringList:(NSString *)val;

@property (readonly, nonatomic) NSArray *types;

@end
