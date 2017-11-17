//
//  RangeSlider.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 01.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RangeSlider : UIControl {
  CGFloat min, max, preferred; //the min and max of the range	
  NSString *attributeId;

  UIImageView *minSlider, *maxSlider, *preferredSlider;
  UIImageView *backgroundImageView, *subRangeTrackImageView, *superRangeTrackImageView, *inRangeTrackImageView; // the sliders representing the min and max, and a background view;
  UIView *trackingSlider; // a variable to keep track of which slider we are tracking (if either)
  UILabel *titleLabel;
  UILabel *fromLabel;
  UILabel *toLabel;
  UILabel *preferredLabel;
}

-(void)updateTrackImageViews;
-(void)updateThumbViews;

@property (nonatomic) CGFloat min, max, preferred;
@property (retain, nonatomic) NSString *attributeId;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *fromLabel;
@property (retain, nonatomic) UILabel *toLabel;
@property (retain, nonatomic) UILabel *preferredLabel;

@end
