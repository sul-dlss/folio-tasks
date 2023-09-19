package edu.stanford;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

public class ConnectToILLiad {

    public static void connect (String transactSQL, Connection connection) throws SQLException {
        try
        {
            Statement stmt = connection.createStatement();
            stmt.executeUpdate(transactSQL);
        }
        catch (SQLException s) {
            System.err.println("State: " + s.getSQLState() + " ErrorCode:" + s.getErrorCode() +"\n-----------");
            System.err.println(s.getMessage());
        }
    }
}
