//
//  DetailsViewController.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UsedCar.h"

@interface DetailsViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
@private
	id delegate;
  UsedCar *usedCar;
  NSString *usedCarGFZ;
  CGRect originalWebView;

@public
  IBOutlet UINavigationItem *navigation;
  IBOutlet UIButton *addBookmark;
  IBOutlet UIButton *viewLocation;
  IBOutlet UILabel *modelLabel;
  //IBOutlet UILabel *searchHighlightLabel;
  //IBOutlet UISwitch *highlight;
  IBOutlet UIWebView *imageWebView;
  IBOutlet UIWebView *detailsWebView;
  IBOutlet UIWebView *contactWebView;
  IBOutlet UIWebView *featuresWebView;
  IBOutlet UIWebView *imagesWebView;
  IBOutlet UIImageView *favoriteView;
  IBOutlet UIActivityIndicatorView *calculationIndicator;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner usedCar:(UsedCar *)u;

-(IBAction)loadBackView:(id)sender;
-(IBAction)addFavorite:(id)sender;
-(IBAction)viewLocation:(id)sender;
-(IBAction)sendData:(id)sender;
-(IBAction)updateView:(id)sender;
-(void)createEmail:(int)attachmentSize;

@property (retain, nonatomic) UINavigationItem *navigation;
@property (nonatomic, retain) UIButton *addBookmark;
@property (nonatomic, retain) UIButton *viewLocation;
@property (retain, nonatomic) UILabel *modelLabel;
//@property (retain, nonatomic) UILabel *searchHighlightLabel;
//@property (retain, nonatomic) UISwitch *highlight;
@property (retain, nonatomic) UIWebView *imageWebView;
@property (retain, nonatomic) UIWebView *detailsWebView;
@property (retain, nonatomic) UIWebView *contactWebView;
@property (retain, nonatomic) UIWebView *featuresWebView;
@property (retain, nonatomic) UIWebView *imagesWebView;
@property (retain, nonatomic) UIImageView *favoriteView;
@property (retain, nonatomic) UIActivityIndicatorView *calculationIndicator;

@end
