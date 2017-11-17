//
//  PSMultiValueSpecifierTable.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppSetting.h"

@interface PSMultiValueSpecifierTable : UIViewController {
	id delegate;
  int selectedRow;
  InAppSetting *setting;
  IBOutlet UITableView *theTableView;
  IBOutlet UINavigationItem *titleOfTable;
}

-(id)initWithSetting:(InAppSetting *)inputSetting delegate:(id)inputDelegate nibName:(NSString *)nibName;
-(id)getValue;
-(void)setValue:(id)newValue;

-(IBAction)loadBackView:(id)sender;

@property (retain, nonatomic) UITableView *theTableView;
@property (retain, nonatomic) UINavigationItem *titleOfTable;

@end