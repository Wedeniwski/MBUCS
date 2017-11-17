//
//  GeneralInfoViewController.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeneralInfoViewController : UIViewController {
	id delegate;
  NSString *fileName;
  NSString *titleName;
  NSString *content;
  NSString *subdirectory;
  NSString *buttonTitle;

  IBOutlet UINavigationItem *titleNavigationItem;
  IBOutlet UIWebView *webView;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner fileName:(NSString *)fName title:(NSString *)tName;

-(IBAction)loadBackView:(id)sender;

@property (nonatomic, retain) UINavigationItem *titleNavigationItem;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *subdirectory;
@property (nonatomic, retain) NSString *buttonTitle;

@end
