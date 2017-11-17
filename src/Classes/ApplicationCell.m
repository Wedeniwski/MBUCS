//
//  ApplicationCell.m
//  InPark
//
//  Created by Sebastian Wedeniwski on 27.08.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ApplicationCell.h"
#import "WebData.h"
#import "SearchCriteria.h"
#import "MercedesCarBoardViewController.h"
#import "IPadHelper.h"

@implementation ApplicationCell

@synthesize imageExisting;
@synthesize iconView;
@synthesize modelLabel, kmLabel, psLabel, erstzulassungLabel, leistungenLabel;
@synthesize fitPreferenceView;
@synthesize fitPreferenceLabel;
@synthesize priceLabel;
@synthesize certificateView, bookmarkView;


-(void)dealloc {
  [usedCar release];
  [iconView release];
  [kmLabel release];
  [psLabel release];
  [erstzulassungLabel release];
  [leistungenLabel release];
  [modelLabel release];
  [fitPreferenceView release];
  [fitPreferenceLabel release];
  [priceLabel release];
  [certificateView release];
  [bookmarkView release];
  [super dealloc];
}

-(void)enabled {
  imageExisting = YES;
}

-(void)findImageLink:(UsedCar *)uCar {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  NSArray *images = [WebData linksToImages:uCar versionOfData:searchCriteria.usedCarData.versionOfData checkUpToDateAltImages:NO];
  if (images != nil && [images count] > 0) {
    NSString *url = [WebData getImageURL:[images objectAtIndex:0] size:0];
    NSData *imageData = [ApplicationCell dataInCacheFor:uCar.gfzNumber];
    if (imageData == nil && [delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
      MercedesCarBoardViewController *m = (MercedesCarBoardViewController *)delegate;
      NSUInteger idx = [m.tableData indexOfObject:uCar];
      if (idx == 0) [WebData isValidPage:uCar];
    }
    [self performSelectorOnMainThread:@selector(loadImageFromArgs:) withObject:[NSArray arrayWithObjects:url, uCar, imageData, nil] waitUntilDone:NO];
  }
  [pool release];
}

-(void)loadImageFrom:(UsedCar *)uCar {
  [usedCar release];
  usedCar = nil;
  [iconView.image release];
  iconView.image = nil;
  imageExisting = YES;
  [self performSelectorInBackground:@selector(findImageLink:) withObject:uCar];
}

+(UIImage *)getImageFrom:(UsedCar *)uCar urlString:(NSString *)url {
  if ([url hasPrefix:@"http:"]) {
    NSData *d = [ApplicationCell dataInCacheFor:uCar.gfzNumber];
    if (d != nil) return [UIImage imageWithData:d];
    NSError *error = nil;
    d = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:&error];
    if (error != nil) {
      NSLog(@"Error (%@) accessing image at URL %@", [error localizedDescription], url);
      return nil;
    } else {
      UIImage *newIcon = [UIImage imageWithData:d];
      [ApplicationCell addToCache:uCar.gfzNumber data:d];
      return newIcon;
    }
  }
  return [UIImage imageNamed:url];
}

-(void)loadImageFromArgs:(NSArray *)args {
  NSString *url = [args objectAtIndex:0];
  UsedCar *uCar = [args objectAtIndex:1];
  NSData *imageData = ([args count] == 2)? nil : [args objectAtIndex:2];
  if ([url hasPrefix:@"http:"]) {
    [usedCar release];
    usedCar = [uCar retain];
    if (imageData != nil) {
      UIImage *image = [[UIImage alloc] initWithData:imageData];
      [self setIcon:image];
      [image release];
      iconView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
      if ([delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
        MercedesCarBoardViewController *m = (MercedesCarBoardViewController *)delegate;
        NSUInteger idx = [m.tableData indexOfObject:usedCar];
        if (idx == 0 && [WebData isInPageCache:usedCar] && ![WebData isValidPage:usedCar]) {
          [m.theTableView beginUpdates];
          [m.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:YES];
          [m.tableData removeObjectAtIndex:idx];
          [m.theTableView endUpdates];
          [m updateTableSizeView];
          return;
        }
      }
      gfzNumber = [uCar.gfzNumber retain];
      NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:15.0];
      connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
  } else {
    imageExisting = ![url isEqualToString:@"closed.png"];
    iconView.image = [UIImage imageNamed:url];
    iconView.contentMode = UIViewContentModeCenter;
    iconView.clipsToBounds = YES;
  }
}

-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
  imageExisting = NO;
  if (data == nil) {
    data = [[NSMutableData alloc] initWithCapacity:10000];
  }
  [data appendData:incrementalData];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
  imageExisting = NO;
  if (data == nil) {
    NSLog(@"Error: No data!");
  } else {
    //NSLog(@"Data size: %d  for model %@", [data length], [usedCar stringAttribute:MODELL]);
    if ([data length] < 500) { // ToDo: not fix!
      iconView.image = [UIImage imageNamed:@"closed.png"];
      iconView.clipsToBounds = YES;
      iconView.contentMode = UIViewContentModeCenter;
      if ([delegate isKindOfClass:[MercedesCarBoardViewController class]]) {
        MercedesCarBoardViewController *m = (MercedesCarBoardViewController *)delegate;
        NSUInteger idx = [m.tableData indexOfObject:usedCar];
        if (idx != NSNotFound) {
          [m.theTableView beginUpdates];
          [m.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:YES];
          [m.tableData removeObjectAtIndex:idx];
          [m.theTableView endUpdates];
          [m updateTableSizeView];
        }
      }
    } else {
      [ApplicationCell addToCache:gfzNumber data:data];
      UIImage *image = [[UIImage alloc] initWithData:data];
      [self setIcon:image];
      [image release];
      iconView.contentMode = UIViewContentModeScaleAspectFill;
    }
    [data release];
    data = nil;
  }
  [connection release];
  connection = nil;
  [gfzNumber release];
  gfzNumber = nil;
}

-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
  NSLog(@"Connection did fail %d: %@", [error code], [error localizedDescription]);
  [data release];
  data = nil;
  [connection release];
  connection = nil;
  [gfzNumber release];
  gfzNumber = nil;
  imageExisting = YES;
}

-(void)setIcon:(UIImage *)newIcon {
  imageExisting = YES;
  iconView.layer.masksToBounds = YES;
  iconView.layer.cornerRadius = 5.0;
  iconView.image = newIcon;
  iconView.clipsToBounds = YES;
}

-(void)setPreferenceFit:(double)newPreferenceFit {
  [fitPreferenceView setPreferenceFit:newPreferenceFit];
  fitPreferenceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"list.cell.fit", nil), (int)(100.0*newPreferenceFit)];
}

//static NSMutableDictionary *imageCache = nil;

+(void)clearImageCache {
  // ToDo: need more experiences
  /*@synchronized([ApplicationCell class]) {
    if (imageCache == nil) imageCache = [[NSMutableDictionary alloc] initWithCapacity:100];
    else [imageCache removeAllObjects];
  }*/
}

+(NSData *)dataInCacheFor:(NSString *)gfzNumber {
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  NSString *path = [[WebData localImageCachePath:searchCriteria.usedCarData.versionOfData] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", gfzNumber]];
  return [NSData dataWithContentsOfFile:path];
}

+(void)addToCache:(NSString *)gfzNumber data:(NSData *)data {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  NSString *path = [[WebData localImageCachePath:searchCriteria.usedCarData.versionOfData] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", gfzNumber]];
  [data writeToFile:path atomically:YES];
  [pool release];
}

@end
