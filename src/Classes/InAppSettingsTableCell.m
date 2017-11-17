//
//  InAppSettingsTableCell.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InAppSettingsTableCell.h"
#import "InAppSettingConstants.h"
#import "IPadHelper.h"

@implementation InAppSettingsTableCell

@synthesize setting;

#pragma mark -

-(id)initWithSetting:(InAppSetting *)inputSetting reuseIdentifier:(NSString *)reuseIdentifier {
  //the docs say UITableViewCellStyleValue1 is used for settings, 
  //but it doesn't look 100% the same so we will just draw our own UILabels
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  if (self != nil) {
    setting = [inputSetting retain];
    //setup title label
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = InAppSettingBoldFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:titleLabel];
    
    //setup value label
    valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valueLabel.font = InAppSettingNormalFont;
    valueLabel.textColor = InAppSettingBlue;
    valueLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:valueLabel];
  }
  return self;
}

-(void)setupCell:(InAppSetting *)inputSetting {
  if (self != nil) {
    [setting release];
    setting = [inputSetting retain];
  }
}

-(void)dealloc {
  [setting release];
  [titleLabel release];
  [valueLabel release];
  [super dealloc];
}

-(float)inAppSettingTableWidth {
  return ([IPadHelper isIPad])? 688.0f : 320.0f;
}

#pragma mark Cell lables

-(void)setTitle {
  [self setTitle:[self.setting valueForKey:@"Title"]];
}

-(void)setDetail {
  [self setDetail:[self getValue]];
}

-(void)setTitle:(NSString *)title {
  titleLabel.text = NSLocalizedString(title, nil);
  //float maxWidth = InAppSettingTableWidth;
  //maxWidth = self.frame.size.width;
  CGFloat maxTitleWidth = [self inAppSettingTableWidth]-(InAppSettingCellPadding*4);
  CGSize titleSize = [titleLabel.text sizeWithFont:titleLabel.font];
  if (titleSize.width > maxTitleWidth) titleSize.width = maxTitleWidth;
  CGRect titleFrame = titleLabel.frame;
  titleFrame.size = titleSize;
  titleFrame.origin.x = InAppSettingCellPadding;
  titleFrame.origin.y = (CGFloat)round((self.contentView.frame.size.height*0.5f)-(titleSize.height*0.5f))-InAppSettingOffsetY;
  titleLabel.frame = titleFrame;
}

-(void)setDetail:(NSString *)detail {
  valueLabel.text = NSLocalizedString(detail, nil);
  NSUInteger disclosure = (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)? 2 : 0;
  CGFloat maxValueWidth = ([self inAppSettingTableWidth]-(InAppSettingCellPadding*(4+disclosure)))-(titleLabel.frame.size.width+InAppSettingCellPadding);
  CGSize valueSize = [valueLabel.text sizeWithFont:valueLabel.font];
  if (valueSize.width > maxValueWidth) valueSize.width = maxValueWidth;
  CGRect valueFrame = valueLabel.frame;
  valueFrame.size = valueSize;
  valueFrame.origin.x = (CGFloat)round(([self inAppSettingTableWidth]-(InAppSettingCellPadding*(3+disclosure)))-valueFrame.size.width);
  valueFrame.origin.y = (CGFloat)round((self.contentView.frame.size.height*0.5f)-(valueSize.height*0.5f))-InAppSettingOffsetY;
  valueLabel.frame = valueFrame;
}

-(void)setDisclosure:(BOOL)disclosure {
  self.accessoryType = (disclosure)? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

#pragma mark Value

-(id)getValue {
  id value = [[NSUserDefaults standardUserDefaults] valueForKey:[setting valueForKey:@"Key"]];
  if (value == nil) {
    value = [setting valueForKey:@"DefaultValue"];
    if (value == nil) {
      NSArray *a = [setting valueForKey:@"Values"];
      if ([a count] > 0) value = [a objectAtIndex:0];
    }
  }
  return value;
}


-(void)setValue {
  //implement this per cell type
}

-(UIControl *)getValueInput {
  return nil;
}

-(void)setValue:(id)newValue {
  [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:[self.setting valueForKey:@"Key"]];
}

@end