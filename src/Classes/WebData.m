//
//  WebData.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebData.h"
#import "SearchCriteria.h"
#import "ApplicationCell.h"
#import "md5.h"
#import "bzlib.h"

@implementation WebData

@synthesize path, hashCode;
@synthesize version;
@synthesize fileSize, uncompressedFileSize, dataCount;

-(id)init:(NSString *)lineOfData owner:(id<UpdateDelegate>)owner {
  self = [super init];
  if (self != nil) {
    data = nil;
    connection = nil;
    delegate = owner;
    // String versionInfo = filename + ',' + version + ',' + usedCars.size() + ',' + f.length() + ',' + uf.length() + ',' + hashCode(compressedFilename);
    NSArray *values = [lineOfData componentsSeparatedByString:@","];
    if ([values count] == 6) {
      path = [[values objectAtIndex:0] retain];
      version = [[values objectAtIndex:1] doubleValue];
      dataCount = [[values objectAtIndex:2] intValue];
      fileSize = [[values objectAtIndex:3] intValue];
      uncompressedFileSize = [[values objectAtIndex:4] intValue];
      hashCode = [[values objectAtIndex:5] retain];
    }
  }
  return self;
}

-(void)dealloc {
  [path release];
  path = nil;
  [hashCode release];
  hashCode = nil;
  [super dealloc];
}

+(NSString *)localDataPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}

+(BOOL)initImageCachePath:(double)versionOfData {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *dataPath = [WebData localDataPath];
  NSString *sourcePath = [NSString stringWithFormat:@"%ld", (long)versionOfData];
  NSError *error = nil;
  NSArray *files = [fileManager contentsOfDirectoryAtPath:dataPath error:&error];
  if (error != nil) {
    NSLog(@"%@", [error localizedDescription]);
    return NO;
  }
  for (NSString *file in files) {
    if ([file hasPrefix:@"."] || [file isEqualToString:sourcePath]) continue;
    NSString *fullPath = [dataPath stringByAppendingPathComponent:file];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:fullPath error:&error];
    if (error != nil) {
      NSLog(@"Error getting attributes of path %@ - %@", fullPath, [error localizedDescription]);
      return NO;
    } else if ([attributes objectForKey:NSFileType] == NSFileTypeDirectory) {
      [fileManager removeItemAtPath:fullPath error:&error];
      if (error != nil) {
        NSLog(@"Error removing path %@ - %@", fullPath, [error localizedDescription]);
        return NO;
      }
    }
  }
  sourcePath = [dataPath stringByAppendingPathComponent:sourcePath];
  if (![fileManager fileExistsAtPath:sourcePath]) {
    NSError *error = nil;
    [fileManager createDirectoryAtPath:sourcePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
      NSLog(@"Error creating path %@ - %@", sourcePath, [error localizedDescription]);
      return NO;
    }
  }
  return YES;
}

+(void)deleteImageCachePath:(double)versionOfData {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *path = [WebData localImageCachePath:versionOfData];
  [fileManager removeItemAtPath:path error:nil];
  NSError *error = nil;
  [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}

+(NSString *)localImageCachePath:(double)versionOfData {
  return [[WebData localDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", (long)versionOfData]];
}

+(NSString *)sourceDataPath {
  return @"http://www.mbucs.com/";
}

+(NSString *)sizeToString:(int)size {
  if (size < 1023) return [NSString stringWithFormat:@"%d bytes", size];
  float fSize = size/1024.0f;
  if (fSize < 1023) return [NSString stringWithFormat:@"%1.1f kB", fSize];
  fSize /= 1024;
  if (fSize < 1023) return [NSString stringWithFormat:@"%1.2f MB", fSize];
  fSize /= 1024;
  return [NSString stringWithFormat:@"%1.2f GB", fSize];
}

+(WebData *)availableUpdates:(id<UpdateDelegate>)owner {
  NSURL *availableData = [NSURL URLWithString:[[WebData sourceDataPath] stringByAppendingPathComponent:@"UsedCars.info"]];
  NSError *error = nil;
  NSString *versionInfo = [NSString stringWithContentsOfURL:availableData encoding:NSASCIIStringEncoding error:&error];
  if (error != nil) {
    NSLog(@"Error retrieving UsedCars.info: %@", [error localizedDescription]);
  } else  //NSData *data = [NSData dataWithContentsOfURL:availableData];
  if (versionInfo != nil && [versionInfo length] > 0) {
    //NSString *versionInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //if ([versionInfo length] > 0) {
    SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
    WebData *data = [[[WebData alloc] init:versionInfo owner:owner] autorelease];
    if (data.version == 0.0) {
      NSLog(@"Error to parse info file: %@", versionInfo);
      return data;
    }
    if (searchCriteria.usedCarData.versionOfData < data.version) return data;
  }
  return nil;
}

+(BOOL)isUpdateNecessary:(double)versionOfData {
  NSString *versionPrefix = [NSString stringWithFormat:@"UsedCars_%ld", (long)versionOfData];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:[WebData localImageCachePath:versionOfData]]) return NO;    
  NSURL *availableData = [NSURL URLWithString:[[WebData sourceDataPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info", versionPrefix]]];
  NSError *error = nil;
  NSString *versionInfo = [NSString stringWithContentsOfURL:availableData encoding:NSASCIIStringEncoding error:&error];
  if (error != nil) {
    NSLog(@"Error retrieving %@.info: %@", versionPrefix, [error localizedDescription]);
    return ([error code] == NSFileReadUnknownError); // code = 256
  }
  NSLog(@"Server version %@ size: %d", versionPrefix, [versionInfo length]);
  if (versionInfo == nil) { // e.g. proxy error
    NSLog(@"Error retrieving %@.info: %@", versionPrefix, (error == nil)? versionInfo : [error localizedDescription]);
    return NO;
  }
  if (![versionInfo hasPrefix:versionPrefix]) {
    NSLog(@"Error retrieving %@.info: %@", versionPrefix, (error == nil)? versionInfo : [error localizedDescription]);
    return YES;
  }
  return NO;
}

-(void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
  if (data == nil) data = [[NSMutableData alloc] initWithCapacity:fileSize];
  [data appendData:incrementalData];
  [delegate downloaded:[WebData sizeToString:[data length]]];
  [delegate status:NSLocalizedString(@"update.download.info", nil) percentage:[data length]/(1.01*fileSize)];
}

-(void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
  [data release];
  data = nil;
  [connection release];
  connection = nil;
  [delegate status:[NSString stringWithFormat:NSLocalizedString(@"update.download.error", nil), [error localizedDescription]] percentage:-1.0];
  [delegate downloaded:@""];
}

-(void)importData {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  BOOL failed = NO;
  if (data != nil) {
    [delegate status:NSLocalizedString(@"update.validate.download.info", nil) percentage:100.0/101.0];
    [delegate downloaded:[WebData sizeToString:[data length]]];
    MD5_CTX mdContext;
    MD5Init(&mdContext);
    MD5Update(&mdContext, data.bytes, data.length);
    MD5Final(&mdContext);
    char md5ofData[33];
    md5ofData[32] = '\x0';
    for (int i = 0; i < 16; ++i) sprintf(md5ofData+2*i, "%02x", mdContext.digest[i]);
    if (![[NSString stringWithUTF8String:md5ofData] isEqualToString:hashCode]) {
      NSLog(@"Wrong hash MD5: %s != %@", md5ofData, hashCode);
      [data release];
      data = nil;
      [delegate status:NSLocalizedString(@"update.download.error.hash", nil) percentage:-1.0];
      [delegate downloaded:@""];
      [pool release];
      return;
    }
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *package = [INDEX_FILE_NAME stringByAppendingString:@".bz2"];
    NSString *destinationPath = [[WebData localDataPath] stringByAppendingPathComponent:package];
    if ([fileManager fileExistsAtPath:destinationPath]) {
      [fileManager removeItemAtPath:destinationPath error:&error];
      if (error != nil) {
        NSLog(@"Error removing already existing tmp package: %@", [error localizedDescription]);
        error = nil;
      }
    }
    if ([data length] > 0 && [data writeToFile:destinationPath atomically:NO]) {
      BZFILE *bz2fp = BZ2_bzopen([destinationPath UTF8String], "rb");
      if (bz2fp == NULL) {
        NSLog(@"Can't open bzip2 stream (%@)", destinationPath);
        failed = YES;
      } else {
        NSString *sourcePath = [[WebData localDataPath] stringByAppendingPathComponent:INDEX_FILE_NAME];
        NSString *tmpUnzipPath = [sourcePath stringByAppendingString:@"-tmp"];
        FILE *fp = fopen([tmpUnzipPath UTF8String], "wb");
        if (fp == NULL) {
          NSLog(@"Can't open file (%@)", tmpUnzipPath);
          failed = YES;
        } else {
          char buffer[0x10000];
          double size = 0.0;
          double downloadedSize = uncompressedFileSize*1.01;
          while (TRUE) {
            int n = BZ2_bzread(bz2fp, buffer, 0x10000);
            if (n <= 0) break;
            size += n;
            [delegate status:NSLocalizedString(@"update.unzip.info", nil) percentage:size/downloadedSize];
            [delegate downloaded:[WebData sizeToString:size]];
            fwrite(buffer, 1, n, fp);
          }
          fclose(fp);
          [fileManager removeItemAtPath:sourcePath error:&error];
          if (error != nil) {
            NSLog(@"File %@ could not be deleted", sourcePath);
            error = nil;
          }
          [fileManager moveItemAtPath:tmpUnzipPath toPath:sourcePath error:&error];
          if (error != nil) {
            NSLog(@"Error move path %@ to %@ (%@)", tmpUnzipPath, sourcePath, [error localizedDescription]);
            error = nil;
            failed = YES;
          }
        }
        BZ2_bzclose(bz2fp);
        [fileManager removeItemAtPath:destinationPath error:&error];
        if (error != nil) {
          NSLog(@"Error deleting %@ (%@)", destinationPath, [error localizedDescription]);
          error = nil;
        }
      }
    }
    [data release];
    data = nil;
  }
  if (failed) {
    [delegate status:NSLocalizedString(@"update.download.imported.error", nil) percentage:-1.0];
    [delegate downloaded:@""];
  } else {
    [delegate status:NSLocalizedString(@"update.download.imported", nil) percentage:1.0];
    [delegate downloaded:@""];
  }
  [pool release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
  [connection release];
  connection = nil;
  [NSThread detachNewThreadSelector:@selector(importData) toTarget:self withObject:nil];
}

-(void)update {
  SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
  if (searchCriteria.usedCarData.versionOfData == version) {
    NSLog(@"Data with this version %f is already available", version);
    return;
  }
  NSString *package = [path stringByAppendingString:@".bz2"];
  NSString *sourcePath = [[WebData sourceDataPath] stringByAppendingPathComponent:package];
  NSURL *availableData = [NSURL URLWithString:sourcePath];
  NSURLRequest *request = [NSURLRequest requestWithURL:availableData cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  NSLog(@"Download file %@", sourcePath);
  [delegate status:NSLocalizedString(@"update.download.info", nil) percentage:0.0];
  [delegate downloaded:@""];
}

+(NSString *)deepLinkToSearch:(BOOL)reload {
  @synchronized([WebData class]) {
    static NSMutableString *globalSessionId = nil;
    static NSMutableString *jSessionId = nil;
    if (!reload && globalSessionId != nil && jSessionId != nil) {
      return [NSString stringWithFormat:@"http://e-services.mercedes-benz.com/dsc_de/globalsessionid/%@/dsc_locale/de_DE/appId/DSC_de/siteLocale/de_DE/VSCVehicleIDSearch.jam2;jsessionid=%@", globalSessionId, jSessionId];
    }
    [globalSessionId release];
    globalSessionId = nil;
    [jSessionId release];
    jSessionId = nil;
    NSString *startURL = @"http://e-services.mercedes-benz.com/dsc_de/Dispatcher.jam?businessCase=UCu&amp;dsc_locale=de_DE&amp;SelfRedirect=true";
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:startURL] encoding:NSASCIIStringEncoding error:&error];
    if (error != nil) {
      NSLog(@"Error accessing main URL: %@", [error localizedDescription]);
    } else if (content != nil) {
      const char *c = [content UTF8String];
      c = strstr(c, "href=\"/dsc_de/globalsessionid/");
      if (c != NULL) {
        globalSessionId = [[NSMutableString alloc] initWithCapacity:40];
        c += 30;
        const char *c2 = c;
        while (TRUE) {
          const char ch = *c2;
          if (ch == '\0' || ch == '/') break;
          [globalSessionId appendFormat:@"%c", ch];
          ++c2;
        }
        c = strstr(c2, ";jsessionid=");
        if (c != NULL) {
          jSessionId = [[NSMutableString alloc] initWithCapacity:40];
          c += 12;
          const char *c2 = c;
          while (TRUE) {
            const char ch = *c2;
            if (ch == '\0' || ch == '\"') break;
            [jSessionId appendFormat:@"%c", ch];
            ++c2;
          }
          return [NSString stringWithFormat:@"http://e-services.mercedes-benz.com/dsc_de/globalsessionid/%@/dsc_locale/de_DE/appId/DSC_de/siteLocale/de_DE/VSCVehicleIDSearch.jam2;jsessionid=%@", globalSessionId, jSessionId];
        }
      }
    }
    return nil;
  }
}

static NSMutableDictionary *pageCache = nil;
+(NSString *)isInPageCache:(UsedCar *)usedCar {
  @synchronized([WebData class]) {
    if (pageCache == nil) pageCache = [[NSMutableDictionary alloc] initWithCapacity:201];
  }
  return [pageCache objectForKey:usedCar.gfzNumber];
}

+(NSString *)onlinePage:(UsedCar *)usedCar {
  NSString *page = [WebData isInPageCache:usedCar];
  if (page != nil) return page;
  if ([pageCache count] >= 200) [pageCache removeAllObjects];  // refresh cache
  NSRange range = [usedCar.gfzNumber rangeOfString:@","];
  if (range.length > 0) {
    [pageCache setObject:@"not_unique.png" forKey:usedCar.gfzNumber];
    return @"not_unique.png";
  }
  NSString *dataURL = [WebData deepLinkToSearch:NO];
  if (dataURL == nil) return @"no_network.png";
  //NSLog(@"URL: %@", dataURL);
  NSString *htmlBody = [NSString stringWithFormat:@"E0001VehicleID=%@", usedCar.gfzNumber];
  NSData *postData = [NSData dataWithBytes:[htmlBody UTF8String] length:[htmlBody length]];
  NSMutableURLRequest *post = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
  [post setCachePolicy:NSURLRequestUseProtocolCachePolicy];
  [post setTimeoutInterval:15.0];
  [post setHTTPMethod:@"POST"];
  [post setHTTPBody:postData];
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *gfzData = nil;
  @synchronized([WebData class]) {
    gfzData = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
  }
  if (error != nil) {
    NSLog(@"Error accessing gfz URL: %@", [error localizedDescription]);
  } else if ([gfzData length] == 0) {
    if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
      NSHTTPURLResponse *hr = (NSHTTPURLResponse *)response;
      NSLog(@"No content for gfz %@ with response: %@", usedCar.gfzNumber, [NSHTTPURLResponse localizedStringForStatusCode:[hr statusCode]]);
    } else {
      NSLog(@"No content for URL: %@", dataURL);
    }
  } else {
    NSString *gfzContent = [[NSString alloc] initWithData:gfzData encoding:NSUTF8StringEncoding];//NSASCIIStringEncoding];
    NSRange range = [gfzContent rangeOfString:@"<td class=\"warn-txt\">"];
    if (range.length > 0) {
      NSLog(@"session timeout");
      dataURL = [WebData deepLinkToSearch:YES];
      [post release];
      post = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:dataURL]];
      [post setCachePolicy:NSURLRequestUseProtocolCachePolicy];
      [post setTimeoutInterval:15.0];
      [post setHTTPMethod:@"POST"];
      [post setHTTPBody:postData];
      gfzData = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
      [gfzContent release];
      gfzContent = [[NSString alloc] initWithData:gfzData encoding:NSASCIIStringEncoding];
    }
    if (error != nil) {
      NSLog(@"Error accessing gfz URL after refresh: %@", [error localizedDescription]);
    } else {
      range = [gfzContent rangeOfString:@"Kein Fahrzeug gefunden"];
      if (range.length > 0) {
        [pageCache setObject:@"closed.png" forKey:usedCar.gfzNumber];
      } else {
        //NSLog(@"GFZ: %@", gfzContent);
        // check if online content really relates to the index data
        //NSLog(@"Kontakt: %@", [usedCar stringAttribute:KONTAKT]);
        // Kontakt
        /*range = [gfzContent rangeOfString:[usedCar stringAttribute:KONTAKT]];
         BOOL wrongContent = (range.length == 0);
         if (wrongContent) NSLog(@"Contact not found in GFZ:%@", usedCar.gfzNumber);
         // Erstzulassung
         if (!wrongContent) {*/
        range = [gfzContent rangeOfString:[DateQuery intToDate:[usedCar attribute:ERSTZULASSUNG]]];
        BOOL wrongContent = (range.length == 0);
        if (wrongContent) NSLog(@"First registration not found in GFZ:%@", usedCar.gfzNumber);
        //}
        // Modell
        if (!wrongContent) {
          range = [gfzContent rangeOfString:[usedCar stringAttribute:MODELL] options:NSCaseInsensitiveSearch];
          wrongContent = (range.length == 0);
          if (wrongContent) NSLog(@"Model not found in GFZ:%@", usedCar.gfzNumber);
        }
        // Farbe
        if (!wrongContent) {
          NSString *color = [usedCar stringAttribute:FARBE];
          if ([color length] > 0) {
            range = [gfzContent rangeOfString:color options:NSCaseInsensitiveSearch];
            wrongContent = (range.length == 0);
            if (wrongContent) {
              NSLog(@"Color not found in GFZ:%@", usedCar.gfzNumber);
              //NSLog(@"GFZ: %@", gfzContent);
              NSLog(@"Farbe: %@", color);
            }
          }
        }
        // PS
        if (!wrongContent) {
          range = [gfzContent rangeOfString:[NSString stringWithFormat:@"(%d PS)", [usedCar attribute:MOTORLEISTUNG]]];
          wrongContent = (range.length == 0);
          if (wrongContent) NSLog(@"HP not found in GFZ:%@", usedCar.gfzNumber);
        }
        if (wrongContent) {
          SearchCriteria *searchCriteria = [SearchCriteria getInstance:nil];
          BOOL notUniqueGFZ = NO;
          for (NSString *gfzKey in searchCriteria.usedCarData.usedCars) {
            range = [gfzKey rangeOfString:@","];
            if (range.length > 0 && [gfzKey hasPrefix:usedCar.gfzNumber]) {
              notUniqueGFZ = YES;
              break;
            }
          }
          [pageCache setObject:(notUniqueGFZ)? @"not_unique.png" : @"closed.png" forKey:usedCar.gfzNumber];
        } else {
          NSLog(@"Cache page size %d for %@", [gfzContent length], usedCar.gfzNumber);
          [pageCache setObject:gfzContent forKey:usedCar.gfzNumber];
        }
      }
    }
    [gfzContent release];
  }
  [post release];
  return [pageCache objectForKey:usedCar.gfzNumber];
}

+(NSArray *)linksToOriginalImages:(UsedCar *)usedCar {
  NSRange range = [usedCar.gfzNumber rangeOfString:@","];
  if (range.length > 0) return [NSArray arrayWithObject:@"not_unique.png"];
  NSString *page = [WebData onlinePage:usedCar];
  if (page == nil) return nil;
  if ([page hasSuffix:@".png"]) return [NSArray arrayWithObject:page];
  const char *c = [page UTF8String];
  c = strstr(c, "var FotoArr = new Array(\"");
  if (c != NULL) {
    c += 25;
    const char *imagePrefix = [IMAGE_PREFIX UTF8String];
    const char *imagePrefix2 = [IMAGE_ALT_PREFIX UTF8String];
    NSMutableArray *links = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    while (TRUE) {
      if (strstr(c, imagePrefix)) c += [IMAGE_PREFIX length];
      else if (strstr(c, imagePrefix2)) c += [IMAGE_ALT_PREFIX length];
      NSMutableString *image = [[NSMutableString alloc] initWithCapacity:200];
      while (TRUE) {
        const char ch = *c;
        if (ch == '\"' || ch == '\0') break;
        [image appendFormat:@"%c", ch];
        ++c;
      }
      [links addObject:image];
      [image release];
      if (*c == '\0' || c[1] != ',' || c[2] != '\"') break;
      c += 3;
    }
    return links;
  }
  return nil;
}

+(void)deleteLinksToImages:(UsedCar *)usedCar versionOfData:(double)versionOfData {
  NSString *relativePath = [NSString stringWithFormat:@"%ld/%@.img", (long)versionOfData, [UsedCar convertFileName:usedCar.gfzNumber]];
  relativePath = [relativePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSString *filePath = [[WebData localDataPath] stringByAppendingPathComponent:relativePath];
  NSError *error = nil;
  [@"closed.png" writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:&error];
  relativePath = [NSString stringWithFormat:@"%ld/%@.png", (long)versionOfData, [UsedCar convertFileName:usedCar.gfzNumber]];
  relativePath = [relativePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  filePath = [[WebData localDataPath] stringByAppendingPathComponent:relativePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:filePath]) {
    [fileManager removeItemAtPath:filePath error:&error];
    if (error != nil) {
      NSLog(@"Error (%@) removing cached image of GFZ %@", [error localizedDescription], usedCar.gfzNumber);
    }
  }
}

+(NSArray *)linksToImages:(UsedCar *)usedCar versionOfData:(double)versionOfData checkUpToDateAltImages:(BOOL)checkUpToDateAltImages {
  //if ([WebData isUpdateNecessary:versionOfData]) return nil;
  if ([WebData isInPageCache:usedCar]) return [WebData linksToOriginalImages:usedCar];
  NSString *relativePath = [NSString stringWithFormat:@"%ld/%@.img", (long)versionOfData, [UsedCar convertFileName:usedCar.gfzNumber]];
  relativePath = [relativePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
  NSString *filePath = [[WebData localDataPath] stringByAppendingPathComponent:relativePath];
  NSError *error = nil;
  BOOL downloaded = NO;
  NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
  if (error != nil || content == nil) {
    error = nil;
    downloaded = YES;
    NSString *startURL = [[WebData sourceDataPath] stringByAppendingPathComponent:relativePath];
    content = [NSString stringWithContentsOfURL:[NSURL URLWithString:startURL] encoding:NSASCIIStringEncoding error:&error];
    if (error != nil) {
      NSLog(@"Error (%@) accessing img URL: %@", [error localizedDescription], startURL);
    }
  }
  if (error == nil && content != nil) {
    if ([content isEqualToString:@"closed.png"]) return nil;
    NSArray *images = [content componentsSeparatedByString:@"\n"];
    if ([images count] > 0 && [WebData isAltImageURL:[images objectAtIndex:0]]) { // only temp substitues might be replaced
      if (checkUpToDateAltImages) {  // ToDo: not tested because of no existing use case (see pageCache)
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        if (error == nil) {
          NSDate *creationDate = [attributes objectForKey:NSFileModificationDate];
          if (creationDate != nil) {
            NSDate *now = [NSDate date];
            NSTimeInterval time = [now timeIntervalSinceDate:creationDate];
            if (time > 24*3600.0) {
              images = [self linksToOriginalImages:usedCar];
              NSMutableString *content2 = [[NSMutableString alloc] initWithCapacity:1000];
              for (NSString *i in images) {
                if ([content2 length] > 0) [content2 appendString:@"\n"];
                [content2 appendString:i];
              }
              [content2 writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:&error];
              [content2 release];
            }
          }
        } else {
          NSLog(@"Error (%@) accessing attributes of file %@", [error localizedDescription], filePath);
        }
      }
    } else if (downloaded) {
      [content writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:&error];
    }
    return images;
  }
  return nil;
}

+(NSString *)getImageURL:(NSString *)relativeLink size:(int)size {
  if ([WebData isAltImageURL:relativeLink]) {
    if (size == 2) relativeLink = [relativeLink stringByReplacingOccurrencesOfString:@".jpg" withString:@"1.jpg"];
    return [IMAGE_ALT_PREFIX stringByAppendingString:relativeLink];
  }
  switch (size) {
    case 0: return [THUMBNAIL_PREFIX  stringByAppendingString:relativeLink];
    case 1: return [IMAGE_PREFIX  stringByAppendingString:relativeLink];
    case 2: return [LARGE_IMAGE_PREFIX  stringByAppendingString:relativeLink];
    default: return nil;
  }
}

+(BOOL)isAltImageURL:(NSString *)relativeLink {
  return [relativeLink hasPrefix:@"/"];
}

+(BOOL)isValidPage:(UsedCar *)usedCar {
  NSString *page = [WebData onlinePage:usedCar];
  return (page != nil && ![page hasSuffix:@".png"]);
}

+(BOOL)isValidFirstImage:(UsedCar *)usedCar versionOfData:(double)versionOfData {
  NSArray *images = [WebData linksToImages:usedCar versionOfData:versionOfData checkUpToDateAltImages:YES];
  UIImage *image = (images != nil && [images count] > 0)? [ApplicationCell getImageFrom:usedCar urlString:[WebData getImageURL:[images objectAtIndex:0] size:0]] : nil;
  return (image != nil);
}

@end
