//
//  InAppSettingsTableCell.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppSetting.h"

@interface InAppSettingsTableCell : UITableViewCell {
  InAppSetting *setting;
  UILabel *titleLabel, *valueLabel;
}

-(id)initWithSetting:(InAppSetting *)inputSetting reuseIdentifier:(NSString *)reuseIdentifier;
-(void)setupCell:(InAppSetting *)inputSetting;
-(float)inAppSettingTableWidth;

-(void)setTitle;
-(void)setDetail;
-(void)setTitle:(NSString *)title;
-(void)setDetail:(NSString *)detail;
-(void)setDisclosure:(BOOL)disclosure;

-(id)getValue;
-(void)setValue;
-(void)setValue:(id)newValue;
-(UIControl *)getValueInput;

@property (nonatomic, retain) InAppSetting *setting;

@end