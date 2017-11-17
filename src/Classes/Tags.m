//
//  Tags.m
//  MercedesCarBoard
//
//  Created by Sebastian Wedeniwski on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tags.h"
#import "SettingsData.h"
#import "Dictionary.h"
#import "StringAttribute.h"
#import "UsedCarData.h"
#import "RegexKitLite.h"

@implementation Tags

@synthesize ignoreTags;
@synthesize allTags;
@synthesize validTagsList;

-(id)init {
  self = [super init];
  if (self != nil) {
    ignoreTags = [[NSMutableSet alloc] initWithCapacity:50];
    attributeTags = [[NSMutableDictionary alloc] initWithCapacity:10];
    allTags = [[NSMutableArray alloc] initWithCapacity:4000];
    allTagsStartsWith = [[NSMutableDictionary alloc] initWithCapacity:500];
    validTagsList = [[NSMutableDictionary alloc] initWithCapacity:2000];
    dendrogramOfTags = [[NSMutableArray alloc] initWithCapacity:40];
  }
  return self;
}

-(void)dealloc {
  [ignoreTags release];
  [attributeTags release];
  [allTags release];
  [allTagsStartsWith release];
  [validTagsList release];
  [dendrogramOfTags release];
  [super dealloc];
}

//-(void)initCategoryTags {
  /*  versionOfTags = 0;
  ignoreTags = [[NSMutableSet alloc] initWithCapacity:100];
  categoryTags = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[NSSet setWithObjects:nil],nil] forKeys:[NSArray arrayWithObjects:nil]];
   */
  /*versionOfTags = 1290245400.0;
  ignoreTags = [[NSMutableSet alloc] initWithObjects:nil];
  categoryTags = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                        [NSSet setWithObjects:@"komfort-einzelsitze",@"garagentoroeffner",@"sitzhoehenverstellung",@"komfortbereifung",@"sitzheizung",@"klimaautomatic",@"airmatic",@"warmluftzusatzh.m.zeitschaltuhr",@"automatisch",@"autotronic",@"komfortkopfstuetzen",@"trockenluftfilter",@"tempomat",@"bordcomputer",@"automatikgetriebe",@"hoehenverst",@"automatisches",@"warmluft-zusatzheizung",@"tempmatik",@"automatische",@"automatik",@"komfort-multifunktionslenkrad",@"servolenkung",@"speedtronic",@"parkfuehrung",@"komfort-fensterheber",@"multifunktionslenkrad",@"komfort-telefonie",@"luftfederung",@"einparkhilfe",@"sitzklimatisierung",@"komfortabstimmung",@"daempfungs-system",@"funk-fernbedienung",@"klimatisierungsautomatik",@"sprachbedienung",@"automatik-getriebe",@"airmatic-paket",@"komfort-fahrersitz",@"komfort-klimatisierungsautomatik",@"klimaanlage",@"komfort-fahrwerk",@"parktronic-system",@"parkassistent",@"komfort-paket",@"parktronic",@"regensensor",@"einpark-paket",@"komfortkopfstuetze",@"park-assistent",@"sitzkomfort-paket",@"zentralverriegelung",@"komfortoeffnung",@"thermotronic",@"komfortsitze",@"pollenfilter",@"komfort-beifahrersitz",@"komfortabel",@"fernbedienung",@"entertainment",@"ir-fernbedienung",@"fensterheber",@"komfortschaltgetriebe",@"komfortschliessung",@"auto-pilot-system",@"thermatic",@"beheizt",@"komfort",nil],
                                                        [NSSet setWithObjects:@"nebelscheinwerfer",@"notrufsystem",@"diebstahlschutz-paket",@"wartungsintervallanzeige",@"diebstahlschutz",@"geschwindigkeitslimit-assistent",@"abstandsregeltempomat",@"nachtlicht",@"abs",@"gepaeck-insassenschutz",@"insassenschutz",@"airbag",@"pre-saf",@"sichtpaket",@"innenraumschutz",@"fahrlicht-assistent",@"wartungsanzeiger",@"reifendruckverlust-warnung",@"pre-safe(R)-bremse",@"stabilitaets-programm",@"reifendruckkontrolle",@"antriebs-schlupfregelung",@"fahrerairbag",@"nachtsicht-assistent",@"stabilitaetsprogramm",@"fernlicht-assistent",@"antiblockiersystem",@"licht-paket",@"notalarm",@"pre-safe",@"spurhalte-assistent",@"diebstahlwarnanlage",@"gepaecksicherungsnetz",@"diebstahl-warnanlage",@"stabilisator",@"differentialsperre",@"reifenluftdruckueberwachung",nil],
                                                        [NSSet setWithObjects:@"roadster",@"leichtmetallfelgen",@"leichtmetallspeichenrad",@"sport",@"cabriolet",@"sl",@"sl55",@"sl63",@"sportlich",@"slr",@"sport-paket",@"leistung",@"sportfahrwerk",@"amg",@"amg-performance",@"kompressor",@"leichtmetallrad",@"mclaren",@"sportcoupe",@"m.sportf",@"sportsitze",@"coupe",@"slk",@"sportgetriebe",@"leichtmetallraeder",@"sportmotor",@"cabriolet/roadster",@"performance",@"cabrio",@"sportpaket",@"turbo",@"sports",@"breitreifen",@"leichtmetall-felgen",nil],
                                                        [NSSet setWithObjects:@"staubfilter",@"hybrid",@"abgasreinigungsanlage",@"bluetec",@"blueefficiency",@"motor-restwaermeausnutzung",@"partikelfilter",@"abgasreinigung",@"schadstoffarm",nil],
                                                        [NSSet setWithObjects:@"kindersitzen",@"kuehlbox",@"sonnenschutz-paket",@"kindersitzverankerung",@"sonnenschutz",@"kindersitzbefestigung",@"sunprotect",@"kindersicherung",@"kindersitzerkennung",@"klapptisch",@"sonnenblenden",nil],
                                                        [NSSet setWithObjects:@"navigationssystem",@"anhaengerkupplung",@"navigations-system",@"anhaengevorrichtung",@"dachtraegervorruestung",@"kartennavigations-system",@"navigations-paket",@"kuehlfach",@"dachtraeger-system",@"kompass",@"reiserechner",nil],
                                                        [NSSet setWithObjects:@"exklusive",@"avantgarde-fahrwerk",@"edelstahl",@"edelholz",@"leder-/designo-holzausf",@"leder",@"lederausstattung",@"nappa",@"avantgarde",@"holz/leder-kombination",@"lederschalthebel",@"leder/wurzelholzausf",@"holz-leder-lenkrad",@"exklusiv",@"edelholzausstattung",@"kastanie",@"exclusive",@"elegance",@"holzausfuehrung",@"teppich",@"lederlenkrad",@"teppichboden",@"holz",nil],
                                                        nil]
                                               forKeys:[NSArray arrayWithObjects:@"COMFORT",@"SAFETY",@"SPORTY",@"ENVIRONMENTAL",@"FAMILY",@"TRAVEL",@"LUXURY",nil]];*/
/*  versionOfTags = 1295606845.463868;
  ignoreTags = [[NSMutableSet alloc] initWithObjects:nil];
  categoryTags = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                        [NSSet setWithObjects:@"kuehlfach",@"navigations-system",@"aktiv-multikontursitze",@"anhaengerkupplung",@"fond-entertainment-paket",@"sonnenschutzrollos",@"navigations-paket",@"kompass",@"kartennavigations-system",@"dachtraeger-system",@"reiserechner",@"dachtraegervorruestung",@"anhaengevorrichtung",@"navigationssystem",@"zusatzwaermetauscher",nil],
                                                        [NSSet setWithObjects:@"blueefficiency",@"staubfilter",@"abgasreinigungsanlage",@"abgasreinigung",@"bluetec",@"hybrid",@"motor-restwaermeausnutzung",@"schadstoffarm",@"partikelfilter",nil],
                                                        [NSSet setWithObjects:@"sichtpaket",@"gepaecksicherungsnetz",@"notrufsystem",@"elektronisches-stabilitaets-programm",@"bi-xenon",@"abstandsregeltempomat",@"spurhalte-assistent",@"fernlicht-assistent",@"innenraumschutz",@"wartungsanzeiger",@"stabilitaetsprogramm",@"asr",@"asd",@"nachtlicht",@"reifenluftdruckueberwachung",@"innenraumueberw",@"innenraumabsicherung",@"feuerloescher",@"fahrer-u",@"diebstahlschutz-paket",@"adaptive",@"gepaeck-insassenschutz",@"geschwindigkeitslimit-assistent",@"diebstahlwarnanlage",@"diebstahlschutz",@"antriebs-schlupfregelung",@"kurvenlicht",@"nachtsicht-assistent",@"pre-saf",@"head-/thorax-sidebags",@"stabilitaets-programm",@"airbag",@"abbiegelicht",@"licht-paket",@"wartungsintervallanzeige",@"esp",@"stabilisator",@"abs",@"fahrerairbag",@"antiblockiersystem",@"elektr.traktions-system",@"pre-safe",@"pre-safe-system",@"isofix",@"reifendruckkontrolle",@"pre-safe%C2%AE-brems",@"nebelscheinwerfer",@"pre-safe(R)-bremse",@"diebstahl-warnanlage",@"differentialsperre",@"fahrassistenz-paket",@"reifendruckverlust-warnung",@"adaptiver",@"gurtschlossstraffer",@"assyst",@"fahrlicht-assistent",@"gurtwarneinrichtung",@"insassenschutz",@"windowbag",@"notalarm",nil],
                                                        [NSSet setWithObjects:@"kastanie",@"nappa",@"exklusiv",@"lederschalthebel",@"leder/wurzelholzausf",@"exklusive",@"teppichboden",@"teppich",@"holz/leder-kombination",@"multimedia-system",@"exklusiv-paket",@"holz-leder-lenkrad",@"exclusive",@"holzausfuehrung",@"lederlenkrad",@"holz",@"lederausstattung",@"edelholz",@"leder-/designo-holzausf",@"edelholzausstattung",@"leder",@"eukalyptus",@"fondeinzelsitze",@"edelstahl",@"komfort",@"elegance",@"ambientebeleuchtung",nil],
                                                        [NSSet setWithObjects:@"automatisches",@"einparkhilfe",@"automatische",@"tempmatik",@"klimaanlage",@"komfortkopfstuetze",@"komfort-fensterheber",@"komfort-klimatisierungsautomatik",@"parktronic",@"automatisch",@"komfortoeffnung",@"komfortabel",@"park-assistent",@"hoehenverst",@"auto-pilot-system",@"pollenfilter",@"flaschenhalter",@"sprachbedienung",@"fondsicherheits-paket",@"fond-entertainment-system",@"orthopaedische",@"komfortliege",@"abblendbar",@"komfort-fahrwerk",@"thermatic",@"servolenkung",@"komfort-multifunktionslenkrad",@"sitzhoehenverstellung",@"parkfuehrung",@"luftfederung",@"speedtronic",@"komfortabstimmung",@"komfortschliessung",@"komfort",@"komfort-paket",@"fondeinzelsitzanlage",@"zentralverriegelung",@"automatikgetriebe",@"fondarmlehne",@"sitzheizung",@"fondbeleuchtung",@"warmluft-zusatzheizung",@"ir-fernbedienung",@"komfort-telefonie",@"klimaautomatic",@"automatik-getriebe",@"parkassistent",@"komfortsitze",@"colorverglasung",@"memorypaket",@"komfortbereifung",@"komfortkopfstuetzen",@"heckdeckelfernschliessung",@"komfort-einzelsitze",@"komfort-fahrersitz",@"sitzkomfort-paket",@"airmatic",@"thermotronic",@"multikontursitz",@"fernbedienung",@"automatik",@"komfort-beifahrersitz",@"garagentoroeffner",@"entertainment",@"fensterheber",@"autotronic",@"heckdeckel-fernentriegelung",@"airscarf-kopfraumheizung",@"funk-fernbedienung",@"trockenluftfilter",@"regensensor",@"sitzklimatisierung",@"beheizt",@"bordcomputer",@"airmatic-paket",@"einpark-paket",@"multifunktionslenkrad",@"parktronic-system",@"fondsitzheizung",@"innenausstattungspaket",@"warmluftzusatzh.m.zeitschaltuhr",@"komfortschaltgetriebe",@"tempomat",@"daempfungs-system",@"klimatisierungsautomatik",nil],
                                                        [NSSet setWithObjects:@"kindersitzerkennung",@"sonnenschutz",@"kindersicherung",@"sonnenblenden",@"kindersitzen",@"easy-pack-system",@"klapptisch",@"kindersitzbefestigung",@"4+2",@"kuehlbox",@"easy-pack-heckklappe",@"rollo",@"sonnenschutz-paket",@"easy-pack-ablagebox",@"3-sitzbank",@"sunprotect",@"kindersitzverankerung",@"easy-pack",nil],
                                                        [NSSet setWithObjects:@"amg-performance",@"sl63",@"sportmotor",@"cabriolet",@"sport-paket",@"sportgetriebe",@"roadster",@"sportpaket",@"kompressor",@"performance",@"amg-speichenraeder",@"sportlich",@"sportcoupe",@"avantgarde",@"leichtmetallrad",@"amg-fahrzeugpapiere",@"amg",@"leichtmetallspeichenrad",@"m.sportf",@"coupe",@"sportsitze",@"sl",@"sports",@"slr",@"sport",@"leichtmetallfelgen",@"breitreifen",@"mclaren",@"slk",@"leichtmetall-felgen",@"sportfahrwerk",@"cabrio",@"avantgarde-fahrwerk",@"sl55",@"cabriolet/roadster",@"speedshift",@"turbo",@"leistung",nil],nil]
                                               forKeys:[NSArray arrayWithObjects:@"TRAVEL",@"ENVIRONMENTAL",@"SAFETY",@"LUXURY",@"COMFORT",@"FAMILY",@"SPORTY",nil]];
}
*/

-(float)getDistanceGram:(int)n source:(const char *)source target:(const char *)target {
  int sl = strlen(source);
  int tl = strlen(target);
  if (sl == 0 || tl == 0) return (sl == tl)? 1 : 0;
  if (sl < n || tl < n) {
    int cost = 0;
    for (int i = 0, ni = MIN(sl, tl); i < ni; ++i) {
      if (source[i] == target[i]) ++cost;
    }
    return ((float)cost)/MAX(sl, tl);
  }
  // construct sa with prefix
  char *sa = malloc((sl+n-1)*sizeof(char));
  for (int i = 0; i < n-1; ++i) sa[i] = 0;
  for (int i = 0; i < sl; ++i) sa[i+n-1] = source[i];
  
  float *p = malloc((sl+1)*sizeof(float)); //'previous' cost array, horizontally
  float *d = malloc((sl+1)*sizeof(float)); // cost array, horizontally
  char *t_j = malloc(n*sizeof(char)); // jth n-gram of t
  
  for (int i = 0; i <= sl; ++i) p[i] = i;
  for (int j = 1; j <= tl; ++j) {
    // construct t_j n-gram
    if (j < n) {
      for (int ti = 0; ti < n-j; ++ti) t_j[ti] = 0;
      for (int ti = 0; ti < j; ++ti) t_j[ti+n-j] = target[ti];
    } else {
      for (int ti = j-n; ti < j; ++ti) t_j[ti-(j-n)] = target[ti];
    }
    d[0] = j;
    for (int i = 1; i <= sl; ++i) {
      int cost = 0;
      int tn = n;
      //compare sa to t_j
      for (int ni = 0; ni < n; ++ni) {
        if (sa[i-1+ni] != t_j[ni]) ++cost;
        else if (sa[i-1+ni] == 0) --tn; //discount matches on prefix
      }
      float ec = ((float)cost)/tn;
      // minimum of cell to the left+1, to the top+1, diagonally left and up +cost
      d[i] = MIN(MIN(d[i-1]+1, p[i]+1),  p[i-1]+ec);
    }
    // copy current distance counts to 'previous row' distance counts
    float *_d = p;
    p = d;
    d = _d;
  }
  // our last action in the above loop was to switch d and p, so p now
  // actually has the most recent cost counts
  float dist = 1.0f - (((float)p[sl]) / MAX(tl, sl));
  free(sa);
  free(t_j);
  free(d);
  free(p);
  return dist;
}

-(NSString *)closestTag:(NSString *)tag {
  if (allTags == nil || [allTags count] == 0 || [tag length] <= 1) return nil;
  if ([UsedCarData stringArraySearch:tag array:allTags] >= 0) return tag;
  const char *t = [tag UTF8String];
  NSString *closestTag = nil;
  float closestDist = 0.0;
  char tmp[3];
  tmp[0] = t[0];
  tmp[1] = t[1];
  tmp[2] = '\x0';
  NSArray *array = [allTagsStartsWith objectForKey:[NSString stringWithUTF8String:tmp]];
  if (array != nil) {
    for (NSString *tag2 in array) {
      float d = [self getDistanceGram:2 source:[tag2 UTF8String] target:t];
      if (d > closestDist) {
        closestDist = d;
        closestTag = tag2;
      } // ToDo: check if more may have the same closest distance
    }
    if (closestTag != nil && closestDist > 0.8) {
      NSLog(@"Found close known tag '%@' for '%@' with distance %f", closestTag, tag, closestDist);
      return closestTag;
    }
  }
  for (NSString *tag2 in allTags) {
    float d = [self getDistanceGram:2 source:[tag2 UTF8String] target:t];
    if (d > closestDist) {
      closestDist = d;
      closestTag = tag2;
    } // ToDo: check if more may have the same closest distance
  }
  if (closestTag != nil && closestDist > 0.8) {
    NSLog(@"Found close known tag '%@' for '%@' with distance %f", closestTag, tag, closestDist);
    return closestTag;
  }
  return nil;//tag;
}

#define REPLACEMENTS 5
+(NSString *)removingAccents:(NSString *)text {
  static NSString *find = @"äöüß€";
  static NSString *replace[REPLACEMENTS] = {@"ae", @"oe", @"ue", @"ss", @"eur"};
  if (text == nil) return text;
  int l = [text length];
  if (l == 0) return text;
  NSCharacterSet *replaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:find];
  NSRange firstOccurance = [text rangeOfCharacterFromSet:replaceCharacterSet];
  BOOL containsUpperLetters = ([text rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].length > 0);
  BOOL containsAccentLetters = ([text rangeOfCharacterFromSet:[NSCharacterSet decomposableCharacterSet]].length > 0);
  if (firstOccurance.length == 0 && !containsUpperLetters && !containsAccentLetters) return text;
  if (firstOccurance.length > 0) {
    NSMutableString *s = [[NSMutableString alloc] initWithCapacity:l];
    if (firstOccurance.location > 0) [s appendString:[text substringToIndex:firstOccurance.location]];
    for (int i = firstOccurance.location; i < l; ++i) {
      unichar c = [text characterAtIndex:i];
      if ([replaceCharacterSet characterIsMember:c]) {
        int j = 0;
        while (j < REPLACEMENTS && c != [find characterAtIndex:j]) ++j;
        if (j < REPLACEMENTS) [s appendString:replace[j]];
      } else {
        [s appendFormat:@"%C", c];
      }
    }
    text = [NSString stringWithString:s];
    [s release];
  }
  if (containsAccentLetters) { // removing accents
    NSString *t = [[NSString alloc] initWithData:[text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding];
    text = [NSString stringWithString:t];
    [t release];
  }
  if (containsUpperLetters) {
    l = [text length];
    const char* c = [text UTF8String];
    l += strlen(c+l);
    char *target = malloc(l+1);
    for (int i = 0; i < l; ++i, ++c) {
      char ch = *c;
      if (!ch) break;
      if (isupper(ch)) ch = tolower(ch);
      target[i] = ch;
    }
    target[l] = '\0';
    text = [NSString stringWithUTF8String:target];
    free(target);
  }
  return text;
}

+(NSString *)removingSpaces:(NSString *)text {
  // ToDo: configure
  NSString *regex = @"([0-9]+)[ ]+(g|km|ps|ccm|l|eur)([ $])";
  NSArray *tokens = [text componentsSeparatedByRegex:regex];
  if (tokens != nil && [tokens count] > 0) {
    NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:[text length]] autorelease];
    //NSLog(@"tokens: %@", tokens);
    for (NSString *token in tokens) {
      [s appendString:token];
      //[s appendString:@" "];
    }
    return s;
  }
  return text;
}

+(NSString *)simplifyToken:(NSString *)token {
  int l = [token length];
  if (l == 0) return nil;
  token = [Tags removingAccents:token];
  NSCharacterSet *ignorePreSuffixCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@".\",®()'/\\- "];
  NSCharacterSet *numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.,/"];
  if ([token rangeOfCharacterFromSet:ignorePreSuffixCharacterSet].length == 0 &&
      [token rangeOfCharacterFromSet:numberCharacterSet].length == 0) return token;
  BOOL isNumber = YES;
  int ignorePos = 0;
  l = [token length];
  NSMutableString *s = [[NSMutableString alloc] initWithCapacity:l];
  for (int i = 0; i < l; ++i) {
    unichar c = [token characterAtIndex:i];
    BOOL ignore = [ignorePreSuffixCharacterSet characterIsMember:c];
    if (ignorePos > 0 || !ignore) {
      if (isNumber && !ignore && ![numberCharacterSet characterIsMember:c]) isNumber = NO;
      if (!ignore) ignorePos = [s length]+1;
      [s appendFormat:@"%C", c];
    }
  }
  token = (isNumber && ignorePos < 3)? nil : [NSString stringWithString:[s substringToIndex:ignorePos]];
  [s release];
  return token;
}

+(NSArray *)separateNumber:(NSString *)token {
  int l = [token length];
  if (l == 0) return nil;
  NSCharacterSet *numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"];
  if ([token rangeOfCharacterFromSet:numberCharacterSet].length == 0) return nil;
  if ([token rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].length == 0) return nil;
  const char* c = [token UTF8String];
  char *t1 = malloc(l+1);
  char *t2 = malloc(l+1);
  int i = 0;
  int j = 0;
  while (TRUE) {
    char ch = *c;
    if (!ch) break;
    if (isalpha(ch) || j == 0 && (ch == '.' || ch == ',')) {
      if (j > 0) {
        t2[j] = '\0';
        j = -1;
      }
      if (i < 0) {
        free(t1);
        free(t2);
        return nil;
      }
      t1[i++] = ch;
    } else if (isdigit(ch) || ch == '.' || ch == ',') {
      if (i > 0) {
        t1[i] = '\0';
        i = -1;
      }
      if (j < 0) {
        free(t1);
        free(t2);
        return nil;
      }
      t2[j++] = ch;
    }
    ++c;
  }
  if (i >= 0) t1[i] = '\0';
  if (j >= 0) t2[j] = '\0';
  NSArray *result = [NSArray arrayWithObjects:[NSString stringWithUTF8String:t1], [NSString stringWithUTF8String:t2], nil];
  free(t1);
  free(t2);
  return result;
}

/*+(NSString *)removeSimpleXMLTags:(NSString *)token {
  int l = [token length];
  if (l <= 3) return nil;
  //NSLog(@"Token: %@", token);
  NSCharacterSet *startTagCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"<"];
  NSCharacterSet *endTagCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
  NSCharacterSet *splitTagCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
  BOOL xmlTag = NO;
  token = [token lowercaseString];
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:l] autorelease];
  for (int i = 0; i < l; ++i) {
    unichar c = [token characterAtIndex:i];
    if (xmlTag) {
      if ([endTagCharacterSet characterIsMember:c]) {
        [s appendString:@" "];
        xmlTag = NO;
      }
    } else {
      if ([startTagCharacterSet characterIsMember:c]) xmlTag = YES;
      else if ([splitTagCharacterSet characterIsMember:c]) [s appendString:@" "];
      else [s appendFormat:@"%C", c];
    }
  }
  return s;
}*/

/*-(NSSet *)internalValidTags:(NSString *)token {
  NSString *token2 = token;
  if ([token2 hasPrefix:@"<b>"]) token2 = [Tags removeSimpleXMLTags:token2];
  token2 = [token2 stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  token2 = [Tags simplifyToken:token2];
  if (token2 == nil) return nil;
  // create tokens list
  NSArray *tokens = [token2 componentsSeparatedByString:@" "];
  NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:2*[tokens count]+1] autorelease];
  for (NSString *token3 in tokens) {
    // delete suffix "(n"
    if ([token3 hasSuffix:@"(n"]) { // ToDo: move to regex
      token3 = [token3 substringToIndex:[token3 length]-2];
    }
    // split tokens, if two words mit / oder , getrennt, nicht aber, wenn eines der beiden Worte kleiner als drei Buchstaben lang ist oder mit - endet
    if ([token3 length] >= 7) {
      NSArray *tokens2 = [token3 componentsSeparatedByString:@","];
      if ([tokens2 count] == 2) {
        NSString *t0 = [tokens2 objectAtIndex:0];
        NSString *t1 = [tokens2 objectAtIndex:1];
        if ([t0 length] >= 3 && [t1 length] >= 3 && ![t0 hasSuffix:@"-"]) {
          t0 = [Tags simplifyToken:t0];
          t1 = [Tags simplifyToken:t1];
          if (t0 != nil) [m addObject:t0];
          if (t1 != nil) [m addObject:t1];
          token3 = nil;
        }
      } else {
        tokens2 = [token3 componentsSeparatedByString:@"/"];
        if ([tokens2 count] == 2) {
          NSString *t0 = [tokens2 objectAtIndex:0];
          NSString *t1 = [tokens2 objectAtIndex:1];
          if ([t0 length] >= 3 && [t1 length] >= 3 && ![t0 hasSuffix:@"-"]) {
            t0 = [Tags simplifyToken:t0];
            t1 = [Tags simplifyToken:t1];
            if (t0 != nil) [m addObject:t0];
            if (t1 != nil) [m addObject:t1];
            token3 = nil;
          }
        }
      }
    }
    if (token3 != nil) {
      token3 = [Tags simplifyToken:token3];
      if (token3 != nil && [token3 length] > 2) [m addObject:token3];
    }
  }
  // ToDo: not fix!
  NSString *MERCEDES_MODEL = @"Mercedes-Benz "; // ToDo: not fix!
  int l = [MERCEDES_MODEL length];
  if ([token length] > l && [token hasPrefix:MERCEDES_MODEL]) {
    char model[4];
    model[0] = model[1] = model[2] = model[3] = '\x0';
    const char *c = [[token substringFromIndex:l] UTF8String];
    while (*c && !isalpha(*c)) ++c;
    for (int i = 0; i < 3 && c[i]; ++i) {
      if (!isalpha(c[i])) break;
      model[i] = tolower(c[i]);
    }
    if (model[0]) [m addObject:[NSString stringWithFormat:@"mercedes_benz_%s", model]];
  }
  Dictionary *dictionary = [Dictionary getInstance];
  NSSet *s =  [dictionary.formulationRules objectForKey:IGNORE_TAGS];
  if (s != nil) [m minusSet:s];
  [validTagsList setObject:m forKey:token];
  // ToDo: removeSynonyms(m);
  return m;
}*/

-(IntSet *)validTags:(NSString *)token {
  return [validTagsList objectForKey:token];
  //return [self convertTagsToIds:[validTagsList objectForKey:token]];
}

/*-(IntSet *)convertTagsToIds:(NSSet *)tags {
  if (tags == nil || [tags count] == 0) return nil;
  IntSet *m = [[[IntSet alloc] initWithCapacity:[tags count]] autorelease];
  //int i = 0;
  for (NSString *t in tags) {
    int i = [UsedCarData stringArraySearch:t array:allTags];
    if (i >= 0) {
      [m add:i];
    } else {
      NSLog(@"Error: Tag %@ does not exist!", t);
    }
  }
  return m;
}*/

-(int)convertTagToId:(NSString *)tag {
  return (tag == nil)? -1 : [UsedCarData stringArraySearch:tag array:allTags];
}

-(NSSet *)tagNamesInArray:(NSArray *)tags {
  NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:[tags count]] autorelease];
  for (IntSet *s in tags) {
    int l = s.size;
    for (int i = 0; i < l; ++i) {
      //NSLog(@"n:%@, size:%d",n, [allTags count]);
      [m addObject:[allTags objectAtIndex:[s valueAt:i]]];
    }
  }
  return m;
}

-(NSSet *)tagNames:(IntSet *)tags {
  int l = tags.size;
  NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:l] autorelease];
  for (int i = 0; i < l; ++i) {
    //NSLog(@"n:%@, size:%d",n, [allTags count]);
    [m addObject:[allTags objectAtIndex:tags.values[i]]];
  }
  return m;
}

/*-(NSSet *)initAttributeTags:(NSString *)attributeId {
  StringAttribute *attribute = [usedCarData.attributeIndex objectForKey:attributeId];
  if (attribute == nil) return nil;
  NSArray *t = attribute.types;
  NSMutableSet *m = [[[NSMutableSet alloc] initWithCapacity:3*[t count]+10] autorelease];
  for (NSString *token in t) {
    NSSet *s = [self internalValidTags:token];
    if (s != nil) [m unionSet:s];
  }
  [m minusSet:ignoreTags];
  return m;
}*/

/*-(void)reset:(BOOL)loadData {
  //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self initCategoryTags];
  if (loadData) {
    NSString *docPath = [SettingsData documentPath];
    NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"TagsVersion"]];
    if ([version doubleValue] > versionOfTags) {
      [ignoreTags release];
      ignoreTags = [[NSMutableSet alloc] initWithSet:[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"ignoreTags"]]];
      [categoryTags release];
      categoryTags = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[docPath stringByAppendingPathComponent:@"categoryTags"]]];
    }
  }
  [attributeTags removeAllObjects];
  [allTags release];
  allTags = [[NSArray alloc] initWithObjects:nil];
}*/

/*-(void)save {
  NSLog(@"Save tags version %f", versionOfTags);
  NSString *docPath = [SettingsData documentPath];
  [NSKeyedArchiver archiveRootObject:ignoreTags toFile:[docPath stringByAppendingPathComponent:@"ignoreTags"]];
  [NSKeyedArchiver archiveRootObject:categoryTags toFile:[docPath stringByAppendingPathComponent:@"categoryTags"]];
  versionOfTags = [[NSDate date] timeIntervalSince1970];
  NSNumber *version = [NSNumber numberWithDouble:versionOfTags];
  [NSKeyedArchiver archiveRootObject:version toFile:[docPath stringByAppendingPathComponent:@"TagsVersion"]];
}*/

// Faktor Vorlieben für Tags aus Zuordnung
-(int)factor:(NSString *)tag {
  int tagId = [self convertTagToId:tag];
  if (tagId >= 0) {
    SettingsData *settings = [SettingsData getInstance];
    NSArray *properties = [settings propertyIdOrder];
    for (NSString *propertyId in properties) {
      for (TagCluster *cluster in dendrogramOfTags) {
        if (cluster.name != nil && [cluster.name isEqualToString:propertyId]) {
          if ([cluster.tags isMember:tagId]) return [settings value:propertyId];
          break;
        }
      }
    }
  }
  return 1;
}

-(void)addTagCluster:(TagCluster *)cluster {
  [dendrogramOfTags addObject:cluster];
}

/*-(BOOL)match:(NSString *)name categoryId:(NSString *)categoryId {
  NSString *t = [name lowercaseString];
  NSSet *set = [categoryTags objectForKey:categoryId];
  if ([set containsObject:t]) return YES;
  for (NSString *tag in set) {
    NSRange r = [t rangeOfString:tag];
    if (r.length > 0) return YES;
  }
  return NO;
}*/

-(void)setupAllTags {
  NSMutableSet *s = [[NSMutableSet alloc] initWithCapacity:4000];
  NSArray *allAttributeTags = [attributeTags allValues];
  for (NSSet *set in allAttributeTags) {
    [s unionSet:set];
  }
  NSArray *a = [[s allObjects] retain];
  [allTags release];
  allTags = [[NSArray alloc] initWithArray:[a sortedArrayUsingSelector:@selector(compare:)]];
  NSLog(@"#allTags: %d", [allTags count]);
  /*for (int i = 2700; i < 2711; ++i) {
    NSLog(@"%@", [allTags objectAtIndex:i]);
  }*/
  [allTagsStartsWith removeAllObjects];
  char tmp[3];
  tmp[2] = '\x0';
  for (NSString *tag in allTags) {
    if ([tag length] >= 2) {
      const char *startsWith = [tag UTF8String];
      tmp[0] = startsWith[0];
      tmp[1] = startsWith[1];
      NSString *key = [NSString stringWithUTF8String:tmp];
      NSMutableArray *array = [allTagsStartsWith objectForKey:key];
      if (array != nil) {
        [array addObject:tag];
      } else {
        array = [[NSMutableArray alloc] initWithCapacity:5];
        [allTagsStartsWith setObject:array forKey:key];
        [array release];
      }
    }
  }
  [a release];
  [s release];
}

-(void)addAttributeTags:(NSSet *)tags attributeId:(NSString *)attributeId {
  [attributeTags setObject:tags forKey:attributeId];
}

-(NSSet *)attributeTags:(NSString *)attributeId {
  return [attributeTags objectForKey:attributeId];
}

-(void)setAttributeTags:(NSSet *)set attributeId:(NSString *)attributeId {
  [attributeTags setObject:set forKey:attributeId];
}

-(NSSet *)propertyTags:(NSString *)propertyId clusterLevel:(int)level {
  for (TagCluster *cluster in dendrogramOfTags) {
    if ([cluster.name isEqualToString:propertyId]) {
      // ToDo: level > 0
      return [self tagNames:cluster.tags];
    }
  }
  return nil;
}

/*-(void)setCategoryTags:(NSSet *)set categoryId:(NSString *)categoryId {
  [categoryTags setObject:set forKey:categoryId];
}*/

-(void)addAttribute:(NSString *)tag attributeTag:(NSString *)attributeId {
  NSMutableSet *m = [[NSMutableSet alloc] initWithSet:[attributeTags objectForKey:attributeId]];
  [m addObject:tag];
  [self setAttributeTags:m attributeId:attributeId];
  [m release];
}

-(void)addPropertyTag:(NSString *)tag propertyId:(NSString *)propertyId {
  for (TagCluster *cluster in dendrogramOfTags) {
    // ToDo: level > 0
    if ([cluster.name isEqualToString:propertyId]) {
      int i = [UsedCarData stringArraySearch:tag array:allTags];
      if (i >= 0) {
        [cluster.tags add:i];
      } else {
        NSLog(@"Error: Tag %@ does not exist!", tag);
      }
    }
  }
}

-(void)removeAttribute:(NSString *)tag attributeTag:(NSString *)attributeId {
  NSMutableSet *m = [[NSMutableSet alloc] initWithSet:[attributeTags objectForKey:attributeId]];
  [m removeObject:tag];
  [self setAttributeTags:m attributeId:attributeId];
  [m release];
}

-(void)removeProperyTag:(NSString *)tag propertyId:(NSString *)propertyId {
  for (TagCluster *cluster in dendrogramOfTags) {
    // ToDo: level > 0
    if ([cluster.name isEqualToString:propertyId]) {
      int i = [UsedCarData stringArraySearch:tag array:allTags];
      if (i >= 0) {
        [cluster.tags remove:i];
      } else {
        NSLog(@"Error: Tag %@ does not exist!", tag);
      }
    }
  }
}

-(void)minusSetAttribute:(NSSet *)set attributeTag:(NSString *)attributeId {
  NSMutableSet *m = [[NSMutableSet alloc] initWithSet:[attributeTags objectForKey:attributeId]];
  [m minusSet:set];
  [self setAttributeTags:m attributeId:attributeId];
  [m release];
}

-(void)minusProperyTags:(NSSet *)tags propertyId:(NSString *)propertyId {
  for (TagCluster *cluster in dendrogramOfTags) {
    // ToDo: level > 0
    if ([cluster.name isEqualToString:propertyId]) {
      for (NSString *tag in tags) {
        int i = [UsedCarData stringArraySearch:tag array:allTags];
        if (i >= 0) {
          [cluster.tags remove:i];
        } else {
          NSLog(@"Error: Tag %@ does not exist!", tag);
        }
      }
    }
  }
}

-(NSString *)toString {
  NSMutableString *s = [[[NSMutableString alloc] initWithCapacity:10000] autorelease];
  for (NSString *tag in ignoreTags) {
    [s appendString:tag];
    [s appendString:@","];
  }
  for (TagCluster *t in dendrogramOfTags) {
    [s appendString:[t toString]];
  }
  return s;
}

@end
