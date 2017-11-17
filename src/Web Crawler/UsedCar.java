import java.io.*;
import java.text.*;
import java.util.*;


class ToLowerCaseComperator implements Comparator {
  public int compare(Object o1, Object o2) {
    return ((String)o1).toLowerCase().compareTo(((String)o2).toLowerCase());
  }

  public boolean equals(Object obj) {
    return false;
  }
}

public class UsedCar implements Comparable {
  public static final String[] propertyIds = { "TRAVEL", "ENVIRONMENTAL", "SAFETY", "LUXURY", "COMFORT", "FAMILY", "SPORTY" };
 
  String gfzNumber;
  int erstzulassung;
  int kilometerstand; // km
  String fahrzeugart;
  String karosserieform;
  int motorleistung;
  int hubraum; // ccm
  String kraftstoffart;
  int kraftstoffverbrauch; // l/1000 km
  int co2Emissionen; // g/km
  String getriebe;
  String farbe;
  String polster;
  int vorbesitzer;
  String modell;
  List<String> ausstattungsmerkmale;
  int kaufpreis;  // euro
  String garantie;
  String kontakt;
  List<String> bilder;
  Set<Integer> tags;
  float[] propertyMatch;  // size = Tags.propertyTags.size();
/*
 Kraftstoffverbrauch 
 (kombiniert)	 	8,5 l/100 km
 CO2-Emissionen 
 (kombiniert)	 	223 g/km
 */
  
  public static final int MIN_ERSTZULASSUNG = 1970;
  public static final String GFZ_NUMBER = "gfz";
  public static final String ERSTZULASSUNG = "erstzulassung";
  public static final String KILOMETERSTAND = "km";
  public static final String FAHRZEUGART = "art";
  public static final String KAROSSERIEFORM = "karosserie";
  public static final String MOTORLEISTUNG = "ps";
  public static final String HUBRAUM = "hubraum";
  public static final String KRAFTSTOFFART = "kraftstoff";
  public static final String KRAFTSTOFFVERBRAUCH = "verbrauch";
  public static final String CO2_EMISSIONEN = "co2";
  public static final String GETRIEBE = "getriebe";
  public static final String FARBE = "farbe";
  public static final String POLSTER = "polster";
  public static final String VORBESITZER = "vorbesitzer";
  public static final String MODELL = "modell";
  public static final String AUSSTATTUNGSMERKMALE = "ausstattung";
  public static final String KAUFPREIS = "preis";
  public static final String GARANTIE = "garantie";
  public static final String KONTAKT = "kontakt";

  private static String sortBy;
  
  public UsedCar(String gfz) {
    gfzNumber = gfz;
    garantie = "";
    ausstattungsmerkmale = new ArrayList<String>(100);
    bilder = new ArrayList<String>(6);
    propertyMatch = new float[propertyIds.length];
    for (int i = 0; i < propertyIds.length; ++i) {
      propertyMatch[i] = 0.0f;
    }
  }

  public boolean equals(Object obj) {
    UsedCar usedCar = (UsedCar)obj;
    if (erstzulassung != usedCar.erstzulassung) {
      System.out.println("different erstzulassung: " + erstzulassung + " != " + usedCar.erstzulassung);
      return false;
    }
    if (kilometerstand != usedCar.kilometerstand) {
      System.out.println("different kilometerstand: " + kilometerstand + " != " + usedCar.kilometerstand);
      return false;
    }
    if (!fahrzeugart.equals(usedCar.fahrzeugart)) {
      System.out.println("different fahrzeugart");
      return false;
    }
    if (!karosserieform.equals(usedCar.karosserieform)) {
      System.out.println("different karosserieform");
      return false;
    }
    if (motorleistung != usedCar.motorleistung) {
      System.out.println("different motorleistung");
      return false;
    }
    if (hubraum != usedCar.hubraum) {
      System.out.println("different hubraum");
      return false;
    }
    if (!kraftstoffart.equals(usedCar.kraftstoffart)) {
      System.out.println("different kraftstoffart");
      return false;
    }
    if (kraftstoffverbrauch != usedCar.kraftstoffverbrauch) {
      System.out.println("different kraftstoffverbrauch");
      return false;
    }
    if (co2Emissionen != usedCar.co2Emissionen) {
      System.out.println("different co2Emissionen");
      return false;
    }
    if (!getriebe.equals(usedCar.getriebe)) {
      System.out.println("different getriebe");
      return false;
    }
    if (!farbe.equals(usedCar.farbe)) {
      System.out.println("different farbe");
      return false;
    }
    if (!polster.equals(usedCar.polster)) {
      System.out.println("different polster");
      return false;
    }
    if (vorbesitzer != usedCar.vorbesitzer) {
      System.out.println("different vorbesitzer");
      return false;
    }
    if (!modell.equals(usedCar.modell)) {
      System.out.println("different modell");
      return false;
    }
    if (!garantie.equals(usedCar.garantie)) {
      System.out.println("different garantie");
      return false;
    }
    if (kaufpreis != usedCar.kaufpreis) {
      System.out.println("different kaufpreis");
      return false;
    }
    if (!kontakt.equals(usedCar.kontakt)) {
      System.out.println("different kontakt");
      return false;
    }
    if (!ausstattungsmerkmale.equals(usedCar.ausstattungsmerkmale)) {
      System.out.println("different ausstattungsmerkmale");
      return false;
    }
    //List<String> bilder;
    return true;
  }

  static void sortBy(String sortBy) {
    UsedCar.sortBy = sortBy;
  }

  void setupTags(Tags tgs) {
    Set<Integer> m = new HashSet<Integer>(40);
    List<String> attributeIds = UsedCar.stringAttributeIdOrder();
    for (String attributeId : attributeIds) {
      List<String> set = stringSetAttribute(attributeId);
      if (set != null) {
        for (String token : set) {
          try {
            Set<Integer> s = tgs.validTags(token);
            if (s != null) m.addAll(s);
          } catch (RuntimeException e) {
            System.err.println("Invalide token '" + token + "' in " + attributeId + " at " + gfzNumber);
            throw e;
          }
        }
      } else {
        String token = stringAttribute(attributeId);
        if (token != null) {
          try {
            Set<Integer> s = tgs.validTags(token);
            if (s != null) m.addAll(s);
          } catch (RuntimeException e) {
            System.err.println("Invalide token '" + token + "' in " + attributeId + " at " + gfzNumber);
            throw e;
          }
        }
      }
    }
    tags = m;
    for (int i = 0; i < propertyIds.length; ++i) {
      try {
        TagCluster cluster = tgs.getTagCluster(propertyIds[i]);
        Set<Integer> match = tgs.convertTagsToIds(cluster.tags);
        match.retainAll(tags);
        propertyMatch[i] = match.size();  // ToDo: consider also other levels insider the cluster
      } catch (RuntimeException e) {
        System.err.println("Invalide tag cluster in " + propertyIds[i] + " at " + gfzNumber);
        throw e;
      }
    }
  }

  int intAttribute(String name) {
    if (name.equals(ERSTZULASSUNG)) {
      return erstzulassung;
    } else if (name.equals(KILOMETERSTAND)) {
      return kilometerstand;
    } else if (name.equals(MOTORLEISTUNG)) {
      return motorleistung;
    } else if (name.equals(HUBRAUM)) {
      return hubraum;
    } else if (name.equals(KRAFTSTOFFVERBRAUCH)) {
      return kraftstoffverbrauch;
    } else if (name.equals(CO2_EMISSIONEN)) {
      return co2Emissionen;
    } else if (name.equals(VORBESITZER)) {
      return vorbesitzer;
    } else if (name.equals(KAUFPREIS)) {
      return kaufpreis;
    }
    return 0;
  }
  
  String stringAttribute(String name) {
    if (name.equals(GFZ_NUMBER)) {
      return gfzNumber;
    } else if (name.equals(FAHRZEUGART)) {
      return fahrzeugart;
    } else if (name.equals(KAROSSERIEFORM)) {
      return karosserieform;
    } else if (name.equals(KRAFTSTOFFART)) {
      return kraftstoffart;
    } else if (name.equals(GETRIEBE)) {
      return getriebe;
    } else if (name.equals(FARBE)) {
      return farbe;
    } else if (name.equals(POLSTER)) {
      return polster;
    } else if (name.equals(MODELL)) {
      return modell;
    } else if (name.equals(GARANTIE)) {
      return garantie;
    } else if (name.equals(KONTAKT)) {
      return kontakt;
    }
    return null;
  }

  List<String> stringSetAttribute(String name) {
    if (name.equals(AUSSTATTUNGSMERKMALE)) {
      return ausstattungsmerkmale;
    }
    return null;
  }

  static List<String> stringAttributeIdOrder() {
    List<String> list = new ArrayList<String>(10);
    list.add(FAHRZEUGART);
    list.add(KRAFTSTOFFART);
    list.add(KAROSSERIEFORM);
    list.add(GETRIEBE);
    list.add(FARBE);
    list.add(POLSTER);
    list.add(MODELL);
    list.add(AUSSTATTUNGSMERKMALE);
    list.add(GARANTIE);
    list.add(KONTAKT);
    return list;
  }

  static List<String> attributeIdOrder() {
    List<String> list = new ArrayList<String>(20);
    list.add(MODELL);
    list.add(KAUFPREIS);
    list.add(KILOMETERSTAND);
    list.add(ERSTZULASSUNG);
    list.add(FAHRZEUGART);
    list.add(KAROSSERIEFORM);
    list.add(MOTORLEISTUNG);
    list.add(HUBRAUM);
    list.add(KRAFTSTOFFART);
    list.add(KRAFTSTOFFVERBRAUCH);
    list.add(CO2_EMISSIONEN);
    list.add(GETRIEBE);
    list.add(FARBE);
    list.add(POLSTER);
    list.add(VORBESITZER);
    list.add(GARANTIE);
    list.add(KONTAKT);
    list.add(AUSSTATTUNGSMERKMALE);
    return list;
  }

  int dateToInt(String date) {
    int i = date.indexOf('/');
    if (i <= 0 || date.length() < 6) return 0;
    int d = Integer.parseInt(date.substring(0, i))-1 + 12*(Integer.parseInt(date.substring(i+1, i+5))-MIN_ERSTZULASSUNG);
    return (d < 0)? 0 : d;
  }

  String intToDate(int date) {
    if (date == 0) return "";
    date += MIN_ERSTZULASSUNG*12;
    int month = date%12;
    String s = (month >= 9)? Integer.toString(month+1) : ("0"+Integer.toString(month+1));
    return s + "/" + Integer.toString((date-month)/12);
  }

  public int compareTo(Object o) {
    UsedCar usedCar = (UsedCar)o;
    String s = stringAttribute(sortBy);
    if (s != null) {
      // array must be sorted as lowercase, e.g. be aware of V < _ < v
      return s.toLowerCase().compareTo(usedCar.stringAttribute(sortBy).toLowerCase());
    }
    int i = intAttribute(sortBy);
    int j = usedCar.intAttribute(sortBy);
    if (i > j) return 1;
    else if (i == j) return 0;
    return -1;
  }

  void add(String attribute, String value) {
    if (attribute.equals("Erstzulassung") || attribute.equals("firstRegistration")) {
      erstzulassung = dateToInt(value);
      if (!value.startsWith(intToDate(erstzulassung)) || erstzulassung > 550) {
        System.out.println("Value:" + value + ", " + erstzulassung + ", " + intToDate(erstzulassung));
        System.out.println("gfz:" + gfzNumber);
        //System.exit(1);
      }
    } else if (attribute.equals("Kilometerstand") || attribute.equals("mileage")) {
      String s = value.replace(".", "").replace(" km", "");
      kilometerstand = Integer.parseInt(s.replace("ca", "").trim());
    } else if (attribute.equals("Fahrzeugart") || attribute.equals("typeOfVehicle")) {
      fahrzeugart = value;
    } else if (attribute.equals("Karosserieform") || attribute.equals("bodyDesign")) {
      karosserieform = value;
    } else if (attribute.equals("Motorleistung")) {
      //<nobr>60 kW</nobr> <nobr>(82 PS)</nobr>
      int i = value.indexOf('(')+1;
      motorleistung = Integer.parseInt(value.substring(i, value.indexOf(' ', i)));
      //i = value.indexOf('>')+1;
      //motorleistungKW = Integer.valueOf(value.substring(i, value.indexOf(' ', i)));
    } else if (attribute.equals("powerHP")) {
      motorleistung = Integer.parseInt(value);
    } else if (attribute.equals("engineSize")) {
      hubraum = Integer.parseInt(value);
    } else if (attribute.equals("Hubraum")) {
      hubraum = Integer.parseInt(value.substring(0, value.indexOf(' ')));
    } else if (attribute.equals("Kraftstoffart") || attribute.equals("fuelType")) {
      kraftstoffart = value;
    } else if (attribute.equals("Kraftstoffverbrauch")) {
      // 5&nbsp;l/100 km
      try {
        int i = value.indexOf('&');
        if (i > 0) kraftstoffverbrauch = (int)(10.0*Double.parseDouble(value.substring(0, i).replace(",", ".")));
      } catch (NumberFormatException nfe) {
        System.out.println("kraftstoffverbrauch: " + value);
      }
    } else if (attribute.equals("fuelConsumption")) {
      kraftstoffverbrauch = Integer.parseInt(value);
    } else if (attribute.equals("CO2-Emissionen")) {
      // 134&nbsp;g/km
      try {
        int i = value.indexOf('&');
        if (i > 0) co2Emissionen = Integer.parseInt(value.substring(0, i));
      } catch (NumberFormatException nfe) {
        System.out.println("co2Emissionen: " + value);
      }
    } else if (attribute.equals("co2")) {
      co2Emissionen = Integer.parseInt(value);
    } else if (attribute.equals("Getriebe") || attribute.equals("gearbox")) {
      getriebe = value;
    } else if (attribute.equals("Farbe") || attribute.equals("color")) {
      farbe = value;
    } else if (attribute.equals("Polster") || attribute.equals("cushion")) {
      polster = value;
    } else if (attribute.equals("Vorbesitzer") || attribute.equals("previousOwner")) {
      vorbesitzer = Integer.parseInt(value);
    } else if (attribute.equals("Modell") || attribute.equals("model")) {
      modell = value;
    } else if (attribute.equals("Ausstattungsmerkmale") || attribute.equals("feature")) {
      ausstattungsmerkmale.add(value);
    } else if (attribute.equals("Kaufpreis")) {
      kaufpreis = (int)(Double.parseDouble(value.replace(".", "").replace(",", ".")));
    } else if (attribute.equals("price")) {
      kaufpreis = Integer.parseInt(value);
    } else if (attribute.equals("Garantie") || attribute.equals("warranty")) {
      garantie = value;
    } else if (attribute.equals("Kontakt") || attribute.equals("contact")) {
      kontakt = value;
    } else if (attribute.equals("Bilder") || attribute.equals("image")) {
      bilder.add(value);
    }
  }

  public String toCString() {
    StringBuffer s = new StringBuffer(2000);
    s.append("[[UsedCar alloc] initWithGFZNumber:@\"");
    s.append(gfzNumber);
    s.append("\" erstzulassung:@\"");
    s.append(erstzulassung);
    s.append("\" kilometerstand:");
    s.append(kilometerstand);
    s.append(" fahrzeugart:@\"");
    if (fahrzeugart != null) s.append(fahrzeugart.replace("\"", "\\\""));
    s.append("\" karosserieform:@\"");
    if (karosserieform != null) s.append(karosserieform.replace("\"", "\\\""));
    s.append("\" motorleistung:");
    s.append(motorleistung);
    s.append(" hubraum:");
    s.append(hubraum);
    s.append(" kraftstoffart:@\"");
    if (kraftstoffart != null) s.append(kraftstoffart.replace("\"", "\\\""));
    s.append("\" kraftstoffverbrauch:");
    s.append(kraftstoffverbrauch);
    s.append(" co2Emissionen:");
    s.append(co2Emissionen);
    s.append(" getriebe:@\"");
    if (getriebe != null) s.append(getriebe.replace("\"", "\\\""));
    s.append("\" farbe:@\"");
    if (farbe != null) s.append(farbe.replace("\"", "\\\""));
    s.append("\" polster:@\"");
    if (polster != null) s.append(polster.replace("\"", "\\\""));
    s.append("\" vorbesitzer:");
    s.append(vorbesitzer);
    s.append(" modell:@\"");
    if (modell != null) s.append(modell.replace("\"", "\\\""));
    s.append("\" ausstattungsmerkmale:[NSArray arrayWithObjects:");
    Iterator<String> i = ausstattungsmerkmale.iterator();
    while (i.hasNext()) {
      s.append("@\"");
      s.append(i.next().replace("\"", "\\\""));
      s.append("\",");
    }
    s.append("nil] kaufpreis:");
    s.append(kaufpreis);
    s.append(" garantie:@\"");
    if (garantie != null) s.append(garantie);
    s.append("\" kontakt:@\"");
    if (kontakt != null) s.append(kontakt.replace("\"", "\\\""));
    s.append("\" bilder:[NSArray arrayWithObjects:");
    i = bilder.iterator();
    while (i.hasNext()) {
      s.append("@\"");
      s.append(i.next());
      s.append("\",");
    }
    s.append("nil]]");
    return s.toString();
  }

  public String toCompactString(Map<String, List<String> > attributeTypes) {
    StringBuilder s = new StringBuilder(2000);
    s.append("[\"");
    s.append(gfzNumber);
    s.append('\"');
    ToLowerCaseComperator cmp = new ToLowerCaseComperator();
    Iterator<String> i = attributeIdOrder().iterator();
    while (i.hasNext()) {
      String attributeId = i.next();
      String value = stringAttribute(attributeId);
      if (value != null) {
        int idx = Collections.binarySearch(attributeTypes.get(attributeId), value, cmp);
        if (idx < 0) System.err.println("ERROR! " + attributeId + ": " + value);
        s.append(',');
        s.append(idx);
      } else {
        List<String> attributeValues = attributeTypes.get(attributeId);
        List<String> set = stringSetAttribute(attributeId);
        if (set != null) {
          s.append(",[");
          List<Integer> list = new ArrayList<Integer>(200);
          Iterator<String> j = set.iterator();
          if (j.hasNext()) {
            String t = j.next();
            int idx = Collections.binarySearch(attributeValues, t, cmp);
            if (idx < 0) {
              System.err.println("Fehlende Ausstattung: " + attributeId + ", " + t);
              System.exit(1);
            }
            list.add(new Integer(idx));
            while (j.hasNext()) {
              t = j.next();
              idx = Collections.binarySearch(attributeValues, t, cmp);
              if (idx < 0) {
                System.err.println("Fehlende Ausstattung: " + attributeId + ", " + t);
                System.exit(1);
              }
              list.add(new Integer(idx));
            }
          }
          Collections.sort(list);
          Iterator<Integer> k = list.iterator();
          if (k.hasNext()) {
            Integer prevInt = k.next();
            s.append(prevInt);
            while (k.hasNext()) {
              Integer intValue = k.next();
              if (!intValue.equals(prevInt)) {
                s.append(',');
                s.append(intValue);
                prevInt = intValue;
              }
            }
          }
          s.append(']');
        } else {
          int v = intAttribute(attributeId);
          s.append(',');
          s.append(v);
        }
      }
    }
    if (tags != null) {
      s.append(",[");
      List<Integer> list = new ArrayList<Integer>(tags.size());
      list.addAll(tags);
      Collections.sort(list);
      Iterator<Integer> j = list.iterator();
      if (j.hasNext()) {
        s.append(j.next());
        while (j.hasNext()) {
          s.append(',');
          s.append(j.next());
        }
      }
      s.append(']');
    }
    s.append('[');
    s.append(propertyMatch[0]);
    for (int j = 1; j < propertyIds.length; ++j) {
      s.append(',');
      s.append(propertyMatch[j]);
    }
    s.append(']');
    
    /* ToDo: optimize
["0-21615090",53,25700,4000,489,4,4,109,1991,1,0,0,0,93,216,1,4,365,
     [159,39,112,125,149,155,163,275,280,303,338,353,361,376,443,453,461,606,535,564,687,733,762,781,814,821,827,834,847,877,918,902,1014,52],
     ["169007/i0AfGilIQR6-YdhRw6aWENu16_NjlPmZqJNYARxx1Ib_XOqasy7unulxziC6xkD76J62qJJrcuialQvg-BL9UIacDiqBBk9ZESEIHU3ba9DU.P00.jpg",
      "169007/iHzrBO0oMfqeS_L5O3zLrAsDWwuAK0RtcSutNqFm3y3mt8BhSNZDdWevCIVOmGBe0l4tlrFO_zkeqiOV2Zrzai5aU1iGYZRf2VabOPb6Oq5g.P01.jpg",
      "169007/iI7bwWXnLo3hoYN24dPvvgF8uzHppfOPv8N2mcZUFn_oFbUAtvbXxZahKjhl1hA27zYybxaTMKxxuLDtGDBfvAQZCwNPhukK_PohhJ8UKvWo.P02.jpg",
      "169007/iPx_WQswWSU58Xm3V4JB7Vx_qPsPU-z_NW3VkBNnRb10J3h82Gm3-TpnQJLsotzvdntDyVmDY-m1uJDaCClXtUZleAOc37mF7cAU_LFqjVsQ.P03.jpg",
      "169007/iuCuULX3hCg0lnOKar3y9MzW46bgF51B593VZxoAID0Z0AxZRvicksputTfTRJlivxg88ZS1NReTYzFwtk-kqxO9hk0pMePoCcfZ8OyWJK2M.P04.jpg",
      "169007/iwq5SKaPHgcbvKDy2uI2HgD8GGgFhUqvp9WqO9hY6ls-KYXXP2sVvD3uotro716cwm41EAPo4UHI11Jho24AWBbwunRjYJoUM14Mw4eizzYA.P05.jpg",
      "169007/iVjs-BAohdd51ZqiepV-kbmEbSp3MK7M6sTkhx4QdvJ457ND3UFcGEl-lfangp-wrSvDiTzMRF2ODWra6DlZXa-mDSz2MpQ9jWY-F9ZxSdYA.P06.jpg"]]
     ["0-21615092",53,25700,1000,489,4,4,109,1991,1,56,147,0,93,216,1,4,364,[267,39,112,125,149,163,275,280,303,338,353,361,376,400,443,453,461,535,564,687,733,762,781,814,821,827,834,847,877,918,902,52],["http://e-services.mercedes-benz.com/pkw/200x150/169007/iu8ASVQ_EQkQSvmRN-T4gWw_VhSjWHtDNySaM3I_rjNman-SvEb8g_BvGdn801hFDbQQNJb-Uql3NwI7Il1P1FydYjOf5VSiobiyLwqis7EA.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ijBMGIBQjNa5SfgOlVxM7elZsHpQBnpZKK4s4UB9_rrgyYPUaSTGkcKilkGytXduK1WfTdjU6sjD-WOxM0Ir1uWZw_A_5sj2i1fVje8eVHno.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ipAt2dMgNH7iKNCCZoqLE1UHdu_QdJJ1SeJhJTTFUv-F-1lOj0q8rjNocGT7z-Kzk2NmejRG9bRu3_uUONz5oFq4w19-EpmTlTLBQ8qf6JPk.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/i0z27azzHgB3fu3LGbEOYGQ8cq8Fzb5P2ZbhBGPruZLb8bWlcbe4MRBJA1_RkH2UfieQ3pElpyKtLdjvUd9j1epeiq6QaoPgDmGJ5f2e8IvI.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iJfUjZXZgh1BSGxcvhF87nNAoKDCe3MibavLr78hxPw3umGXTCHFm6JLcVFaMLO1wSwAopGX7uI5dZFNi4j_6WMNTnUtdgKFifxoISVRnUDg.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iSTiW0Id_DOp_INhr_Oc8errnQHHLNhkh7T-JCqcYlLKAHDxFurPLxYEv56FuPMKTuxYptFetPgEMTdOc1cInVe3l82DFjB5f0mglJmGG-2Q.P05.jpg"]]["0-21615093",53,25700,3000,489,4,4,109,1991,1,0,0,0,122,216,1,4,365,[159,39,112,125,149,155,163,275,280,303,338,353,361,376,443,453,461,606,535,564,687,733,762,781,814,821,827,834,847,877,918,902,1014,52],["http://e-services.mercedes-benz.com/pkw/200x150/169007/i_-zagafmSIwBCRu-S5nnnJnQhh6dmavyWd2Otx-bxfQeaaO0bccS3Qut9LX3V73drsPZc1eqRTwscGsbc72ftIUtBW8K_hAcHL-ZPjVjMR4.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/irDbBLuQIit5bpAquODrCVYXwbVhJJtena3b94Kd8G-rL2gD80kEu473NYLJhlAECqt_Kn1azo-MQRgW4Y-nQ6RcbqYJtSr8fXzJ0fUoHFsM.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ifU6zIYOdbrjwNK2Vy7Hbm6OpgzLrRVaxnYslJ72110wIZxLq0GhgfRQIRLU-WrsW-6IlA9-bpUPUIq_fFOlCs_w4Mh5_XN2tSVPHsJQLlvk.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iP3sL6VHLLLDjkH7qJqbQBA7dH0zBgbEr84jQwlm61fcHoO3KqnZqhGpZvvXdsPY9CLY7I4xQVXfsTNvE7UI0leGbKF2OyHkwH9c78oiysFY.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/im-qj6o3fLYCm65wvd72SExEapvH0mviqX183DgoqqCzq_xAuc-waV3OLmYNHoha0liZwZ3SqfOPShgGuW7h1WQ7B2meS5IEPtv6scHU30lA.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iIJ3celY6sUQitNo9_oLWlblwSAPOqOIxr9nqfSIkW4d16DWVv1X1yE8povLqm7v946asflPEh40rcIvE-dTITbF4QOqwAd9JRyHAJHnWxTc.P05.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ib194xnKasZSpTmiWAEMEor-XAhp-NZAiz_3neMD0zF8sgPZ5Hon65IRqNW3af3jX3wks8L9xfs1mdBO9jH1pkjYcIauWCqgbELgRJPSeZyE.P06.jpg"]]["0-21615094",53,25400,6000,489,4,4,109,1991,1,0,0,2,93,216,1,4,363,[159,39,112,125,149,155,163,275,280,303,338,353,361,376,453,461,606,535,564,687,733,762,814,821,827,834,877,918,902,1014,52],["http://e-services.mercedes-benz.com/substitutes/pkw/169/0/800/AV/07/1191f.jpg","http://e-services.mercedes-benz.com/substitutes/pkw/169/0/800/AV/07/1191s.jpg"]]["0-21615098",53,25700,3000,489,4,4,109,1991,1,0,0,0,93,216,1,4,363,[159,39,112,125,149,155,163,275,280,303,338,353,361,376,443,453,461,606,535,564,687,733,762,781,814,821,827,834,847,877,918,902,1014,52],["http://e-services.mercedes-benz.com/pkw/200x150/169007/iCrx04WROPj-Si1_7ZQWzgbnU_OOZ6ZuYgNioNQC5x1zV_hbFYwjgvgw3uOp7CTnjvhtMmirrD5NNsUpyh8qHmgHxKiUowcHUIN9Gd6CHBOo.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iC5Z0N_zBTvyObTE28155niNbqKe4UkoMU65qj966F7RRxMBHKDaVN3aOHQSfnSeObPIVvmIgFXzhVlUvlKVmMtVzhrJyO93Q2Pigx0TMoO8.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ivEv-MPkyzYaI_WrwHu47M5JWqStLb0VX4YzyXkCewSpqKmwMF6oSAMxvLlQT6yniZH8G_IdX-VzYkX5HZ4MXEymBJulUDDJnIMNT7XIPGQA.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iMMRDfkeadejV2tsO-3bmlhLIKClOMiSaldS5IGyQ0o80XrX6WA_glGZtbfsZkYuFuzCQQL8aTvsjHE_xDAddjDNQ0WFJUE1Jn91qm0Nykgw.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iqPtbROmr2X8I5ji1cH_JC-jwCWXB5M-erWaVFLY2IQytlzXzg2x5OhXTAD6Q9CbLItFd_9eUoFKJqpxFA6tiSx_GzVtpHt4xl0v-CCNjAJ8.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iaPo2M8yIzz0Ej5hsYygf7jigAGRd4Uubf42-n3fCc5XqPsjsmOFQGqSuDwnYK72InrhHRO6PKO0_9dbgqMxjxnFy02zcQTwTT1QFCxrMrQw.P05.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iVuyqWsKR3mnIefaDtvnJZTsTH6Tu22fQptfcd_mUJZTEWwTnhuDwDqG7cRLs3eF6rIkMMGjMpkDxlNjDRwM9EdDJHF-OqELpr7OVPi45Wf8.P06.jpg"]]["0-21615099",53,25700,3000,489,4,4,109,1991,1,0,0,0,93,216,1,4,362,[267,39,112,125,149,163,275,280,303,338,353,361,376,400,443,453,461,535,564,687,733,762,781,814,821,827,834,847,877,918,902,52],["http://e-services.mercedes-benz.com/substitutes/pkw/169/0/800/EL/07/1191f.jpg","http://e-services.mercedes-benz.com/substitutes/pkw/169/0/800/EL/07/1191s.jpg","http://e-services.mercedes-benz.com/substitutes/pkw/169/0/800/EL/07/1191r.jpg"]]["0-21615102",53,21400,1000,489,4,4,109,1991,1,50,131,2,93,273,1,4,361,[807,39,125,149,155,163,275,280,338,353,363,376,443,453,461,687,736,762,781,814,821,827,834,847,877,902],["http://e-services.mercedes-benz.com/pkw/200x150/169007/iYeqdu1mv5u4RmlBqP5Yi0eoQ1yLTkdPODhKdDPFHC6k8wYy9Gtda7GHxMQVhcgeMixrk3Di402VvG_O_JU_5ALF1P8FcvORf9XzTf3e9gLg.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iBafT97MlGKOo0SViTpRHYQHRbwOq1VFCNz1MBvB6xYJynKvGn1jZEpcsJQbE-RN4Di9W0LkF1Dzz6pZwGlGcLDKVlCjB8rCwi7A6ZL-HG-4.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ixs2UdoV3rRj-0O6H6ZEr18urmQD-w6CYa60k4cYoePbwQaibroYlXew6H25p5zJ23jyUkrsY50tYybCwrRyJ4Hni6g7MiL-DjLJqalbYMN4.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ixYB9AT2aBset537XalLfaDWMkuAZ1NyGS47STGIshLAQg6lO_Vkr_Bmd5AHMJdL3rvSddqoCAKkA1UAsakx7ENbFcVVu5xnc00p9RFebA3o.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iJCixX7heFZIqk2fbQOsXeGRHJEl7hLDtXA8MkEP8hQlMetmss9PXaP9wySg1kB3TV8wbR8gJTLcZy6I3udUPxhjhr-wm3O--u98XZ2R2wRI.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iikrDzFR1Oh1cx7J7FYB930ouW9vz3TDhsnoGcCilnEIp1_yiMhCT5aIR8E7UXt_T_wGH5PTxgt38PAQfKOMIQb06PIWfj88UZ6wTgNYNF2g.P05.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/i3Hgk9h90NPkwPkhiy0ujwb12VqnArl2g2Q3nwT2ZaPkEUw1tyIcJ3BOJCB5KwL1X1fUrVxmKBMcnuUss5Bhd81mColResyq13khb3Aa-GTw.P06.jpg"]]["0-21615104",53,21400,1000,489,4,4,109,1991,1,50,131,2,93,273,1,4,364,[807,39,125,149,155,163,275,280,338,353,363,376,443,453,461,687,736,762,781,814,821,827,834,847,877,902],["http://e-services.mercedes-benz.com/pkw/200x150/169007/ih8jBI3C64haoe9pNFiGbqd9L2k1SrATRawv5HRTZNzGldE67Af8xnJuFlA_7oxzfoYcAKp-L6QDudrZxqSAFPwhGupDLdd47PYBtFOqa9Nk.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iMfVhNa2Z01iI_9u_M8rA38PGP7L4GlNiPoSj_g2ID7UBXu30vOCKRXiDMclU2xt9H_SyBlBbGaUmIEy7jvuUYkB-bNnrrIlW6EoP9T-Q2sg.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/i65Gt3zeaGgz9vX6ZdDpgtzmSPe5IH1c4NVpVAixnBbqzwnkXlRR6UkQgq-3iXfLnEHEFZS9gTQa-VqObLtRmV85JSp1eLsFuZe6OmbigAek.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ihCKp7yjO4YF_nw64iNGNuqlAP_5xtVlNaB75kHFD1m7WuoJguAXRv1W5qynJY-fUgG5_BMhyblepWH_rD6DdiYVDY9QEP8espUiUWfyiMVc.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iy3e0RSe0nLSKyaKd6aWMN0pROhTkYtMuF6zlfXaQ7QYY5aqEBHjdeaMkPVKFbJYikmCaEpRM9a9zV2hGJbXFxoDi2rBc1T8FR8CoZ1wEWBg.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iJREglgZ6pomBuwh0KTubrJN1TBmIp1e7PYOnHP8TVcgCDmyUBfDRwB08DM7qNBZ36LMbFap-P11w_qJyW5D61vnMZ5vZShRH1Au8jTQwuiE.P05.jpg"]]["0-21615105",53,21400,2000,489,4,4,109,1991,1,50,131,2,93,273,1,4,362,[807,39,125,149,155,163,275,280,338,353,363,376,443,453,461,687,736,762,781,814,821,827,834,847,877,902],["http://e-services.mercedes-benz.com/pkw/200x150/169007/iqwev6UhYXs-JNZOpQqYIWyEzsG1moKxKkR6GHI7GUWnt_rWkR4_1R6CgfktygbQ415VsxpVBMaOngWGSh8TIS7TezygoyavRcww06b6v7iA.P00.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iB0xa1-p-Qvs2FRCyEC-_JS8F-aY1E_4q5yKf1sru9vPLHNZHNJaoSL-awnzIH974oYAxrkJckLEILoYcfLjMCC3WG6oqHv3CVUfXwvFAeY0.P01.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iDNk1zT0eNKXzrDEGutzejcapKRkR5yvRqyiRiFZvVlwrdMEg1oUreJ3n2NU9lTqmvdoJRaN1ff5Khs-Swjyjd_UtFeHC2i8ObXcGVrTNY5c.P02.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iBWhOx5pcPCnysb3qTxXa69LY3KVDynB6bu-nf2VQsAmGrS_QwBXIbyoDD8N0dK1GZGGwiO2r0c1Xjdl_5A8tWYVURX7sWf_1L54vcslKedg.P03.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/ioZie-7dAxa06gESOfi4DFWGbeecauWSImqqhBG-yQREgDeuKuKyilmixKLjNAQwOGrKeklXyG5irA7di3FamR_0125soCzIZm69KrpdBaeU.P04.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/in3t48R8SPaRd_pjyb92OZIcAOktMU-ITQGUq6PxqaL7020Z5lpAKCf-QfcZli7ERq7I1Qs_c9BdwR8n1gQSffoGar5PwzU8I8t8FHRIeBpY.P05.jpg","http://e-services.mercedes-benz.com/pkw/200x150/169007/iYBRUsdH-6uWU-rbO4zRszPM-2s5ctp8nMzN4CwgWM3CW-amPgEy80m6xj_eBje8h9BfsSuS9SKzEgPi8S0lltkpN-kz3TL7JCcL9kUWupf0.P06.jpg"]]
     */
    s.append("[");
    /*String bilderPrefix = "http://e-services.mercedes-benz.com/pkw/200x150/";
    String bilderPrefix2 = "http://e-services.mercedes-benz.com/substitutes/pkw";
    i = bilder.iterator();
    if (i.hasNext()) {
      s.append("\"");
      String image = i.next().replace("\"", "\\\"");
      if (image.startsWith(bilderPrefix)) image = image.substring(bilderPrefix.length());
      else if (image.startsWith(bilderPrefix2)) image = image.substring(bilderPrefix2.length());
      s.append(image);
      s.append("\"");
      while (i.hasNext()) {
        s.append(",\"");
        image = i.next().replace("\"", "\\\"");
        if (image.startsWith(bilderPrefix)) image = image.substring(bilderPrefix.length());
        else if (image.startsWith(bilderPrefix2)) image = image.substring(bilderPrefix2.length());
        s.append(image);
        s.append("\"");
      }
    }*/
    s.append("]]");
    return s.toString();
  }

  public String getImages() {
    String bilderPrefix = "http://e-services.mercedes-benz.com/pkw/200x150/";
    String bilderPrefix2 = "http://e-services.mercedes-benz.com/substitutes/pkw";
    StringBuilder s = new StringBuilder(1000);
    Iterator<String> i = bilder.iterator();
    if (i.hasNext()) {
      String image = i.next();
      if (image.startsWith(bilderPrefix)) image = image.substring(bilderPrefix.length());
      else if (image.startsWith(bilderPrefix2)) image = image.substring(bilderPrefix2.length());
      s.append(image);
      while (i.hasNext()) {
        s.append('\n');
        image = i.next();
        if (image.startsWith(bilderPrefix)) image = image.substring(bilderPrefix.length());
        else if (image.startsWith(bilderPrefix2)) image = image.substring(bilderPrefix2.length());
        s.append(image);
      }
    }
    return s.toString();
  }

  public String toString() {
    StringBuffer s = new StringBuffer(2000);
    s.append("<gfz number=\"");
    s.append(gfzNumber);
    s.append("\">\n  <firstRegistration>");
    s.append(intToDate(erstzulassung));
    s.append("</firstRegistration>\n  <mileage>");
    s.append(kilometerstand);
    s.append("</mileage>\n  <typeOfVehicle>");
    if (fahrzeugart != null) s.append(fahrzeugart.replace("\"", "\\\""));
    s.append("</typeOfVehicle>\n  <bodyDesign>");
    if (karosserieform != null) s.append(karosserieform.replace("\"", "\\\""));
    s.append("</bodyDesign>\n  <powerHP>");
    s.append(motorleistung);
    s.append("</powerHP>\n  <engineSize>");
    s.append(hubraum);
    s.append("</engineSize>\n  <fuelType>");
    if (kraftstoffart != null) s.append(kraftstoffart.replace("\"", "\\\""));
    s.append("</fuelType>\n  <fuelConsumption>");
    s.append(kraftstoffverbrauch);
    s.append("</fuelConsumption>\n  <co2>");
    s.append(co2Emissionen);
    s.append("</co2>\n  <gearbox>");
    if (getriebe != null) s.append(getriebe.replace("\"", "\\\""));
    s.append("</gearbox>\n  <color>");
    if (farbe != null) s.append(farbe.replace("\"", "\\\""));
    s.append("</color>\n  <cushion>");
    if (polster != null) s.append(polster.replace("\"", "\\\""));
    s.append("</cushion>\n  <previousOwner>");
    s.append(vorbesitzer);
    s.append("</previousOwner>\n  <model>");
    if (modell != null) s.append(modell.replace("\"", "\\\""));
    s.append("</model>\n  <features>");
    Iterator<String> i = ausstattungsmerkmale.iterator();
    while (i.hasNext()) {
      s.append("<feature>");
      s.append(i.next().replace("\"", "\\\""));
      s.append("</feature>");
    }
    s.append("</features>\n  <price>");
    s.append(kaufpreis);
    s.append("</price>\n  <warranty>");
    if (garantie != null) s.append(garantie);
    s.append("</warranty>\n  <contact>");
    if (kontakt != null) s.append(kontakt.replace("\"", "\\\""));
    s.append("</contact>\n  <images>");
    i = bilder.iterator();
    while (i.hasNext()) {
      s.append("<image>");
      s.append(i.next());
      s.append("</image>");
    }
    s.append("</images>\n</gfz>\n");
    return s.toString();
  }
}
