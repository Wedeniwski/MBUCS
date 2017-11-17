import java.io.*;
import java.net.*;
import java.util.*;

public class Consolidate {
  static String globalSessionId = null;
  static String jSessionId = null;

  static String deepLinkToSearch() throws IOException, MalformedURLException {
    if (globalSessionId != null && jSessionId != null) {
      return "http://e-services.mercedes-benz.com/dsc_de/globalsessionid/" + globalSessionId + "/dsc_locale/de_DE/appId/DSC_de/siteLocale/de_DE/VSCVehicleIDSearch.jam2;jsessionid=" + jSessionId;
    }
    String startURL = "http://e-services.mercedes-benz.com/dsc_de/Dispatcher.jam?businessCase=UCu&amp;dsc_locale=de_DE&amp;SelfRedirect=true";
    URL url = new URL(startURL);
    HttpURLConnection connection = (HttpURLConnection)url.openConnection();
    connection.setAllowUserInteraction(false);
    connection.setDoInput(true);
    OutputStreamWriter wr = null;
    InputStream inStream = connection.getInputStream();
    ByteArrayOutputStream data = new ByteArrayOutputStream(100000);
    byte buffer[] = new byte[50000];
    while (true) {
      int numRead = inStream.read(buffer);
      if (numRead == -1) break;
      data.write(buffer, 0, numRead);
    }
    inStream.close();
    String content = data.toString();
    int idx = content.indexOf("href=\"/dsc_de/globalsessionid/");
    if (idx >= 0) {
      idx += 30;
      int idx2 = idx;
      while (true) {
        char ch = content.charAt(idx2);
        if (ch == '\0' || ch == '/') break;
        ++idx2;
      }
      globalSessionId = content.substring(idx, idx2);
      idx = content.indexOf(";jsessionid=", idx2);
      idx += 12;
      idx2 = idx;
      while (true) {
        char ch = content.charAt(idx2);
        if (ch == '\0' || ch == '\"') break;
        ++idx2;
      }
      jSessionId = content.substring(idx, idx2);
      return "http://e-services.mercedes-benz.com/dsc_de/globalsessionid/" + globalSessionId + "/dsc_locale/de_DE/appId/DSC_de/siteLocale/de_DE/VSCVehicleIDSearch.jam2;jsessionid=" + jSessionId;
    }
    return null;
  }

  static UsedCar onlinePage(String gfzNumber) throws IOException, MalformedURLException {
    String dataURL = deepLinkToSearch();
    String htmlBody = "E0001VehicleID=" + gfzNumber;
    URL url = new URL(dataURL);
    HttpURLConnection connection = (HttpURLConnection)url.openConnection();
    connection.setAllowUserInteraction(false);
    connection.setDoInput(true);
    connection.setRequestMethod("POST");
    connection.setDoOutput(true);
    final int responseTimeOutSecs = 60;
    connection.setConnectTimeout(responseTimeOutSecs * 1000);
    connection.setReadTimeout(responseTimeOutSecs * 1000);
    OutputStreamWriter wr = new OutputStreamWriter(connection.getOutputStream());
    wr.write(htmlBody);
    wr.flush();
    InputStream inStream = connection.getInputStream();
    ByteArrayOutputStream data = new ByteArrayOutputStream(100000);
    byte buffer[] = new byte[50000];
    while (true) {
      int numRead = inStream.read(buffer);
      if (numRead == -1) break;
      data.write(buffer, 0, numRead);
    }
    String content = data.toString();
    inStream.close();
    wr.close();
    String searchFor = "<!-- start st043.jsp -->";
    int i = content.indexOf(searchFor);
    if (i >= 0) {
      i += searchFor.length();
      int j = content.indexOf("<!-- stop st002.jsp", i);
      if (j >= 0) {
        StringReader reader = new StringReader(content.substring(i, j));
        UsedCar usedCar = CreateDataPool.readUsedCarData(gfzNumber, reader);
        reader.close();
        return usedCar;
      }
    }
    return null;
  }

  public static void main(String[] args) {
    // java -cp WebCrawler.jar Consolidate
    try {
      File dir = new File("data/.");
      File[] files = dir.listFiles();
      for (int i = 0; i < files.length; ++i) {
        String name = files[i].getName();
        int idx = name.indexOf(',');
        if (idx >= 0 && name.toLowerCase().endsWith(".xml")) {
          String gfzNumber = name.substring(0, idx);
          Reader reader = new InputStreamReader(new FileInputStream("data/" + name));
          UsedCar usedCar = CreateDataPool.readUsedCarXMLData(gfzNumber, reader);
          reader.close();
          System.out.println("GFZ: " + gfzNumber);
          UsedCar onlineUsedCar = onlinePage(usedCar.gfzNumber);
          if (usedCar.equals(onlineUsedCar)) {
            String mainFilePath = "data/" + gfzNumber + ".xml";
            System.out.println("delete " + mainFilePath);
            File f = new File(mainFilePath);
            f.delete();
            System.out.println("rename data/" + name + " to " + mainFilePath);
            f = new File("data/" + name);
            f.renameTo(new File(mainFilePath));
          } else {
            reader = new InputStreamReader(new FileInputStream("data/" + gfzNumber + ".xml"));
            UsedCar mainUsedCar = CreateDataPool.readUsedCarXMLData(gfzNumber, reader);
            reader.close();
            System.out.println("delete data/" + name);
            File f = new File("data/" + name);
            f.delete();
            if (!usedCar.equals(mainUsedCar)) {
              String mainFilePath = "data/" + gfzNumber + ".xml";
              System.out.println("delete " + mainFilePath);
              f = new File(mainFilePath);
              f.delete();
              System.out.println("output online data to " + mainFilePath);
              OutputStream output = new FileOutputStream(mainFilePath);
              output.write(onlineUsedCar.toString().getBytes());
              output.close();
            }
          }
        }
      }
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
