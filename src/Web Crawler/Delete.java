import java.io.*;
import java.util.*;

public class Delete {
  public static void main(String[] args) {
    // java -cp WebCrawler.jar Delete 1301465378
    try {
      // FTP
      FTP ftp = new FTP();
      ftp.connect(FTPCredentials.connect);
      ftp.login(FTPCredentials.user, FTPCredentials.password);
      ftp.cd(FTPCredentials.path);
      ftp.setMode(FTP.MODE_BINARY);
      List<String> packages = new ArrayList<String>(10);
      String oldestPackage = null;
      if (args == null || args.length == 0) {
        List<String> files = ftp.dir();
        for (String file : files) {
          if (file.startsWith("UsedCars_") && file.endsWith(".data.bz2")) {
            int idx = file.indexOf('.');
            if (idx > 9) packages.add(file.substring(9, idx));
          }
        }
        if (packages.size() > 0) {
          Collections.sort(packages);
          oldestPackage = packages.get(0);
          long now = System.currentTimeMillis();
          if (now-Long.parseLong(oldestPackage) > 10*24*3600*1000) {
            System.out.println("Package " + oldestPackage + " is older than 10 days");
          } else {
            oldestPackage = null;
          }
        }
        for (String file : files) {
          if (file.length() > 0 && Character.isDigit(file.charAt(0)) && file.equals(Long.toString(Long.parseLong(file))) && !packages.contains(file)) {
            oldestPackage = file;
            System.out.println("Package " + oldestPackage + " not completely deleted from server!");
          }
        }
      } else {
        oldestPackage = args[0];
      }
      if (oldestPackage != null) {
        System.out.println("Delete package " + oldestPackage + " on server");
        try {
          ftp.deleteFile("UsedCars_" + oldestPackage + ".data.bz2");
        } catch (IOException ioe) {
          ioe.printStackTrace();
        }
        try {
          ftp.deleteFile("UsedCars_" + oldestPackage + ".info");
        } catch (IOException ioe) {
          ioe.printStackTrace();
        }
        ftp.cd(oldestPackage);
        List<String> files = ftp.dir();
        for (String file : files) {
          if (!file.equals(".") && !file.equals("..")) {
            int error = 0;
            do {
              try {
                ftp.deleteFile(file);
                error = 0;
              } catch (IOException ioe) {
                System.out.println("Error deleting file " + file);
                ioe.printStackTrace();
                Thread.currentThread().sleep(500);
                ftp.disconnect();
                ++error;
                ftp.connect(FTPCredentials.connect);
                ftp.login(FTPCredentials.user, FTPCredentials.password);
                ftp.cd(FTPCredentials.path);
                ftp.setMode(FTP.MODE_BINARY);
                ftp.cd(oldestPackage);
              }
            } while (error > 0);
          }
        }
        ftp.cd("..");
        ftp.deleteDir(oldestPackage);
        System.out.println("Package " + oldestPackage + " completely deleted on server");
      }
      ftp.disconnect();
      File localFile = new File(oldestPackage);
      File[] localFiles = localFile.listFiles();
      if (localFiles != null) {
        System.out.println("Delete local package " + oldestPackage);
        for (int i = 0; i < localFiles.length; ++i) {
          localFiles[i].delete();
        }
        localFile.delete();
      }
      localFile = new File("img_" + oldestPackage);
      localFiles = localFile.listFiles();
      if (localFiles != null) {
        System.out.println("Delete local img package " + oldestPackage);
        for (int i = 0; i < localFiles.length; ++i) {
          localFiles[i].delete();
        }
        localFile.delete();
      }
      localFile = new File("../UsedCars_" + oldestPackage + ".data");
      localFile.delete();
      localFile = new File("../UsedCars_" + oldestPackage + ".data.bz2");
      localFile.delete();
      localFile = new File("../UsedCars_" + oldestPackage + ".info");
      localFile.delete();
      /*
       Delete package 1301881229 on server
       java.io.IOException: DELE failed with 550 UsedCars_1301881229.data.bz2: No such file or directory
       at FTP.checkResponseCode(FTP.java:775)
       at FTP.executeCommand(FTP.java:801)
       at FTP.deleteFile(FTP.java:596)
       at Delete.main(Delete.java:46)
       at WebCrawler.main(WebCrawler.java:880)
       java.io.IOException: DELE failed with 550 UsedCars_1301881229.info: No such file or directory
       at FTP.checkResponseCode(FTP.java:775)
       at FTP.executeCommand(FTP.java:801)
       at FTP.deleteFile(FTP.java:596)
       at Delete.main(Delete.java:51)
       at WebCrawler.main(WebCrawler.java:880)
       Package 1301881229 completely deleted on server
       Delete local package 1301881229
       */
    } catch (Throwable t) {
      t.printStackTrace();
    }
  }
}
