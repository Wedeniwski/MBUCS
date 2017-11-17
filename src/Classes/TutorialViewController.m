//
//  TutorialViewController.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TutorialViewController.h"
#import "IPadHelper.h"
#import "MercedesCarBoardViewController.h"

@implementation TutorialViewController

@synthesize buttonTitle, navigationTitle, startHtmlAnchor;
@synthesize titleNavigationItem;
@synthesize scrollView;
@synthesize pageControl;

-(void)updatePageWidthHeight:(UIInterfaceOrientation)toInterfaceOrientation {
  //MercedesCarBoardAppDelegate *app = (MercedesCarBoardAppDelegate *)[[UIApplication sharedApplication] delegate];
  //CGRect r = app.window.frame;  
  CGRect r = [[UIScreen mainScreen] bounds];
  if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
    pageWidth = r.size.width;
    pageHeight = r.size.height-100;
  } else {
    pageHeight = r.size.width;
    pageWidth = r.size.height;
  }
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner helpData:(HelpData *)hData {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self != nil) {
    delegate = owner;
    helpData = [hData retain];
    numberOfPages = [helpData.keys count]+1;
    webPages = nil;
    navigationTitle = nil;
    startHtmlAnchor = nil;
  }
  return self;
}

-(void)updateView {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  BOOL iPad = [IPadHelper isIPad];
  int fontSize = (iPad)? 14 : 12;
  
  scrollView.contentSize = CGSizeMake(pageWidth * numberOfPages, pageHeight);
  
  NSMutableString *s = [[NSMutableString alloc] initWithCapacity:2000];
  [s setString:@"<html><head>"];
  [s appendFormat:@"</head><body style=\"font-family:helvetica;font-size:%dpxbackground-color: transparent\"><ul>", fontSize];
  for (NSString *pageKey in helpData.keys) {
    [s appendFormat:@"<li><a href=\"#%@\">%@</a></li>", pageKey, [helpData.titles objectForKey:pageKey]];
  }
  [s appendString:@"</ul></body></html>"];
  //NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  CGRect frame = scrollView.frame;
  frame.origin.x = 10;
  frame.origin.y = 10;
  frame.size.width = pageWidth-20;
  frame.size.height = pageHeight-20;
  NSMutableArray *pages = nil;
  if (webPages == nil) {
    pages = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    UIWebView *webPage = [[UIWebView alloc] initWithFrame:frame];
    webPage.backgroundColor = [UIColor clearColor];
    webPage.delegate = self;
    [webPage loadHTMLString:[NSString stringWithString:s] baseURL:nil];
    [pages addObject:webPage];
    [scrollView addSubview:webPage];
    [webPage release];
  } else {
    UIWebView *webPage = [webPages objectAtIndex:0];
    webPage.frame = frame;
    [webPage loadHTMLString:[NSString stringWithString:s] baseURL:nil];
  }
  int page = 1;
  for (NSString *pageKey in helpData.keys) {
    frame.origin.x = pageWidth*page + 10;
    [s setString:@"<html><head>"];
    [s appendFormat:@"</head><body style=\"font-family:helvetica;font-size:%dpxbackground-color: transparent\"><h2>", fontSize];
    [s appendString:[helpData.titles objectForKey:pageKey]];
    [s appendString:@"</h2>"];
    [s appendString:[helpData.pages objectForKey:pageKey]];
    [s appendString:@"</body></html>"];
    if (webPages == nil) {
      UIWebView *webPage = [[UIWebView alloc] initWithFrame:frame];
      webPage.backgroundColor = [UIColor clearColor];
      webPage.delegate = self;
      [webPage loadHTMLString:[NSString stringWithString:s] baseURL:nil];
      [pages addObject:webPage];
      [scrollView addSubview:webPage];
      [webPage release];
    } else {
      UIWebView *webPage = [webPages objectAtIndex:page];
      webPage.frame = frame;
      [webPage loadHTMLString:[NSString stringWithString:s] baseURL:nil];
    }
    ++page;
  }
  [s release];
  if (pages != nil) webPages = pages;
  [pool release];
}

-(int)pageNumber:(NSString *)htmlAnchor {
  if (htmlAnchor == nil) return 0;
  int page = 1;
  for (NSString *pageKey in helpData.keys) {
    if ([pageKey isEqualToString:htmlAnchor]) break;
    ++page;
  }
  return (page >= numberOfPages)? 0 : page;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad {
  [super viewDidLoad];
  titleNavigationItem.title = (navigationTitle != nil)? navigationTitle : NSLocalizedString(@"tutorial.title", nil);
  titleNavigationItem.leftBarButtonItem.title = (buttonTitle != nil)? buttonTitle : NSLocalizedString(@"back", nil);

  pageControl.numberOfPages = numberOfPages;
  pageControl.currentPage = [self pageNumber:startHtmlAnchor];

  scrollView.pagingEnabled = YES;
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.delegate = self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self updatePageWidthHeight:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self updateView];
  [self changePage:self];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted) {
    pageControl.currentPage = [self pageNumber:[[request URL] fragment]];
    [self changePage:self];
    return NO;
  }
  return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
  // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
  // which a scroll event generated from the user hitting the page control triggers updates from
  // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
  if (pageControlUsed) return; // do nothing - the scroll was initiated from the page control, not the user dragging

  // Switch the indicator when more than 50% of the previous/next page is visible
  int page = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
  pageControl.currentPage = page;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  pageControlUsed = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  pageControlUsed = NO;
}

-(IBAction)loadBackView:(id)sender {
  if (buttonTitle != nil && [delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
    MercedesCarBoardViewController *controller = (MercedesCarBoardViewController *)delegate;
    [controller checkAvailableDownloads:self];
  }
	[delegate dismissModalViewControllerAnimated:YES];
}

-(IBAction)homePage:(id)sender {
  pageControl.currentPage = 0;
  [self changePage:sender];
}

-(IBAction)changePage:(id)sender {
	// update the scroll view to the appropriate page
  CGRect frame = scrollView.frame;
  frame.origin.x = pageWidth * pageControl.currentPage;
  frame.origin.y = 10;
  [scrollView scrollRectToVisible:frame animated:YES];
  pageControlUsed = YES;
}

-(void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Relinquish ownership any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
  [super viewDidUnload];
  buttonTitle = nil;
  navigationTitle = nil;
  startHtmlAnchor = nil;
  titleNavigationItem = nil;
  scrollView = nil;
  pageControl = nil;
}

-(void)dealloc {
  [buttonTitle release];
  [helpData release];
  [webPages release];
  [navigationTitle release];
  [startHtmlAnchor release];
  [titleNavigationItem release];
  [scrollView release];
  [pageControl release];
  [super dealloc];
}

@end
