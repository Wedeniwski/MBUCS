import java.io.*;
import java.math.BigInteger;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.*;
import java.util.*;

public class CreateDataPool {
  public static final String TOKEN_SEPARATOR = " \t\n\r\">#";

  static Map<String, List<String> > attributeTypes = new HashMap(50);
  static Tags tags = null;
  
  static String valueOf(String value, int pos) {
    int l = value.length();
    while (pos < l && TOKEN_SEPARATOR.indexOf(value.charAt(pos)) >= 0) ++pos;
    int i = value.indexOf("</td>", pos);
    if (i == -1) {
      int j = l-1;
      while (j > pos && TOKEN_SEPARATOR.indexOf(value.charAt(j)) >= 0) --j;
      if (j < l-1) i = j+1;
    }
    String s = (i == -1)? value.substring(pos) : value.substring(pos, i);
    return s;
  }

  private static String removeTags(String value) {
    int i = value.indexOf('<');
    return (i >= 0)? value.substring(0, i) : value;
  }

  /*
   Kraftstoffverbrauch 
   (kombiniert)	 	8,5 l/100 km
   CO2-Emissionen 
   (kombiniert)	 	223 g/km
   */  
  static UsedCar readUsedCarData(String gfzNumber, Reader reader) throws IOException {
    try {
      String[] attributes = {">Erstzulassung<", ">Kilometerstand<", ">Fahrzeugart<", ">Karosserieform<", "Motorleistung", ">Hubraum<", ">Kraftstoffart<", "Kraftstoffverbrauch", "CO2-Emissionen", ">Getriebe<", ">Farbe<", ">Polster<", ">Vorbesitzer<"};
      boolean model = true;
      BufferedReader bufferedReader = new BufferedReader(reader);
      UsedCar usedCar = new UsedCar(gfzNumber);
      while (true) {
        String line = bufferedReader.readLine();
        if (line == null) break;
        if (model && line.indexOf("<b>") >= 0) {
          usedCar.add("Modell", removeTags(valueOf(line, line.indexOf("<b>")+3)));
          model = false;
        }
        for (int i = 0; i < attributes.length; ++i) {
          if (line.indexOf(attributes[i]) >= 0) {
            do {
              line = bufferedReader.readLine();
            } while (line.indexOf("<td ") == -1);
            StringBuffer buffer = new StringBuffer(100);
            while (line.indexOf("</td>") == -1) {
              buffer.append(line);
              line = bufferedReader.readLine();
            }
            buffer.append(line);
            line = buffer.toString();
            String attribute = (attributes[i].charAt(0) == '>')? attributes[i].substring(1, attributes[i].length()-1) : attributes[i];
            usedCar.add(attribute, valueOf(line, line.indexOf('>')+1));
          }
        }
        if (line.indexOf(">Ausstattungslinie<") >= 0) {
          while (true) {
            line = bufferedReader.readLine();
            if (line.indexOf("<td class=\"angaben\">") >= 0) {
              line = bufferedReader.readLine();
              usedCar.add("Ausstattungsmerkmale", line.trim());
            }
            if (line.indexOf("Ausstattungsmerkmale") >= 0) break;
            if (line.indexOf("Weitere Sonderausstattungen") >= 0) break;
            if (line.indexOf("</table>") >= 0) break;
          }
        }
        if (line.indexOf("Ausstattungsmerkmale") >= 0) {
          while (true) {
            line = bufferedReader.readLine();
            if (line.indexOf("<td class=\"angaben\">") >= 0) {
              usedCar.add("Ausstattungsmerkmale", valueOf(line, line.indexOf('>')+1));
            }
            if (line.indexOf("Weitere Sonderausstattungen") >= 0) break;
          }
        }
        if (line.indexOf("Kaufpreis") >= 0) {
          do {
            line = bufferedReader.readLine();
          } while (line.indexOf("<b>") == -1);
          usedCar.add("Kaufpreis", removeTags(valueOf(line, line.indexOf('>')+1)));
        }
        if (line.indexOf(">Leistungen f") >= 0) {
          // Mercedes-Benz Europa-Garantie
          // Junge Sterne Garantie
          while (true) {
            line = bufferedReader.readLine();
            if (line.indexOf("class=\"angaben\"") >= 0) {
              line = bufferedReader.readLine();
              usedCar.add("Garantie", line.trim());
              break;
            }
          }
        }
        if (line.indexOf("boxHeadline") >= 0) {
          do {
            line = bufferedReader.readLine();
          } while (line != null && line.indexOf("<b>") == -1);
          if (line != null) {
            StringBuffer buffer = new StringBuffer(100);
            while (line.indexOf("<img ") == -1) {
              buffer.append(line.trim());
              line = bufferedReader.readLine();
            }
            line = buffer.toString();
            usedCar.add("Kontakt", line);
          }
        }
      }
      return usedCar;
    } catch (NullPointerException e) {
      System.err.println("WRONG Format for GFZ " + gfzNumber);
    }
    return null;
  }
  
  static UsedCar readUsedCarXMLData(String gfzNumber, Reader reader) throws IOException {
    String[] attributes = {"firstRegistration>", "mileage>", "typeOfVehicle>", "bodyDesign>", "powerHP>", "powerKW>", "engineSize>", "fuelType>", "fuelConsumption>", "co2>", "gearbox>", "color>", "cushion>", "previousOwner>", "model>", "price>", "warranty>", "contact>", "features>", "images>"};
    String[] subAttributes = {"feature>", "image>"};
    BufferedReader bufferedReader = new BufferedReader(reader);
    String line = bufferedReader.readLine();
    if (line.startsWith("<gfz number=")) {
      int i = line.indexOf('\"');
      int j = line.indexOf('\"', i+1);
      if (j > i) gfzNumber = line.substring(i+1, j);
    }
    UsedCar usedCar = new UsedCar(gfzNumber);
    while (true) {
      line = bufferedReader.readLine();
      if (line == null) break;
      for (int i = 0; i < attributes.length; ++i) {
        int j = line.indexOf(attributes[i]);
        if (j >= 0) {
          j += attributes[i].length();
          int k = line.indexOf(attributes[i], j);
          if (k > j) {
            boolean containsSubAttributes = false;
            for (int i2 = 0; i2 < subAttributes.length; ++i2) {
              int j2 = 0;
              while (true) {
                j2 = line.indexOf(subAttributes[i2], j2);
                if (j2 < 0) break;
                j2 += subAttributes[i2].length();
                int k2 = line.indexOf(subAttributes[i2], j2);
                if (k2 > j2) {
                  usedCar.add(subAttributes[i2].substring(0, subAttributes[i2].length()-1), line.substring(j2, k2-2));
                  containsSubAttributes = true;
                }
                j2 = k2+subAttributes[i2].length();
              }
            }
            if (!containsSubAttributes) usedCar.add(attributes[i].substring(0, attributes[i].length()-1), line.substring(j, k-2));
          }
        }
      }
    }
    return usedCar;
  }
  
  static byte[] toString(String variable, List<String> list) {
    int l = list.size();
    StringBuilder buffer = new StringBuilder(l*20);
    buffer.append(variable);
    for (String t : list) {
      buffer.append('\"');
      buffer.append(t);
      buffer.append('\"');
    }
    return buffer.toString().getBytes();
  }

  static byte[] toString(String variable, int[] array) {
    return toString(variable, array, 0, array.length);
  }

  static byte[] toString(String variable, int[] array, int i, int l) {
    StringBuilder buffer = new StringBuilder(l*20+10);
    buffer.append(variable);
    if (l > 0 && i >= 0 && i < l) {
      buffer.append(array[i]);
      while (++i < l) {
        buffer.append(',');
        buffer.append(array[i]);
      }
    }
    return buffer.toString().getBytes();
  }

  static void write(OutputStream output, String attributeName, List<UsedCar> listCarData, List<String> listLowerGfz) throws IOException {
    System.out.print("write:" + attributeName);
    int l = listCarData.size();
    if (l == 0) return;
    String s = listCarData.get(0).stringAttribute(attributeName);
    if (s != null) {
      UsedCar.sortBy(attributeName);
      List<String> list = new ArrayList<String>(l);
      Collections.sort(listCarData);
      String type = listCarData.get(0).stringAttribute(attributeName);
      list.add(type);
      for (int i = 1; i < l; ++i) {
        String t = listCarData.get(i).stringAttribute(attributeName);
        if (!t.equalsIgnoreCase(type)) {
          list.add(t);
          type = t;
        }
      }
      attributeTypes.put(attributeName, list);
      StringBuilder buffer = new StringBuilder(10*list.size()+10);
      buffer.append("\ns:");
      buffer.append(attributeName);
      output.write(buffer.toString().getBytes());
      output.write(toString("\n", list));
      System.out.println(", size:" + list.size());
      buffer.delete(0, buffer.length());
      buffer.append("\n");
      int j = 0;
      for (int i = 0; i < list.size(); ++i) {
        String art = list.get(i);
        int k = j;
        while (j < l && listCarData.get(j).stringAttribute(attributeName).equalsIgnoreCase(art)) ++j;
        if (i > 0) buffer.append(',');
        buffer.append(j-k);
      }
      output.write(buffer.toString().getBytes());
    } else {
      StringBuilder buffer = new StringBuilder(10*l+10);
      buffer.append("\nIntAttribute:");
      buffer.append(attributeName);
      int[] index = new int[l];
      int[] array = new int[l];
      UsedCar.sortBy(attributeName);
      Collections.sort(listCarData);
      for (int i = 0; i < l; ++i) {
        array[i] = listCarData.get(i).intAttribute(attributeName);
        index[i] = Collections.binarySearch(listLowerGfz, listCarData.get(i).gfzNumber.toLowerCase());
        if (index[i] < 0) {
          System.err.println("Not found GFZ: " + listCarData.get(i).gfzNumber);
          System.err.println("i=" + i);
          System.err.println(listCarData.get(i).toString());
          System.exit(1);
        }
      }
      output.write(buffer.toString().getBytes());
      output.write(toString("\nvalues:", array));
      output.write(toString("\nindex:", index));
    }
  }

  static void write(OutputStream output, Tags tags, String attributeName) throws IOException {
    try {
      List<String> list = attributeTypes.get(attributeName);
      StringBuilder buffer = new StringBuilder(10*list.size()+10);
      for (String token : list) {
        Set<Integer> set = tags.validTags(token);
        if (set == null) {
          if (token.length() == 0) {
            buffer.append("[]");
          } else {
            System.out.println("Missing valid tags for " + token);
          }
        } else {
          buffer.append('[');
          boolean first = true;
          for (Integer i : set) {
            if (!first) buffer.append(',');
            buffer.append(i);
            first = false;
          }
          buffer.append(']');
        }
      }
      output.write(buffer.toString().getBytes());
    } catch (RuntimeException e) {
      System.out.println("Error to write tags of attribute " + attributeName);
      throw e;
    }
  }

  static void writeData(List<UsedCar> listCarData, long version, String filename) {
    int l = listCarData.size();
    List<String> listGfz = new ArrayList<String>(l);
    List<String> listLowerGfz = new ArrayList<String>(l);
    OutputStream writer = null;
    try {
      writer = new FileOutputStream("../" + filename);
      UsedCar.sortBy(UsedCar.GFZ_NUMBER);
      Collections.sort(listCarData);
      for (int i = 0; i < l; ++i) {
        String s = listCarData.get(i).gfzNumber;
        listGfz.add(s);
        listLowerGfz.add(s.toLowerCase());
      }
      writer.write((Long.toString(version) + ',' + l).getBytes());
      write(writer, UsedCar.FAHRZEUGART, listCarData, listLowerGfz);
      write(writer, UsedCar.KAROSSERIEFORM, listCarData, listLowerGfz);
      write(writer, UsedCar.KRAFTSTOFFART, listCarData, listLowerGfz);
      write(writer, UsedCar.GETRIEBE, listCarData, listLowerGfz);
      write(writer, UsedCar.FARBE, listCarData, listLowerGfz);
      write(writer, UsedCar.POLSTER, listCarData, listLowerGfz);
      write(writer, UsedCar.MODELL, listCarData, listLowerGfz);
      write(writer, UsedCar.GARANTIE, listCarData, listLowerGfz);
      write(writer, UsedCar.KONTAKT, listCarData, listLowerGfz);

      // Ausstattungsmerkmale
      List<String> listAusstattungsmerkmale = new ArrayList<String>(l);
      Set<String> set = new HashSet<String>(l);
      for (int i = 0; i < l; ++i) {
        Iterator<String> iter = listCarData.get(i).ausstattungsmerkmale.iterator();
        while (iter.hasNext()) {
          set.add(iter.next());
        }
      }
      Iterator<String> iter = set.iterator();
      while (iter.hasNext()) {
        listAusstattungsmerkmale.add(iter.next());
      }
      Collections.sort(listAusstattungsmerkmale, new ToLowerCaseComperator());
      System.out.print("write:" + UsedCar.AUSSTATTUNGSMERKMALE);
      StringBuilder buffer = new StringBuilder(100*l+1000);
      buffer.append("\ns:");
      buffer.append(UsedCar.AUSSTATTUNGSMERKMALE);
      writer.write(buffer.toString().getBytes());
      buffer.delete(0, buffer.length());
      writer.write(toString("\n", listAusstattungsmerkmale));
      System.out.println(", size:" + listAusstattungsmerkmale.size());
      attributeTypes.put(UsedCar.AUSSTATTUNGSMERKMALE, listAusstattungsmerkmale);
      buffer.append("\n");
      for (int i = 0; i < listAusstattungsmerkmale.size(); ++i) {
        String ausstattung = listAusstattungsmerkmale.get(i);
        int k = 0;
        for (int j = 0; j < l; ++j) {
          if (listCarData.get(j).ausstattungsmerkmale.indexOf(ausstattung) >= 0) ++k;
        }
        if (i > 0) buffer.append(',');
        buffer.append(k);
      }
      writer.write(buffer.toString().getBytes());
      buffer.delete(0, buffer.length());
      tags = new Tags(attributeTypes);
      List<String> attributeIds = UsedCar.stringAttributeIdOrder();
      for (String attributeId : attributeIds) {
        System.out.println("write tags: " + attributeId);
        buffer.append("\nt:" + attributeId);
        Set<String> set2 = tags.attributeTags.get(attributeId);
        for (String t : set2) {
          buffer.append('\n');
          buffer.append(t);
        }
      }
      buffer.append('\n');
      writer.write(buffer.toString().getBytes());
      buffer.delete(0, buffer.length());
      write(writer, tags, UsedCar.FAHRZEUGART);
      write(writer, tags, UsedCar.KAROSSERIEFORM);
      write(writer, tags, UsedCar.KRAFTSTOFFART);
      write(writer, tags, UsedCar.GETRIEBE);
      write(writer, tags, UsedCar.FARBE);
      write(writer, tags, UsedCar.POLSTER);
      write(writer, tags, UsedCar.MODELL);
      write(writer, tags, UsedCar.GARANTIE);
      write(writer, tags, UsedCar.KONTAKT);
      write(writer, tags, UsedCar.AUSSTATTUNGSMERKMALE);
      buffer.append('\n');
      UsedCar.sortBy(UsedCar.GFZ_NUMBER);
      Collections.sort(listCarData);
      int i = 0;
      for (UsedCar s : listCarData) {
        s.setupTags(tags);
        buffer.append(s.toCompactString(attributeTypes));
        if (++i == 100) {
          writer.write(buffer.toString().getBytes());
          buffer.delete(0, buffer.length());
          i = 0;
        }
      }
      buffer.append('\n');
      System.out.println("write tag clusters");
      buffer.append(tags.toCompactString());
      System.out.println("write geo for addresses");
      buffer.append(Addresses.toCompactString(listCarData));
      writer.write(buffer.toString().getBytes());
      writer.close();
      writer = new FileOutputStream("tags.txt");
      writer.write(tags.toString(attributeTypes).getBytes());
      System.out.println("Number of all tags: " + tags.allTags.size());
    } catch (Throwable t) {
      t.printStackTrace();
    } finally {
      try {
        if (writer != null) writer.close();
      } catch (IOException ioe) {
      }
    }
  }

  private static String hashCode(String filename) throws IOException, NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("MD5");
    byte[] buffer = new byte[8192];
    InputStream fin = null;
    try {
      fin = new FileInputStream(filename);
      while (true) {
        int n = fin.read(buffer);
        if (n <= 0) break;
        digest.update(buffer, 0, n);
      }
      byte[] md5sum = digest.digest();
      BigInteger bigInt = new BigInteger(1, md5sum);
      String hCode = bigInt.toString(16);
      while (hCode.length() < 32) hCode = "0" + hCode;
      return hCode;
    } finally {
      if (fin != null) fin.close();
		}
  }

  /**
   *  Compresses a specified file.
   *  @param inFilename name of the file which should be compressed
   *  @param outFilename name of the compressed file
   *  @exception  IOException  if an I/O error occurs.
   **/
  public static void bzip2CompressData(String inFilename, String outFilename) throws IOException {
    BufferedInputStream in = null;
    BufferedOutputStream out = null;
    Bzip2OutputStream bzout = null;
    try {
      in = new BufferedInputStream(new FileInputStream(inFilename), 4*1024);
      out = new BufferedOutputStream(new FileOutputStream(outFilename), 4*1024);
      out.write('B');
      out.write('Z');
      int ch = in.read();
      if (ch != -1) { // Bug if file size equal to 0
        bzout = new Bzip2OutputStream(out);
        do {
          bzout.write(ch);
          ch = in.read();
        } while (ch != -1);
        bzout.flush();
      }
    } finally {
      in.close();
      bzout.close();
      out.close();
    }
  }

  public static String createDownload(List<UsedCar> usedCars, long version) {
    // ToDo: check how to create safe download
    String filename = "UsedCars_" + version + ".data";
    writeData(usedCars, version, filename);
    OutputStream writer = null;
    try {
      System.out.println("create download data");
      String compressedFilename = filename + ".bz2";
      bzip2CompressData("../" + filename, "../" + compressedFilename);
      // ToDo: bzip2 -9 -k <filename>
      writer = new FileOutputStream("../UsedCars.info");
      File f = new File("../" + compressedFilename);
      File uf = new File("../" + filename);
      String versionInfo = filename + ',' + version + ',' + usedCars.size() + ',' + f.length() + ',' + uf.length() + ',' + hashCode("../" + compressedFilename);
      writer.write(versionInfo.getBytes());
      writer.close();
      writer = new FileOutputStream("../UsedCars_" + version + ".info");
      writer.write(versionInfo.getBytes());
      writer.close();
      writer = new FileOutputStream("tags.txt");
      writer.write(tags.toString(attributeTypes).getBytes());
      System.out.println("Number of all tags: " + tags.allTags.size());
      return compressedFilename;
    } catch (RuntimeException e) {
      e.printStackTrace();
      throw e;
    } catch (Throwable t) {
      t.printStackTrace();
      return null;
    } finally {
      try {
        if (writer != null) writer.close();
      } catch (IOException ioe) {
      }
    }
  }
  
  public static void main(String[] args) {
    // java -Xmx500M -cp WebCrawler.jar CreateDataPool
    System.out.println("Default Charset=" + Charset.defaultCharset());
    System.out.println("file.encoding=" + System.getProperty("file.encoding"));
    List<UsedCar> usedCars = new ArrayList<UsedCar>(40000);
    long version = System.currentTimeMillis()/1000;
    //long existingVersion = 0;
    try {
      String versionFileName = "img_" + Long.toString(version);
      String infoFilename = "UsedCars_" + version + ".info";
      File versionFolder = new File(versionFileName);
      StringBuilder buffer = new StringBuilder(50000);
      File dir = new File("data/.");
      File[] files = dir.listFiles();

      List<String> allData = new ArrayList<String>(2*files.length);
      if (!new File("../" + infoFilename).exists()) {
        for (int i = 0; i < files.length; ++i) {
          String name = files[i].getName();
          if (name.toLowerCase().endsWith(".xml")) {
            String gfzNumber = name.substring(0, name.length()-4);
            Reader reader = null;
            try {
              reader = new InputStreamReader(new FileInputStream("data/" + name));
              UsedCar usedCar = readUsedCarXMLData(gfzNumber, reader);
              if (usedCar.erstzulassung > 500) { // ToDO: not FIX
                System.out.println("NOT include gfz:" + usedCar.gfzNumber + ", EZ:" + usedCar.erstzulassung + ", " + usedCar.intToDate(usedCar.erstzulassung));
                reader.close();
                reader = null;
                File f = new File("data/" + name);
                if (!f.renameTo(new File("data-problems/" + name))) f.delete();
              } else {
                usedCars.add(usedCar);
                allData.add(gfzNumber + ".img");
                allData.add(usedCar.getImages());              
              }
            } catch (Exception e) {
              System.err.println("ERROR in: " + gfzNumber);
              throw e;
            } finally {
              if (reader != null) reader.close();
            }
          }
        }
        if (usedCars.size() == 0) {
          System.err.println("NO data!");
          return;
        }
        createDownload(usedCars, version);
        int error = 0;
        FTP ftp = new FTP();
        // ToDo: performance mput command
        do {
          try {
            ftp.connect(FTPCredentials.connect);
            ftp.login(FTPCredentials.user, FTPCredentials.password);
            ftp.cd(FTPCredentials.path);
            ftp.setMode(FTP.MODE_BINARY);
            error = 0;
          } catch (IOException ioe) {
            ioe.printStackTrace();
            ftp.disconnect();
            Thread.currentThread().sleep(500);
            ftp = new FTP();
            ++error;
          }
          if (error > 3) System.exit(1);
        } while (error > 0);
        String compressedFilename = "UsedCars_" + version + ".data.bz2";
        System.out.println("Upload " + compressedFilename);
        ftp.put("../" + compressedFilename, compressedFilename, FTP.MODE_BINARY);
        System.out.println("Upload " + infoFilename);
        ftp.put("../" + infoFilename, infoFilename, FTP.MODE_BINARY);
        ftp.put("../UsedCars.info", "UsedCars2.info", FTP.MODE_BINARY);
        ftp.disconnect();
      }
      // IMG path
      if (!versionFolder.exists()) {
        System.out.println("create img path " + versionFileName);
        versionFolder.mkdir();
        Iterator<String> iter = allData.iterator();
        while (iter.hasNext()) {
          String imgFileName = iter.next();
          String images = iter.next();
          int error = 0;
          do {
            try {
              OutputStream out = new FileOutputStream(versionFileName + '/' + imgFileName);
              out.write(images.getBytes());
              out.close();
              //if (first && !imgFileName.equals("data/090637.img")) continue;  // ToDo: temp index file
              //ftp.fastBinaryPut(images.getBytes(), imgFileName);
              error = 0;
            } catch (IOException ioe) {
              ioe.printStackTrace();
              Thread.currentThread().sleep(500);
              ++error;
            }
            if (error > 3) System.exit(1);
          } while (error > 0);
        }
        allData.clear();
      }

      // FTP
      FTP ftp = new FTP();
      // ToDo: performance mput command
      ftp.connect(FTPCredentials.connect);
      ftp.login(FTPCredentials.user, FTPCredentials.password);
      ftp.cd(FTPCredentials.path);
      ftp.setMode(FTP.MODE_BINARY);
      List<String> imgDataExistingFiles = null;
      try {
        ftp.makeDir(Long.toString(version));
        ftp.cd(Long.toString(version));
      } catch (IOException ioe) {
        ftp.cd(Long.toString(version));
        imgDataExistingFiles = ftp.dir();
        if (imgDataExistingFiles.size() > 0) {
          imgDataExistingFiles.remove(imgDataExistingFiles.size()-1);
        }
      }
      files = versionFolder.listFiles();
      for (int i = 0; i < files.length; ++i) {
        String name = files[i].getName();
        if (imgDataExistingFiles != null && imgDataExistingFiles.indexOf(name) >= 0) continue;
        int error = 0;
        do {
          try {
            if (error > 0) {
              Thread.currentThread().sleep(500);
              ftp.disconnect();
              ftp.connect(FTPCredentials.connect);
              ftp.login(FTPCredentials.user, FTPCredentials.password);
              ftp.cd(FTPCredentials.path);
              ftp.setMode(FTP.MODE_BINARY);
              ftp.cd(Long.toString(version));
            }
            System.out.println(name);
            ftp.put(versionFileName + '/' + name, name, FTP.MODE_BINARY);
            error = 0;
          } catch (Throwable t) {
            t.printStackTrace();
            ++error;
          }
        } while (error > 0);
      }
      ftp.cd("..");
      ftp.deleteFile("UsedCars.info");
      ftp.rename("UsedCars2.info", "UsedCars.info");
      System.out.println("New index activated. Check content of UsedCars.info:");
      ftp.disconnect();
      System.out.println("Create new data folder");
      File fileData = new File("data");
      fileData.renameTo(new File(Long.toString(version)));
      fileData.mkdir();
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
