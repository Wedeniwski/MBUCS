import java.io.*;
import java.net.*;
import java.util.*;

public class Addresses {
  private static Map<String, double[]> addressLocations = readAddressLocations();

  private static Map<String, double[]> readAddressLocations() {
    Map<String, double[]> locations = new HashMap<String, double[]>(1000);
    StringBuilder buffer = new StringBuilder(100000);
    InputStream input = null;
    try {
	    input = new FileInputStream("addresses.txt");
	    byte b[] = new byte[10000];
	    while (true) {
        int numRead = input.read(b);
        if (numRead == -1) break;
        buffer.append(new String(b, 0, numRead));
      }
    } catch (IOException e) {
      e.printStackTrace();
	    return locations;
    } finally {
      try {
        if (input != null) input.close();
      } catch (IOException e) {
      }
    }
    StringTokenizer tokens = new StringTokenizer(buffer.toString(), "\n");
    while (tokens.hasMoreTokens()) {
      String line = tokens.nextToken();
      int i = line.indexOf(',');
      int j = line.indexOf(',', i+1);
      double[] latlon = new double[2];
      latlon[0] = Double.parseDouble(line.substring(0, i));
      latlon[1] = Double.parseDouble(line.substring(i+1, j));
      locations.put(line.substring(j+1), latlon);
    }
    return locations;
  }

  private static void writeAddressLocations() {
    OutputStream output = null;
    try {
      output = new FileOutputStream("addresses.txt");
      StringBuilder buffer = new StringBuilder(100000);
      Iterator<String> i = addressLocations.keySet().iterator();
      while (i.hasNext()) {
        String address = i.next();
        double[] latlon = addressLocations.get(address);
        buffer.append(latlon[0]);
        buffer.append(',');
        buffer.append(latlon[1]);
        buffer.append(',');
        buffer.append(address);
        if (i.hasNext()) buffer.append('\n');
      }
      output.write(buffer.toString().getBytes());
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (output != null) {
        try {
          output.close();
        } catch (IOException e) {
        }
      }
    }
  }

  public static String getAddress(UsedCar usedCar) {
    int j = usedCar.kontakt.indexOf("<br>");
    int l = usedCar.kontakt.length();
    if (j < 0) return null;
    int k = j+4;
    while (k < l && usedCar.kontakt.charAt(k) != '<') ++k;
    int i = j;
    while (i > 0 && usedCar.kontakt.charAt(i) != '>') --i;
    return usedCar.kontakt.substring(i+1, j) + ", " + usedCar.kontakt.substring(j+4, k);
  }

  public static double[] latitudeLongitudeOfAddress(String address) {
    // see http://stevemorse.org/jcal/latlonbatch.html?direction=forward
    double[] latlon = addressLocations.get(address);
    if (latlon != null) return latlon;
    latlon = new double[2];
    while (true) {
      try {
        String urlPath = "http://api.maps.yahoo.com/ajax/geocode?appid=" + System.currentTimeMillis() + "&qt=1&id=m&qs=" + URLEncoder.encode(address + ", Deutschland", "UTF8");
        //String urlPath = "http://xml1.maps.vip.re3.yahoo.com/ajax/geocode?appid=1302965334864&qt=1&id=m&qs=" + URLEncoder.encode(address + ", Deutschland", "UTF8") + "&noCacheIE=1302965334864";
        URL url = new URL(urlPath);
        HttpURLConnection connection = (HttpURLConnection)url.openConnection();
        connection.setAllowUserInteraction(false);
        connection.setDoInput(true);
        connection.setRequestMethod("GET");
        connection.setDoOutput(false);
        final int responseTimeOutSecs = 60;
        connection.setConnectTimeout(responseTimeOutSecs * 1000);
        connection.setReadTimeout(responseTimeOutSecs * 1000);
        InputStream inStream = connection.getInputStream();
        ByteArrayOutputStream data = new ByteArrayOutputStream(1000);
        byte buffer[] = new byte[1000];
        while (true) {
          int numRead = inStream.read(buffer);
          if (numRead == -1) break;
          data.write(buffer, 0, numRead);
        }
        String content = data.toString();
        inStream.close();
        String find = "\"GeoPoint\":{";
        int i = content.indexOf(find);
        if (i >= 0) {
          i = content.indexOf(':', i+find.length());
          int j = content.indexOf(',', i);
          latlon[0] = Double.parseDouble(content.substring(i+1, j));
          i = content.indexOf(':', j);
          j = content.indexOf('}', i);
          latlon[1] = Double.parseDouble(content.substring(i+1, j));
          if (latlon[0] == 0.0 && latlon[1] == 0.0) {
            System.out.println("NO geo for " + address);
            return null;
          }
          addressLocations.put(address, latlon);
          System.out.println("New address (" + latlon[0] + ',' + latlon[1] + "): " + address);
          writeAddressLocations();
          return latlon;
        } else {
          System.out.println("NO geo for " + address);
          return null;
        }
      } catch (IOException ioe) {
        ioe.printStackTrace();
        try {
          Thread.currentThread().sleep(10000);
        } catch (InterruptedException e) {}
      }
    }
  }

  public static String toCompactString(List<UsedCar> listCars) {
    Set<String> addresses = new HashSet<String>(1000);
    addresses.add("");
    for (UsedCar usedCar : listCars) {
      String address = getAddress(usedCar);
      if (address == null) {
        if (usedCar.kontakt.length() > 0) System.out.println("NO Address for: " + usedCar.gfzNumber);
      } else addresses.add(address);
    }
    List<String> sortedAddresses = new ArrayList<String>(addresses.size());
    sortedAddresses.addAll(addresses);
    Collections.sort(sortedAddresses);
    StringBuilder result = new StringBuilder(10000);
    result.append('(');
    boolean first = true;
    for (UsedCar usedCar : listCars) {
      String address = getAddress(usedCar);
      int idx = sortedAddresses.indexOf(address);
      if (!first) result.append(',');
      result.append((idx >= 0)? idx : 0);
      first = false;
    }
    result.append(")[");
    first = true;
    for (String address : sortedAddresses) {
      double[] latlon = (address.length() == 0)? null : latitudeLongitudeOfAddress(address);
      if (!first) result.append(',');
      if (latlon != null) {
        result.append(latlon[0]);
        result.append(',');
        result.append(latlon[1]);
      } else {
        result.append(',');
      }
      first = false;
    }
    result.append(']');
    return result.toString();
  }

  public static void main(String[] args) {
    // java -cp WebCrawler.jar Addresses
    Set<String> addresses = new HashSet<String>(1000);
    try {
      String rootPath = "1302986015/";
      File dir = new File(rootPath + '.');
      File[] files = dir.listFiles();
      for (int i = 0; i < files.length; ++i) {
        String name = files[i].getName();
        if (name.toLowerCase().endsWith(".xml")) {
          String gfzNumber = name.substring(0, name.indexOf('.'));
          Reader reader = new InputStreamReader(new FileInputStream(rootPath + name));
          UsedCar usedCar = CreateDataPool.readUsedCarXMLData(gfzNumber, reader);
          reader.close();
          String address = getAddress(usedCar);
          if (address == null) {
            if (usedCar.kontakt.length() > 0) System.out.println("NO Address for: " + gfzNumber);
          } else addresses.add(address);
        }
      }
    } catch (Throwable t) {
      t.printStackTrace();
    }
    System.out.println("All addresses (" + addresses.size() + "):");
    for (String address : addresses) {
      double[] latlon = latitudeLongitudeOfAddress(address);
      if (latlon != null) {
        // (51.164181,10.45415): Gesellschaft mbH &amp; Co KG, AutorisierterMercedes-, Benz Verkauf und Service
        // (0.0,0.0): Weseler Straße 100 - 108, 45478 Mülheim a.d. Ruhr
        System.out.println("(" + latlon[0] + ',' + latlon[1] + "): " + address);
      }
    }
  }
}
