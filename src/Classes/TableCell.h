//
//  TableCell.h
//  InPark
//
//  Created by Sebastian Wedeniwski on 12.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCell : UITableViewCell {
	id delegate;

}

@property (assign, nonatomic) id delegate;

@end
