package edu.stanford;

import com.microsoft.sqlserver.jdbc.SQLServerDataSource;

import java.io.*;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonString;

public class Pop2ILLiad {
  public static String folio_user = new String();
  public static String NVTGC = new String();
  public static String optionalPhone = new String();
  public static String requiredEmail = new String();
  public static Date today = new Date();
  public static Date expiry = new Date();
  public static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
  public static SimpleDateFormat sdf_ill = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S");
  public static StringBuilder sqlSTF = new StringBuilder();
  public static StringBuilder sqlS7Z = new StringBuilder();
  public static SQLServerDataSource stf = new SQLServerDataSource();
  public static SQLServerDataSource s7z = new SQLServerDataSource();
  public static Map<String, String> illData = new LinkedHashMap<>();

  public static void main(String[] args) throws Exception {
    try {
      Properties props = new Properties();
      props.load(new FileInputStream("src/main/resources/server.conf"));

      String pass = props.getProperty("PASS");
      String server = props.getProperty("SERVER");

      Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDataSource");

      stf.setUser("STF");
      stf.setPassword(pass);
      stf.setServerName(server);
      stf.setPortNumber(1433);
      stf.setDatabaseName("ILLData");

      s7z.setUser("S7Z");
      s7z.setPassword("S7ZPassword");
      s7z.setServerName(server);
      s7z.setPortNumber(1433);
      s7z.setDatabaseName("ILLData");

      BufferedReader br = new BufferedReader(new FileReader(new File(args[0])));

      // For each json line of the folio-user.log file
      while ((folio_user = br.readLine()) != null) {
        try {
          JsonReader jsonReader = Json.createReader(new StringReader(folio_user));
          JsonObject batch = jsonReader.readObject();
          JsonArray users = batch.getJsonArray("users");


          for (int u = 0; u < users.size(); u++) {
            try {
              JsonObject obj = users.getJsonObject(u);
              JsonArray departments = obj.getJsonArray("departments");

              for (int d = 0; d < departments.size(); d++) {
                if (departments.getJsonString(d).toString().equals("Interlibrary Borrowing - GSB")) {
                  NVTGC = "S7Z";
                } else {
                  NVTGC = "STF";
                }
              }

              String sunetid = obj.getJsonString("username").getString();

              JsonString expiryDateJson = obj.getJsonString("expirationDate");
              if (expiryDateJson != null && expiryDateJson.getString().length() > 0) {
                expiry = sdf.parse(expiryDateJson.getString());
              }

              JsonString phoneJson = obj.getJsonObject("personal").getJsonString("phone");
              if (phoneJson != null) {
                optionalPhone = phoneJson.getString();
              }

              JsonString emailJson = obj.getJsonObject("personal").getJsonString("email");
              if (emailJson != null) {
                requiredEmail = emailJson.getString();
              } else {
                System.err.println("Skipping user: " + sunetid + ". No email address in folio user record.");
                continue;
              }

              System.err.println(sunetid);

              illData.clear();
              illData.put("UserName", "'" + sunetid + "'"); // 50 *
              illData.put("LastName", "'"
                  + obj.getJsonObject("personal").getJsonString("lastName").getString().replaceAll("[\'\"]", "") + "'"); // 40
                                                                                                                         // *
              illData.put("FirstName",
                  "'" + obj.getJsonObject("personal").getJsonString("firstName").getString().replaceAll("[\'\"]", "")
                      + "'"); // 40 *
              illData.put("SSN", "'" + getString(obj, "barcode") + "'"); // 20
              illData.put("Status", "'" + getString(obj, "patronGroup") + "'"); // 15
              illData.put("EMailAddress", "'" + requiredEmail + "'"); // 50 *
              illData.put("Phone", "'" + optionalPhone + "'"); // 15 *
              illData.put("MobilePhone", "'NULL'"); // 15
              illData.put("Department", "'" + departments.getString(0) + "'"); // 255
              illData.put("NVTGC", "'" + NVTGC + "'"); // 20 *
              illData.put("Password", "''"); // 64
              illData.put("NotificationMethod", "'Electronic'"); // 8
              illData.put("DeliveryMethod", "'Hold for Pickup'"); // 25
              illData.put("LoanDeliveryMethod", "'NULL'"); // 25
              illData.put("LastChangedDate", "'" + sdf_ill.format(today) + "'");
              illData.put("AuthorizedUsers", "'SUL'"); // 255
              illData.put("Cleared", "'Yes'");
              illData.put("Web", "'Yes'"); // 3
              illData.put("Address", "''"); // 40
              illData.put("Address2", "''"); // 40
              illData.put("City", "''"); // 30
              illData.put("State", "''"); // 2
              illData.put("Zip", "''"); // 10
              illData.put("Site", "'SUL'"); // 40
              illData.put("ExpirationDate", "'" + sdf_ill.format(expiry) + "'");
              illData.put("Number", "NULL"); //
              illData.put("UserRequestLimit", "NULL");
              illData.put("Organization", "'NULL'"); //
              illData.put("Fax", "NULL"); //
              illData.put("ShippingAcctNo", "NULL");
              illData.put("ArticleBillingCategory", "NULL"); //
              illData.put("LoanBillingCategory", "NULL"); //
              illData.put("Country", "NULL"); //
              illData.put("SAddress", "NULL"); //
              illData.put("SAddress2", "NULL"); //
              illData.put("SCity", "NULL"); //
              illData.put("SState", "NULL"); //
              illData.put("SZip", "NULL"); //
              illData.put("PasswordHint", "NULL"); //
              illData.put("SCountry", "NULL"); //
              illData.put("RSSID", "NULL");
              illData.put("AuthType", "'RemoteAuth'");
              illData.put("UserInfo1", "'" + getString(obj, "externalSystemId") + "'"); //
              illData.put("UserInfo2", "NULL"); //
              illData.put("UserInfo3", "NULL"); //
              illData.put("UserInfo4", "NULL"); //
              illData.put("UserInfo5", "NULL"); //
              if (NVTGC.equals("STF")) {
                sqlSTF.append(GetTransactSQL.transactSql(illData, sunetid.toString())).append("\n\r");
              }

              if (NVTGC.equals("S7Z")) {
                sqlS7Z.append(GetTransactSQL.transactSql(illData, sunetid.toString())).append("\n\r");
              }
            } catch (javax.json.stream.JsonParsingException e) {
              e.printStackTrace();
              continue;
            }
          }
        } catch (javax.json.stream.JsonParsingException e) {
          System.err.println(e);
          continue;
        } catch (Exception e) {
          System.err.println(e);
          continue;
        }
      }

      Connection stfConn = stf.getConnection();
      ConnectToILLiad.connect(GetTransactSQL.transactBegin(), stfConn);
      ConnectToILLiad.connect(sqlSTF.toString(), stfConn);
      ConnectToILLiad.connect(GetTransactSQL.transactCommit(), stfConn);
      stfConn.close();

      Connection s7zConn = s7z.getConnection();
      ConnectToILLiad.connect(GetTransactSQL.transactBegin(), s7zConn);
      ConnectToILLiad.connect(sqlS7Z.toString(), s7zConn);
      ConnectToILLiad.connect(GetTransactSQL.transactCommit(), s7zConn);
      s7zConn.close();
    } catch (Exception e) {
      System.err.println("Pop2ILLiad: " + e.getMessage());
      e.printStackTrace();
    }
  }

  public static String getString(JsonObject obj, String name) {
    try {
      if (!obj.isNull(name)) {
        return obj.getJsonString(name).toString();
      } else {
        return null;
      }
    } catch (ClassCastException e) {
      return null;
    }
  }
}
