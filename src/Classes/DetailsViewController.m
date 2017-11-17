//
//  DetailsViewController.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DetailsViewController.h"
#import "MercedesCarBoardViewController.h"
#import "TutorialViewController.h"
#import "DateQuery.h"
#import "SearchCriteria.h"
#import "IPadHelper.h"
#import "WebData.h"
#import "HelpData.h"
#import "Bookmarks.h"

@implementation DetailsViewController

@synthesize navigation;
@synthesize addBookmark, viewLocation;
@synthesize modelLabel;//, searchHighlightLabel;
//@synthesize highlight;
@synthesize imageWebView, detailsWebView, contactWebView, featuresWebView, imagesWebView;
@synthesize favoriteView;
@synthesize calculationIndicator;

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner usedCar:(UsedCar *)u {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self != nil) {
    delegate = owner;
    usedCar = [u retain];
    NSRange range = [usedCar.gfzNumber rangeOfString:@","];
    usedCarGFZ = (range.length == 0)? [usedCar.gfzNumber retain] : [[usedCar.gfzNumber substringToIndex:range.location] retain];
  }
  return self;
}

#pragma mark -
#pragma mark Actions

-(IBAction)loadBackView:(id)sender {
  if (detailsWebView.frame.origin.y != originalWebView.origin.y) {
    [self updateView:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    detailsWebView.frame = originalWebView;
    //highlight.hidden = NO;
    //searchHighlightLabel.hidden = NO;
    [UIView commitAnimations];
  } else {
    if ([delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
      MercedesCarBoardViewController *m = (MercedesCarBoardViewController *)delegate;
      [m.theTableView reloadData];
    }
    [delegate dismissModalViewControllerAnimated:YES];
  }
}

-(IBAction)addFavorite:(id)sender {
  Bookmarks *bookmarks = [Bookmarks getInstance];
  [bookmarks addUsedCarBookmark:usedCar];
  [Bookmarks save:bookmarks];
  addBookmark.hidden = YES;
  navigation.title = NSLocalizedString(@"detailed.view.title.favorite", nil);
  favoriteView.hidden = NO;
}

-(IBAction)viewLocation:(id)sender {
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  if (usedCar.locationIndex >= 0 && usedCar.locationIndex < [searchCriteria.usedCarData.latitudeLongitudeOfAddresses count]) {
    NSString *address = [searchCriteria.usedCarData getAddressOf:usedCar];
    /*CLLocation *location = [searchCriteria.usedCarData.latitudeLongitudeOfAddresses objectAtIndex:usedCar.locationIndex];
    NSString *latlong = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@&mrt=yp&ll=%@",
                     [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];*/
    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@&mrt=yp",
                     [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
  }
}

-(IBAction)sendData:(id)sender {
  [calculationIndicator startAnimating];
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  NSArray *images = [WebData linksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:NO];
  if (images != nil && [images count] > 0) {
    BOOL alt = [WebData isAltImageURL:[images objectAtIndex:0]];
    UIAlertView *dialog = [[UIAlertView alloc]
                           initWithTitle:(alt)? NSLocalizedString(@"email.attachments.alt.image.title", nil) : NSLocalizedString(@"email.attachments.image.title", nil)
                           message:(alt)? NSLocalizedString(@"email.attachments.alt.higher.resolution", nil) : NSLocalizedString(@"email.attachments.higher.resolution", nil)
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"no", nil)
                           otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    dialog.tag = 2;
    [dialog show];
    [dialog release];
  } else {
    [self createEmail:-1];
  }
}

-(void)createEmail:(int)attachmentSize {
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  SettingsData *settings = [SettingsData getInstance];
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:[NSString stringWithFormat:@"MBUCS:[%@]", [usedCar stringAttribute:MODELL]]];
	NSMutableString *emailBody = [[NSMutableString alloc] initWithCapacity:200];
  [emailBody appendFormat:@"GFZ: %@\n\n", usedCarGFZ];
  BOOL propertyFit = NO;
  for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {
    float f = [usedCar getPropertyFactor:i usedCarData:searchCriteria.usedCarData settings:settings];
    if (f > 0.0f) {
      if (!propertyFit) [emailBody appendFormat:@"%@  (%d%%)\n", NSLocalizedString(@"detailed.view.buyer.preferences", nil), (int)(usedCar.preferenceFit*100)];
      [emailBody appendFormat:@"%@: %d%%\n", [settings name:[UsedCarData getPropertyId:i]], (int)(f*100)];
      propertyFit = YES;
    }
  }
  if (propertyFit) [emailBody appendString:@"\n"];
  [emailBody appendFormat:@"%@\n", NSLocalizedString(@"detailed.view.car.description", nil)];
  NSArray *attributes = [UsedCar attributeIdOrder];
  for (NSString *attributeId in attributes) {
    if ([attributeId isEqualToString:MODELL] || [attributeId isEqualToString:KONTAKT] || [attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) continue;  // ToDo: find generic solution
    id query = [searchCriteria dateQuery:attributeId];
    if (query == nil) query = [searchCriteria intQuery:attributeId];
    if (query != nil) {
      if ([attributeId isEqualToString:KRAFTSTOFFVERBRAUCH] || [attributeId isEqualToString:CO2_EMISSIONEN]) {
        if ([usedCar attribute:attributeId] == 0) continue;  // ToDo: find generic solution
      }
      [emailBody appendFormat:@"%@: %@\n", [UsedCar attributeName:attributeId], [query format:[usedCar attribute:attributeId]]];
    } else {
      query = [searchCriteria stringQuery:attributeId];
      if (query != nil) {
        NSString *text = [usedCar stringAttribute:attributeId];
        if (text != nil && [text length] > 0) {
          [emailBody appendFormat:@"%@: %@\n", [UsedCar attributeName:attributeId], text];
        }
      }
    }
  }
  [emailBody appendFormat:@"\n%@\n", [UsedCar attributeName:AUSSTATTUNGSMERKMALE]];
  for (NSString *feature in [usedCar getAustattungsmerkmale:searchCriteria.usedCarData.attributeIndex]) {
    [emailBody appendFormat:@"- %@\n", feature];
  }
  [controller setMessageBody:emailBody isHTML:NO];
  if (attachmentSize >= 0) {
    NSArray *images = [WebData linksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:NO];
    int i = 0;
    for (NSString *image in images) {
      NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[WebData getImageURL:image size:attachmentSize]]];
      if (data != nil) {
        [controller addAttachmentData:data mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@_%d.jpg", usedCarGFZ, i]];
        ++i;
      }
    }
  }
  [emailBody release];
	[self presentModalViewController:controller animated:YES];
  [controller release];
  [calculationIndicator stopAnimating];
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

-(IBAction)updateView:(id)sender {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *highlightColor = @"#14ba22";
  //NSString *highlightColorIndirect = highlightColor; // ToDo
  BOOL highlightText = YES;//highlight.on;
  //iPhone
  //NSMutableString *s = [[NSMutableString alloc] initWithString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style><style type=\"text/css\">table {font-family:helvetica;font-size:12px;background-color:transparent;}</style></head><body><table>"];
  //iPad
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  IntSet *queryTags = [[IntSet alloc] initWithCapacity:[searchCriteria.genericTagQuery count]+1];
  for (NSString *tag in searchCriteria.genericTagQuery) {
    [queryTags add:[searchCriteria.tags convertTagToId:tag]];
  }
  //NSSet *queryTags = [[NSSet setWithArray:[queryAllTags allValues]] retain];  // BUG! All NSNumber values will be translated to NSString!
  //NSLog(@"queryTags: %@", queryTags);
  modelLabel.text = [usedCar stringAttribute:MODELL];
  if (highlightText && [queryTags intersectsSet:[searchCriteria.tags validTags:modelLabel.text]]) {
    modelLabel.textColor = [UIColor colorWithRed:20.0f/255.0f green:186.0f/255.0f blue:34.0f/255.0f alpha:1.0];
  }
  modelLabel.backgroundColor = [UIColor clearColor];
  SettingsData *settings = [SettingsData getInstance];
  NSMutableString *s = [[NSMutableString alloc] initWithString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style><style type=\"text/css\">table {font-family:helvetica;font-size:12px;background-color:transparent;}</style>"];
  [s appendString:@"<script>document.ontouchmove = function(event) { if (document.body.scrollHeight == document.body.clientHeight) event.preventDefault(); }</script>"];
  [s appendString:@"</head><body>"];
  [s appendString:@"<table><font size=\"-3\">"];
  [s appendFormat:NSLocalizedString(@"detailed.view.copyright", nil), usedCarGFZ];
  [s appendString:@"</font></table>&nbsp;"];
  if ([IPadHelper isIPad]) [s appendString:@"<center><table><tr><td>"];
  BOOL propertyFit = NO;
  for (int i = 0; i < NUMBER_OF_PROPERTY_IDS; ++i) {
    float f = [usedCar getPropertyFactor:i usedCarData:searchCriteria.usedCarData settings:settings];
    if (f > 0.0f) {
      if (!propertyFit) [s appendFormat:@"<table><tr><td><b>%@</b></td><td><center>(%d%%)</center></td></tr>", NSLocalizedString(@"detailed.view.buyer.preferences", nil), (int)(usedCar.preferenceFit*100)];
      NSString *pId = [UsedCarData getPropertyId:i];
      [s appendFormat:@"<tr><td>%@ %@</td><td><center>%d%%</center></td></tr>", [settings name:pId], [settings valueTitle:pId], (int)(f*100)];
      propertyFit = YES;
    }
  }
  if (propertyFit) [s appendString:@"</table>&nbsp;"];
  [s appendFormat:@"<table><tr><td><b>%@</b></td><td>", NSLocalizedString(@"detailed.view.car.description", nil)];
  IntSet *allStringQueryTags = [[IntSet alloc] initWithCapacity:20];
  [allStringQueryTags unionSet:[searchCriteria associatedSearchTags]];
  NSArray *attributes = [UsedCar attributeIdOrder];
  for (NSString *attributeId in attributes) {
    if ([attributeId isEqualToString:MODELL] || [attributeId isEqualToString:KONTAKT] || [attributeId isEqualToString:AUSSTATTUNGSMERKMALE]) continue;  // ToDo: find generic solution
    id query = [searchCriteria structuredDateQuery:attributeId];
    if (query == nil) query = [searchCriteria structuredIntQuery:attributeId];
    if (query != nil) {
      if ([attributeId isEqualToString:KRAFTSTOFFVERBRAUCH] || [attributeId isEqualToString:CO2_EMISSIONEN]) {
        if ([usedCar attribute:attributeId] == 0) continue;  // ToDo: find generic solution
      }
      BOOL highlighted = NO;
      [s appendFormat:@"<tr><td>%@:</td><td>", [UsedCar attributeName:attributeId]];
      if (highlightText && [query hasQuery]) {
        if ([query isKindOfClass:[IntQuery class]]) {
          IntQuery *intQuery = (IntQuery *)query;
          if (!intQuery.indirekterFaktor) {
            [s appendFormat:@"<font color=\"%@\"><b>", highlightColor];
            highlighted = YES;
          }
        } else {
          [s appendFormat:@"<font color=\"%@\"><b>", highlightColor];
          highlighted = YES;
        }
      }
      [s appendString:[query format:[usedCar attribute:attributeId]]];
      if (highlighted) [s appendString:@"</b></font>"];
      [s appendString:@"</td></tr>"];
    } else {
      query = [searchCriteria structuredStringQuery:attributeId];
      if (query != nil) {
        StringQuery *stringQuery = (StringQuery *)query;
        NSString *text = [usedCar stringAttribute:attributeId];
        if (text != nil && [text length] > 0) {
          BOOL highlighted = NO;
          [s appendFormat:@"<tr><td>%@:</td><td>", [UsedCar attributeName:attributeId]];
          if (highlightText /*&& ![stringQuery isEmpty]*/) {
            IntSet *i = [searchCriteria.tags validTags:text];
            IntSet *j = stringQuery.values;//associatedTags;
            //NSLog(@"%@: %@ - %@\nsearch string tags: %@", attributeId, text, [searchCriteria.tags tagNames:i], [searchCriteria.tags tagNames:j]);
            [allStringQueryTags unionSet:j];
            if ([j intersectsSet:i] || [queryTags intersectsSet:i]) {
              [s appendFormat:@"<font color=\"%@\"><b>", highlightColor];
              highlighted = YES;
            }
          }
          [s appendString:text];
          if (highlighted) [s appendString:@"</b></font>"];
          [s appendString:@"</td></tr>"];
        }
      }
    }    
  }
  [s appendString:@"</table>"];
  NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  if ([IPadHelper isIPad]) {
    [s appendString:@"</td></tr></table></center></body></html>"];
    [detailsWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
    [s setString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style><style type=\"text/css\">table {font-family:helvetica;font-size:12px;background-color:transparent;}</style></head><body>"];
  } else {
    [s appendString:@"&nbsp;"];
  }
  [s appendFormat:@"<table><tr><td colspan=\"2\" valign=\"top\"><b>%@</b></td><td>", [UsedCar attributeName:AUSSTATTUNGSMERKMALE]];
  for (NSString *feature in [usedCar getAustattungsmerkmale:searchCriteria.usedCarData.attributeIndex]) {
    [s appendString:@"<tr><td valign=\"top\"><img src=\"bullet.gif\" width=\"11\" height=\"10\"></td><td>"];
    //IntSet *set = [searchCriteria.tags validTags:feature];
    //NSLog(@"feature: %@ - tag names: %@", feature, [searchCriteria.tags tagNames:set]);
    //NSLog(@"queryTags: %d: %@", [queryTags containsObject:[NSNumber numberWithInt:1829]], queryTags);
    //if (highlightText) NSLog(@"%@ intersects (%d) with %@", [queryTags toString], [queryTags intersectsSet:[searchCriteria.tags validTags:feature]], [[searchCriteria.tags validTags:feature] toString]);
    BOOL highlighted = NO;
    if (highlightText) {
      IntSet *i = [searchCriteria.tags validTags:feature];
      if ([allStringQueryTags intersectsSet:i] || [queryTags intersectsSet:i]) {
        [s appendFormat:@"<font color=\"%@\"><b>", highlightColor];
        highlighted = YES;
      }
    }
    [s appendString:feature];
    if (highlighted) [s appendString:@"</b></font>"];
    [s appendString:@"</td></tr>"];
  }
  [s appendString:@"</table>"];
  [allStringQueryTags release];
  if ([IPadHelper isIPad]) {
    [s appendString:@"</body></html>"];
    [featuresWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
    [s setString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style><style type=\"text/css\">table {font-family:helvetica;font-size:10px;background-color:transparent;}</style></head><body>"];
  } else {
    [s appendString:@"&nbsp;"];
  }
  if (sender != nil) {
    NSArray *images = [WebData linksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:YES];
    if (images != nil) {
      int l = [images count];
      if (l > 1) {
        [s appendFormat:@"<center><font size=\"-2\">%@<table>", [WebData isAltImageURL:[images objectAtIndex:0]]? NSLocalizedString(@"detailed.view.click.alt.image.enlarge", nil) : NSLocalizedString(@"detailed.view.click.image.enlarge", nil)];
        for (int i = 1; i < l; ++i) {
          [s appendFormat:@"<tr><td><a href=\"#%d\"><img src=\"%@\"></a></td></tr>", i, [WebData getImageURL:[images objectAtIndex:i] size:1]];
        }
        [s appendString:@"</table></font></center>"];
      }
    }
  }
  [s appendString:@"</body></html>"];
  if ([IPadHelper isIPad]) {
    [imagesWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
  } else {
    [detailsWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
  }
  [s setString:@"<html><head><style type=\"text/css\">table {font-family:helvetica;font-size:10px;background-color:transparent;}</style>"];
  [s appendString:@"<script>document.ontouchmove = function(event) { if (document.body.scrollHeight == document.body.clientHeight) event.preventDefault(); }</script>"];
  [s appendString:@"</head><body><table>"];
  if (![IPadHelper isIPad]) [s appendString:@"<font size=\"-2\">"];
  [s appendString:[usedCar stringAttribute:KONTAKT]];
  if (![IPadHelper isIPad]) [s appendString:@"</font>"];
  [s appendString:@"</table></body></html>"];
  [contactWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
  [s release];
  [queryTags release];
  [pool release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad {
  [super viewDidLoad];
  navigation.leftBarButtonItem.title = NSLocalizedString(@"back", nil);
  navigation.rightBarButtonItem.title = NSLocalizedString(@"detailed.view.send", nil);
  originalWebView = detailsWebView.frame;
  NSString *page = [WebData onlinePage:usedCar];
  if (page == nil || [page isEqualToString:@"closed.png"]) {
    addBookmark.hidden = YES;
    viewLocation.hidden = YES;
    favoriteView.hidden = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closed.png"]];
    navigation.titleView = imageView;
    modelLabel.text = NSLocalizedString(@"detailed.view.sold", nil);
    navigation.rightBarButtonItem = nil;
    [imageView release];
    NSLog(@"GFZ %@ sold", usedCar.gfzNumber);
    SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
    [WebData deleteLinksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData];
  } else {
    if ([page hasSuffix:@".png"]) {
      addBookmark.hidden = YES;
      viewLocation.hidden = YES;
      favoriteView.hidden = YES;
      UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closed.png"]];
      imageView.frame = CGRectMake([IPadHelper isIPad]? 384.0 : 160.0, 0.0, 44.0, 44.0);
      navigation.titleView = imageView;
      [imageView release];
      NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
      [imageWebView loadHTMLString:[NSString stringWithFormat:@"<html><body><center><img src=\"%@\"></center></body></html>", page] baseURL:baseURL];
      [self updateView:nil];
    } else {
      Bookmarks *bookmarks = [Bookmarks getInstance];
      BOOL favorite = [bookmarks containsUsedCarBookmark:usedCar];
      addBookmark.hidden = favorite;
      favoriteView.hidden = !favorite;
      SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
      viewLocation.hidden = (usedCar.locationIndex <= 0 || usedCar.locationIndex >= [searchCriteria.usedCarData.latitudeLongitudeOfAddresses count]);

      navigation.title = (favorite)? NSLocalizedString(@"detailed.view.title.favorite", nil) : @"";
      [self updateView:self];
      NSArray *images = [WebData linksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:YES];
      if (images != nil && [images count] > 0) {
        NSMutableString *s = [[NSMutableString alloc] initWithString:@"<html><head><style type=\"text/css\">body {margin:0;background-color:transparent;}</style><style type=\"text/css\">table {font-family:helvetica;font-size:10px;background-color:transparent;}</style>"];
        [s appendFormat:@"</head><body><center><font size=\"-2\">%@", [WebData isAltImageURL:[images objectAtIndex:0]]? NSLocalizedString(@"detailed.view.click.alt.image.enlarge", nil) : NSLocalizedString(@"detailed.view.click.image.enlarge", nil)];
        if ([IPadHelper isIPad]) {
          [s appendFormat:@"<a href=\"#0\"><img src=\"%@\"></a>", [WebData getImageURL:[images objectAtIndex:0] size:1]];
        } else {
          [s appendFormat:@"<a href=\"#0\"><img src=\"%@\" width=\"*\" height=\"70\">", [WebData getImageURL:[images objectAtIndex:0] size:0]];
        }
        [s appendString:@"</center></body></html>"];
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        [imageWebView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
        [s release];
      }
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

#pragma mark -
#pragma mark Web view delegate

-(void)setupLargeImages:(NSString *)urlstr {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [pool release];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (!calculationIndicator.hidden) return NO;
  if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || navigationType == UIWebViewNavigationTypeOther && [[request URL] host] != nil) {
    if (detailsWebView.frame.origin.y != originalWebView.origin.y) {
      UIAlertView *dialog = [[UIAlertView alloc]
                             initWithTitle:NSLocalizedString(@"detailed.view.exit", nil)
                             message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"detailed.view.exit.text", nil), NSLocalizedString(@"detailed.view.exit.link", nil)]
                             delegate:self
                             cancelButtonTitle:NSLocalizedString(@"no", nil)
                             otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
      dialog.tag = 1;
      [dialog show];
      [dialog release];
      return YES;
    }
    NSURL *requestURL = [request URL];
    if ([[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"]) {
      return ![[UIApplication sharedApplication] openURL:requestURL];
    }
    NSString *urlstr = [requestURL fragment];
    if ([urlstr isEqualToString:@"0"] || [urlstr isEqualToString:[NSString stringWithFormat:@"%d", [urlstr intValue]]]) {
      [calculationIndicator startAnimating];
      // Crash: [self performSelectorInBackground:@selector(setupLargeImages:) withObject:urlstr];
      SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
      NSArray *images = [WebData linksToImages:usedCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:YES];
      if (images != nil) {
        int l = [images count];
        //int imageWidth = detailsWebView.frame.size.width;
        //if ([IPadHelper isIPad]) imageWidth += featuresWebView.frame.size.width;
        if (l > 0) {
          BOOL isAltImage = [WebData isAltImageURL:[images objectAtIndex:0]];
          NSString *copyright = [NSString stringWithFormat:NSLocalizedString(@"detailed.view.images.copyright", nil), usedCarGFZ];
          NSMutableString *s = [[NSMutableString alloc] initWithCapacity:1000];
          for (int i = 0; i < l; ++i) {
            //[s appendFormat:@"<h1><a name=\"%d\">%@ %d</a></h1><p><center><img src=\"%@\" width=\"%d\" height=\"*\"></center></p>", i+1, NSLocalizedString(@"detailed.view.image", nil), i+1, [WebData getImageURL:[images objectAtIndex:i]], imageWidth];
            [s appendFormat:@"<h1><a name=\"%d\">%@ %d</a></h1><p><font size=\"-2\">%@</font><p><center><img src=\"%@\"></center></p>",
             i+1, (isAltImage)? NSLocalizedString(@"detailed.view.alt.image", nil) : NSLocalizedString(@"detailed.view.image", nil), i+1,
             copyright, [WebData getImageURL:[images objectAtIndex:i] size:2]];
          }
          HelpData *helpData = [[HelpData alloc] initWithContent:s];
          TutorialViewController *controller = [[TutorialViewController alloc] initWithNibName:@"TutorialView" owner:self helpData:helpData];
          controller.navigationTitle = (isAltImage)? NSLocalizedString(@"detailed.view.alt.images.title", nil) : NSLocalizedString(@"detailed.view.images.title", nil);
          controller.startHtmlAnchor = [NSString stringWithFormat:@"%d", [urlstr intValue]+1];
          [self presentModalViewController:controller animated:YES];
          [controller release];
          [helpData release];
          [s release];
        }
        [self updateView:self];
      }
      [calculationIndicator stopAnimating];
    } else if ([urlstr isEqualToString:@"fullpage"]) {
      NSString *page = [WebData onlinePage:usedCar];
      if (page != nil) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        CGRect rec = ([IPadHelper isIPad])? imagesWebView.frame : detailsWebView.frame;
        detailsWebView.frame = CGRectMake(modelLabel.frame.origin.x, modelLabel.frame.origin.y, modelLabel.frame.origin.x+modelLabel.frame.size.width-modelLabel.frame.origin.x, rec.origin.y+rec.size.height-modelLabel.frame.origin.y);
        //highlight.hidden = YES;
        //searchHighlightLabel.hidden = YES;
        [UIView commitAnimations];
        NSURL *baseURL = nil;
        if ([page hasSuffix:@".png"]) {
          page = [NSString stringWithFormat:@"<html><body><center><img src=\"%@\"></center></body></html>", page];
          baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        }
        [detailsWebView loadHTMLString:page baseURL:baseURL];
      }
    }
  }
  return YES;
}

#pragma mark -
#pragma mark Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView.tag == 1) {
    if (buttonIndex == 1) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"detailed.view.exit.link", nil)]];
    }
  } else if (alertView.tag == 2) {
    [self createEmail:(buttonIndex == 1)? 2 : 1];
  }
}

#pragma mark -
#pragma mark Memory Management

-(void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
  [super viewDidUnload];
  navigation = nil;
  addBookmark = nil;
  viewLocation = nil;
  modelLabel = nil;
  //searchHighlightLabel = nil;
  //highlight = nil;
  imageWebView = nil;
  detailsWebView = nil;
  contactWebView = nil;
  featuresWebView = nil;
  imagesWebView = nil;
  favoriteView = nil;
  calculationIndicator = nil;
}

-(void)dealloc {
  [usedCar release];
  [usedCarGFZ release];
  [navigation release];
  [addBookmark release];
  [viewLocation release];
  [modelLabel release];
  //[searchHighlightLabel release];
  //[highlight release];
  [imageWebView release];
  [detailsWebView release];
  [contactWebView release];
  [featuresWebView release];
  [imagesWebView release];
  [favoriteView release];
  [calculationIndicator release];
  [super dealloc];
}

@end
