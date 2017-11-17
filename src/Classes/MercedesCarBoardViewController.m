//
//  MercedesCarBoardViewController.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MercedesCarBoardViewController.h"
#import "ApplicationCell.h"
#import "UsedCar.h"
#import "DetailsViewController.h"
#import "SettingsData.h"
#import "StringAttribute.h"
#import "TokenPoolViewController.h"
#import "TutorialViewController.h"
#import "GeneralInfoViewController.h"
#import "BookmarksViewController.h"
#import "IPadHelper.h"

/*
 ToDo:
 Baureihenübergreifende Beschreibung der Ausstattungslinien Classic, Avantgarde und Elegance:
 Classic
 Mit ihrer umfangreichen Serienausstattung bietet die Linie Classic alles, was das Herz eines anspruchsvollen Autofahrers höher schlagen lässt. Sie ist genau die richtige Wahl für Menschen, bei denen Qualität, Sicherheit und ein hervorragendes Preis-/Wert-Verhältnis im Vordergrund stehen. Und die sich an Design-Merkmalen erfreuen, die schon von außen erkennen lassen, was sich unter dem Kleid eines Mercedes-Benz verbirgt.
 Elegance
 Wer nicht nur ein hervorragend ausgestattetes Fahrzeug, sondern gleichzeitig ein repräsentatives Automobil sucht, trifft mit der Linie Elegance nicht nur den Nerv der Zeit: Außen eine elegante Erscheinung, innen ein perfektes Zusammenspiel von hochwertigen Materialien und harmonischen Farben. Edelhölzer, Leichtmetallfelgen und Karosserie-Details aus Chrom unterstützen das Gefühl, einen ganz besonderen Wagen zu steuern.
 Avantgarde
 Die Ausstattungslinie Avantgarde ist perfekt auf die Wünsche jener Individualisten zugeschnitten, die einerseits einen dynamischen Auftritt schätzen, andererseits aber auch auf Luxus und Komfort in ihrem Fahrzeug Wert legen. Wenn Dynamik und Sportlichkeit für Sie bereits im Stand beginnt und in der ersten Kurve noch lange nicht endet, dann dürften Sie begeistert sein.
 */

@implementation MercedesCarBoardViewController

@synthesize tableData;
//@synthesize disableViewOverlay;
//@synthesize theSearchBar;
@synthesize searchTextView;
@synthesize searchClearButton;
@synthesize searchSegmentedControl;
@synthesize tagCloud;
@synthesize theTableView;
@synthesize cellOwner;
//@synthesize openDetailSearchView;
@synthesize dateOfDataLabel, numberOfRecords;
@synthesize bottomToolbar;
@synthesize downloadIndicator, calculationIndicator;
@synthesize downloadProgress;
@synthesize downloadStatus, downloadedSize, noDataLabel;
@synthesize bookmarkView, searchFrameView;

/*-(IBAction)updateSlider:(RangeSlider *)slider {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  IntQuery *q = [searchCriteria intQuery:slider.attributeId];
  if (q == nil) q = [searchCriteria dateQuery:slider.attributeId];
  if (q != nil) {
    double m = q.maxWert;
    if (m != 0.0) {
      x = q.von/m;
      y = q.bis/m;
      z = q.bevorzugt/m;
    }
  }
  if (x != slider.min || y != slider.max || z != slider.preferred) {
    slider.min = x;
    slider.max = y;
    slider.preferred = z;
  }
}

-(IBAction)updateSearch:(RangeSlider *)sender {
  NSString *ab = nil;
  NSString *bis = nil;
  NSString *bevorzugt = nil;
  IntQuery *q = [searchCriteria intQuery:sender.attributeId];
  if (q == nil) q = [searchCriteria dateQuery:sender.attributeId];
  if (q != nil) {
    int m = q.maxWert;//+1;
    int i = (int)(sender.min*m);
    int j = (int)(sender.max*m);
    int k = (int)(sender.preferred*m);
    if (i == k && j == k) q.von = q.bis = 0;
    else {
      q.von = i;
      q.bis = j;
    }
    q.bevorzugt = k;
    ab = [[q format:i] retain];
    bis = [[q format:j] retain];
    bevorzugt = [[q format:k] retain];
  }
  intValueSearchLabel.text = [searchCriteria toSearchField];
  if (bevorzugt != nil) {
    if (bis != nil) {
      if ([ab isEqualToString:bis]) {
        sender.fromLabel.text = bevorzugt;
        sender.preferredLabel.text = @"";
        sender.toLabel.text = @"";
      } else {
        sender.fromLabel.text = [NSString stringWithFormat:@"ab %@", ab];
        sender.preferredLabel.text = [NSString stringWithFormat:@"bevorzugt %@", bevorzugt];
        sender.toLabel.text = [NSString stringWithFormat:@"bis %@", bis];
      }
    } else {
      sender.fromLabel.text = bevorzugt;
      sender.preferredLabel.text = @"";
      sender.toLabel.text = @"";
    }
  } else {
    sender.fromLabel.text = @"";
    sender.preferredLabel.text = (bevorzugt != nil)? bevorzugt : @"";
    sender.toLabel.text = @"";
  }
  [ab release];
  [bis release];
  [bevorzugt release];
}

-(IBAction)updateView:(RangeSlider *)sender {
  if (sender == nil) {
    if ([searchTextView.text length] > 0 || searchCriteria.lastParse != nil && [searchCriteria.lastParse length] > 0) {
      [searchCriteria recommendation:searchTextView.text structured:intValueSearchLabel.text maxOfRecommendations:MAX_RECOMMENDATION recommendation:tableData];
      //numberOfRecords.text = ([tableData count] == 0)? @"" : [NSString stringWithFormat:@"%d", [tableData count]];
      [ApplicationCell clearImageCache];
      [theTableView reloadData];
      [searchSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedString(@"search.tab.1", nil), [tableData count]] forSegmentAtIndex:1];
    }
  //} else {
  //  [self updateSearch:sender];
  }
  //[self textSegmentedControlValueChanged:nil];
}*/

-(IBAction)searchSegmentedControlValueChanged:(id)sender {
  if ([searchCriteria.usedCarData count] > 0) {
    if (searchSegmentedControl.selectedSegmentIndex == 1) {
      theTableView.hidden = NO;
      tagCloud.hidden = YES;
    } else {
      //[self textViewDidChange:searchTextView]; // result sets may be larger for the tag clouds
      theTableView.hidden = YES;
      tagCloud.hidden = NO;
    }
    [searchTextView resignFirstResponder];
  }
}

/*
-(IBAction)statusUpdateView:(RangeSlider *)sender {
  [self updateView:nil];
}

-(void)updateSearchSlider:(RangeSlider *)slider attributeId:(NSString *)attributeId {
  if (attributeId == nil) {
    slider.hidden = YES;
  } else {
    slider.attributeId = attributeId;
    slider.titleLabel.text = [UsedCar attributeName:attributeId];
    // ToDo: [self updateSliderScale:attributeId];
    [self updateSlider:slider];
    [self updateSearch:slider];
    [slider updateThumbViews];
    [slider updateTrackImageViews];
    slider.hidden = NO;
  }
}

-(IBAction)rangeSegmentedControlValueChanged:(id)sender {
  //SettingsData *settingsData = [SettingsData getInstance];
  NSArray *a = [UsedCar intAttributeIdOrder];
  NSInteger i = 3*rangeSegmentedControl.selectedSegmentIndex;
  int l = [a count];
  if (i >= l) {
    [self pageDetailedView:sender];
    rangeSegmentedControl.selectedSegmentIndex = 0;
  } else {
    if (i < l) {
      [self updateSearchSlider:firstSlider attributeId:[a objectAtIndex:i]];
    } else {
      [self updateSearchSlider:firstSlider attributeId:nil];
    }
    if (i+1 < l) {
      [self updateSearchSlider:secondSlider attributeId:[a objectAtIndex:i+1]];
    } else {
      [self updateSearchSlider:secondSlider attributeId:nil];
    }
    if (i+2 < l) {
      [self updateSearchSlider:thirdSlider attributeId:[a objectAtIndex:i+2]];
    } else {
      [self updateSearchSlider:thirdSlider attributeId:nil];
    }
  }
}

-(IBAction)textSegmentedControlValueChanged:(id)sender {
  if (!textSegmentedControl.hidden) {
    NSInteger i = textSegmentedControl.selectedSegmentIndex;
    if (i == 0) {
      if (sender != nil) [self pageDetailedView:sender];
      textSegmentedControl.selectedSegmentIndex = 1;
    } else {
      --i;
      NSArray *a = [UsedCar stringAttributeIdOrder];
      NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
      [tagCloud loadHTMLString:[searchCriteria tagCloud:theSearchBar.text structured:intValueSearchLabel.text attributeId:[a objectAtIndex:i]] baseURL:baseURL];
    }
  }
}

-(IBAction)switchDetailedView:(id)sender {
  if (detailedView == YES) {
    detailedView = NO;
    disableViewOverlay.hidden = YES;
    openDetailSearchView.highlighted = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    theTableView.frame = CGRectMake(originTableRect.origin.x, originTableRect.origin.y+10, originTableRect.size.width, 1004-10);
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.disableViewOverlay cache:NO];
    [UIView commitAnimations];
    //theTableView.allowsSelection = YES;
    //theTableView.scrollEnabled = YES;
  } else {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float height = 360.0;
    theTableView.frame = CGRectMake(originTableRect.origin.x, height, originTableRect.size.width, 1004-height);
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.disableViewOverlay cache:NO];
    [UIView commitAnimations];
    detailedView = YES;
    openDetailSearchView.highlighted = YES;
    disableViewOverlay.hidden = NO;
    //theTableView.allowsSelection = NO;
    //theTableView.scrollEnabled = NO;
  }
}

-(IBAction)pageDetailedView:(id)sender {
  if (!pageLeft) {
    pageLeft = YES;
    rangeSegmentedControl.hidden = YES;
    firstSlider.hidden = YES;
    secondSlider.hidden = YES;
    thirdSlider.hidden = YES;
    tagCloud.hidden = NO;
    textSegmentedControl.hidden = NO;
    [self textSegmentedControlValueChanged:nil];
  } else {
    pageLeft = NO;
    rangeSegmentedControl.hidden = NO;
    firstSlider.hidden = NO;
    secondSlider.hidden = NO;
    thirdSlider.hidden = NO;
    tagCloud.hidden = YES;
    textSegmentedControl.hidden = YES;
  }
}*/

-(void)updateLabels {
  int n = [searchCriteria.usedCarData count];
  if (n > 0) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencySymbol:@""];
    [formatter setMaximumFractionDigits:0];
    numberOfRecords.text = [formatter stringFromNumber:[NSNumber numberWithInt:n]];
    [formatter release];
  } else {
    numberOfRecords.text = @"";
  }
  numberOfRecords.hidden = NO;
  dateOfDataLabel.text = [searchCriteria.usedCarData dateOfData];
  dateOfDataLabel.hidden = NO;
}

-(void)updateGUI {
  BOOL dataAvailable = ([searchCriteria.usedCarData count] > 0);
  BOOL unloadThruMemoryWarning = (searchCriteria.lastParse != nil && [searchCriteria.lastParse length] > 0);
  noDataLabel.hidden = dataAvailable;
  theTableView.hidden = !unloadThruMemoryWarning;
  searchTextView.hidden = !dataAvailable;
  searchTextView.text = (unloadThruMemoryWarning)? searchCriteria.lastParse : NSLocalizedString(@"search.placeholder", nil);
  searchTextView.textColor = (unloadThruMemoryWarning)? [UIColor blackColor] : [UIColor lightGrayColor];
  searchClearButton.hidden = !unloadThruMemoryWarning;
  tagCloud.hidden = (!dataAvailable || unloadThruMemoryWarning);
  searchSegmentedControl.hidden = !dataAvailable;
  searchFrameView.hidden = !dataAvailable;
  searchSegmentedControl.selectedSegmentIndex = (unloadThruMemoryWarning)? 1 : 0;
  downloadStatus.text = @"";
  downloadStatus.hidden = YES;
  downloadedSize.text = @"";
  downloadedSize.hidden = YES;
  downloadProgress.hidden = YES;
  bottomToolbar.items = toolButtonItems;
  [downloadIndicator stopAnimating];
  [self updateLabels];
  Bookmarks *bookmarks = [Bookmarks getInstance];
  if (!bookmarks.disclaimerKnown) {
    GeneralInfoViewController *controller = [[GeneralInfoViewController alloc] initWithNibName:@"GeneralInfoView" owner:self fileName:@"about.txt" title:NSLocalizedString(@"about.title", nil)];
    controller.buttonTitle = NSLocalizedString(@"done", nil);
    [self presentModalViewController:controller animated:YES];
    [controller release];
    bookmarks.disclaimerKnown = YES;
    [Bookmarks save:bookmarks];
  }
  lastCheckIfUpdateNecessary = 0.0;
  if (unloadThruMemoryWarning) [self updateSearchResults];
}

-(void)initData:(NSNumber *)reload {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"init data");
  searchCriteria = [SearchCriteria getInstance:self reload:[reload boolValue]];
  BOOL unloadThruMemoryWarning = (searchCriteria.lastParse != nil && [searchCriteria.lastParse length] > 0);
  if (unloadThruMemoryWarning) {
    [self searchThread:nil];
  }
  [self performSelectorOnMainThread:@selector(updateGUI) withObject:nil waitUntilDone:NO];
  [pool release];
}

-(void)viewDidLoad {
  [super viewDidLoad];
  BOOL unloadThruMemoryWarning = ([SearchCriteria instanceExist] && searchCriteria.lastParse != nil && [searchCriteria.lastParse length] > 0);
  tableData = [[NSMutableArray alloc] initWithCapacity:MAX_RECOMMENDATION];
  searchThreadData = [[NSMutableArray alloc] initWithCapacity:10];
  searchThreadResults = [[NSMutableArray alloc] initWithCapacity:10];
  availableUpdate = nil;
  lastCheckIfUpdateNecessary = 0.0;
  toolButtonItems = [bottomToolbar.items retain];
  noDataLabel.text = NSLocalizedString(@"no.data", nil);
  bookmarkView.hidden = YES;
  [searchSegmentedControl removeAllSegments];
  [searchSegmentedControl insertSegmentWithTitle:NSLocalizedString(@"search.tab.0", nil) atIndex:0 animated:NO];
  [searchSegmentedControl insertSegmentWithTitle:[NSString stringWithFormat:NSLocalizedString(@"search.tab.1", nil), 0] atIndex:1 animated:NO];
  CGFloat width = searchSegmentedControl.frame.size.width;//[searchSegmentedControl widthForSegmentAtIndex:0];
  [searchSegmentedControl setWidth:width*0.6f forSegmentAtIndex:0];
  //[searchSegmentedControl setWidth:width*0.8f forSegmentAtIndex:1];
  bottomToolbar.items = nil;
  normalTextColor = searchTextView.textColor;
  searchTextView.hidden = YES;
  if ([IPadHelper isIPad]) searchFrameView.image = [UIImage imageNamed:@"search_frame_ipad.png"];
  searchClearButton.hidden = YES;
  searchSegmentedControl.hidden = YES;
  searchFrameView.hidden = YES;
  tagCloud.hidden = YES;
  theTableView.hidden = YES;
  originTableRect = theTableView.frame;
  originTagCloudRect = tagCloud.frame;
  dateOfDataLabel.hidden = YES;
  numberOfRecords.hidden = YES;
  downloadStatus.text = @"";
  downloadStatus.hidden = unloadThruMemoryWarning;
  downloadedSize.text = @"";
  downloadedSize.hidden = unloadThruMemoryWarning;
  downloadProgress.hidden = unloadThruMemoryWarning;
  [downloadIndicator startAnimating];
  if (unloadThruMemoryWarning) {
    searchTextView.text = searchCriteria.lastParse;
    @synchronized(searchThreadData) {
      [searchThreadData addObject:searchCriteria.lastParse];
    }
  }
  [NSThread detachNewThreadSelector:@selector(initData:) toTarget:self withObject:[NSNumber numberWithBool:NO]];
  //[self performSelectorInBackground:@selector(initData) withObject:nil];

  /*if (![IPadHelper isIPad]) {
    NSMutableArray *newButtons = [[NSMutableArray alloc] initWithArray:bottomToolbar.items];
    [newButtons removeObjectAtIndex:2];
    [newButtons removeObjectAtIndex:1];
    bottomToolbar.items = newButtons;
    [newButtons release];
  }*/

  /*originTableRect = theTableView.frame;

  float height = 304.0;
  disableViewOverlay = [[UIView alloc] initWithFrame:CGRectMake(theTableView.frame.origin.x, originTableRect.origin.y+10, theTableView.frame.size.width, height)];
  disableViewOverlay.backgroundColor = [UIColor blackColor];
  disableViewOverlay.hidden = YES;
  disableViewOverlay.alpha = 0.8;
  openDetailSearchView.hidden = YES;
  detailedView = NO;
  pageLeft = YES;

  intValueSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, theTableView.frame.size.width-20, 20)];
  intValueSearchLabel.font = [UIFont systemFontOfSize:11];
  intValueSearchLabel.backgroundColor = [UIColor clearColor];
  intValueSearchLabel.textColor = [UIColor whiteColor];
  intValueSearchLabel.text = @"";
  [disableViewOverlay addSubview:intValueSearchLabel];

  //SettingsData *settingsData = [SettingsData getInstance];
  rangeSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20, 30, theTableView.frame.size.width-40, 30)];
  rangeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  [rangeSegmentedControl insertSegmentWithTitle:@"Vorlieben" atIndex:0 animated:NO];
  [rangeSegmentedControl insertSegmentWithTitle:@"Weitere Attribute" atIndex:1 animated:NO];
  [rangeSegmentedControl insertSegmentWithTitle:@"Weitere Attribute" atIndex:2 animated:NO];
  [rangeSegmentedControl insertSegmentWithTitle:@"..." atIndex:3 animated:NO];
  [disableViewOverlay addSubview:rangeSegmentedControl];
  
	firstSlider = [[RangeSlider alloc] initWithFrame:CGRectMake(20, 84, theTableView.frame.size.width-40, 60)];
  secondSlider = [[RangeSlider alloc] initWithFrame:CGRectMake(20, 154, theTableView.frame.size.width-40, 60)];
  thirdSlider = [[RangeSlider alloc] initWithFrame:CGRectMake(20, 224, theTableView.frame.size.width-40, 60)];
	[firstSlider addTarget:self action:@selector(updateView:) forControlEvents:UIControlEventValueChanged];
	[firstSlider addTarget:self action:@selector(statusUpdateView:) forControlEvents:UIControlEventTouchUpInside];
	[secondSlider addTarget:self action:@selector(updateView:) forControlEvents:UIControlEventValueChanged];
	[secondSlider addTarget:self action:@selector(statusUpdateView:) forControlEvents:UIControlEventTouchUpInside];
	[thirdSlider addTarget:self action:@selector(updateView:) forControlEvents:UIControlEventValueChanged];
	[thirdSlider addTarget:self action:@selector(statusUpdateView:) forControlEvents:UIControlEventTouchUpInside];
  
  [disableViewOverlay addSubview:firstSlider];
  [disableViewOverlay addSubview:secondSlider];
  [disableViewOverlay addSubview:thirdSlider];
  [rangeSegmentedControl addTarget:self action:@selector(rangeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
  rangeSegmentedControl.selectedSegmentIndex = 0;
  [self rangeSegmentedControlValueChanged:rangeSegmentedControl];

  tagCloud = [[UIWebView alloc] initWithFrame:CGRectMake(20, 70, theTableView.frame.size.width-40, 230)];
  tagCloud.delegate = self;
  tagCloud.hidden = YES;
  [disableViewOverlay addSubview:tagCloud];
  textSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20, 30, theTableView.frame.size.width-40, 30)];
  textSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  [textSegmentedControl insertSegmentWithTitle:@"..." atIndex:0 animated:NO];
  NSArray *a = [UsedCar stringAttributeNameOrder];
  for (int i = 0; i < [a count]; ++i) {
    [textSegmentedControl insertSegmentWithTitle:[a objectAtIndex:i] atIndex:i+1 animated:NO];
  }
  // add 'Tags'
  [textSegmentedControl addTarget:self action:@selector(textSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
  textSegmentedControl.hidden = YES;
  [disableViewOverlay addSubview:textSegmentedControl];

  textSegmentedControl.selectedSegmentIndex = 1;
  //[self textSegmentedControlValueChanged];
  
  //CGRect rect = theTableView.frame;
  //rect.size.height = 0.0f;
  //[disableViewOverlay setFrame:rect];
  [self.view addSubview:disableViewOverlay];
  [self updateView:nil];*/
  //[settingsData release];
}

// Since this view is only for searching give the UISearchBar 
// focus right away
-(void)viewDidAppear:(BOOL)animated {
  //[self.theSearchBar becomeFirstResponder];
  [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Threads for calculations

-(void)updateTableSizeView {
  [searchSegmentedControl setTitle:[NSString stringWithFormat:NSLocalizedString(@"search.tab.1", nil), [tableData count]] forSegmentAtIndex:1];
}

-(BOOL)recommendationResultStillNeeded {
  return ([searchThreadData count] == 0);
}

-(void)searchThread:(id)sender {
  NSString *searchText = nil;
  @synchronized(searchThreadResults) {
    @synchronized(searchThreadData) {
      if ([searchThreadData count] > 1) {
        [searchThreadData removeObjectAtIndex:0];
        return;
      }
      searchText = [[searchThreadData lastObject] retain];
      [searchThreadData removeAllObjects];
    }
  }
  /*if (sender != nil || [searchText length] == 0) [self internalSearchThread:searchText];
  else {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(internalSearchThread:) userInfo:searchText repeats:NO];
    [pool release];
  }*/
  //[NSThread sleepForTimeInterval:0.3];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSLog(@"search thread: %@", searchText);
  if (searchText != nil && (sender == nil || [searchText isEqualToString:searchTextView.text])) {
    NSString *tags;
    int n = [searchCriteria.usedCarData count];
    BOOL noResult = YES;
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:n];
    @synchronized(searchThreadResults) {
      [searchCriteria recommendation:searchText structured:@"" maxOfRecommendations:n recommendation:results];
      if ([searchThreadData count] == 0) {
        if ([searchText length] == 0) {
          tags = @"";
          [results removeAllObjects];
        } else {
          tags = [searchCriteria tagCloud:searchText structured:@"" attributeId:nil grouping:YES maxTagsInResult:[IPadHelper isIPad]? 500 : 300 tmpResultArray:results];
          [searchCriteria recommendation:searchText structured:@"" maxOfRecommendations:MAX_RECOMMENDATION recommendation:results];
        }
        if ([searchThreadData count] == 0) {
          [searchThreadResults addObject:[NSArray arrayWithObjects:searchText, results, tags, nil]];
          noResult = NO;
        }
        //NSLog(@"number of results in queue: %d (%@)", [searchThreadResults count], searchText);
      } else {
        //NSLog(@"number of data in query queue: %d (%@)", [searchThreadData count], searchText);
        sender = nil;
      }
    }
    [results release];
    if (!noResult) {
      if (sender == nil) [self performSelectorOnMainThread:@selector(updateSearchResults) withObject:nil waitUntilDone:NO];
      else [self updateSearchResults];
    }
  }
  [pool release];
  [searchText release];
}

-(void)updateSearchResults {
  NSString *searchText = nil;
  NSString *tags = nil;
  NSArray *searchResults = nil;
  @synchronized(searchThreadResults) {
    if ([searchThreadResults count] > 0) {
      NSArray *args = [searchThreadResults lastObject];
      searchText = [[args objectAtIndex:0] retain];
      searchResults = [[args objectAtIndex:1] retain];
      tags = [[args objectAtIndex:2] retain];
      [searchThreadResults removeAllObjects];
    }
  }
  if (tags != nil) {
    NSLog(@"parsed search text: '%@'  current search text: '%@'", searchText, searchTextView.text);
    if ([searchText isEqualToString:searchTextView.text]) {
      [tagCloud loadHTMLString:tags baseURL:nil];
      if (![tableData isEqualToArray:searchResults]) {
        [tableData setArray:searchResults];
        [ApplicationCell clearImageCache];
        [theTableView reloadData];
        if ([tableData count] > 0) {
          [theTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        [self updateTableSizeView];
      }
    }
    [tags release];
  }
  [searchResults release];
  [searchText release];
}

#pragma mark -
#pragma mark Text view delegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
  if (searchTextView.textColor != normalTextColor) {
    if ([searchTextView.text isEqualToString:NSLocalizedString(@"search.placeholder", nil)]) searchTextView.text = @"";
    searchTextView.textColor = normalTextColor;
    searchClearButton.hidden = ([searchTextView.text length] == 0);
  }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
  if ([searchTextView.text length] == 0) {
    searchTextView.text = NSLocalizedString(@"search.placeholder", nil);
    searchTextView.textColor = [UIColor lightGrayColor];
    searchClearButton.hidden = YES;
  } else {
    searchClearButton.hidden = NO;
  }
}

-(void)textViewDidChange:(UITextView *)textView {
  if (searchTextView.textColor != normalTextColor && [searchTextView.text isEqualToString:NSLocalizedString(@"search.placeholder", nil)]) return;
  if ([searchTextView.text hasSuffix:@"\n"]) {
    searchTextView.text = [searchTextView.text substringToIndex:[searchTextView.text length]-1];
    [searchTextView resignFirstResponder];
    return;
  }
  if (calculationIndicator.hidden) {
    searchSegmentedControl.enabled = NO;
    theTableView.hidden = NO;
    Bookmarks *bookmarks = [Bookmarks getInstance];
    bookmarkView.hidden = ![bookmarks containsQueryBookmark:searchTextView.text];
    searchClearButton.hidden = ([searchTextView.text length] == 0);
    [calculationIndicator startAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    tagCloud.frame = CGRectMake(originTagCloudRect.origin.x, originTagCloudRect.origin.y+originTagCloudRect.size.height, originTagCloudRect.size.width, originTagCloudRect.size.height);
    theTableView.frame = CGRectMake(originTableRect.origin.x, originTableRect.origin.y+originTableRect.size.height, originTableRect.size.width, originTableRect.size.height);
    CGRect r = searchSegmentedControl.frame;
    searchSegmentedControl.frame = CGRectMake(r.origin.x, r.origin.y+originTagCloudRect.origin.y+originTagCloudRect.size.height, r.size.width, r.size.height);
    [UIView commitAnimations];
  }
  @synchronized(searchThreadData) {
    [searchThreadData addObject:searchTextView.text];
  }
  [NSThread detachNewThreadSelector:@selector(searchThread:) toTarget:self withObject:nil];
}

#pragma mark -
#pragma mark Web view delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted) {
    __block NSMutableString *s = [[NSMutableString alloc] initWithString:searchTextView.text];
    __block NSString *selected = [StringQuery decode:[[request URL] fragment]];
    [searchCriteria.usedCarData.attributeIndex enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
      NSString *attributeId = key;
      StringAttribute *attribute = object;
      if (attribute != nil && ![attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) {
        int i = [UsedCarData stringArraySearch:selected array:attribute.types];
        if (i >= 0) {
          if (![s hasSuffix:@" "]) [s appendString:@" "];
          [s appendString:attributeId];
          [s appendString:@" "];
          [s appendString:[StringQuery encode:selected]];
          selected = nil;
          *stop = YES;
        }
      }
    }];
    if (selected != nil) {
      NSArray *addQueries = [selected componentsSeparatedByString:@" "];
      for (NSString *addQuery in addQueries) {
        if ([addQuery length] > 0) {
          NSRange range = [s rangeOfString:addQuery];
          if (range.length == 0) {
            if (![s hasSuffix:@" "]) [s appendString:@" "];
            [s appendString:addQuery];
          }
        }
      }
    }
    searchTextView.text = s;
    [s release];
    [self textViewDidChange:searchTextView];
    [searchTextView resignFirstResponder];
    
    /*NSInteger i = textSegmentedControl.selectedSegmentIndex-1;
    if (i < 0) return YES;
    //SettingsData *settingsData = [SettingsData getInstance];
    NSArray *a = [UsedCar stringAttributeIdOrder];
    NSString *attributeId = [a objectAtIndex:i];
    StringQuery *s = [searchCriteria stringQuery:attributeId];
    StringAttribute *attribute = [searchCriteria.usedCarData.attributeIndex objectForKey:attributeId];
    int j = [UsedCarData stringArraySearch:[StringQuery decode:urlstr] array:attribute.types];
    if (j >= 0) [s add:j];
    intValueSearchLabel.text = [searchCriteria toSearchField];
    [self updateView:nil];*/
    return NO;
  }
  return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
  if ([searchThreadResults count] == 0) {
    NSLog(@"Finish WebPage reload");
    searchSegmentedControl.enabled = YES;
    theTableView.hidden = NO;
    [calculationIndicator stopAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    tagCloud.frame = originTagCloudRect;
    theTableView.frame = originTableRect;
    CGRect r = searchSegmentedControl.frame;
    searchSegmentedControl.frame = CGRectMake(r.origin.x, originTagCloudRect.origin.y-r.size.height, r.size.width, r.size.height);
    [UIView commitAnimations];
    NSString *content = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.textContent"];
    if (searchSegmentedControl.selectedSegmentIndex == 0 && content != nil && [content hasSuffix:@"}"] && [tableData count] > 0) {
      searchSegmentedControl.selectedSegmentIndex = 1;
    }
  }
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*#pragma mark -
#pragma mark UISearchBarDelegate Methods

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  NSString *t = theSearchBar.text;
  if (t != nil) {
    if ([t length] > 1) {
      if ([t hasSuffix:@" "]) {
        [self updateView:nil];
      } else if (searchCriteria.lastParse != nil && [searchCriteria.lastParse length] > [t length]) {
        [tableData removeAllObjects];
        [theTableView reloadData];
      }
    } else if ([t length] == 0) {
      //intValueSearchLabel.text = @"";
      [self updateView:nil];
      //[self rangeSegmentedControlValueChanged:rangeSegmentedControl];
    }
  }  
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  // searchBarTextDidBeginEditing is called whenever 
  // focus is given to the UISearchBar
  // call our activate method so that we can do some 
  // additional things when the UISearchBar shows.
  [self searchBar:searchBar activate:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  // searchBarTextDidEndEditing is fired whenever the 
  // UISearchBar loses focus
  // We don't need to do anything here.
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  searchBar.text = @"";
  //intValueSearchLabel.text = @"";
  [searchCriteria clear];
  [self updateView:nil];
  [self searchBar:searchBar activate:NO];
  //[self rangeSegmentedControlValueChanged:rangeSegmentedControl];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [self updateView:nil];
  [self searchBar:searchBar activate:NO];
}

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
-(void)searchBar:(UISearchBar *)searchBar activate:(BOOL)active {
  //theTableView.allowsSelection = (!active || !detailedView);
  //theTableView.scrollEnabled = (!active || !detailedView);
  if (!active) {
    [searchBar resignFirstResponder];
    //openDetailSearchView.hidden = YES;
    //disableViewOverlay.hidden = YES;
    //if (detailedView) {
    //  [self switchDetailedView:nil];
    //} else {
    //  [UIView beginAnimations:nil context:NULL];
    //  [UIView setAnimationDuration:0.5];
    //  //theTableView.frame = originTableRect;
    //  [UIView commitAnimations];
    //}
  //} else {
    //openDetailSearchView.hidden = NO;
    //disableViewOverlay.hidden = !detailedView;
    // probably not needed if you have a details view since you 
    // will go there on selection
    //NSIndexPath *selected = [self.theTableView indexPathForSelectedRow];
    //if (selected) {
    //  [self.theTableView deselectRowAtIndexPath:selected animated:NO];
    //}
    //if (!detailedView) {
    //  [UIView beginAnimations:nil context:NULL];
    //  [UIView setAnimationDuration:0.5];
    //  theTableView.frame = CGRectMake(originTableRect.origin.x, originTableRect.origin.y+10, originTableRect.size.width, 1004-10);
    //  [UIView commitAnimations];
    //}
  }
  [searchBar setShowsCancelButton:active animated:NO];
}
*/

#pragma mark -
#pragma mark Mail compose view delegate

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet {
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
  [controller setToRecipients:[NSArray arrayWithObject:@"info@mbucs.com"]];
	[controller setSubject:NSLocalizedString(@"email.subject", nil)];
  
	// Fill out the email body text
	NSMutableString *emailBody = [[NSMutableString alloc] initWithCapacity:200];
  [emailBody appendString:NSLocalizedString(@"email.comment", nil)];
  [emailBody appendFormat:@"\n\n%@ %@", NSLocalizedString(@"email.query", nil), searchTextView.text];
  [emailBody appendFormat:@"\n\n%@ %@", NSLocalizedString(@"email.app.version", nil), [SettingsData appVersion]];
  [emailBody appendFormat:@"\n%@ %@", NSLocalizedString(@"email.data.version", nil), [searchCriteria.usedCarData dateOfData]];
  [emailBody appendFormat:@"\n\n%@", NSLocalizedString(@"email.profile", nil)];
  SettingsData *settings = [SettingsData getInstance];
  for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {
    NSString *pId = [UsedCarData getPropertyId:i];
    int factor = [settings value:pId];
    [emailBody appendFormat:@"\n%@ - %d", pId, factor];
  }
  [emailBody appendFormat:@"\n\n%@\n", NSLocalizedString(@"email.results", nil)];
  int n = MIN([tableData count], MAX_RECOMMENDATION);
  for (int i = 0; i < n; ++i) {
    UsedCar *u = [tableData objectAtIndex:i];
    [emailBody appendString:u.gfzNumber];
    if (i+1 < n) [emailBody appendString:@";"];
  }
  [controller setMessageBody:emailBody isHTML:NO];
  [emailBody release];
	[self presentModalViewController:controller animated:YES];
  [controller release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	switch (result)	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
			break;
		default:
			//message.text = @"Result: not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Actions

-(IBAction)infoView:(id)sender {
  [searchTextView resignFirstResponder];
  UIActionSheet *sheet = [[UIActionSheet alloc]
                          initWithTitle:NSLocalizedString(@"info.action.sheet.title", nil)
                          delegate:self
                          cancelButtonTitle:nil
                          destructiveButtonTitle:NSLocalizedString(@"cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"info.action.sheet.button1", nil),
                          NSLocalizedString(@"info.action.sheet.button2", nil),
                          NSLocalizedString(@"info.action.sheet.button3", nil),
                          nil];
  sheet.actionSheetStyle = UIActionSheetStyleDefault;
  sheet.tag = 2;
  [sheet showFromBarButtonItem:[bottomToolbar.items lastObject] animated:YES];
  [sheet release];
}

-(IBAction)tagsView:(id)sender {
  //TokenPoolViewController *controller = [[TokenPoolViewController alloc] initWithNibName:@"TokenPoolView" owner:self tags:searchCriteria.tags];
  TokenPoolViewController *controller = [[TokenPoolViewController alloc] initWithNibName:@"TokenPoolView-iPad" owner:self tags:searchCriteria.tags];
  [self presentModalViewController:controller animated:YES];
  [controller release];
}

-(IBAction)actionView:(id)sender {
  [searchTextView resignFirstResponder];
  UIActionSheet *sheet = [[UIActionSheet alloc]
                          initWithTitle:NSLocalizedString(@"action.sheet.title", nil)
                          delegate:self
                          cancelButtonTitle:nil
                          destructiveButtonTitle:NSLocalizedString(@"cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"action.sheet.button1", nil),
                          NSLocalizedString(@"action.sheet.button2", nil),
                          NSLocalizedString(@"action.sheet.button3", nil),
                          nil];
  sheet.actionSheetStyle = UIActionSheetStyleDefault;
  sheet.tag = 3;
  int l = [bottomToolbar.items count];
  if (l >= 4) l = l/2;
  else if (l > 0) --l;
  [sheet showFromBarButtonItem:[bottomToolbar.items objectAtIndex:l] animated:YES];
  [sheet release];
}

-(IBAction)clearSearch:(id)sender {
  [searchCriteria clear];
  searchTextView.text = @"";
  [self textViewDidChange:searchTextView];
  [searchTextView resignFirstResponder];
}

-(void)areUpdatesAvailable {
  [calculationIndicator stopAnimating];
  if (availableUpdate == nil) {
    UIAlertView *dialog = [[UIAlertView alloc]
                           initWithTitle:NSLocalizedString(@"update.alert.title", nil)
                           message:NSLocalizedString(@"update.alert.text", nil)
                           delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"ok", nil)
                           otherButtonTitles:nil];
    [dialog show];
    [dialog release];
  } else {
    UIAlertView *dialog = nil;
    if (availableUpdate.version == 0.0) {
      dialog = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"update.alert.title", nil)
                message:NSLocalizedString(@"update.alert.cannot.connect", nil)
                delegate:nil
                cancelButtonTitle:NSLocalizedString(@"ok", nil)
                otherButtonTitles:nil];
      [availableUpdate release];
      availableUpdate = nil;
    } else {
      dialog = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"update.alert.title", nil)
                message:[NSString stringWithFormat:NSLocalizedString(@"update.alert.available", nil), [WebData sizeToString:availableUpdate.fileSize]]
                delegate:self
                cancelButtonTitle:NSLocalizedString(@"no", nil)
                otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
      dialog.tag = 1;
    }
    [dialog show];
    [dialog release];
  }
}

-(void)checkAvailableUpdates {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  availableUpdate = [[WebData availableUpdates:self] retain];
  [self performSelectorOnMainThread:@selector(areUpdatesAvailable) withObject:nil waitUntilDone:NO];
  [pool release];
}

-(IBAction)checkAvailableDownloads:(id)sender {
  [calculationIndicator startAnimating];
  [availableUpdate release];
  availableUpdate = nil;
  [NSThread detachNewThreadSelector:@selector(checkAvailableUpdates) toTarget:self withObject:nil];
}

#pragma mark -
#pragma mark InAppSettings delegate

-(void)updateSettings {
  [SettingsData getInstance:YES];
  [searchCriteria clear];
  [self textViewDidChange:searchTextView];
}

#pragma mark -
#pragma mark Action sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet.tag == 2) {
    if (buttonIndex == 1) { // Tutorial
      TutorialViewController *controller = [[TutorialViewController alloc] initWithNibName:@"TutorialView" owner:self helpData:[HelpData getHelpData]];
      [self presentModalViewController:controller animated:YES];
      [controller release];
    } else if (buttonIndex == 2) { // About
      GeneralInfoViewController *controller = [[GeneralInfoViewController alloc] initWithNibName:@"GeneralInfoView" owner:self fileName:@"about.txt" title:NSLocalizedString(@"about.title", nil)];
      [self presentModalViewController:controller animated:YES];
      [controller release];
    } else if (buttonIndex == 3) { // Profile
      InAppSettingsViewController *controller = [[InAppSettingsViewController alloc] initWithNibName:@"InAppSettingsView" bundle:nil];
      controller.delegate = self;
      controller.preferenceTitle = @"Profile";
      [self presentModalViewController:controller animated:YES];
      [controller release];
    }
  } else if (actionSheet.tag == 3) {
    if (buttonIndex == 1) { // Abfrage merken
      Bookmarks *bookmarks = [Bookmarks getInstance];
      if (!searchClearButton.hidden && [searchTextView.text length] > 0 && ![bookmarks containsQueryBookmark:searchTextView.text]) {
        [bookmarks addQueryBookmark:searchTextView.text];
        [Bookmarks save:bookmarks];
        bookmarkView.hidden = NO;
      }
    } else if (buttonIndex == 2) { // Merkzettel
      BookmarksViewController *controller = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" owner:self bookmarks:[Bookmarks getInstance]];
      [self presentModalViewController:controller animated:YES];
      [controller release];
    } else if (buttonIndex == 3) { // Feedback
      if ([MFMailComposeViewController canSendMail]) {
        [self displayComposerSheet];
      }
    }
  }
}

#pragma mark -
#pragma mark Update delegate

-(void)updateStatusGUI:(NSArray *)args {
  NSString *status = [args objectAtIndex:0];
  double percentage = [[args objectAtIndex:1] doubleValue];
  downloadStatus.text = status;
  downloadProgress.progress = (percentage < 0.0)? 0.0 : percentage;
  if (percentage < 0.0 || percentage == 1.0) {
    if (percentage < 0.0) {
      UIAlertView *dialog = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"error", nil)
                             message:status
                             delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                             otherButtonTitles:nil];
      [dialog show];
      [dialog release];
      [self updateGUI];
    } else {
      [NSThread detachNewThreadSelector:@selector(initData:) toTarget:self withObject:[NSNumber numberWithBool:YES]];
    }
  }
}

-(void)status:(NSString *)status percentage:(double)percentage {
  NSNumber *n = [[NSNumber alloc] initWithDouble:percentage];
  NSArray *args = [[NSArray alloc] initWithObjects:status, n, nil];
  [self performSelectorOnMainThread:@selector(updateStatusGUI:) withObject:args waitUntilDone:NO];
  [n release];
  [args release];
}

-(void)updateDownloadedGUI:(NSString *)number {
  downloadedSize.text = number;
}

-(void)downloaded:(NSString *)number {
  [self performSelectorOnMainThread:@selector(updateDownloadedGUI:) withObject:number waitUntilDone:NO];
}

#pragma mark -
#pragma mark Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1 && alertView.tag == 2) {
    Bookmarks *bookmarks = [Bookmarks getInstance];
    [bookmarks clearUsedCarBookmarks];
    [Bookmarks save:bookmarks];
  }
  if (buttonIndex == 1 && availableUpdate != nil) {
    Bookmarks *bookmarks = [Bookmarks getInstance];
    if ([bookmarks.usedCarBookmarks count] > 0) {
      UIAlertView *dialog = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"update.alert.title", nil)
                             message:NSLocalizedString(@"update.alert.bookmarks", nil)
                             delegate:self
                             cancelButtonTitle:NSLocalizedString(@"no", nil)
                             otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
      dialog.tag = 2;
      [dialog show];
      [dialog release];
      return;
    }
    [downloadIndicator startAnimating];
    downloadStatus.text = @"";
    downloadStatus.hidden = NO;
    downloadedSize.text = @"";
    downloadedSize.hidden = NO;
    downloadProgress.progress = 0.0;
    downloadProgress.hidden = NO;
    bottomToolbar.items = nil;
    searchTextView.hidden = YES;
    searchSegmentedControl.hidden = YES;
    searchFrameView.hidden = YES;
    noDataLabel.hidden = YES;
    dateOfDataLabel.hidden = YES;
    numberOfRecords.hidden = YES;
    [self clearSearch:self];
    [availableUpdate update];
    //updateNecessary = NO;
  }
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [tableData count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *appCellId = @"ApplicationCell";
  ApplicationCell *appCell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:appCellId];
  if (appCell == nil) {
    [cellOwner loadNibNamed:appCellId owner:self];
    appCell = (ApplicationCell *)cellOwner.cell;
  }
  UsedCar *u = [tableData objectAtIndex:indexPath.row];
  if ([IPadHelper isIPad]) {
    IntQuery *q = [[IntQuery alloc] init:MOTORLEISTUNG];
    appCell.psLabel.text = [q format:[u attribute:MOTORLEISTUNG]];
    [q release];
    appCell.psLabel.hidden = NO;
    appCell.leistungenLabel.text = [u stringAttribute:GARANTIE];
    appCell.leistungenLabel.hidden = NO;
  } else {
    appCell.psLabel.hidden = YES;
    appCell.leistungenLabel.hidden = YES;
    CGRect r = appCell.modelLabel.frame;
    r.size.width = 235;
    appCell.modelLabel.frame = r;
    r = appCell.kmLabel.frame;
    r.origin.x = 140;
    appCell.kmLabel.frame = r;
    //r = appCell.erstzulassungLabel.frame;
    //r.origin.x = 220;
    //appCell.erstzulassungLabel.frame = r;
  }
  //[appCell setIcon:[UIImage imageNamed:[u.gfzNumber stringByAppendingString:@".jpg"]]];
  //NSArray *images = [WebData linksToImages:u.gfzNumber]; //[u getBilder];
  //if (images != nil && [images count] > 0) 
  [appCell loadImageFrom:u];//[images objectAtIndex:0]];
  //else [appCell enabled];
  // [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[u.bilder objectAtIndex:0]]
  appCell.modelLabel.text = [u stringAttribute:MODELL];
  appCell.erstzulassungLabel.text = [DateQuery intToDate:[u attribute:ERSTZULASSUNG]];
  IntQuery *q = [[IntQuery alloc] init:KAUFPREIS];
  appCell.priceLabel.text = [q format:[u attribute:KAUFPREIS]];
  [q release];
  q = [[IntQuery alloc] init:KILOMETERSTAND];
  appCell.kmLabel.text = [q format:[u attribute:KILOMETERSTAND]];
  [q release];
  [appCell setPreferenceFit:u.preferenceFit];
  appCell.certificateView.hidden = ![u hasCertificate];
  Bookmarks *bookmarks = [Bookmarks getInstance];
  BOOL marked = [bookmarks containsUsedCarBookmark:u];
  appCell.bookmarkView.hidden = !marked;
  UIColor *color = (marked)? [UIColor colorWithRed:0.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.05f] : [UIColor clearColor];
  appCell.contentView.backgroundColor = color;
  appCell.backgroundColor = color;
  appCell.selectionStyle = (appCell.imageExisting)? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
  return appCell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  ApplicationCell *cell = (ApplicationCell *)[tableView cellForRowAtIndexPath:indexPath];
  return (cell.imageExisting)? indexPath : nil;
}

-(void)detailsView:(UsedCar *)usedCar {
  DetailsViewController *controller = nil;
  if ([IPadHelper isIPad]) {
    controller = [[DetailsViewController alloc] initWithNibName:@"DetailsView-iPad" owner:self usedCar:usedCar];
  } else {
    controller = [[DetailsViewController alloc] initWithNibName:@"DetailsView" owner:self usedCar:usedCar];
  }
  controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
  [self presentModalViewController:controller animated:YES];
  [controller release];
  NSIndexPath *indexPath = [theTableView indexPathForSelectedRow];
  if (indexPath != nil) [theTableView deselectRowAtIndexPath:indexPath animated:NO];
  [calculationIndicator stopAnimating];
}

-(void)loadOnlineData:(UsedCar *)usedCar {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [WebData onlinePage:usedCar];
  [self performSelectorOnMainThread:@selector(detailsView:) withObject:usedCar waitUntilDone:NO];
  [pool release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [searchTextView resignFirstResponder];
  BOOL viewRecord = YES;
  double now = [NSDate timeIntervalSinceReferenceDate];
  if (lastCheckIfUpdateNecessary == 0.0 || now-lastCheckIfUpdateNecessary > 24*3600.0) {
    lastCheckIfUpdateNecessary = now;
    if ([WebData isUpdateNecessary:searchCriteria.usedCarData.versionOfData]) {
      UIAlertView *dialog = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"update.alert.title", nil)
                             message:NSLocalizedString(@"update.alert.necessary", nil)
                             delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                             otherButtonTitles:nil];
      [dialog show];
      [dialog release];
      [WebData deleteImageCachePath:searchCriteria.usedCarData.versionOfData];
      viewRecord = NO;
    }
  }
  if (viewRecord) {
    [calculationIndicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(loadOnlineData:) toTarget:self withObject:[tableData objectAtIndex:indexPath.row]];
  }
}

#pragma mark -
#pragma mark Memory Management Methods

-(void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

-(void)viewDidUnload {
  lastCheckIfUpdateNecessary = 0.0;
  theTableView = nil;
  //theSearchBar = nil;
  searchTextView = nil;
  searchClearButton = nil;
  searchSegmentedControl = nil;
  tagCloud = nil;
  cellOwner = nil;
  //disableViewOverlay = nil;
  //openDetailSearchView = nil;
  dateOfDataLabel = nil;
  numberOfRecords = nil;
  bottomToolbar = nil;
  downloadIndicator = nil;
  calculationIndicator = nil;
  downloadProgress = nil;
  downloadStatus = nil;
  downloadedSize = nil;
  noDataLabel = nil;
  bookmarkView = nil;
  searchFrameView = nil;
}

-(void)dealloc {
  lastCheckIfUpdateNecessary = 0.0;
  [searchThreadData release];
  [searchThreadResults release];
  [availableUpdate release];
  [theTableView release];
  //[theSearchBar release];
  [searchTextView release];
  [searchClearButton release];
  [searchSegmentedControl release];
  [tagCloud release];
  [cellOwner release];
  [searchCriteria dealloc];
  [tableData dealloc];
  /*[disableViewOverlay release];
  [rangeSegmentedControl release];
  [firstSlider release];
  [secondSlider release];
  [thirdSlider release];
  [textSegmentedControl release];
  [openDetailSearchView release];*/
  [dateOfDataLabel release];
  [numberOfRecords release];
  [bottomToolbar release];
  [downloadIndicator release];
  [calculationIndicator release];
  [downloadProgress release];
  [downloadStatus release];
  [downloadedSize release];
  [noDataLabel release];
  [bookmarkView release];
  [searchFrameView release];
  [toolButtonItems release];
  [super dealloc];
}

@end
