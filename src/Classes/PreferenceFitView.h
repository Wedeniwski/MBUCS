//
//  PreferenceFitView.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceFitView : UIView {
  double preferenceFit;
  UIImageView *backgroundImageView;
  UIImageView *foregroundImageView;
}

-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)coder;
-(void)setPreferenceFit:(double)newPreferenceFit;
-(int)getRating;
-(void)setRating:(int)newRating;

@property (readonly) double preferenceFit;

@end
