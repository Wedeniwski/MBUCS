//
//  GeneralInfoViewController.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 11.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeneralInfoViewController.h"
#import "TutorialViewController.h"
#import "SettingsData.h"
#import "IPadHelper.h"

@implementation GeneralInfoViewController

@synthesize titleNavigationItem;
@synthesize webView;
@synthesize content, subdirectory, buttonTitle;

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner fileName:(NSString *)fName title:(NSString *)tName {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self != nil) {
    delegate = owner;
    fileName = (fName != nil)? [fName retain] : nil;
    titleName = [tName retain];
    content = nil;
    subdirectory = nil;
    buttonTitle = nil;
  }
  return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(void)viewDidLoad {
  [super viewDidLoad];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  titleNavigationItem.title = NSLocalizedString(titleName, nil);
  titleNavigationItem.leftBarButtonItem.title = (buttonTitle == nil)? NSLocalizedString(@"back", nil) : buttonTitle;
  BOOL iPad = [IPadHelper isIPad];
  NSString *data = content;
  if (data == nil) {
    NSString *filePath = fileName;
    NSRange found = [fileName rangeOfString:@"/"];
    if (found.length == 0) {
      NSString *bPath = [[NSBundle mainBundle] bundlePath];
      if (subdirectory != nil) bPath = [bPath stringByAppendingPathComponent:subdirectory];
      filePath = [[bPath stringByAppendingPathComponent:[SettingsData currentLanguage]] stringByAppendingPathComponent:fileName];
    }
    NSError *error = nil;
    //data = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
      NSLog(@"Error accessing file %@  (%@)", filePath, [error localizedDescription]);
    }
    // ToDo: make general through variable Icon
    if (iPad) data = [data stringByReplacingOccurrencesOfString:@"mbucs.png" withString:@"mbucs@2x.png"];
  }
  if (data != nil) {
    int fontSize = (iPad)? 14 : 12;
    BOOL isAbout = [fileName isEqualToString:@"about.txt"];
    NSMutableString *s = [[NSMutableString alloc] initWithCapacity:[data length]+500];
    [s setString:@"<html><head>"];
    if (!isAbout) {
      [s appendFormat:@"<style type=\"text/css\">table {font-family:helvetica;font-size:%dpx;background-color:transparent;}</style>", fontSize];
    }
    [s appendString:@"<script>document.ontouchmove = function(event) { if (document.body.scrollHeight == document.body.clientHeight) event.preventDefault(); }</script>"];
    [s appendFormat:@"</head><body style=\"font-family:helvetica;font-size:%dpxbackground-color: transparent\">", fontSize];
    if (isAbout) {
      [s appendFormat:@"<p>%@ %@</p>", NSLocalizedString(@"version", nil), [SettingsData appVersion]];
      /*[s appendFormat:@"<p>%@ %@</p><table><tr><td>", NSLocalizedString(@"version", nil), [SettingsData appVersion]];
      NSString *t = [ParkData getParkDataVersions];
      t = [t stringByReplacingOccurrencesOfString:@":" withString:@"</td><td>"];
      [s appendString:[t stringByReplacingOccurrencesOfString:@"\n" withString:@"</td></tr><tr><td>"]];
      [s appendString:@"</td></tr></table>"];*/
    }
    [s appendString:data];
    [s appendString:@"</body></html>"];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    webView.backgroundColor = [UIColor clearColor];
    [webView loadHTMLString:[NSString stringWithString:s] baseURL:baseURL];
    [s release];
  }
  [pool release];
}

/*-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}*/

-(IBAction)loadBackView:(id)sender {
  if (buttonTitle != nil) {
    TutorialViewController *controller = [[TutorialViewController alloc] initWithNibName:@"TutorialView" owner:delegate helpData:[HelpData getHelpData]];
    controller.buttonTitle = buttonTitle;
    controller.startHtmlAnchor = @"introduction";
    [self presentModalViewController:controller animated:YES];
    [controller release];
  }
	[delegate dismissModalViewControllerAnimated:YES];
}


-(void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Relinquish ownership any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
  [super viewDidUnload];
  titleNavigationItem = nil;
  webView = nil;
  fileName = nil;
  titleName = nil;
  content = nil;
  subdirectory = nil;
  buttonTitle = nil;
}

-(void)dealloc {
  [titleNavigationItem release];
  [webView release];
  [fileName release];
  [titleName release];
  [content release];
  [subdirectory release];
  [buttonTitle release];
  [super dealloc];
}

@end
