//
//  MercedesCarBoardViewController.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CellOwner.h"
#import "SearchCriteria.h"
#import "RangeSlider.h"
#import "WebData.h"
#import "InAppSettingsViewController.h"

@interface MercedesCarBoardViewController : UIViewController </*UISearchBarDelegate,*/ UITableViewDataSource, UITextViewDelegate, UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UpdateDelegate, SearchCriteriaDelegate,InAppSettingsDelegate> {
	NSMutableArray *tableData;
  SearchCriteria *searchCriteria;
  WebData *availableUpdate;
  //BOOL detailedView;
  BOOL pageLeft;
  double lastCheckIfUpdateNecessary;

  NSMutableArray *searchThreadData;
  NSMutableArray *searchThreadResults;

	//IBOutlet UIView *disableViewOverlay;
  IBOutlet UITableView *theTableView;
  //IBOutlet UISearchBar *theSearchBar;
  IBOutlet UITextView *searchTextView;
  IBOutlet UIButton *searchClearButton;
  IBOutlet UISegmentedControl *searchSegmentedControl;
  IBOutlet UIWebView *tagCloud;
  IBOutlet CellOwner *cellOwner;
  //IBOutlet UIButton *openDetailSearchView;
  IBOutlet UILabel *dateOfDataLabel;
  IBOutlet UILabel *numberOfRecords;
  IBOutlet UIToolbar *bottomToolbar;
  IBOutlet UIActivityIndicatorView *downloadIndicator;
  IBOutlet UIActivityIndicatorView *calculationIndicator;
  IBOutlet UIProgressView *downloadProgress;
  IBOutlet UILabel *downloadStatus;
  IBOutlet UILabel *downloadedSize;
  IBOutlet UILabel *noDataLabel;
  IBOutlet UIImageView *bookmarkView;
  IBOutlet UIImageView *searchFrameView;

  NSArray *toolButtonItems;
  /*UILabel *intValueSearchLabel;
  UISegmentedControl *rangeSegmentedControl;
  RangeSlider *firstSlider;
  RangeSlider *secondSlider;
  RangeSlider *thirdSlider;
  UISegmentedControl *textSegmentedControl;
  UIWebView *tagCloud;*/
  CGRect originTableRect;
  CGRect originTagCloudRect;
  UIColor *normalTextColor;
}

-(void)updateTableSizeView;
-(void)searchThread:(id)sender;
-(void)updateSearchResults;

/*-(IBAction)updateSlider:(RangeSlider *)slider;
-(IBAction)updateSearch:(RangeSlider *)sender;
-(IBAction)updateView:(RangeSlider *)sender;*/
-(IBAction)searchSegmentedControlValueChanged:(id)sender;
/*-(IBAction)rangeSegmentedControlValueChanged:(id)sender;
-(IBAction)textSegmentedControlValueChanged:(id)sender;
-(IBAction)switchDetailedView:(id)sender;
-(IBAction)pageDetailedView:(id)sender;*/
//-(void)searchBar:(UISearchBar *)searchBar activate:(BOOL)active;
-(IBAction)infoView:(id)sender;
-(IBAction)tagsView:(id)sender;
-(IBAction)actionView:(id)sender;
-(IBAction)clearSearch:(id)sender;
-(IBAction)checkAvailableDownloads:(id)sender;

-(void)updateSettings;

@property (retain, nonatomic) NSMutableArray *tableData;
//@property (retain, nonatomic) UIView *disableViewOverlay;

@property (retain, nonatomic) UITableView *theTableView;
//@property (retain, nonatomic) UISearchBar *theSearchBar;
@property (retain, nonatomic) UITextView *searchTextView;
@property (retain, nonatomic) UIButton *searchClearButton;
@property (retain, nonatomic) UISegmentedControl *searchSegmentedControl;
@property (retain, nonatomic) UIWebView *tagCloud;
@property (retain, nonatomic) CellOwner *cellOwner;
//@property (retain, nonatomic) UIButton *openDetailSearchView;
@property (retain, nonatomic) UILabel *dateOfDataLabel;
@property (retain, nonatomic) UILabel *numberOfRecords;
@property (retain, nonatomic) UIToolbar *bottomToolbar;
@property (nonatomic, retain) UIActivityIndicatorView *downloadIndicator;
@property (nonatomic, retain) UIActivityIndicatorView *calculationIndicator;
@property (nonatomic, retain) UIProgressView *downloadProgress;
@property (nonatomic, retain) UILabel *downloadStatus;
@property (nonatomic, retain) UILabel *downloadedSize;
@property (nonatomic, retain) UILabel *noDataLabel;
@property (nonatomic, retain) UIImageView *bookmarkView;
@property (nonatomic, retain) UIImageView *searchFrameView;

@end
