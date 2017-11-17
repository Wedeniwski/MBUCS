//
//  TokenPoolViewController.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TokenPoolViewController.h"
#import "UsedCar.h"
#import "SettingsData.h"
#import "TagCloud.h"
#import "IntSet.h"

@implementation TokenPoolViewController

@synthesize attributeSegmentedControl;
@synthesize categorySegmentedControl;
@synthesize attributeWebView;
@synthesize categoryWebView;
@synthesize deletedTagsLabel;
@synthesize actionButton, deleteTokensButton;


-(void)updateView {
  NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  SettingsData *settingsData = [SettingsData getInstance];
  NSArray *a = [UsedCar stringAttributeIdOrder];
  NSMutableSet *set = [NSMutableSet setWithSet:[tags attributeTags:[a objectAtIndex:attributeSegmentedControl.selectedSegmentIndex]]];
  [set minusSet:tags.ignoreTags];
  NSMutableSet *set2 = [NSMutableSet setWithCapacity:10];
  NSArray *c = [settingsData propertyIdOrder];
  int l = [c count];
  for (int i = 0; i < l; ++i) {
    [set2 unionSet:[tags propertyTags:[c objectAtIndex:i] clusterLevel:0]];
    //[set minusSet:[tags categoryTags:[c objectAtIndex:i]]];
  }
  [set2 intersectSet:set];
  [attributeWebView loadHTMLString:[TagCloud create:set minus:set2] baseURL:baseURL];
  if (categorySegmentedControl.hidden) {
    [categoryWebView loadHTMLString:[TagCloud create:tags.ignoreTags minus:nil] baseURL:baseURL];
  } else {
    NSString *propertyId = [c objectAtIndex:categorySegmentedControl.selectedSegmentIndex];
    [categoryWebView loadHTMLString:[TagCloud create:[tags propertyTags:propertyId clusterLevel:0] minus:nil] baseURL:baseURL];
  }
}

-(IBAction)loadBackView:(id)sender {
  //[tags save];
	[delegate dismissModalViewControllerAnimated:YES];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
  [picker setSubject:@"Category Tags"];
	[picker setMessageBody:[tags toString] isHTML:NO];
	[self presentModalViewController:picker animated:YES];
  [picker release];
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

-(IBAction)sendData:(id)sender {
  UIActionSheet *sheet = [[UIActionSheet alloc]
                          initWithTitle:NSLocalizedString(@"Aktionen", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Abbruch", nil)
                          destructiveButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"Tag-Zuordnungen verschicken", nil),
                          nil];
  [sheet showFromBarButtonItem:actionButton animated:YES];
  [sheet release];
}

-(IBAction)deleteTokens:(id)sender {
  if (deleteTokensButton.style != UIBarButtonItemStyleBordered) {
    deleteTokensButton.style = UIBarButtonItemStyleBordered;
    deletedTagsLabel.hidden = YES;
    categorySegmentedControl.hidden = NO;
  } else {
    deleteTokensButton.style = UIBarButtonItemStyleDone;
    deletedTagsLabel.hidden = NO;
    categorySegmentedControl.hidden = YES;
  }
  [self updateView];
}

-(IBAction)dictionary:(id)sender {
  InAppSettingsViewController *controller = [[InAppSettingsViewController alloc] initWithNibName:@"InAppSettingsView" bundle:nil];
  controller.delegate = self;
  controller.preferenceTitle = @"Datenbasis";
  controller.preferenceSpecifiers = @"Dictionary";
  [self presentModalViewController:controller animated:YES];
  [controller release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    if ([MFMailComposeViewController canSendMail]) {
      [self displayComposerSheet];
    }
  }
}

-(IBAction)attributeSegmentedControlValueChanged:(id)sender {
  [self updateView];
}

-(IBAction)categorySegmentedControlValueChanged:(id)sender {
  [self updateView];
}

#pragma mark -
#pragma mark InAppSettings delegate

-(void)updateSettings {
  [SettingsData getInstance:YES];
}

#pragma mark -
#pragma mark Web view delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted) {
    NSString *urlstr = [[request URL] fragment];
    SettingsData *settingsData = [SettingsData getInstance];
    NSArray *a = [UsedCar stringAttributeIdOrder];
    NSString *attributeId = [a objectAtIndex:attributeSegmentedControl.selectedSegmentIndex];
    if (webView == attributeWebView) {
      [tags removeAttribute:urlstr attributeTag:attributeId];
      if (categorySegmentedControl.hidden) {
        [tags.ignoreTags addObject:urlstr];
      } else {
        NSArray *c = [settingsData propertyIdOrder];
        NSString *propertyId = [c objectAtIndex:categorySegmentedControl.selectedSegmentIndex];
        [tags addPropertyTag:urlstr propertyId:propertyId];
      }
    } else if (webView == categoryWebView) {
      if (categorySegmentedControl.hidden) {
        [tags.ignoreTags removeObject:urlstr];
      } else {
        NSArray *c = [settingsData propertyIdOrder];
        NSString *propertyId = [c objectAtIndex:categorySegmentedControl.selectedSegmentIndex];
        [tags removeProperyTag:urlstr propertyId:propertyId];
      }
      [tags addAttribute:urlstr attributeTag:attributeId];
    }
    [self updateView];
    return NO;
  }
  return YES;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner tags:(Tags*)t {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self != nil) {
    delegate = owner;
    tags = [t retain];
  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  deletedTagsLabel.hidden = YES;
  SettingsData *settingsData = [SettingsData getInstance];
  NSArray *a = [UsedCar stringAttributeNameOrder];
  for (int i = 0; i < [a count]; ++i) {
    if (i < 2) {
      [attributeSegmentedControl setTitle:[a objectAtIndex:i] forSegmentAtIndex:i];
    } else {
      [attributeSegmentedControl insertSegmentWithTitle:[a objectAtIndex:i] atIndex:i animated:NO];
    }
  }
  a = [settingsData propertyNameOrder];
  for (int i = 0; i < [a count]; ++i) {
    if (i < 2) {
      [categorySegmentedControl setTitle:[a objectAtIndex:i] forSegmentAtIndex:i];
    } else {
      [categorySegmentedControl insertSegmentWithTitle:[a objectAtIndex:i] atIndex:i animated:NO];
    }
  }
  [self updateView];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
  [super viewDidUnload];
  attributeSegmentedControl = nil;
  categorySegmentedControl = nil;
  attributeWebView = nil;
  categoryWebView = nil;
  deletedTagsLabel = nil;
  deleteTokensButton = nil;
}

-(void)dealloc {
  [super dealloc];
  [tags release];
  // ToDo:!
  //[attributeSegmentedControl release];
  //[categorySegmentedControl release];
  //[attributeWebView release];
  //[categoryWebView release];
  //[deletedTagsLabel release];
  //[deleteTokensButton release];
}


@end
