//
//  TokenPoolViewController.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Tags.h"
#import "InAppSettingsViewController.h"

@interface TokenPoolViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, InAppSettingsDelegate> {
@private
	id delegate;
  Tags *tags;

@public
  IBOutlet UISegmentedControl *attributeSegmentedControl;
  IBOutlet UISegmentedControl *categorySegmentedControl;
  IBOutlet UIWebView *attributeWebView;
  IBOutlet UIWebView *categoryWebView;
  IBOutlet UILabel *deletedTagsLabel;
  IBOutlet UIBarButtonItem *actionButton;
  IBOutlet UIBarButtonItem *deleteTokensButton;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner tags:(Tags*)t;
-(IBAction)loadBackView:(id)sender;
-(IBAction)sendData:(id)sender;
-(IBAction)deleteTokens:(id)sender;
-(IBAction)dictionary:(id)sender;
-(IBAction)attributeSegmentedControlValueChanged:(id)sender;
-(IBAction)categorySegmentedControlValueChanged:(id)sender;

-(void)updateSettings;

@property (assign, nonatomic) UISegmentedControl *attributeSegmentedControl;
@property (assign, nonatomic) UISegmentedControl *categorySegmentedControl;
@property (assign, nonatomic) UIWebView *attributeWebView;
@property (assign, nonatomic) UIWebView *categoryWebView;
@property (assign, nonatomic) UILabel *deletedTagsLabel;
@property (assign, nonatomic) UIBarButtonItem *actionButton;
@property (assign, nonatomic) UIBarButtonItem *deleteTokensButton;

@end
