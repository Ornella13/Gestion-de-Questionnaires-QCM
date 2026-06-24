package com.scholarly.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {
    private static final String URL = "jdbc:mysql://localhost:3306/gestion_questionnaire?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = ""; 
    private static Connection connection = null;

    public static Connection getConnection() throws SQLException {
        try {
            if (connection == null || connection.isClosed()) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
            
                connection.setAutoCommit(true);
                System.out.println("=== CONNEXION RÉUSSIE À XAMPP ===");
           
            }
        } catch (ClassNotFoundException e) {
            
            System.err.println("=== ÉCHEC DE CONNEXION : " + e.getMessage());
            throw new SQLException("Driver MySQL non trouvé", e);
        }
        return connection;
    }
}