//
//  BookmarksViewController.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarksViewController.h"
#import "DetailsViewController.h"
#import "MercedesCarBoardViewController.h"
#import "ApplicationCell.h"
#import "DateQuery.h"
#import "IntQuery.h"
#import "IPadHelper.h"

@implementation BookmarksViewController

@synthesize titleNavigationItem;
@synthesize bookmarksTableView;
@synthesize cellOwner;

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner bookmarks:(Bookmarks *)marks {
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self != nil) {
    canEdit = NO;
    delegate = owner;
    bookmarks = [marks retain];
  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  titleNavigationItem.title = NSLocalizedString(@"bookmarks.title", nil);
  titleNavigationItem.leftBarButtonItem.title = NSLocalizedString(@"back", nil);
  editButton = [titleNavigationItem.rightBarButtonItem retain];
  doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(switchEditingBookmarks:)];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Actions

-(IBAction)loadBackView:(id)sender {
	[delegate dismissModalViewControllerAnimated:YES];
}

-(IBAction)switchEditingBookmarks:(id)sender {
  if (canEdit) {
    canEdit = NO;
    titleNavigationItem.rightBarButtonItem = editButton;
  } else {
    canEdit = YES;
    titleNavigationItem.rightBarButtonItem = doneButton;
  }
  [bookmarksTableView setEditing:canEdit animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (section == 0)? [bookmarks.usedCarBookmarks count] : [bookmarks.queryBookmarks count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return (section == 0)? NSLocalizedString(@"bookmarks.table.header.used.cars", nil) : NSLocalizedString(@"bookmarks.table.header.queries", nil);
}

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return canEdit;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    if (indexPath.section == 0) {
      [bookmarks removeUsedCarBookmarkAtIndex:indexPath.row];
    } else {
      [bookmarks removeQueryBookmarkAtIndex:indexPath.row];
    }
    [Bookmarks save:bookmarks];
    [bookmarksTableView reloadData];
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section == 0)? 74.0 : 44.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    static NSString *appCellId = @"ApplicationCell";
    ApplicationCell *appCell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:appCellId];
    if (appCell == nil) {
      [cellOwner loadNibNamed:appCellId owner:self];
      appCell = (ApplicationCell *)cellOwner.cell;
    }
    UsedCar *u = [bookmarks.usedCarBookmarks objectAtIndex:indexPath.row];
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
    }
    [appCell loadImageFrom:u];
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
    //appCell.bookmarkView.hidden = ![searchCriteria.bookmarks containsUsedCarBookmark:u];
    appCell.selectionStyle = (appCell.imageExisting)? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    return appCell;
  } else {
    static NSString *cellId = @"QueryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
      cell.textLabel.font = [UIFont systemFontOfSize:10.0];
      cell.textLabel.textAlignment = UITextAlignmentLeft;
      cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.numberOfLines = 2;
    }
    cell.textLabel.text = [bookmarks.queryBookmarks objectAtIndex:indexPath.row];
    return cell;
  }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section > 0) return indexPath;
  ApplicationCell *cell = (ApplicationCell *)[tableView cellForRowAtIndexPath:indexPath];
  return (cell.imageExisting)? indexPath : nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UsedCar *u = [bookmarks.usedCarBookmarks objectAtIndex:indexPath.row];
    DetailsViewController *controller = nil;
    if ([IPadHelper isIPad]) {
      controller = [[DetailsViewController alloc] initWithNibName:@"DetailsView-iPad" owner:self usedCar:u];
    } else {
      controller = [[DetailsViewController alloc] initWithNibName:@"DetailsView" owner:self usedCar:u];
    }
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    [controller release];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  } else {
    if ([delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
      MercedesCarBoardViewController *m = (MercedesCarBoardViewController *)delegate;
      NSString *s = [bookmarks.queryBookmarks objectAtIndex:indexPath.row];
      if (![s isEqualToString:m.searchTextView.text]) {
        m.searchTextView.text = s;
        [m textViewDidChange:m.searchTextView];
      }
    }
    [self loadBackView:self];
  }
}

#pragma mark -
#pragma mark Memory Management Methods

-(void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

-(void)viewDidUnload {
  [super viewDidUnload];
  titleNavigationItem = nil;
  bookmarksTableView = nil;
  cellOwner = nil;
}

-(void)dealloc {
  [titleNavigationItem release];
  [bookmarksTableView release];
  [cellOwner release];
  [bookmarks release];
  [doneButton release];
  [editButton release];
  [super dealloc];
}

@end
