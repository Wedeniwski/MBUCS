//
//  InAppSettingsViewController.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppSettingsTableCell.h"

@protocol InAppSettingsDelegate
-(void)updateSettings;
@end

@interface InAppSettingsViewController : UIViewController {
	id<InAppSettingsDelegate> delegate;
  NSString *file;
  NSString *preferenceTitle;
  NSString *preferenceSpecifiers;
  NSMutableArray *headers, *displayHeaders;
  NSMutableDictionary *settings;
  IBOutlet UITableView *theTableView;
  IBOutlet UINavigationItem *titleOfTable;
}

-(IBAction)loadBackView:(id)sender;
-(void)controlEditingDidBeginAction:(UIControl *)control;

@property (assign, nonatomic) id<InAppSettingsDelegate> delegate;
@property (copy, nonatomic) NSString *file;
@property (retain, nonatomic) NSString *preferenceTitle;
@property (retain, nonatomic) NSString *preferenceSpecifiers;
@property (retain, nonatomic) UITableView *theTableView;
@property (retain, nonatomic) UINavigationItem *titleOfTable;

@end