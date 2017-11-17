//
//  BookmarksViewController.h
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 16.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmarks.h"
#import "CellOwner.h"

@interface BookmarksViewController : UIViewController {
	id delegate;
  BOOL canEdit;
  Bookmarks *bookmarks;
  UIBarButtonItem *doneButton;
  UIBarButtonItem *editButton;

  IBOutlet UINavigationItem *titleNavigationItem;
  IBOutlet UITableView *bookmarksTableView;
  IBOutlet CellOwner *cellOwner;
}

-(id)initWithNibName:(NSString *)nibNameOrNil owner:(id)owner bookmarks:(Bookmarks *)marks;

-(IBAction)loadBackView:(id)sender;
-(IBAction)switchEditingBookmarks:(id)sender;

@property (nonatomic, retain) UINavigationItem *titleNavigationItem;
@property (nonatomic, retain) UITableView *bookmarksTableView;
@property (nonatomic, retain) CellOwner *cellOwner;
@end
