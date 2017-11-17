//
//  TutorialViewController.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpData.h"

@interface TutorialViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate> {
	id delegate;
  HelpData *helpData;
  int numberOfPages;
  NSString *buttonTitle;
  CGFloat pageWidth, pageHeight;
  BOOL pageControlUsed;
  NSArray *webPages;
  NSString *navigationTitle;
  NSString *startHtmlAnchor;

  IBOutlet UINavigationItem *titleNavigationItem;
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIPageControl *pageControl;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner helpData:(HelpData *)hData;

-(int)pageNumber:(NSString *)htmlAnchor;
-(IBAction)loadBackView:(id)sender;
-(IBAction)homePage:(id)sender;
-(IBAction)changePage:(id)sender;

@property (nonatomic, retain) NSString *buttonTitle;
@property (nonatomic, retain) NSString *navigationTitle;
@property (nonatomic, retain) NSString *startHtmlAnchor;
@property (nonatomic, retain) UINavigationItem *titleNavigationItem;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@end
