//
//  ApplicationCell.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PreferenceFitView.h"
#import "TableCell.h"
#import "UsedCar.h"

@interface ApplicationCell : TableCell {
@private
  BOOL imageExisting;
  UsedCar *usedCar;
  NSString *gfzNumber;
  NSURLConnection *connection;
  NSMutableData *data;

@public
  IBOutlet UIImageView *iconView;
  IBOutlet UILabel *modelLabel;
  IBOutlet UILabel *kmLabel;
  IBOutlet UILabel *psLabel;
  IBOutlet UILabel *erstzulassungLabel;
  IBOutlet UILabel *leistungenLabel;
  IBOutlet PreferenceFitView *fitPreferenceView;
  IBOutlet UILabel *fitPreferenceLabel;
  IBOutlet UILabel *priceLabel;
  IBOutlet UIImageView *certificateView;
  IBOutlet UIImageView *bookmarkView;
}

-(void)enabled;
-(void)loadImageFrom:(UsedCar *)uCar;
+(UIImage *)getImageFrom:(UsedCar *)uCar urlString:(NSString *)url;
-(void)loadImageFromArgs:(NSArray *)args;
-(void)setIcon:(UIImage *)newIcon;
-(void)setPreferenceFit:(double)newPreferenceFit;

+(void)clearImageCache;
+(NSData *)dataInCacheFor:(NSString *)gfzNumber;
+(void)addToCache:(NSString *)gfzNumber data:(NSData *)data;

@property (readonly) BOOL imageExisting;
@property (retain, nonatomic) UIImageView *iconView;
@property (retain, nonatomic) UILabel *modelLabel;
@property (retain, nonatomic) UILabel *kmLabel;
@property (retain, nonatomic) UILabel *psLabel;
@property (retain, nonatomic) UILabel *erstzulassungLabel;
@property (retain, nonatomic) UILabel *leistungenLabel;
@property (retain, nonatomic) PreferenceFitView *fitPreferenceView;
@property (retain, nonatomic) UILabel *fitPreferenceLabel;
@property (retain, nonatomic) UILabel *priceLabel;
@property (retain, nonatomic) UIImageView *certificateView;
@property (retain, nonatomic) UIImageView *bookmarkView;

@end
