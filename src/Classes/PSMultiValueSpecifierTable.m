//
//  PSMultiValueSpecifierTable.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PSMultiValueSpecifierTable.h"

@implementation PSMultiValueSpecifierTable

@synthesize theTableView;
@synthesize titleOfTable;

-(int)getSelectedRow {
  NSArray *a = [setting valueForKey:@"Values"];
  int l = [a count];
  for (int i = 0; i < l; ++i) {
    id cellValue = [a objectAtIndex:i];
    if ([cellValue isKindOfClass:[NSNumber class]]) {
      if ([(NSNumber *)cellValue intValue] == [(NSNumber *)[self getValue] intValue]) {
        return i;
      }
    } else {  // ToDo: support also other types beside Numbers and Strings if needed
      if ([cellValue isEqualToString:[self getValue]]) {
        return i;
      }
    }
  }
  return 0;
}

-(id)initWithSetting:(InAppSetting *)inputSetting delegate:(id)inputDelegate nibName:(NSString *)nibName {
  self = [super initWithNibName:nibName bundle:nil];
  if (self != nil) {
    setting = [inputSetting retain];
    delegate = inputDelegate;
    selectedRow = [self getSelectedRow];
  }
  return self;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  self.titleOfTable.title = NSLocalizedString([setting valueForKey:@"Title"], nil);
  //[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
  //[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
}

-(void)dealloc {
  [setting release];
  [theTableView release];
  [super dealloc];
}

#pragma mark Value

-(id)getValue {
  id value = [[NSUserDefaults standardUserDefaults] valueForKey:[setting valueForKey:@"Key"]];
  if (value == nil) {
    value = [setting valueForKey:@"DefaultValue"];
    if (value == nil) {
      NSArray *a = [setting valueForKey:@"Values"];
      if ([a count] > 0) value = [a objectAtIndex:0];
    }
  }
  return value;
}

-(void)setValue:(id)newValue {
  [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:[setting valueForKey:@"Key"]];
}

#pragma action methods

-(IBAction)loadBackView:(id)sender {
	[delegate dismissModalViewControllerAnimated:YES];
}

#pragma mark Table view methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[setting valueForKey:@"Values"] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"PSMultiValueSpecifierTableCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
  }
  NSArray *titles = [setting valueForKey:@"Titles"];
  if (titles == nil) titles = [setting valueForKey:@"Values"];
  NSString *cellTitle = NSLocalizedString([titles objectAtIndex:indexPath.row], nil);
  cell.textLabel.text = cellTitle;
	if (indexPath.row == selectedRow) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.textColor = [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f];  // blue
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
  }
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  id cellValue = [[setting valueForKey:@"Values"] objectAtIndex:indexPath.row];
  [self setValue:cellValue];
  selectedRow = indexPath.row;
  [tableView reloadData];
  return indexPath;
}

@end