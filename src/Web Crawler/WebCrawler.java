import java.text.*;
import java.util.*;
import java.net.*;
import java.io.*;

public class WebCrawler implements Runnable {
  public static final String SEARCH = "Search";
  public static final String STOP = "Stop";
  public static final String DISALLOW = "Disallow:";
  public static final int SEARCH_LIMIT = 1000;
  public static final String TOKEN_SEPARATOR = " \t\n\r\">#";

  Stack<String> urlsToSearch;
  static Set<String> searchedURLs = new HashSet<String>(10000);
  String searchType;
  String startURL;
  static String oldDataPath = null;

  public WebCrawler(String startURL, String searchType) {
    this.searchType = searchType;
    this.startURL = startURL;
    urlsToSearch = new Stack<String>();
    // set default for URL access
    URLConnection.setDefaultAllowUserInteraction(false);
  }

  boolean isValidURL(URL urlLink) {
    // only look at http links
    if (!urlLink.getProtocol().equals("http")) return false;
    int tries = 0;
    boolean error = false;
    do {
      error = false;
      try {
        // try opening the URL
        URLConnection urlLinkConnection = urlLink.openConnection();
        urlLinkConnection.setAllowUserInteraction(false);
        trace("verify valid URL " + urlLink.toString());  // ToDo: REMOVE
        InputStream linkStream = urlLink.openStream();
        String strType = urlLinkConnection.guessContentTypeFromStream(linkStream);
        trace("strType: " + strType);  // ToDo: REMOVE
        linkStream.close();
        // if the proper type, add it to the results list
        // unless we have already seen it
        if (strType != null && strType.equals(searchType)) {
          trace("valid URL: " + urlLink.toString());
        }
      } catch (IOException e) {
        trace("ERROR (try:" + tries + "): couldn't verify valid URL " + urlLink.toString());
        error = true;
        try {
          Thread.currentThread().sleep(1000);
        } catch (InterruptedException ie) {}
      }
    } while (error && ++tries < 2);
    return !error;
  }

  int mileageLow = -1;
  int mileageHigh = -1;
  int initialRegistrationLow = -1;
  int initialRegistrationHigh = -1;
  int priceLow = -1;
  int priceHigh = -1;
  String searchForVehicleCategory = "all";
  String searchModel = "";
  boolean reachedLimits = false;
  boolean done = false;

  String getPostData(String strURL) {
    if (strURL.indexOf("globalsessionid") > 0 && strURL.indexOf("?VehicleId=") == -1 && strURL.indexOf("?OffsetPageNumber=") == -1) {
      return searchModel
           + "E0001MileageLow=" + mileageLow
           + "&E0002MileageHigh=" +mileageHigh
           + "&E0003InitialRegistrationLow=" +initialRegistrationLow
           + "&E0004InitialRegistrationHigh=" + initialRegistrationHigh
           + "&E0005PriceLow=" + priceLow
           + "&E0006PriceHigh=" + priceHigh
           + "&E0032SearchForVehicleCategory=" + searchForVehicleCategory;
    }
    return null;
  }

  int containsAnotherPage(String content, int repeatQueryWithPage) {
    if (content.indexOf("OffsetPageNumber="+(repeatQueryWithPage+1)) < 0) return -1;
    return content.indexOf("OffsetPageNumber="+repeatQueryWithPage);
  }

  boolean summaryOfDataExists(String content, int idx) {
    if (oldDataPath == null) return false;
    try {
      int l = content.length();
      while (idx < l && TOKEN_SEPARATOR.indexOf(content.charAt(idx)) >= 0) ++idx;
      int idx2 = idx;
      while (idx2 < l && TOKEN_SEPARATOR.indexOf(content.charAt(idx2)) == -1) ++idx2;
      String strURL = content.substring(idx, idx2);
      idx2 = strURL.indexOf("?VehicleId=");
      if (idx2 >= 0) {
        String gfzNumber = strURL.substring(idx2+11).replace("%2F", "-");
        if (gfzNumber.indexOf('%') >= 0) System.out.println("gfzNumber: " + gfzNumber);
        String fileName = oldDataPath + '/' + gfzNumber + ".xml";
        File f = new File(fileName);
        if (f.exists()) {
          FileReader reader = new FileReader(fileName);
          UsedCar usedCar = CreateDataPool.readUsedCarXMLData(gfzNumber, reader);
          reader.close();
          int idx3 = idx+idx2;
          while (idx3 < l && content.charAt(idx3) != '>') ++idx3;
          int idx4 = content.indexOf('<', idx3+1);
          String model = CreateDataPool.valueOf(content.substring(idx3+1, idx4), 0);  // ToDo: Performance without substring
          //System.out.println("model: " + model);
          if (usedCar.stringAttribute(UsedCar.MODELL).indexOf(model) < 0) return false;
          idx3 = content.indexOf("</a>", idx4+1);
          idx4 = content.indexOf('<', idx3+4);
          String fuelType = CreateDataPool.valueOf(content.substring(idx3+4, idx4), 0);
          //System.out.println("fuelType: " + fuelType);
          if (!fuelType.equals(usedCar.stringAttribute(UsedCar.KRAFTSTOFFART))) return false;
          idx3 = content.indexOf("<td class=\"sav-cll-p\">", idx4+1);  // skip Garantie
          idx3 = content.indexOf("<td class=\"sav-cll-p\">", idx3+22);
          idx4 = content.indexOf('<', idx3+22);
          String farbe = CreateDataPool.valueOf(content.substring(idx3+22, idx4), 0);
          //System.out.println("farbe: " + farbe);
          if (!farbe.equals(usedCar.stringAttribute(UsedCar.FARBE))) return false;
          idx3 = content.indexOf("<td class=\"sav-cll-p\"", idx4+1);  // skip Erstzulassung (oft fehlerhaft)
          idx3 = content.indexOf("<br>", idx3+21);
          idx4 = content.indexOf('<', idx3+4);
          String mileage = CreateDataPool.valueOf(content.substring(idx3+4, idx4), 0).replace(".", "");
          //System.out.println("mileage: " + mileage + ", " + Integer.toString(usedCar.intAttribute(UsedCar.KILOMETERSTAND)));
          if (!mileage.equals(Integer.toString(usedCar.intAttribute(UsedCar.KILOMETERSTAND)))) return false;
          idx3 = content.indexOf("<td class=\"sav-cll-p\">", idx4+1);  // skip Kontakt
          idx3 = content.indexOf("<td class=\"sav-cll-p\"", idx3+22);
          idx3 = content.indexOf("<b>", idx3+21);
          idx4 = content.indexOf('<', idx3+3);
          String kaufpreis = CreateDataPool.valueOf(content.substring(idx3+3, idx4), 0).replace(".", "");
          //System.out.println("kaufpreis: " + kaufpreis);
          if (!kaufpreis.equals(Integer.toString(usedCar.intAttribute(UsedCar.KAUFPREIS)))) return false;
          String targetName = "data/" + gfzNumber + ".xml";
          if ((new File(targetName)).exists()) {
            trace("file " + targetName + " already exist");
          } else {
            trace("copy: " + targetName);
            copy(fileName, targetName);
          }
          return true;
        }
      }
    } catch (IOException ioe) {
      ioe.printStackTrace();
    }
    return false;
  }

  /**
   *  Copy a file or a whole directory from a source path to a destination path.
   *  @param source source filename or directory
   *  @param source destination filename or directory
   *  @exception  IOException  if an I/O error occurs.
   **/
  public static void copy(String source, String destination) throws IOException {
    File file = new File(source);
    if (file.isDirectory()) {
      new File(destination).mkdir();
      File[] list = file.listFiles();
      if (list != null) {
        for (int i = 0; i < list.length; ++i) {
          copy(list[i].getAbsolutePath(), destination + '/' + list[i].getName());
        }
      }
    } else {
      writeData(new FileInputStream(file), new FileOutputStream(destination), true, true);
    }
  }
  
  /**
   *  Transfers the data from a specified input stream to an output stream.
   *  @param in   input stream
   *  @param out  output stream
   *  @param closeIn close input stream after the transfer if <code>true</code>.
   *  @param closeOut close output stream after the transfer if <code>true</code>.
   *  @return size of output stream.
   *  @exception  IOException  if an I/O error occurs.
   **/
  public static int writeData(InputStream in, OutputStream out, boolean closeIn, boolean closeOut) throws IOException {
    int size = 0;
    try {
      byte[] buffer = new byte[64 * 1024];
      while (true) {
        int n = in.read(buffer);
        if (n <= 0) break;
        if (out != null) out.write(buffer, 0, n);
        size += n;
      }
    } finally {
      if (closeIn) in.close();
      if (closeOut && out != null) out.close();
    }
    return size;
  }

  int findStartOfURL(String url, String content, int idx) {
    if (idx >= 0) {
      idx = content.indexOf("href", idx);
      if (idx >= 0) idx = content.indexOf('=', idx)+1;
      return idx;
    }
    if (url.startsWith("http://e-services.mercedes-benz.com/")) {
      String searchFor = "if(action==\"search\")";
      idx = content.indexOf(searchFor);
      if (idx >= 0) {
        idx += searchFor.length();
        searchFor = "document.forms['f023_quicksearch'].action=";
        idx = content.indexOf(searchFor, idx);
      } else { // pages with content
        searchFor = "<a class=\"boldLink\"";
        idx = 0;
        do {
          idx = content.indexOf(searchFor, idx);
          if (idx >= 0) {
            idx = content.indexOf("href", idx+searchFor.length());
            if (idx >= 0) idx = content.indexOf('=', idx)+1;
          }
        } while (idx >= 0 && summaryOfDataExists(content, idx));
        return idx;
      }
      return (idx == -1)? idx : (idx+searchFor.length());
    } else {
      idx = content.indexOf("<a");
      if (idx >= 0) idx = content.indexOf("href", idx);
      if (idx >= 0) idx = content.indexOf('=', idx);
      return idx;
    }
  }

  String[] nextURL(URL context, String url, String content, int idx) {
    idx = findStartOfURL(url, content, idx);
    if (idx == -1) return null;
    int l = content.length();
    while (idx < l && TOKEN_SEPARATOR.indexOf(content.charAt(idx)) >= 0) ++idx;
    int idx2 = idx;
    while (idx2 < l && TOKEN_SEPARATOR.indexOf(content.charAt(idx2)) == -1) ++idx2;
    String strURL = content.substring(idx, idx2);
    URL urlLink = null;
    String[] result = new String[2];
    result[0] = null;
    result[1] = content.substring(idx2);
    try {
      urlLink = new URL(context, strURL);
      //if (isValidURL(urlLink)) {
        result[0] = urlLink.toString();
      //}
    } catch (MalformedURLException e) {
      trace("ERROR: bad URL " + strURL);
    }
    return result;
  }
  
  boolean writeOutput(String dataName, byte[] data) {
    trace("output: " + dataName);
    OutputStream output = null;
    try {
      output = new FileOutputStream(dataName);
      output.write(data);
      return true;
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
    return false;
  }

  boolean readIndex() {
    StringBuilder buffer = new StringBuilder(10000);
    InputStream input = null;
    try {
	    input = new FileInputStream("usedcars.idx");
	    byte b[] = new byte[1000];
	    while (true) {
        int numRead = input.read(b);
        if (numRead == -1) break;
        buffer.append(new String(b, 0, numRead));
      }
    } catch (IOException e) {
	    return false;
    } finally {
      try {
        if (input != null) input.close();
      } catch (IOException e) {
      }
    }
    StringTokenizer tokens = new StringTokenizer(buffer.toString(), ",");
    initialRegistrationLow = Integer.parseInt(tokens.nextToken());
    initialRegistrationHigh = Integer.parseInt(tokens.nextToken());
    mileageLow = Integer.parseInt(tokens.nextToken());
    mileageHigh = Integer.parseInt(tokens.nextToken());
    priceLow = Integer.parseInt(tokens.nextToken());
    priceHigh = Integer.parseInt(tokens.nextToken());
    searchModel = tokens.nextToken();
    if (tokens.hasMoreTokens()) {
      searchForVehicleCategory = tokens.nextToken();
    } else {
      searchForVehicleCategory = searchModel;
      searchModel = "";
    }
    return true;
  }

  void writeIndex() {
    OutputStream output = null;
    try {
      output = new FileOutputStream("usedcars.tmp");
      StringBuilder buffer = new StringBuilder(200);
      buffer.append(initialRegistrationLow);
      buffer.append(',');
      buffer.append(initialRegistrationHigh);
      buffer.append(',');
      buffer.append(mileageLow);
      buffer.append(',');
      buffer.append(mileageHigh);
      buffer.append(',');
      buffer.append(priceLow);
      buffer.append(',');
      buffer.append(priceHigh);
      buffer.append(',');
      buffer.append(searchModel);
      buffer.append(',');
      buffer.append(searchForVehicleCategory);
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
    File target = new File("usedcars.idx");
    target.delete();
    File source = new File("usedcars.tmp");
    source.renameTo(target);
  }

  static int numberOfDownloadedFiles(String pathName) {
    File dir = new File(pathName);
    return dir.list().length;
  }

  String filterContentName(String content) {
    //int i = content.toLowerCase().indexOf("gfz-nummer");
    int i = content.indexOf("GFZ-Nummer");
    if (i >= 0) i = content.indexOf("<td ", i);
    if (i >= 0) {
      int l = content.length();
      while (i < l && content.charAt(i) != '>') ++i;
      while (++i < l && TOKEN_SEPARATOR.indexOf(content.charAt(i)) >= 0);
      int j = content.indexOf('<', i);
      while (j > i && TOKEN_SEPARATOR.indexOf(content.charAt(j-1)) >= 0) --j;
      return (i < j)? content.substring(i, j).replace(",", "%2C") : null;
    }
    return null;
  }

  String convertFileName(String fileName) {
    return fileName.replace('/', '-').replace('?', '_');
  }

  boolean isEqual(File file, String content) {
    int n = (int)file.length();
    if (n != content.getBytes().length) return false;
    StringBuilder buffer = new StringBuilder(n+10);
    InputStream input = null;
    try {
	    input = new FileInputStream(file);
	    byte b[] = new byte[n];
	    while (true) {
        int numRead = input.read(b);
        if (numRead == -1) break;
        buffer.append(new String(b, 0, numRead));
      }
    } catch (IOException e) {
	    return false;
    } finally {
      try {
        if (input != null) input.close();
      } catch (IOException e) {
      }
    }
    return content.equals(buffer.toString());
  }

  boolean filterOutput(String url, String type, byte[] data) {
    if (type == null || type.equals("text/html")) {
      String content = new String(data, 0, data.length);
      String contentName = filterContentName(content);
      if (contentName == null) return false;
      UsedCar usedCar = null;
      String searchFor = "<!-- start st043.jsp -->";
      int i = content.indexOf(searchFor);
      if (i >= 0) {
        i += searchFor.length();
        int j = content.indexOf("<!-- stop st002.jsp", i);
        if (j >= 0) {
          StringReader reader = null;
          try {
            reader = new StringReader(content.substring(i, j));
            usedCar = CreateDataPool.readUsedCarData(contentName, reader);
          } catch (IOException e) {
            e.printStackTrace();
          } finally {
            if (reader != null) reader.close();
          }
        }
      }
      if (usedCar != null) {
        searchFor = "var FotoArr = new Array(";
        i = content.indexOf(searchFor);
        if (i >= 0) {
          i += searchFor.length()+1;
          do {
            int j = content.indexOf('\"', i);
            if (j < 0) break;
            usedCar.add("Bilder", content.substring(i, j));
            i = j+3;
          } while (content.charAt(i-2) == ',' && content.charAt(i-1) == '\"');
        }
        writeIndex();
        if (contentName.indexOf(',') >= 0) {
          System.err.println("INTERNAL ERROR: wrong name " + contentName);
          System.exit(1);
        }
        String filePath = "data/" + convertFileName(contentName) + ".xml";
        File f = new File(filePath);
        int idx = 0;
        while (f.exists()) {
          trace("File " + filePath + " already exist!");
          if (isEqual(f, usedCar.toString())) break;
          filePath = "data/" + convertFileName(contentName) + ',' + (++idx) + ".xml";
          f = new File(filePath);
        }
        return (f.exists())? true : writeOutput(filePath, usedCar.toString().getBytes());
      }
    /*} else if (type.equals("image/jpeg")) {
      return writeOutput(contentName + ".jpg", data);*/
    }
    return false;
  }

  private static boolean robotSafe(URL url) {
    String strHost = url.getHost();
    // form URL of the robots.txt file
    String strRobot = "http://" + strHost + "/robots.txt";
    URL urlRobot;
    try { 
	    urlRobot = new URL(strRobot);
    } catch (MalformedURLException e) {
	    // something weird is happening, so don't trust it
	    return false;
    }
    StringBuilder strCommands = new StringBuilder(10000);
    InputStream urlRobotStream = null;
    try {
	    urlRobotStream = urlRobot.openStream();
	    // read in entire file
	    byte b[] = new byte[1000];
	    while (true) {
        int numRead = urlRobotStream.read(b);
        if (numRead == -1) break;
        strCommands.append(new String(b, 0, numRead));
      }
    } catch (IOException e) {
	    // if there is no robots.txt file, it is OK to search
	    return true;
    } finally {
      try {
        if (urlRobotStream != null) urlRobotStream.close();
      } catch (IOException e) {
      }
    }
    // assume that this robots.txt refers to us and 
    // search for "Disallow:" commands.
    String strURL = url.getFile();
    int index = 0;
    while (true) {
      index = strCommands.indexOf(DISALLOW, index);
      if (index == -1) break;
	    index += DISALLOW.length();
	    StringTokenizer st = new StringTokenizer(strCommands.substring(index));
	    if (st.hasMoreTokens()) {
        // if the URL starts with a disallowed path, it is not safe
        if (strURL.indexOf(st.nextToken()) == 0) return false;
      }
    }
    return true;
  }

  String urlId(String url) {
    int idx = url.indexOf("?VehicleId=");
    return (idx >= 0)? url.substring(idx+11) : url;
  }

  private void clearSearchedURLs(Set<String> searchedURLs) {
    List<String> s = new ArrayList<String>(searchedURLs.size());
    for (String url : searchedURLs) {
      if (url.startsWith("http:")) s.add(url);
    }
    searchedURLs.removeAll(s);
  }

  public void run() {
    String searchFor = "Search for cars:";
    if (initialRegistrationLow >= 0) searchFor += " from " + initialRegistrationLow + " to " + initialRegistrationHigh;
    if (mileageLow >= 0) searchFor += " from " + mileageLow + " to " + mileageHigh;
    if (priceLow >= 0) searchFor += " from " + priceLow + " to " + priceHigh;
    if (searchModel.length() > 0) searchFor += " model: " + searchModel;
    if (!searchForVehicleCategory.equals("all")) searchFor += " category: " + searchForVehicleCategory;
    trace(searchFor);

    int numberFound = 0;
    int repeatQueryWithPage = 0;
    // initialize search data structures
    urlsToSearch.clear();
    //searchedURLs.clear();
    do {
      numberFound = 0;
      String strURL = startURL;
      if (strURL.length() == 0) {
        trace("ERROR: must enter a starting URL");
        return;
      }
      urlsToSearch.add(strURL);
      clearSearchedURLs(searchedURLs);
      while (!urlsToSearch.empty() && numberFound < SEARCH_LIMIT) {
        // get the first element from the to be searched list
        strURL = urlsToSearch.pop();
        String urlId = urlId(strURL);
        if (searchedURLs.contains(urlId)) continue;
        // mark the URL as searched (we want this one way or the other)
        searchedURLs.add(urlId);
        //trace("searching " + urlId + " : " + strURL);
        URL url = null;
        try {
          url = new URL(strURL);
        } catch (MalformedURLException e) {
          trace("ERROR: invalid URL " + strURL);
          continue;
        }      
        // can only search http: protocol URLs
        if (!url.getProtocol().equals("http")) continue;
        // test to make sure it is before searching
        //if (!robotSafe(url)) break;

        int tries = 0;
        boolean error = false;
        do {
          error = false;
          try {
            // try opening the URL
            HttpURLConnection connection = (HttpURLConnection)url.openConnection();
            connection.setAllowUserInteraction(false);
            connection.setDoInput(true);
            final int responseTimeOutSecs = 60;
            connection.setConnectTimeout(responseTimeOutSecs * 1000);
            connection.setReadTimeout(responseTimeOutSecs * 1000);
            OutputStreamWriter wr = null;
            String postData = getPostData(strURL);
            //trace(strURL);
            if (postData != null) {
              connection.setRequestMethod("POST");
              connection.setDoOutput(true);
              wr = new OutputStreamWriter(connection.getOutputStream());
              wr.write(postData);
              wr.flush();
              //trace("searching data: " + postData);
            }
            InputStream inStream = connection.getInputStream();
            //InputStream urlStream = url.openStream();
            String type = connection.guessContentTypeFromStream(inStream);
            // correct type
            if (type == null && url.toString().toLowerCase().endsWith(".jpg")) type = "image/jpeg";
            //if (type == null || !type.equals("text/html")) continue;
            // search the input stream for links
            // first, read in the entire URL
            ByteArrayOutputStream content = new ByteArrayOutputStream(100000);
            byte data[] = new byte[50000];
            while (true) {
              int numRead = inStream.read(data);
              if (numRead == -1) break;
              content.write(data, 0, numRead);
            }
            inStream.close();
            if (wr != null) wr.close();
            if (postData != null /*strURL.equals(startURL)*/) {
              int idx = containsAnotherPage(content.toString(), Math.max(0, repeatQueryWithPage-1));
              if (idx >= 0) {
                if (repeatQueryWithPage > 0) {
                  // load the other page
                  String[] strLink = nextURL(url, strURL, content.toString(), idx);
                  if (strLink != null && strLink[0] != null && !searchedURLs.contains(urlId(strLink[0]))) {
                    urlsToSearch.add(strLink[0]);
                    reachedLimits = (++repeatQueryWithPage >= 9);
                    continue;
                  }
                } else {
                  ++repeatQueryWithPage;
                }
              } else {
                repeatQueryWithPage = 0;
              }
            }
            data = content.toByteArray();
            if (filterOutput(strURL, type, data)) ++numberFound;
            if (type == null || type.equals("text/html")) {
              String s = content.toString();
              while (true) {
                String[] strLink = nextURL(url, strURL, s, -1);
                if (strLink == null) break;
                if (strLink[0] != null && !searchedURLs.contains(urlId(strLink[0]))) {
                  urlsToSearch.add(strLink[0]);
                }
                s = strLink[1];
              }
            }
          } catch (IOException e) {
            trace("ERROR (try:" + tries + "): couldn't open URL " + strURL);
            error = true;
            try {
              Thread.currentThread().sleep(1000);
            } catch (InterruptedException ie) {}
          }
        } while (error && ++tries < 2);
        if (error) break;
      }
      //if (repeatQueryWithPage > 0) trace("repeatQueryWithPage:" + repeatQueryWithPage + ", numberFound:" + numberFound);
    } while (repeatQueryWithPage > 0);
    if (numberFound >= SEARCH_LIMIT) {
	    trace("reached search limit of " + SEARCH_LIMIT);
    } else {
	    //trace("done");
    }
    done = true;
  }

  public static String findLargestNumericalPath() {
    File dir = new File(".");
    File[] files = dir.listFiles();
    long maxValue = 0;
    for (int i = 0; i < files.length; ++i) {
      try {
        String name = files[i].getName();
        long value = Long.parseLong(name);
        if (value > maxValue) {
          File f = new File(name);
          if (f.isDirectory()) maxValue = value;
        }
      } catch (NumberFormatException nfe) {
      }
    }
    return (maxValue > 0)? Long.toString(maxValue) : null;
  }
    
    private static void trace(String text) {
    trace(text, true, true);
  }
  
  private static void trace(String text, boolean timestamp, boolean newLine) {
    if (timestamp) {
      if (newLine) {
        System.out.println(formatter.format(new Date()) + text);
      } else {
        System.out.print(formatter.format(new Date()) + text);
        System.out.flush();
      }
    } else {
      if (newLine) {
        System.out.println(text);
      } else {
        System.out.print(text);
        System.out.flush();
      }
    }
  }
  private static SimpleDateFormat formatter = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss ");

  // java -Xmx500M -jar WebCrawler.jar
  public static void main (String args[]) {
    // http://www.mercedes-benz.de/content/germany/mpc/mpc_germany_website/de/home_mpc/passengercars/home/_used_cars/used_car_search.html
    // http://e-services.mercedes-benz.com/dsc_de/Dispatcher.jam?businessCase=UCu&amp;dsc_locale=de_DE&amp;SelfRedirect=true
    // http://www.whatgreencar.com/view-car/
    String startURL = "http://e-services.mercedes-benz.com/dsc_de/Dispatcher.jam?businessCase=UCu&amp;dsc_locale=de_DE&amp;SelfRedirect=true";
    trace("check if there is a http://e-services.mercedes-benz.com/robots.txt");
    try { 
      if (!robotSafe(new URL(startURL))) {
        trace("start URL is not allowed to crawl");
        return;
      }
    } catch (MalformedURLException e) {
      e.printStackTrace();
	    // something weird is happening, so don't trust it
	    return;
    }
    trace("start URL can be crawled");
    /*if (args.length != 1) {
      System.err.println("WebCrawler <start URL>");
      //return;
    } else {
      startURL = args[0];
    }*/

    // Behind a firewall set your proxy and port here!
    /*Properties props= new Properties(System.getProperties());
     props.put("http.proxySet", "true");
     props.put("http.proxyHost", "");
     props.put("http.proxyPort", "");
     Properties newprops = new Properties(props);
     System.setProperties(newprops);*/

    WebCrawler webCrawler = null;
    trace("searching...");
    int milageValues[] = {0, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000, -1};
    int initialRegistrationValues[] = {1950, 1980, 1990, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, -1};
    int priceValues[] = {0, 2500, 5000, 7500, 10000, 12500, 15000, 17500, 20000, 25000, 30000, 35000, 40000, 45000, 50000, 60000, 70000, 80000, 90000, 100000, -1};
    String vehicleCategory[] = {"C", "1", "2", "Z"};
    String models[] = {"ER01C01=WDB004&", // A-Klasse - Limousine
      "ER01C03=WDB003&", // A-Klasse - Coupé
      "ER12C05=WDB189&", // B-Klasse - Offroader/Tourer
      "ER02C01=WDB014&", // C-Klasse - Limousine
      "ER02C02=WDB015&", // C-Klasse - T-Modell/Kombi/Van
      "ER02C03=WDB013&", // C-Klasse - Coupé
      "ER06C03=WDB053&", // CL-Klasse - Coupé
      "ER19C03=WDB233&", // CLC-Klasse - Coupé
      "ER05C03=WDB063&", // CLK-Klasse - Coupé
      "ER05C04=WDB061&", // CLK-Klasse - Cabriolet/Roadster
      "ER11C03=WDB073&", // CLS-Klasse - Coupé
      "ER03C01=WDB024&", // E-Klasse - Limousine
      "ER03C02=WDB025&", // E-Klasse - T-Modell/Kombi/Van
      "ER03C03=WDB023&", // E-Klasse - Coupé
      "ER03C04=WDB021&", // E-Klasse - Cabriolet/Roadster
      "ER10C05=WDB126&", // G-Klasse - Offroader/Tourer
      "ER17C05=WDB206&", // GL-Klasse - Offroader/Tourer
      "ER20C05=WDB226&", // GLK-Klasse - Offroader/Tourer
      "ER09C05=WDB116&", // M-Klasse - Offroader/Tourer
      "ER16C05=WDB190&", // R-Klasse - Offroader/Tourer
      "ER04C01=WDB044&", // S-Klasse - Limousine
      "ER08C04=WDB081&", // SL-Klasse - Cabriolet/Roadster
      "ER07C04=WDB101&", // SLK-Klasse - Cabriolet/Roadster
      "ER18C03=WDB213&", // SLR-Klasse - Coupé
      "ER18C04=WDB211&", // SLR-Klasse - Cabriolet/Roadster
      "ER13C02=WDB142&", // Vaneo - T-Modell/Kombi/Van
      "ER14C02=WDB152&", // Viano - T-Modell/Kombi/Van
      "ER15C02=WDB132&"}; // V-Klasse - T-Modell/Kombi/Van

    // Test:
    if (args.length == 1) {
      webCrawler = new WebCrawler(startURL, "text/html");
      webCrawler.mileageLow = 0;
      webCrawler.mileageHigh = 10000;
      webCrawler.initialRegistrationLow = 2010;
      webCrawler.initialRegistrationHigh = -1;
      webCrawler.priceLow = 15000;
      webCrawler.priceHigh = 17500;
      webCrawler.searchModel = "ER01C01=WDB004&";
      webCrawler.searchForVehicleCategory = "C";
      webCrawler.run();
    } else {
      webCrawler = new WebCrawler(startURL, "text/html");
      webCrawler.oldDataPath = findLargestNumericalPath();
      trace("Previous data version " + webCrawler.oldDataPath);
      boolean startAtIndex = webCrawler.readIndex();
      boolean directToPriceSelection = false;
      for (int j = 0; j < initialRegistrationValues.length-1; ++j) {
        if (startAtIndex && webCrawler.initialRegistrationLow != initialRegistrationValues[j]) continue;
        if (startAtIndex && webCrawler.initialRegistrationHigh == initialRegistrationValues[j]) {
          webCrawler.reachedLimits = true;
        } else {
          if (j > 0 && initialRegistrationValues[j+1]-initialRegistrationValues[j] == 1 && initialRegistrationValues[j]-initialRegistrationValues[j-1] > 1) continue;
          if (!directToPriceSelection) {
            webCrawler = new WebCrawler(startURL, "text/html");
            if (initialRegistrationValues[j+1]-initialRegistrationValues[j] > 1) {
              webCrawler.initialRegistrationLow = initialRegistrationValues[j];
              webCrawler.initialRegistrationHigh = initialRegistrationValues[j+1];
            } else {
              webCrawler.initialRegistrationLow = initialRegistrationValues[j];
              webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
            }
            webCrawler.run();
            startAtIndex = false;
            if (webCrawler.reachedLimits) directToPriceSelection = true;
          }
        }
        if (directToPriceSelection || webCrawler.reachedLimits) {
          for (int k = 0; k < priceValues.length-1; ++k) {
            if (startAtIndex && webCrawler.priceLow != priceValues[k]) continue;
            startAtIndex = false;
            webCrawler = new WebCrawler(startURL, "text/html");
            webCrawler.initialRegistrationLow = initialRegistrationValues[j];
            webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
            webCrawler.priceLow = priceValues[k];
            webCrawler.priceHigh = priceValues[k+1];
            webCrawler.run();
            if (webCrawler.reachedLimits) {
              for (int m = 0; m < models.length; ++m) {
                webCrawler = new WebCrawler(startURL, "text/html");
                webCrawler.initialRegistrationLow = initialRegistrationValues[j];
                webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
                webCrawler.priceLow = priceValues[k];
                webCrawler.priceHigh = priceValues[k+1];
                webCrawler.searchModel = models[m];
                webCrawler.run();
                if (webCrawler.reachedLimits) {
                  for (int n = 0; n < vehicleCategory.length; ++n) {
                    webCrawler = new WebCrawler(startURL, "text/html");
                    webCrawler.initialRegistrationLow = initialRegistrationValues[j];
                    webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
                    webCrawler.priceLow = priceValues[k];
                    webCrawler.priceHigh = priceValues[k+1];
                    webCrawler.searchModel = models[m];
                    webCrawler.searchForVehicleCategory = vehicleCategory[n];
                    webCrawler.run();
                    if (webCrawler.reachedLimits) {
                      for (int i = 0; i < milageValues.length-1; ++i) {
                        webCrawler = new WebCrawler(startURL, "text/html");
                        webCrawler.mileageLow = milageValues[i];
                        webCrawler.mileageHigh = milageValues[i+1];
                        webCrawler.initialRegistrationLow = initialRegistrationValues[j];
                        webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
                        webCrawler.priceLow = priceValues[k];
                        webCrawler.priceHigh = priceValues[k+1];
                        webCrawler.searchModel = models[m];
                        webCrawler.searchForVehicleCategory = vehicleCategory[n];
                        webCrawler.run();
                        if (webCrawler.reachedLimits) {
                          trace("COULD NOT DOWNLOAD ALL RECORDS!");
                          if (i > 0) {
                            int nFiles = numberOfDownloadedFiles("data/.");
                            webCrawler = new WebCrawler(startURL, "text/html");
                            webCrawler.mileageLow = milageValues[i];
                            webCrawler.mileageHigh = milageValues[i];
                            webCrawler.initialRegistrationLow = initialRegistrationValues[j];
                            webCrawler.initialRegistrationHigh = initialRegistrationValues[j];
                            webCrawler.priceLow = priceValues[k];
                            webCrawler.priceHigh = priceValues[k+1];
                            webCrawler.searchModel = models[m];
                            webCrawler.searchForVehicleCategory = vehicleCategory[n];
                            webCrawler.run();
                            //new Thread(webCrawler).start();
                            trace("Number of new downloaded records: " + (numberOfDownloadedFiles("data/.")-nFiles));
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    trace("Number of new downloaded records: " + numberOfDownloadedFiles("data/."));
    trace("COMPLETED");
    File index = new File("usedcars.idx");
    index.delete();
    Consolidate.main(null);
    CreateDataPool.main(null);
    Delete.main(null);
  }
}
