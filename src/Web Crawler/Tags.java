import java.util.*;

public class Tags {
  //const int REPLACEMENTS = 4;
  final static String[] endings = {"en", "es", "em", "e", "r", "s", "n"};  // ToDo: not FIX
  final static Set<String> baseColor = new HashSet<String>(Arrays.asList("blau","weiss","grau","silber","gruen","schwarz","braun","violett","orange","beige","metallic","rot","gelb","platin","anthrazit"));
  List<String> allTags;
  Set<String> ignoreTags;
  Map<String, Set<String> > attributeTags;
  Map<String, Set<String> > propertyTags;
  private Map<String, Set<String> > validTagsList;
  List<TagCluster> dendrogramOfTags;

  private static final String PLAIN_ASCII =
  "AaEeIiOoUu"    // grave
  + "AaEeIiOoUuYy"  // acute
  + "AaEeIiOoUuYy"  // circumflex
  + "AaOoNn"        // tilde
  + "AaEeIiOoUuYy"  // umlaut
  + "Aa"            // ring
  + "Cc"            // cedilla
  + "OoUu"          // double acute
  ;
  
  private static final String UNICODE =
  "\u00C0\u00E0\u00C8\u00E8\u00CC\u00EC\u00D2\u00F2\u00D9\u00F9"             
  + "\u00C1\u00E1\u00C9\u00E9\u00CD\u00ED\u00D3\u00F3\u00DA\u00FA\u00DD\u00FD" 
  + "\u00C2\u00E2\u00CA\u00EA\u00CE\u00EE\u00D4\u00F4\u00DB\u00FB\u0176\u0177" 
  + "\u00C3\u00E3\u00D5\u00F5\u00D1\u00F1"
  + "\u00C4\u00E4\u00CB\u00EB\u00CF\u00EF\u00D6\u00F6\u00DC\u00FC\u0178\u00FF" 
  + "\u00C5\u00E5"                                                             
  + "\u00C7\u00E7" 
  + "\u0150\u0151\u0170\u0171" 
  ;

  public Tags(Map<String, List<String> > attributeTypes) {
    //versionOfTags = 1295606845.463868;
    ignoreTags = new HashSet<String>(20);
    propertyTags = new HashMap<String, Set<String> >(10);
    // ToDo: not FIX
    ignoreTags.addAll(Arrays.asList("aktiengesellschaft", "auf", "amp;", "amp;g", "das", "dem", "den", "der", "durch", "fax", "gautomobilgesellschaft", "gmbh", "ii/iii", "iii", "mercedes-gmbh", "mbh", "mit", "nach", "nur", "oder", "ohne", "service", "strasse", "tel", "und", "unter", "verkauf", "vertrieb", "von", "weg", "zum", "zur"));
    propertyTags.put("TRAVEL", new HashSet<String>(Arrays.asList("motorcaravan","batterie","kuehlfach","navigationssystem","aktiv-multikontursitz","anhaengerkupplung","fond-entertainment-paket","sonnenschutzrollos","navigations-paket","kompass","kartennavigations-system","dachtraeger-system","reiserechner","dachtraegervorruestung","anhaengevorrichtung","zusatzwaermetauscher","tisch","klapptisch","zusatzbatterie","tv-bildschirm","gepaeckraumabtrennung","getraenkebehaelter","cupholder","wohnmobil","doppelcupholder","komfortliege", "klappbare","kapazitaet","comand","aps","dachreling","polo","marco","suv-tourer")));
    propertyTags.put("ENVIRONMENTAL", new HashSet<String>(Arrays.asList("blueefficiency","staubfilter","abgasreinigungsanlage","abgasreinigung","bluetec","hybrid","motor-restwaermeausnutzung","schadstoffarm","partikelfilter","erdgasantrieb","eu3","eu4")));
    propertyTags.put("SAFETY", new HashSet<String>(Arrays.asList("sidebag","pre-safe-bremse","pre-safe-system","sichtpaket","gepaecksicherungsnetz","notrufsystem","elektronisches-stabilitaets-programm","bi-xenon","abstandsregeltempomat","spurhalte-assistent","fernlicht-assistent","innenraumschutz","wartungsanzeiger","stabilitaetsprogramm","asr","asd","nachtlicht","reifenluftdruckueberwachung","innenraumueberw","innenraumabsicherung","feuerloescher","diebstahlschutz-paket","adaptive","gepaeck-insassenschutz","geschwindigkeitslimit-assistent","diebstahlwarnanlage","diebstahlschutz","antriebs-schlupfregelung","kurvenlicht","nachtsicht-assistent","pre-saf","head-/thorax-sidebags","airbag","abbiegelicht","licht-paket","wartungsintervallanzeige","esp","stabilisator","abs","fahrerairbag","antiblockiersystem","elektr.traktions-system","isofix","reifendruckkontrolle","nebelscheinwerfer","differentialsperre","fahrassistenz-paket","reifendruckverlust-warnung","gurtschlossstraffer","assyst","fahrlicht-assistent","gurtwarneinrichtung","insassenschutz","windowbag","notalarm","totwinkel-assistent","bremsanlage","distronic")));
    propertyTags.put("LUXURY", new HashSet<String>(Arrays.asList("ambiente","exklus","kastanie","nappa","exklusiv","lederschalthebel","teppichboden","teppich","multimedia-system","exklusiv-paket","holz-leder-lenkrad","holzausfuehrung","lederlenkrad","holz","lederausstattung","edelholz","leder-/designo-holzausf","edelholzausstattung","leder","eukalyptus","fondeinzelsitze","edelstahl","komfort","elegance","ambientebeleuchtung","exklusive","zierteile")));
    propertyTags.put("COMFORT", new HashSet<String>(Arrays.asList("einparkhilfe","automatisch","tempmatik","klimaanlage","komfortkopfstuetze","komfort-fensterheber","komfort-klimatisierungsautomatik","parktronic","automatisch","komfortoeffnung","komfortabel","park-assistent","hoehenverst","auto-pilot-system","pollenfilter","flaschenhalter","sprachbedienung","linguatronic","fondsicherheits-paket","fond-entertainment-system","orthopaedische","komfortliege","abblendbar","komfort-fahrwerk","thermatic","servolenkung","komfort-multifunktionslenkrad","sitzhoehenverstellung","parkfuehrung","luftfederung","speedtronic","komfortabstimmung","komfortschliessung","komfort","komfort-paket","fondeinzelsitzanlage","zentralverriegelung","automatikgetriebe","fondarmlehne","sitzheizung","fondbeleuchtung","ir-fernbedienung","komfort-telefonie","klimaautomatic","parkassistent","komfortsitze","colorverglasung","memorypaket","komfortbereifung","heckdeckelfernschliessung","komfort-einzelsitze","komfort-fahrersitz","sitzkomfort-paket","airmatic","thermotronic","multikontursitz","fernbedienung","automatik","komfort-beifahrersitz","garagentoroeffner","entertainment","fensterheber","autotronic","heckdeckel-fernentriegelung","airscarf-kopfraumheizung","funk-fernbedienung","trockenluftfilter","regensensor","sitzklimatisierung","beheizt","bordcomputer","airmatic-paket","einpark-paket","multifunktionslenkrad","parktronic-system","fondsitzheizung","innenausstattungspaket","warmluftzusatzh.m.zeitschaltuhr","komfortschaltgetriebe","tempomat","daempfungs-system","klimatisierungsautomatik","zusatzheizung","komfortabstimmung")));
    propertyTags.put("FAMILY", new HashSet<String>(Arrays.asList("van","kindersitzerkennung","sonnenschutz","kindersicherung","sonnenblenden","kindersitzen","easy-pack-system","kindersitzbefestigung","kuehlbox","easy-pack-heckklappe","rollo","sonnenschutz-paket","easy-pack-ablagebox","3-sitzbank","sunprotect","kindersitzverankerung","easy-pack")));
    propertyTags.put("SPORTY", new HashSet<String>(Arrays.asList("amg-performance","sl63","sportmotor","cabriolet","sport","sport-paket","sportgetriebe","roadster","sportpaket","kompressor","performance","amg-speichenraeder","sportlich","sportcoupe","avantgarde","leichtmetallrad","amg-fahrzeugpapiere","amg","m.sportf","coupe","sportsitze","slr","sport","leichtmetallfelgen","breitreifen","mclaren","mercedes_benz_slk","sportfahrwerk","cabrio","cabriolet","avantgarde-fahrwerk","sl55","speedshift","turbo","leistung","ergonomie-sportlenkrad","carbon","performance-package","schmiederaeder")));

    // feueropal,bornit,elfenbein,covellin,malachit,impala,varicolor,violan,arrow,antimon,graphit,ungueltige,laurit,himalayas,digenit,diamant,crystal,lack,teide,designo,magno

    allTags = new ArrayList<String>(5000);
    validTagsList = new HashMap<String, Set<String> >(1000);
    attributeTags = new HashMap<String, Set<String> >(20);
    Set<String> m = new HashSet<String>(3000);
    List<String> a = UsedCar.stringAttributeIdOrder();
    for (String attributeId : a) {
      Set<String> s = initAttributeTags(attributeTypes.get(attributeId), attributeId);
      if (s != null) {
        attributeTags.put(attributeId, s);
        m.addAll(s);
      }
    }
    //Set<String> toRemove = new HashSet<String>(100);
    Map<String, String> toReplace = new HashMap<String, String>(100);
    removeSynonyms(m, toReplace);
    //if (m.contains("navigations-system")) System.out.println("ERROR: 'navigations-system'"); // ToDo: REMOVE!
    //allTags.clear();
    //allTags.addAll(m);
    for (String attributeId : a) {
      Set<String> s = attributeTags.get(attributeId);
      s.removeAll(ignoreTags);
      for (String key : toReplace.keySet()) {
        if (s.remove(key)) {
          while (true) {
            String key2 = toReplace.get(key);
            if (key2 == null) break;
            key = key2;
          }
          s.add(key);
        }
      }
      //removeSynonyms(s);
    }
    Collection<Set<String> > v = validTagsList.values();
    for (Set<String> tags : v) {
      tags.removeAll(ignoreTags);
      for (String key : toReplace.keySet()) {
        if (tags.remove(key)) {
          while (true) {
            String key2 = toReplace.get(key);
            if (key2 == null) break;
            key = key2;
          }
          tags.add(key);
        }
      }
      //removeSynonyms(tags);
    }
    v = propertyTags.values();
    for (Set<String> tags : v) {
      tags.removeAll(ignoreTags);
      for (String key : toReplace.keySet()) {
        if (tags.remove(key)) {
          System.out.print("Replace property tag '" + key);
          while (true) {
            String key2 = toReplace.get(key);
            if (key2 == null) break;
            key = key2;
          }
          System.out.println("' by '" + key + "'");
          tags.add(key);
        }
      }
      //removeSynonyms(tags);
    }
    allTags.addAll(m);  // remove allTags!!! not needed because of attributeTags
    Collections.sort(allTags);
    createDendrogram();
  }

  public TagCluster getTagCluster(String name) {
    for (TagCluster t : dendrogramOfTags) {
      if (t.name != null && name.equals(t.name)) {
        // check if tags (from the propertyTags) are not existing in the data pool
        if (!t.validated) {
          List<String> toRemove = new ArrayList<String>(t.tags.size());
          for (String tag : t.tags) {
            int i = Collections.binarySearch(allTags, tag);
            if (i < 0) {
              System.out.println("Remove tag '" + tag + "' from cluster " + t.name);
              toRemove.add(tag);
            }
          }
          t.tags.removeAll(toRemove);
          t.validated = true;
        }
        return t;
      }
    }
    return null;
  }

  public boolean areLettersEqual(String source, String target) {
    final int sl = source.length();
    final int tl = target.length();
    int i = 0;
    int j = 0;
    boolean areEqual = false;
    while (i < sl && j < tl) {
      char cs = source.charAt(i);
      char ct = target.charAt(j);
      while (!Character.isLetter(cs)) {
        if (++i == sl) return areEqual;
        cs = source.charAt(i);
      }
      while (!Character.isLetter(ct)) {
        if (++j == tl) return areEqual;
        ct = target.charAt(j);
      }
      if (cs != ct) return false;
      areEqual = true;
      ++i;
      ++j;
    }
    return areEqual;
  }

  public boolean isAcronym(String source, String target) {
    // e.g. "elektr.verstellb" and "elek.verstellb"
    if (source.length() > target.length()) {
      String t = source;
      source = target;
      target = t;
    }
    StringTokenizer tokens = new StringTokenizer(source, "-.,/\\");
    while (tokens.hasMoreTokens()) {
      String token = tokens.nextToken();
      if (target.indexOf(token) < 0) return false;
    }
    return true;
  }

  public float getDistanceGram(int n, String source, String target) {
    final int sl = source.length();
    final int tl = target.length();
    if (sl == 0 || tl == 0) return (sl == tl)? 1 : 0;
    // extension: the first n characters of source and target must be equal
    if (sl < n || tl < n) return 0;
    for (int i = 0; i < n; ++i) {
      if (source.charAt(i) != target.charAt(i)) return 0;
    }
    //int cost = 0;
    //for (int i = 0, ni = Math.min(sl, tl); i < ni; ++i) {
    // if (source.charAt(i) == target.charAt(i)) ++cost;
    //}
    //if (sl < n || tl < n) return (float)cost/Math.max(sl, tl);

    char[] sa = new char[sl+n-1];
    for (int i = 0; i < n-1; ++i) sa[i] = 0;
    for (int i = 0; i < sl; ++i) sa[i+n-1] = source.charAt(i);

    float[] p = new float[sl+1]; 
    float[] d = new float[sl+1]; 
    char[] t_j = new char[n]; // jth n-gram of t
    
    for (int i = 0; i <= sl; ++i) p[i] = i;
    for (int j = 1; j <= tl; ++j) {
      //construct t_j n-gram 
      if (j < n) {
        for (int ti = 0; ti < n-j; ++ti) t_j[ti] = 0;
        for (int ti = 0; ti < j; ++ti) t_j[ti+n-j] = target.charAt(ti);
      } else {
        for (int ti = j-n; ti < j; ++ti) t_j[ti-(j-n)] = target.charAt(ti);
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
        float ec = (float)cost/tn;
        // minimum of cell to the left+1, to the top+1, diagonally left and up +cost
        d[i] = Math.min(Math.min(d[i-1]+1, p[i]+1),  p[i-1]+ec);
      }
      // copy current distance counts to 'previous row' distance counts
      float[] _d = p;
      p = d;
      d = _d;
    }
    // our last action in the above loop was to switch d and p, so p now
    // actually has the most recent cost counts
    return 1.0f - ((float) p[sl] / Math.max(tl, sl));
  }

  
  Set<String> similarTags(String tag, Set<String> tagsToConsider) {
    Set<String> result = new HashSet<String>(5);
    int i = tag.length();
    for (String t : tagsToConsider) {
      int j = t.length();
      if (j < i) {  // ToDo: n-gram search
        if (j <= 3) {
          if (tag.startsWith(t) || tag.endsWith(t)) result.add(t);
        } else {
          if (tag.indexOf(t) >= 0) result.add(t);
        }
      } else if (j > i) {
        if (i <= 3) {
          if (t.startsWith(tag) || t.endsWith(tag)) result.add(t);
        } else {
          if (t.indexOf(tag) >= 0) result.add(t);
        }
      }
    }
    return result;
  }

  private void createDendrogram() {
    dendrogramOfTags = new ArrayList<TagCluster>(allTags.size());
    Set<String> tagsToConsider = new HashSet(allTags);
    // use property tags for the first set of clusters
    Set<String> set = propertyTags.keySet();
    for (String property : set) {
      Set<String> t = propertyTags.get(property);
      tagsToConsider.removeAll(t);
      dendrogramOfTags.add(new TagCluster(property, 1, t));
    }
    for (TagCluster cluster : dendrogramOfTags) {
      for (String tag : cluster.tags) {
        Set<String> t = similarTags(tag, tagsToConsider);
        if (t != null && t.size() > 0) {
          tagsToConsider.removeAll(t);
          cluster.addLevel(new TagCluster(2, t));
        }
      }
    }
    // use product categroies for the other set of clusters
    List<String> attributeIdOrder = UsedCar.stringAttributeIdOrder();
    for (String attributeId : attributeIdOrder) {
      Set<String> t = attributeTags.get(attributeId);
      tagsToConsider.removeAll(t);
      TagCluster cluster = new TagCluster(1, t);
      dendrogramOfTags.add(cluster);
      for (String tag : t) {
        Set<String> s = similarTags(tag, tagsToConsider);
        if (s != null && s.size() > 0) {
          tagsToConsider.removeAll(s);
          cluster.addLevel(new TagCluster(2, s));
        }
      }
    }
    if (tagsToConsider.size() > 0) {
      System.out.println("Not all tags in dendrogram (" + tagsToConsider.size() + ")!");
    }
    // tisch - cluster level 1 : klapptisch - cluster level 2
    // {tisch}-{klapptisch}
    // {automatisch}
    
  }

  // ToDo: read plist with synonyms
  public void removeSynonyms(Set<String> tags, Map<String, String> toReplace) {
    final boolean verbose = true;//(tags.size() == allTags.size());
    tags.removeAll(ignoreTags);
    String[] tagsArray = tags.toArray(new String[0]);
    int l = tagsArray.length;
    //for (String tag : tags) {
    for (int i = 0; i < l; ++i) {
      String tag = tagsArray[i];
      if (tag.startsWith("mercedes_benz_")) continue;  // ToDo: not fix!
      // delete suffix "(n"
      /*if (tag.endsWith("(n")) { // ToDo: move to regex
        String tag2 = tag.substring(0, tag.length()-2);
        toReplace.put(tag, tag2);
        if (tags.remove(tag)) tags.add(tag2);
      } else {*/
        for (int j = i+1; j < l; ++j) {
          String tag2 = tagsArray[j];
          float distance2 = getDistanceGram(2, tag, tag2);
          if (distance2 >= 0.9f || distance2 >= 0.8f && isAcronym(tag, tag2)) {
            float distance3 = getDistanceGram(3, tag, tag2);
            if (distance3 >= 0.8f) {
              float distance4 = getDistanceGram(4, tag, tag2);
              if (distance4 >= 0.8f) {
                if (tag.length() < tag2.length()) {
                  String tag3 = toReplace.get(tag2);
                  if (tag3 == null) {
                    if (verbose) System.out.println("REMOVE tag2 '" + tag2 + "' because '" + tag + "' exists with distance " + distance2 + " / " + distance3 + " / " + distance4);
                    toReplace.put(tag2, tag);
                    tags.remove(tag2);
                    if (toReplace.get(tag) == null) tags.add(tag);
                  } else if (tag3.length() < tag.length()) {
                    if (verbose) System.out.println("REPLACE tag2 '" + tag2 + "'/'" + tag + "' because '" + tag3 + "' exists with distance " + distance2 + " / " + distance3 + " / " + distance4);
                    tags.remove(tag);
                    tags.remove(tag2);
                    if (toReplace.get(tag3) == null) tags.add(tag3);
                    toReplace.put(tag, tag3);
                    toReplace.put(tag2, tag3);
                  }
                } else {
                  String tag3 = toReplace.get(tag);
                  if (tag3 == null) {
                    if (verbose) System.out.println("REMOVE tag '" + tag + "' because '" + tag2 + "' exists with distance " + distance2 + " / " + distance3 + " / " + distance4);
                    toReplace.put(tag, tag2);
                    tags.remove(tag);
                    if (toReplace.get(tag2) == null) tags.add(tag2);
                  } else if (tag3.length() < tag2.length()) {
                    if (verbose) System.out.println("REPLACE tag '" + tag + "'/'" + tag2 + "' because '" + tag3 + "' exists with distance " + distance2 + " / " + distance3 + " / " + distance4);
                    tags.remove(tag);
                    tags.remove(tag2);
                    if (toReplace.get(tag3) == null) tags.add(tag3);
                    toReplace.put(tag, tag3);
                    toReplace.put(tag2, tag3);
                  }
                }
              }
            }
          }
        //}
        
        /*for (int i = 0; i < endings.length; ++i) {
          int n = tag.length()-endings[i].length();
          if (n > 3 && tag.endsWith(endings[i])) {
            String shortTag = tag.substring(0, n);
            if (allTags.contains(shortTag)) {
              float distance2 = getDistanceGram(2, tag, shortTag);
              if (distance2 >= 0.8f) {
                float distance3 = getDistanceGram(3, tag, shortTag);
                if (distance3 >= 0.8f) {
                  float distance4 = getDistanceGram(4, tag, shortTag);
                  if (distance4 >= 0.8f) {
                    if (verbose) System.out.println("REMOVE tag '" + tag + "' because '" + shortTag + "' exists with distance " + distance2 + " / " + distance3 + " / " + distance4);
                    toRemove.add(tag);
                    toAdd.add(shortTag);
                    break;
                  }
                }
              }
            }
          }
        }*/
      }
    }
  }
  
  // remove accentued from a string and replace with ascii equivalent
  private static String removingAccents(String s) {
    if (s == null) return null;
    s = s.replace("Ä", "ae");
    s = s.replace("ä", "ae");
    s = s.replace("Ö", "oe");
    s = s.replace("ö", "oe");
    s = s.replace("Ü", "ue");
    s = s.replace("ü", "ue");
    s = s.replace("ß", "ss");
    s = s.replace("é", "e");
    s = s.replace("®", "");
    s = s.replace("¾", "");
    s = s.replace("  -", "-");
    /*
     s = s.replaceAll("[èéêë]","e");
     s = s.replaceAll("[ûù]","u");
     s = s.replaceAll("[ïî]","i");
     s = s.replaceAll("[àâ]","a");
     s = s.replaceAll("Ô","o");
     
     s = s.replaceAll("[ÈÉÊË]","E");
     s = s.replaceAll("[ÛÙ]","U");
     s = s.replaceAll("[ÏÎ]","I");
     s = s.replaceAll("[ÀÂ]","A");
     s = s.replaceAll("Ô","O");
     */
    //s = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD).replaceAll("\\p{InCombiningDiacriticalMarks}+", ""); 
    int l = s.length();
    StringBuilder sb = new StringBuilder(l+10);
    for (int i = 0; i < l; ++i) {
      char c = s.charAt(i);
      /*if (c == '\u00C4' || c == '\u00E4') sb.append("ae");
      else if (c == '\u00D6' || c == '\u00F6') sb.append("oe");
      else if (c == '\u00DC' || c == '\u00FC') sb.append("ue");
      else if (c == '\u00DF') sb.append("ss");
      else {*/
        int pos = UNICODE.indexOf(c);
        if (pos >= 0) sb.append(PLAIN_ASCII.charAt(pos));
        else sb.append(Character.toLowerCase(c));
      //}
    }
    /*for (int offset = 0; offset < l; ) {
      int codepoint = s.codePointAt(offset);
      offset += Character.charCount(codepoint);
      if (codepoint == 8730 && offset < l) {
        codepoint = s.codePointAt(offset);
        offset += Character.charCount(codepoint);
        if (codepoint == 228 || codepoint == 196) sb.append("ae");
        else if (codepoint == 246 || codepoint == 214) sb.append("oe");
        else if (codepoint == 252 || codepoint == 220) sb.append("ue");
        else if (codepoint == 223) sb.append("ss");
        else sb.appendCodePoint(Character.toLowerCase(codepoint));
//          System.out.println("codepoint:" + codepoint);
      } else
        sb.appendCodePoint(Character.toLowerCase(codepoint));
    }*/
    return sb.toString();
  }

  private static String simplifyToken(String token) {
    int l = token.length();
    if (l == 0) return null;
    token = removingAccents(token);
    l = token.length();
    String ignorePreSuffixCharacterSet = ".\",®¾()'/\\-+ ";
    String numberCharacterSet = "0123456789.,/";
    boolean isNumber = true;
    int ignorePos = 0;
    StringBuilder s = new StringBuilder(l);
    for (int i = 0; i < l; ++i) {
      char c = token.charAt(i);
      boolean ignore = (ignorePreSuffixCharacterSet.indexOf(c) >= 0);
      if (ignorePos > 0 || !ignore) {
        if (isNumber && !ignore && numberCharacterSet.indexOf(c) < 0) isNumber = false;
        if (!ignore) ignorePos = s.length()+1;
        s.append(c);
      }
    }
    return (isNumber && ignorePos < 3)? null : s.substring(0, ignorePos);
  }
  
  String removeSimpleXMLTags(String token) {
    int l = token.length();
    if (l <= 3) return null;
    //NSLog("Token: %", token);
    boolean xmlTag = false;
    token = token.toLowerCase();
    StringBuilder s = new StringBuilder(l);
    for (int i = 0; i < l; ++i) {
      char c = token.charAt(i);
      if (xmlTag) {
        if (c == '>') {
          s.append(' ');
          xmlTag = false;
        }
      } else {
        if (c == '<') xmlTag = true;
        else if (c == '&') s.append(' ');
        else s.append(c);
      }
    }
    return s.toString();
  }
  
  Set<String> internalValidTags(String token, String attributeId) {
    String token2 = token;
    if (token2.startsWith("<b>")) token2 = removeSimpleXMLTags(token2);
    token2 = token2.replace("&quot;", "\"");
    token2 = simplifyToken(token2);
    if (token2 == null) return null;
    // create tokens list
    StringTokenizer tokens = new StringTokenizer(token2);
    Set<String> m = new HashSet<String>(3*tokens.countTokens()+1);
    while (tokens.hasMoreTokens()) {
      String token3 = tokens.nextToken();
      // split tokens, if two words mit / oder , getrennt, nicht aber, wenn eines der beiden Worte kleiner als drei Buchstaben lang ist oder mit - endet
      if (token3.length() >= 7) {
        StringTokenizer tokens2 = new StringTokenizer(token3, ",");
        if (tokens2.countTokens() == 2) {
          String t0 = tokens2.nextToken();
          String t1 = tokens2.nextToken();
          if (t0.length() >= 3 && t1.length() >= 3 && !t0.endsWith("-")) {
            t0 = simplifyToken(t0);
            t1 = simplifyToken(t1);
            if (t0 != null) m.add(t0);
            if (t1 != null) m.add(t1);
            token3 = null;
          }
        } else {
          tokens2 = new StringTokenizer(token3, "/");
          if (tokens2.countTokens() == 2) {
            String t0 = tokens2.nextToken();
            String t1 = tokens2.nextToken();
            if (t0.length() >= 3 && t1.length() >= 3 && !t0.endsWith("-")) {
              t0 = simplifyToken(t0);
              t1 = simplifyToken(t1);
              if (t0 != null) m.add(t0);
              if (t1 != null) m.add(t1);
              token3 = null;
            }
          }
        }
      }
      if (token3 != null) {
        token3 = simplifyToken(token3);
        if (token3 != null && token3.length() > 2) m.add(token3);
      }
    }
    // ToDo: not fix!
    if (attributeId.equals(UsedCar.MODELL)) {
      String MERCEDES_MODEL = "Mercedes-Benz "; // ToDo: not fix!
      int l = MERCEDES_MODEL.length();
      int n = token.length();
      if (n > l && token.startsWith(MERCEDES_MODEL)) {
        StringBuilder sb = new StringBuilder(5);
        while (l < n && !Character.isLetter(token.charAt(l))) ++l;
        for (int i = 0; i < 3 && l < n; ++i, ++l) {
          if (!Character.isLetter(token.charAt(l))) break;
          sb.append(Character.toLowerCase(token.charAt(l)));
        }
        if (sb.length() > 0) {
          m.add("mercedes_benz_" + sb.toString());
          m.remove(sb.toString());
        }
      }
    } else if (attributeId.equals(UsedCar.FARBE) || attributeId.equals(UsedCar.POLSTER)) {  // ToDo: not fix
      Iterator<String> i = baseColor.iterator();
      while (i.hasNext()) {
        String color = i.next();
        if (token2.indexOf(color) >= 0) m.add(color);
      }
    } else if (attributeId.equals(UsedCar.KRAFTSTOFFART)) {  // ToDo: not fix
      if (token2.indexOf("diesel") >= 0) m.add("diesel");
    }
    validTagsList.put(token, m);
    return m;
  }

  public Set<Integer> validTags(String token) {
    Set<String> tags = validTagsList.get(token);
    if (tags == null) {
      if (simplifyToken(token) != null) {
        String token2 = null;
        Set<String> set = validTagsList.keySet();  // e.g. "Mercedes-Benz SLK 200 KOMPRESSOR Roadster" != "Mercedes-Benz SLK 200 Kompressor Roadster"
        for (String t : set) {
          if (token.equalsIgnoreCase(t)) {
            token2 = t;
            break;
          }
        }
        if (token2 == null) {
          System.out.println("No valid tag for " + token);
          return null;
        } else {
          tags = validTagsList.get(token2);
        }
      } else {
        return null;
      }
    }
    try {
      return convertTagsToIds(tags);
    } catch (RuntimeException e) {
      System.out.println("Error to find tags for token '" + token);
      throw e;
    }
  }

  public Set<Integer> validBaseColorTags(String token) {
    String s = simplifyToken(token);
    if (s == null) return null;
    Set<String> tags = new HashSet<String>(5);
    Iterator<String> i = baseColor.iterator();
    while (i.hasNext()) {
      String color = i.next();
      if (s.indexOf(color) >= 0) tags.add(color);
    }
    return (tags.size() == 0)? null : convertTagsToIds(tags);
  }

  public Set<Integer> convertTagsToIds(Set<String> tags) {
    Set<Integer> m = new HashSet<Integer>(tags.size());
    for (String t : tags) {
      int i = Collections.binarySearch(allTags, t);
      if (i >= 0) {
        m.add(new Integer(i));
      } else {
        try {
          System.out.println("Error: Tag '" + t + "' does not exist!");
          throw new RuntimeException();
        } catch (RuntimeException e) {
          e.printStackTrace();
          throw e;
        }
      }
    }
    return m;
  }

  //-(NSSet *)tagNames:(NSArray *)tags;
  private Set<String> initAttributeTags(List<String> attributeTypes, String attributeId) {
    Set<String> m = new HashSet<String>(4*attributeTypes.size()+10);
    for (String token : attributeTypes) {
      Set<String> s = internalValidTags(token, attributeId);
      if (s != null) m.addAll(s);
      else if (token.length() > 0) System.out.println("NO tags for: " + token);
    }
    if (attributeId.equals(UsedCar.FARBE) || attributeId.equals(UsedCar.POLSTER)) {
      m.addAll(baseColor);
    }
    m.removeAll(ignoreTags);
    return m;
  }
  //-(id)init:(UsedCarData *)uCarData;

  public String toString(Map<String, List<String> > attributeTypes) {
    StringBuilder sb = new StringBuilder(10000);
    sb.append("Ignore tags:");
    boolean first = true;
    for (String t : ignoreTags) {
      if (!first) sb.append(',');
      sb.append(t);
      first = false;
    }
    sb.append("\n\nTag clusters:\n");
    Set<String> allAssignedTags = new HashSet<String>(allTags.size());
    for (TagCluster tagCluster : dendrogramOfTags) {
      if (tagCluster.name != null) {
        sb.append(tagCluster.name);
        sb.append('\n');
        List<String> a = UsedCar.stringAttributeIdOrder();
        for (String attributeId : a) {
          //System.out.println("attributeId:"+attributeId);
          List<String> tokens = attributeTypes.get(attributeId);
          for (String token : tokens) {
            Set<String> s = internalValidTags(token, attributeId);
            if (s == null) continue;
            Set<String> s2 = new HashSet<String>(s);
            if (s2.retainAll(tagCluster.tags) && s2.size() > 0) {
              allAssignedTags.addAll(s2);
              sb.append(token);
              sb.append(": ");
              first = true;
              for (String cTags : s2) {
                if (ignoreTags.contains(cTags)) continue;
                if (!first) sb.append(", ");
                sb.append(cTags);
                first = false;
              }
              boolean first2 = true;
              for (String cTags : s) {
                if (!s2.contains(cTags) && !ignoreTags.contains(cTags)) {
                  if (first) sb.append('(');
                  else if (first2) sb.append(", (");
                  else sb.append(", ");
                  sb.append(cTags);
                  first = false;
                  first2 = false;
                }
              }
              if (!first2) sb.append(')');
              sb.append('\n');
            }
          }
        }
        sb.append('\n');
      }
    }
    allAssignedTags.removeAll(ignoreTags);
    Set<String> set = new HashSet<String>(allTags);
    if (set.retainAll(allAssignedTags) && set.size() > 0) {
      sb.append("\n\nNot assigned tags:");
      for (String tag : set) {
        sb.append('\n');
        sb.append(tag);
        sb.append(": ");
        first = true;
        List<String> a = UsedCar.stringAttributeIdOrder();
        for (String attributeId : a) {
          List<String> tokens = attributeTypes.get(attributeId);
          for (String token : tokens) {
            Set<String> s = internalValidTags(token, attributeId);
            if (s != null && s.contains(tag)) {
              if (!first) sb.append(',');
              sb.append('\'');
              sb.append(token);
              sb.append('\'');
              first = false;
            }
          }
        }
      }
    }
    return sb.toString();
  }

  public String toCompactString() {
    StringBuilder sb = new StringBuilder(10000);
    boolean first = true;
    for (String t : ignoreTags) {
      if (!first) sb.append("\",");
      sb.append('\"');
      sb.append(t);
      first = false;
    }
    if (!first) sb.append('\"');
    sb.append('\n');
    for (TagCluster t : dendrogramOfTags) {
      sb.append(t.toCompactString(this));
    }
    return sb.toString();
  }

  public static void main(String[] args) {
    System.out.println(removingAccents("Vorführwagen"));
    System.out.println(removingAccents("Coupé"));
    System.out.println(removingAccents("andraditgrün"));
    System.out.println(removingAccents("alabasterweiß"));
    System.out.println(simplifyToken("pre-safe¾"));
    System.out.println(simplifyToken("pre-safe¾-bremse"));
    System.out.println(simplifyToken("pre-safe ¾ -system"));
    System.out.println(simplifyToken("Mercedes-Benz SLK 200 Kompressor Roadster"));
    System.out.println(simplifyToken("Leder Orientbeige"));
  }
}
