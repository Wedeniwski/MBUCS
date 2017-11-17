//
//  InAppSettingsViewController.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 05.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InAppSettingsViewController.h"
#import "InAppSetting.h"
#import "PSMultiValueSpecifierTable.h"
#import "SettingsData.h"

@implementation InAppSettingsViewController

@synthesize delegate;
@synthesize file;
@synthesize preferenceTitle;
@synthesize preferenceSpecifiers;
@synthesize theTableView;
@synthesize titleOfTable;

-(IBAction)loadBackView:(id)sender {
  [delegate updateSettings];
	[self.delegate dismissModalViewControllerAnimated:YES];
}

#pragma mark validate plist data

-(BOOL)isSettingValid:(InAppSetting *)setting {
  NSString *type = [setting getType];
  if ([type isEqualToString:@"PSMultiValueSpecifier"]) {
    if (![setting hasKey] || /*![setting hasDefaultValue] ||*/ ![setting hasTitle]) return NO;
    NSArray *values = [setting valueForKey:@"Values"];
    if (values == nil || [values count] == 0) return NO;
    NSArray *titles = [setting valueForKey:@"Titles"];
    if (titles == nil) titles = values;
    if ([titles count] != [values count]) return NO;
  } else if ([type isEqualToString:@"PSSliderSpecifier"]) {
    if (![setting hasKey] || ![setting hasDefaultValue]) return NO;
    NSNumber *minValue = [setting valueForKey:@"MinimumValue"];
    NSNumber *maxValue = [setting valueForKey:@"MaximumValue"];
    if (minValue == nil || maxValue == nil) return NO;
  } else if ([type isEqualToString:@"PSToggleSwitchSpecifier"]) {
    if (![setting hasKey] || ![setting hasDefaultValue] || ![setting hasTitle]) return NO;
  } else if ([type isEqualToString:@"PSTitleValueSpecifier"]){
    if (![setting hasKey] || ![setting hasDefaultValue] || ![setting hasTitle]) return NO;
  } else if ([type isEqualToString:@"PSChildPaneSpecifier"]){
    if (![setting hasTitle]) return NO;
    NSString *plistFile = [setting valueForKey:@"File"];
    if (plistFile == nil) return NO;
  }
  return YES;
}

#pragma mark setup view

-(id)initWithCoder:(NSCoder *)aDecoder {
  return [self init];
}

-(id)initWithFile:(NSString *)inputFile {
  self = [self init];
  if (self != nil) {
    self.file = inputFile;
  }
  return self;
}

-(void)viewDidLoad {
  titleOfTable.leftBarButtonItem.title = NSLocalizedString(@"back", nil);
  titleOfTable.title = preferenceTitle;
  if ([titleOfTable.title isEqualToString:@""]) {
    titleOfTable.title = NSLocalizedString(@"Settings", nil);
  }
  //load settigns plist
  if (!file) {
    file = @"Root.plist";
  }
  if (!preferenceSpecifiers) {
    preferenceSpecifiers = @"PreferenceSpecifiers";
  }
  
  //load plist
  NSString *bPath = [[NSBundle mainBundle] bundlePath];
  NSString *listFile = [[bPath stringByAppendingPathComponent:[SettingsData currentLanguage]] stringByAppendingPathComponent:file];
  NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:listFile];
  NSArray *prefSpecifiers = [settingsDictionary objectForKey:preferenceSpecifiers];
  
  //create an array for headers(PSGroupSpecifier) and a dictonary to hold arrays of settings
  headers = [[NSMutableArray alloc] init];
  displayHeaders = [[NSMutableArray alloc] init];
  settings = [[NSMutableDictionary alloc] init];
  
  //if the first item is not a PSGroupSpecifier create a header to store the settings
  NSString *currentHeader = @"";
  InAppSetting *firstSetting = [[InAppSetting alloc] initWithDictionary:[prefSpecifiers objectAtIndex:0]];
  if (![firstSetting isType:@"PSGroupSpecifier"]){
    [headers addObject:currentHeader];
    [displayHeaders addObject:@""];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [settings setObject:array forKey:currentHeader];
    [array release];
  }
  [firstSetting release];
  
  //set the first value in the display header to "", while the real header is set to InAppSettingNullHeader
  //this way whats set in the first entry to headers will not be seen
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  for (NSDictionary *eachSetting in prefSpecifiers) {
    InAppSetting *setting = [[InAppSetting alloc] initWithDictionary:eachSetting];
    if ([setting getType]) { //type is required
      if ([setting isType:@"PSGroupSpecifier"]) {
        currentHeader = [setting valueForKey:@"Title"];
        [headers addObject:currentHeader];
        [displayHeaders addObject:currentHeader];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [settings setObject:array forKey:currentHeader];
        [array release];
      } else if ([self isSettingValid:setting]) {
        NSMutableArray *currentArray = [settings objectForKey:currentHeader];
        [currentArray addObject:setting];
      }
    }
    [setting release];
  }
  [pool drain];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [theTableView reloadData];
}

-(void)dealloc {
  [file release];
  [preferenceTitle release];
  [preferenceSpecifiers release];
  [headers release];
  [displayHeaders release];
  [settings release];
  [theTableView release];
  [titleOfTable release];
  [super dealloc];
}

#pragma mark Table view methods

-(InAppSetting *)settingAtIndexPath:(NSIndexPath *)indexPath {
  NSString *header = [headers objectAtIndex:indexPath.section];
  return [[settings objectForKey:header] objectAtIndex:indexPath.row];
}

-(void)controlEditingDidBeginAction:(UIControl *)control {
  //scroll the table view to the cell that is being edited
  //TODO: the cell does not animate to the middle of the table view when the keyboard is becoming active
  //TODO: find a better way to get the cell, what if the nesting changes?
  NSIndexPath *indexPath = [self.theTableView indexPathForCell:(UITableViewCell *)[[control superview] superview]];
  [theTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [headers count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [displayHeaders objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSString *header = [headers objectAtIndex:section];
  return [[settings objectForKey:header] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InAppSetting *setting = [self settingAtIndexPath:indexPath];
  NSString *cellType = [setting cellName];
  Class nsclass = NSClassFromString(cellType);
  if (!nsclass) {
    cellType = @"InAppSettingsTableCell";
    nsclass = NSClassFromString(cellType);
  }
  InAppSettingsTableCell *cell = ((InAppSettingsTableCell *)[tableView dequeueReusableCellWithIdentifier:cellType]);
  if (cell == nil) {
    cell = [[[nsclass alloc] initWithSetting:setting reuseIdentifier:cellType] autorelease];
  }
  [cell setupCell:setting];
  //if the cell is a PSTextFieldSpecifier setup an action to center the table view on the cell
  if ([setting isType:@"PSTextFieldSpecifier"]) {
    [[cell getValueInput] addTarget:self action:@selector(controlEditingDidBeginAction:) forControlEvents:UIControlEventEditingDidBegin];
  }
  [cell setValue];
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  InAppSetting *setting = [self settingAtIndexPath:indexPath];
  if ([setting isType:@"PSMultiValueSpecifier"]) {
    PSMultiValueSpecifierTable *multiValueSpecifier = [[PSMultiValueSpecifierTable alloc] initWithSetting:setting delegate:self nibName:@"PSMultiValueSpecifierView"];
    [self presentModalViewController:multiValueSpecifier animated:YES];
    //[self.navigationController pushViewController:multiValueSpecifier animated:YES];
    [multiValueSpecifier release];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  } else if([setting isType:@"PSChildPaneSpecifier"]){
    NSString *plistFile = [[setting valueForKey:@"File"] stringByAppendingPathExtension:@"plist"];
    InAppSettingsViewController *childPane = [[InAppSettingsViewController alloc] initWithFile:plistFile];  // ToDo!
    childPane.title = [setting valueForKey:@"Title"];
    [self presentModalViewController:childPane animated:YES];
    //[self.navigationController pushViewController:childPane animated:YES];
    [childPane release];
  }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  InAppSetting *setting = [self settingAtIndexPath:indexPath];
  if ([setting isType:@"PSMultiValueSpecifier"] || [setting isType:@"PSChildPaneSpecifier"]) {
    return indexPath;
  }
  return nil;
}

@end
