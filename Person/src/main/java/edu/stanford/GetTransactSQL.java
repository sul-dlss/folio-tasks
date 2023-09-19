package edu.stanford;

import java.io.FileInputStream;
import java.util.Map;
import java.util.Properties;

class GetTransactSQL {

  static String transactBegin(){
    return "BEGIN TRAN\n\r";
  }

  static String transactCommit(){
    return "COMMIT TRAN\n\r-----------";
  }

  static String transactSql(Map<String, String> illData, String sunetid) throws Exception {

    Properties props = new Properties();
    props.load(new FileInputStream("src/main/resources/server.conf"));

    String table_name = props.getProperty("TABLE_NAME");
    String do_not_update_field = props.getProperty("NO_UPDATE");

    StringBuilder sql = new StringBuilder();
    StringBuilder sqlv = new StringBuilder();

    // sql.append(" declare @dept_").append(sunetid).append(" varchar(50)\n\r");
    sql.append(" IF EXISTS (select * from ILLData.dbo.").append(table_name).append(" where UserName = '").append(sunetid).append("')\n\r");
    sql.append(" BEGIN\n\r");
    // sql.append("  SET @dept_").append(sunetid).append(" = (select Department from ILLData.dbo.UsersALL where UserName = '").append(sunetid).append("')\n\r");
    sql.append("  UPDATE ILLData.dbo.").append(table_name).append("\n\r");
    sql.append("  SET\n\r");

    int cnt = 1;
    for (Map.Entry<String, String> entry : illData.entrySet()) {
      String key = entry.getKey();
      String value = entry.getValue();

      /* Keep the same ignore_fields as previously loaded and update the rest with new values */
      // if (key.equals(do_not_update_field)) {
      //   sql.append(key).append("= @dept_").append(sunetid);
      // }
      // else {
      //   sql.append(key).append("=").append(value);
      // }
      sql.append(key).append("=").append(value);

      if (cnt < illData.size()) {
        sql.append(",");
      }
      sql.append("\n\r");
      cnt++;
    }

    sql.append("   WHERE UserName = '").append(sunetid).append("'\n\r");
    sql.append("  END\n\r");
    sql.append(" ELSE\n\r");
    sql.append(" BEGIN\n\r");
    sql.append("  INSERT INTO ILLData.dbo.").append(table_name).append("\n\r");
    sql.append("  (");

    cnt=1;
    for (Map.Entry<String, String> entry : illData.entrySet()) {
      sql.append(entry.getKey());

      if (cnt < illData.size()) {
        sql.append(", ");
      }
      cnt++;
    }

    sql.append(")\n\r");
    sqlv.append(" VALUES\n\r");
    sqlv.append("(");

    cnt=1;
    for (Map.Entry<String, String> entry : illData.entrySet()) {
      sqlv.append(entry.getValue());

      if (cnt < illData.size()) {
        sqlv.append(",");
      }
      cnt++;
    }

    sqlv.append(")\n\r");
    sql.append(sqlv);
    sql.append("  END\n\r");

    String [] activityType = {
      "ClearedUser",
      "PasswordReset",
      "RequestCancelled",
      "RequestElectronicDelivery",
      "RequestOther",
      "RequestOverdue",
      "RequestPickup",
      "RequestShipped"
    };

    for (String anActivityType : activityType) {
      sql.append("IF NOT EXISTS (select * from ILLData.dbo.UserNotifications where UserName = '").append(sunetid).append("' and ActivityType = '").append(anActivityType).append("')\n\r");
      sql.append(" BEGIN\n\r");
      sql.append("  insert into ILLData.dbo.UserNotifications\n\r");
      sql.append("  (Username, ActivityType, NotificationType)\n\r");
      sql.append("  values\n\r");
      sql.append("  ('").append(sunetid).append("','").append(anActivityType).append("','Email')\n\r");
      sql.append(" END\n\r");
    }

    System.err.println(sqlv + "\n-----------");
    return sql.toString();
  }
}
