//
//  UsedCarData.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 06.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <mach/mach.h>
#import <mach/mach_host.h>
#import <CoreLocation/CoreLocation.h>
#import "UsedCarData.h"
#import "SearchCriteria.h"
#import "SettingsData.h"
#import "StringAttribute.h"
#import "TagCluster.h"
#import "WebData.h"

@implementation UsedCarData

@synthesize versionOfData;
@synthesize attributeIndex;
@synthesize usedCars;
@synthesize latitudeLongitudeOfAddresses;
@synthesize minValuesAttributes, maxValuesAttributes;
@synthesize tags;

#define MAX_DATA_IMPORT -1

-(natural_t)getFreeMemory {
  vm_size_t pagesize;
  vm_statistics_data_t vm_stat;
  mach_port_t host_port = mach_host_self();
  mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
  host_page_size(host_port, &pagesize);
  if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
    NSLog(@"Failed to fetch vm statistics");
    return 0;
  }
  // Stats in bytes
  return vm_stat.free_count * pagesize;
}

-(void)clear {
  [attributeIndex release];
  attributeIndex = nil;
  [usedCars release];
  usedCars = nil;
  [latitudeLongitudeOfAddresses release];
  latitudeLongitudeOfAddresses = nil;
  [minValuesAttributes release];
  minValuesAttributes = nil;
  [maxValuesAttributes release];
  maxValuesAttributes = nil;
  [tags release];
  tags = nil;
}

/*-(void)load {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self clear];
  NSString *docPath = [SettingsData documentPath];
  NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"UsedCarVersion"]];
  NSLog(@"load version:%@", version);
  if (version != nil && [version doubleValue] == versionOfData) {
    NSLog(@"load usedCars");
    usedCars = [[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"UsedCarData"]] retain];
    NSLog(@"load attributeIndex");
    attributeIndex = [[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"UsedCarIndex"]] retain];
    minValuesAttributes = [[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"UsedCarMinValues"]] retain];
    maxValuesAttributes = [[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"UsedCarMaxValues"]] retain];
  }
  [pool release];
}

-(void)save {
  NSLog(@"save version:%f  (free memory %d bytes)", versionOfData, [self getFreeMemory]);
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *docPath = [[SettingsData documentPath] retain];
  [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:versionOfData] toFile:[docPath stringByAppendingPathComponent:@"UsedCarVersion"]];
  [NSKeyedArchiver archiveRootObject:attributeIndex toFile:[docPath stringByAppendingPathComponent:@"UsedCarIndex"]];
  [NSKeyedArchiver archiveRootObject:minValuesAttributes toFile:[docPath stringByAppendingPathComponent:@"UsedCarMinValues"]];
  [NSKeyedArchiver archiveRootObject:maxValuesAttributes toFile:[docPath stringByAppendingPathComponent:@"UsedCarMaxValues"]];
  [pool release];
  [NSKeyedArchiver archiveRootObject:usedCars toFile:[docPath stringByAppendingPathComponent:@"UsedCarData"]];
  [docPath release];
  NSLog(@"save completed");
}*/

/*-(NSArray *)readArrayOfList:(NSString *)data {
  NSMutableArray *m = [[NSMutableArray alloc] initWithCapacity:numberOfCars];
  NSArray *lines = [data componentsSeparatedByString:@"],"];
  int n = [lines count];
  if (n != numberOfCars) {
    [m release];
    return nil;
  }
  for (int i = 0; i < n; ++i) {
    [m addObject:[NSMutableArray arrayWithCapacity:1]];
  }
  for (NSString *line in lines) {
    //"0-20341004":["...","...",...
    NSRange r = [line rangeOfString:@":"];
    if (r.location <= 2) {
      NSLog(@"Error in line:%@", line);
      [m release];
      return nil;
    }
    r.length = r.location-2; r.location = 1;
    NSString *gfz = [line substringWithRange:r];
    int idx = [UsedCarData stringArraySearch:gfz array:gfzNumbers];
    if (idx < 0) {
      NSLog(@"Error to find gfz:%@  in line:%@", gfz, line);
      [m release];
      return nil;
    }
    if (r.length+4 < [line length]) {
      NSArray *array = [StringAttribute parseStringList:[line substringFromIndex:r.length+4]];
      if ([array count] == 0) {
        NSLog(@"Error to parse array at gfz:%@ staring at pos:%d in line:%@", gfz, r.length+4, line);
      }
      [m replaceObjectAtIndex:idx withObject:array];
    }
  }
  NSArray *a = [NSArray arrayWithArray:m];
  [m release];
  return a;
}*/

static const char* stringLine(const char *source, char *target, int MAX_CSTRING) {
  int i = 0;
  do {
    char c = source[i];
    if (!c || c == '\n') break;
    target[i] = c;
  } while (++i < MAX_CSTRING);
  target[i] = '\x0';
  return source+i;
}

static const char* stringValue(const char *source, char *target, int MAX_CSTRING) {
  int i = 0;
  if (*source == '\"') {
    do {
      char c = *++source;
      if (!c) break;
      if (c == '\"' && *(source-1) != '\\') {
        ++source;
        break;
      }
      target[i] = c;
    } while (++i < MAX_CSTRING);
  }
  target[i] = '\x0';
  return source;
}

+(const char*)stringList:(const char *)source target:(NSMutableArray *)target {
  if (*source == '[') {
    const int MAX_CSTRING = 500;
    char tmp[MAX_CSTRING+1];
    if (*++source != ']') {
      source = stringValue(source, tmp, MAX_CSTRING);
      if (!*tmp) {
        NSLog(@"missing value in array!");
        exit(1);
      }
      NSString *t = [[NSString alloc] initWithUTF8String:tmp];
      [target addObject:[t stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
      [t release];
      while (*source != ']') {
        if (!*source) {
          NSLog(@"End character ']' of array missing!");
          exit(1);
        }
        if (*source != ',') {
          NSLog(@"Wrong comma char separation '%c' in data", *source);
          exit(1);
        }
        source = stringValue(++source, tmp, MAX_CSTRING);
        t = [[NSString alloc] initWithUTF8String:tmp];
        [target addObject:[t stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]];
        [t release];
      }
    }
    ++source;
  }
  return source;
}

+(const char*)stringArray:(const char *)source target:(NSMutableArray *)target {
  const int MAX_CSTRING = 500;
  char tmp[MAX_CSTRING+1];
  while (TRUE) {
    char c = *source;
    if (!c || c == '\n') break;
    if (c == '\"') {
      int i = 0;
      do {
        c = *++source;
        if (!c) break;
        if (c == '\"') {
          if (*(source-1) == '\\') --i;
          else break;
        }
        tmp[i] = c;
      } while (++i < MAX_CSTRING);
      tmp[i] = '\x0';
      NSString *t = [NSString stringWithUTF8String:tmp];
      if (!c || i == MAX_CSTRING && source[1] != '\"') {
        NSLog(@"Internal ERROR! Invalid string %@", t);
        return NULL;
      }
      [target addObject:t];
    }
    ++source;
  }
  return source;
}

static const char* intValue(const char *source, int *value) {
  int x = 0;
  BOOL neg = FALSE;
  if (*source == '-') {
    ++source;
    neg = TRUE;
  }
  while (TRUE) {
    char c = *source;
    if (c >= '0' && c <= '9') {
      x *= 10; x += (int)(c - '0');
    } else {
      *value = (neg)? -x : x;
      return source;
    }
    ++source;
  }
}

static const char* doubleValue(const char *source, double *value) {
  double x = 0.0;
  double comma = 0.0;
  BOOL neg = FALSE;
  if (*source == '-') {
    ++source;
    neg = TRUE;
  }
  while (TRUE) {
    char c = *source;
    if (c >= '0' && c <= '9') {
      if (comma == 0.0) {
        x *= 10; x += (int)(c - '0');
      } else {
        comma /= 10;
        x += comma * (int)(c - '0');
      }
    } else if (c == '.' && comma == 0.0) {
      comma = 1.0;
    } else {
      *value = (neg)? -x : x;
      return source;
    }
    ++source;
  }
}

+(const char*)intArray:(const char *)source target:(NSMutableArray *)target {
  while (*source) {
    int x = 0;
    source = intValue(source, &x);
    [target addObject:[NSNumber numberWithInt:x]];
    if (*source == '\n') break;
    if (*source != ',') {
      NSLog(@"Wrong comma char separation '%c' in data", *source);
      return NULL;
    }
    ++source;
  }
  return source;
}

+(int)estimateIntSetSize:(const char *)source {
  if (*source != '[') return 0;
  char c = *++source;
  if (c == ']') return 0;
  if (c == '-') c = *++source;
  while (c >= '0' && c <= '9') c = *++source;
  int i = 1;
  while (c == ',') {
    c = *++source;
    if (c == '-') c = *++source;
    while (c >= '0' && c <= '9') c = *++source;
    ++i;
  }
  return i;
}

+(const char*)intSet:(const char *)source target:(IntSet *)target {
  if (![target setCapacity:[UsedCarData estimateIntSetSize:source]]) {
    NSLog(@"ERROR: intSet capacity size!");
    return NULL;
  }
  if (*source == '[') {
    if (*++source != ']') {
      int x = 0;
      source = intValue(source, &x);
      [target addWithoutSort:x];
      while (*source != ']') {
        if (!*source) {
          NSLog(@"End character ']' of array missing!");
          [target sort];
          return NULL;
        }
        if (*source != ',') {
          NSLog(@"Wrong comma char separation '%c' in data", *source);
          [target sort];
          return NULL;
        }
        x = 0;
        source = intValue(++source, &x);
        [target addWithoutSort:x];
      }
      [target sort];
    }
    ++source;
  }
  return source;
}

+(const char *)floatList:(const char *)source target:(float *)propertyMatch n:(int)n {
  int i = 0;
  if (*source == '[') {
    if (*++source != ']') {
      double x = 0;
      source = doubleValue(source, &x);
      propertyMatch[0] = x;
      while (++i < n && *source != ']') {
        if (!*source) {
          NSLog(@"End character ']' of array missing!");
          return NULL;
        }
        if (*source != ',') {
          NSLog(@"Wrong comma char separation '%c' in data", *source);
          return NULL;
        }
        x = 0;
        source = doubleValue(++source, &x);
        propertyMatch[i] = x;
      }
    }
    ++source;
  }
  return (i != n)? NULL : source;
}

/*+(const char*)intList:(const char *)source target:(NSMutableArray *)target {
  if (*source == '[') {
    if (*++source != ']') {
      int x = 0;
      source = intValue(source, &x);
      [target addObject:[NSNumber numberWithInt:x]];
      while (*source != ']') {
        if (!*source) {
          NSLog(@"End character ']' of array missing!");
          return NULL;
        }
        if (*source != ',') {
          NSLog(@"Wrong comma char separation '%c' in data", *source);
          return NULL;
        }
        x = 0;
        source = intValue(++source, &x);
        [target addObject:[NSNumber numberWithInt:x]];
      }
    }
    ++source;
  }
  return source;
}
*/
-(BOOL)readData:(NSString *)filename {
  NSString *filePath = [[WebData localDataPath] stringByAppendingPathComponent:filename];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    FILE *pFile = fopen([filePath UTF8String], "r");
    if (pFile == NULL) {
      NSLog(@"File error %@", filePath);
      return NO;
    }
    // obtain file size:
    fseek(pFile, 0, SEEK_END);
    long lSize = ftell(pFile);
    rewind(pFile);
    
    // allocate memory to contain the whole file:
    char *data = (char*)malloc(sizeof(char)*(lSize+1));
    if (data == NULL) {
      NSLog(@"Memory error");
      fclose(pFile);
      return NO;
    }
    // copy the file into the buffer:
    size_t result = fread(data, 1, lSize, pFile);
    fclose(pFile);
    if (result != lSize) {
      NSLog(@"Reading error");
      free(data);
      return NO;
    }
    float propertyMatch[NUMBER_OF_PROPERTY_IDS];
    data[lSize] = '\x0';
    const char *s = data;
    //NSString *data = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    //if (data != nil) {
      const int MAX_CSTRING = 1500;
      char tmp[MAX_CSTRING+1];
      //const char *s = [data UTF8String]; // faster, less memory
      //[data release];
      versionOfData = 0.0;
      s = doubleValue(s, &versionOfData);
    NSString *sTmp = NSLocalizedString(@"import.data.init", nil);
    [delegate status:[NSString stringWithFormat:sTmp, [self dateOfData]] percentage:0.0];
    [delegate downloaded:@"0"];
    numberOfCars = 0;
    s = intValue(s+1, &numberOfCars);
    if (MAX_DATA_IMPORT > 0 && numberOfCars > MAX_DATA_IMPORT) numberOfCars = MAX_DATA_IMPORT;
    NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:4000];
    while (s[1] == 's' && s[2] == ':') {
      s = stringLine(s+3, tmp, MAX_CSTRING);
      NSString *attributeId = [NSString stringWithUTF8String:tmp];
      NSLog(@"read usedCar index %@", attributeId);
      NSMutableArray *m1 = [[NSMutableArray alloc] initWithCapacity:400];
      NSMutableArray *m2 = [[NSMutableArray alloc] initWithCapacity:400];
      s = [UsedCarData stringArray:s+1 target:m1];
      [tokens addObjectsFromArray:m1];
      if (s != NULL) s = [UsedCarData intArray:s+1 target:m2];
      if (s == NULL || !*s) {
        versionOfData = 0.0;
        numberOfCars = 0;
        [m1 release];
        [m2 release];
        free(data);
        return NO;
      }
      StringAttribute *q = [[StringAttribute alloc] init:m1 frequency:m2];
      [attributeIndex setValue:q forKey:attributeId];
      [q release];
      [m2 release];
      [m1 release];
    }
    if (s[1] != 't' || s[2] != ':') {
      NSLog(@"Tags are missing!");
      versionOfData = 0.0;
      numberOfCars = 0;
      [tokens release];
      free(data);
      return NO;
    } else {
      s = stringLine(s+3, tmp, MAX_CSTRING);
      NSString *attributeId = [NSString stringWithUTF8String:tmp];
      NSMutableSet *m = [[NSMutableSet alloc] initWithCapacity:400];
      while (*s == '\n') {
        if (s[1] == 't' && s[2] == ':') {
          [tags addAttributeTags:m attributeId:attributeId];
          [m release];
          m = [[NSMutableSet alloc] initWithCapacity:400];
          s = stringLine(s+3, tmp, MAX_CSTRING);
          attributeId = [NSString stringWithUTF8String:tmp];
        } else if (s[1] == '[') break;
        else {
          s = stringLine(s+1, tmp, MAX_CSTRING);
          [m addObject:[NSString stringWithUTF8String:tmp]];
        }
      }
      [tags addAttributeTags:m attributeId:attributeId];
      [m release];
      [tags setupAllTags];
    }
    ++s;
    for (NSString *token in tokens) {
      if ([token length] == 0) {
        if (s[0] != '[' || s[1] != ']') {
          NSLog(@"An empty token cannot contains tags!");
        }
        s += 2;
      } else {
        IntSet *intSet = [[IntSet alloc] initWithCapacity:[UsedCarData estimateIntSetSize:s]];
        s = [UsedCarData intSet:s target:intSet];
        [tags.validTagsList setValue:intSet forKey:token];
        [intSet release];
      }
    }
    [tokens release];
    if (*s != '\n') NSLog(@"Spearator after tags are missing!");
    ++s;
    NSLog(@"read usedCar data %d", numberOfCars);
    [usedCars release];
    usedCars = [[NSMutableDictionary alloc] initWithCapacity:numberOfCars];
    NSMutableArray *allUsedCars = [[NSMutableArray alloc] initWithCapacity:numberOfCars];
      for (int i = 0; i < numberOfCars; ++i) {
        if (*s != '[') {
          NSLog(@"Wrong start char '%c' in data", *s);
          versionOfData = 0.0;
          numberOfCars = 0;
          [allUsedCars release];
          free(data);
          return NO;
        }
        ++s;
        s = stringValue(s, tmp, MAX_CSTRING);
        NSString *gfz = [NSString stringWithUTF8String:tmp];
        if ([gfz length] == 0) {
          NSLog(@"Empty gfz in data!");
          versionOfData = 0.0;
          numberOfCars = 0;
          [allUsedCars release];
          free(data);
          return NO;
        }
        if (*s != ',') {
          NSLog(@"Wrong comma char separation '%c' in data", *s);
          versionOfData = 0.0;
          numberOfCars = 0;
          [allUsedCars release];
          free(data);
          return NO;
        }
        ++s;
        if (i%1000 == 0) {
          NSLog(@"setup data record %d of %d (free memory %d bytes)", i, numberOfCars, [self getFreeMemory]);
          [delegate status:NSLocalizedString(@"import.data.progress", nil) percentage:(i*1.0)/numberOfCars];
          [delegate downloaded:[NSString stringWithFormat:@"%d", i]];
        }
        UsedCar *usedCar = [[UsedCar alloc] initWithGFZNumber:gfz];
        NSArray *order = [UsedCar attributeIdOrder];
        for (NSString *attributeId in order) {
          if ([UsedCar isStringAttribute:attributeId] || [UsedCar isIntAttribute:attributeId] || [UsedCar isDateAttribute:attributeId]) {
            int value = 0;
            s = intValue(s, &value);
            [usedCar setAttribute:attributeId value:value];
            if (*s != ',') {
              NSLog(@"Wrong comma char separation '%c' in data", *s);
              versionOfData = 0.0;
              numberOfCars = 0;
              free(data);
              [allUsedCars release];
              return NO;
            }
            ++s;
            if (value > 0 && ([UsedCar isIntAttribute:attributeId] || [UsedCar isDateAttribute:attributeId])) {
              if ([usedCars count] == 0) {
                [minValuesAttributes setAttribute:attributeId value:value];
                [maxValuesAttributes setAttribute:attributeId value:value];
              } else {
                if (value < [minValuesAttributes attribute:attributeId]) [minValuesAttributes setAttribute:attributeId value:value];
                if (value > [maxValuesAttributes attribute:attributeId]) [maxValuesAttributes setAttribute:attributeId value:value];
              }
            }
          } else if ([UsedCar isStringSetAttribute:attributeId]) {
            IntSet *intSet = [[IntSet alloc] initWithCapacity:[UsedCarData estimateIntSetSize:s]];
            s = [UsedCarData intSet:s target:intSet];
            if (*s != ',') {
              NSLog(@"Wrong comma char separation '%c' in data", *s);
              versionOfData = 0.0;
              numberOfCars = 0;
              [intSet release];
              [allUsedCars release];
              free(data);
              return NO;
            }
            ++s;
            [usedCar setSetAttribute:attributeId value:intSet];
            [intSet release];
          } else {
            NSLog(@"Wrong attributeId %@ in data", attributeId);
            versionOfData = 0.0;
            numberOfCars = 0;
            [usedCar release];
            [allUsedCars release];
            free(data);
            return NO;
          }
        }
        IntSet *intSet = [[IntSet alloc] initWithCapacity:[UsedCarData estimateIntSetSize:s]];
        s = [UsedCarData intSet:s target:intSet];
        usedCar.tags = intSet;
        [intSet release];
        if (*s != '[') {
          NSLog(@"Wrong property match array separation '%c' in data", *s);
          versionOfData = 0.0;
          numberOfCars = 0;
          free(data);
          [usedCar release];
          [allUsedCars release];
          return NO;
        }
        s = [UsedCarData floatList:s target:propertyMatch n:NUMBER_OF_PROPERTY_IDS];
        if (s == NULL || *s != '[') {
          if (s != NULL) NSLog(@"Wrong image array separation '%c' in data", *s);
          versionOfData = 0.0;
          numberOfCars = 0;
          free(data);
          [usedCar release];
          [allUsedCars release];
          return NO;
        }
        [usedCar setPropertyMatch:propertyMatch];
        [minValuesAttributes minPropertyMatch:propertyMatch];
        [maxValuesAttributes maxPropertyMatch:propertyMatch];
        /*NSMutableArray *bilder = [[NSMutableArray alloc] initWithCapacity:5];
        s = [UsedCarData stringList:s target:bilder];*/
        if (*++s != ']') {
          NSLog(@"Wrong end char '%c' in data", *s);
          versionOfData = 0.0;
          numberOfCars = 0;
          free(data);
          [usedCar release];
          [allUsedCars release];
          return NO;
        }
        s += 2;
        //[usedCar setBilder:bilder];
        [usedCar trimToSize];
        [allUsedCars addObject:usedCar];
        [usedCars setObject:usedCar forKey:gfz];
        [usedCar release];
        //[bilder release];
      }
    if (*s != '\n') NSLog(@"Spearator after car data are missing!");
    ++s;
    // ignoreTags
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:50];
    s = [UsedCarData stringArray:s target:array];
    [tags.ignoreTags unionSet:[NSSet setWithArray:array]];
    [array release];
    if (*s != '\n') NSLog(@"Spearator after ignore tags are missing!");
    ++s;
    while (*s == '[') {
      IntSet *intSet = [[IntSet alloc] initWithCapacity:50];
      TagCluster *cluster = [[TagCluster alloc] initWithName:nil factor:1 tags:intSet];
      [intSet release];
      s = [cluster parse:s];
      if (s != NULL) {
        [cluster.tags trimToSize];
        [tags addTagCluster:cluster];
      }
      [cluster release];
    }
    // dealer locations
    if (*s == '(') {
      int i = 0;
      int maxLocationIndex = 0;
      while (*s && *s != ')' && i < numberOfCars) {
        int value = 0;
        s = intValue(s+1, &value);
        if (value > maxLocationIndex) maxLocationIndex = value;
        UsedCar *usedCar = [allUsedCars objectAtIndex:i];
        usedCar.locationIndex = value;
        ++i;
      }
      if (i != numberOfCars) NSLog(@"Wrong count (%d) of defined locations!", i);
      if (*s == ')' && *++s == '[') {
        [latitudeLongitudeOfAddresses release];
        latitudeLongitudeOfAddresses = [[NSMutableArray alloc] initWithCapacity:maxLocationIndex+1];
        while (*s && *s != ']') {
          double lat = 0.0;
          double lon = 0.0;
          s = doubleValue(s+1, &lat);
          s = doubleValue(s+1, &lon);
          CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
          [latitudeLongitudeOfAddresses addObject:location];
          [location release];
        }
        if ([latitudeLongitudeOfAddresses count] != maxLocationIndex+1) NSLog(@"Wrong count (%d / %d) of defined locations!", [latitudeLongitudeOfAddresses count], maxLocationIndex);
      } else NSLog(@"Separator after address indexes are missing!");
    }
    [allUsedCars release];
    NSLog(@"Read used car data completed");
    free(data);
  }
  NSLog(@"free memory %d bytes", [self getFreeMemory]);
  return YES;
}

-(id)initWithDelegate:(id<UpdateDelegate>)owner {
  self = [super init];
  if (self != nil) {
    delegate = owner;
    versionOfData = 0.0;
    numberOfCars = 0;
    attributeIndex = nil;
    usedCars = nil;
    NSLog(@"free memory %d bytes", [self getFreeMemory]);
    tags = [[Tags alloc] init];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    attributeIndex = [[NSMutableDictionary alloc] initWithCapacity:10000];
    minValuesAttributes = [[UsedCar alloc] initWithGFZNumber:@""];
    maxValuesAttributes = [[UsedCar alloc] initWithGFZNumber:@""];
    if (![self readData:INDEX_FILE_NAME] || ![WebData initImageCachePath:versionOfData]) {
      UIAlertView *selectionDialog;
      selectionDialog = [[UIAlertView alloc]
                         initWithTitle:@"Internal Error!"
                         message:@"Invalid string (see log)."
                         delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
      [selectionDialog show];
      [selectionDialog release];
    }

    [pool release];
    NSLog(@"version:%f", versionOfData);
    NSLog(@"free memory %d bytes", [self getFreeMemory]);
  }
  return self;
}

-(void)dealloc {
  [self clear];
  [super dealloc];
}

-(NSString *)getAddressOf:(UsedCar *)usedCar {
  NSString *contact = [usedCar stringAttribute:KONTAKT];
  char *data = (char*)malloc(sizeof(char)*([contact length]+1));
  if (data == NULL) return nil;
  const char* s = [contact UTF8String];
  const char* j = strstr(s, "<br>");
  if (j == NULL) return nil;
  const char* i = j;
  while (*--i && *i != '>');
  char *p = data;
  while (++i != j) *p++ = *i;
  i += 4;
  *p++ = ',';
  *p++ = ' ';
  while (*i && *i != '<') *p++ = *i++;
  *p = '\0';
  NSString *result = [NSString stringWithUTF8String:data];
  free(data);
  return result;
}

-(NSString *)dateOfData {
  if (versionOfData == 0.0) return @"";
  NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
  [dateFormat setDateFormat:NSLocalizedString(@"date.format", nil)];
  NSString *s = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:versionOfData]];
  [dateFormat release];
  return s;
}

-(int)count {
  return [usedCars count];
}

+(int)stringArraySearch:(NSString *)key array:(NSArray *)array {
  // array must be sorted as lowercase, e.g. be aware of V < _ < v
  if (key == nil) return -1;
  //key = [key lowercaseString];
	int low = 0;
	int high = [array count]-1;
	while (low <= high) {
    int mid = (low+high) >> 1;
    //NSString* v = [[array objectAtIndex:mid] lowercaseString];
    //NSInteger c = [v compare:key];
    NSString* v = [array objectAtIndex:mid];
    NSInteger c = [v caseInsensitiveCompare:key];
    if (c == NSOrderedAscending) low = mid+1;
    else if (c == NSOrderedDescending) high = mid-1;
    else return mid; // key found
	}
	return -(low+1);  // key not found.
}

+(int)intSearch:(int)key array:(NSArray *)array {
	int low = 0;
	int high = [array count]-1;
	while (low <= high) {
    int mid = (low+high) >> 1;
    int v = [(NSNumber *)[array objectAtIndex:mid] intValue];
    if (v < key) low = mid+1;
    else if (v > key) high = mid-1;
    else return mid; // key found
	}
	return -(low+1);  // key not found.
}

+(NSString *)getPropertyId:(int)propertyIndex {
  static NSString* propertyIds[NUMBER_OF_PROPERTY_IDS] = { @"TRAVEL", @"ENVIRONMENTAL", @"SAFETY", @"LUXURY", @"COMFORT", @"FAMILY", @"SPORTY" };
  return (propertyIndex >= 0 && propertyIndex < NUMBER_OF_PROPERTY_IDS)? propertyIds[propertyIndex] : nil;
}

@end
