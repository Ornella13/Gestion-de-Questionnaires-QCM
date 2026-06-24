package com.schoarly.services;

import com.schoarly.models.Student;
import com.schoarly.models.ExamResult;
import com.schoarly.models.Examen;
import com.schoarly.models.Question;
import com.scholarly.utils.DatabaseManager; 
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DatabaseService {

    public DatabaseService() {
        ensureSchema();
    }

    private void ensureSchema() {
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement()) {
            
            String dbType = conn.getMetaData().getDatabaseProductName();
            String dbUrl = conn.getMetaData().getURL();
            System.out.println("--- DATABASE DIAGNOSTIC ---");
            System.out.println("Using Database: " + dbType);
            System.out.println("Connection URL: " + dbUrl);
            System.out.println("---------------------------");
            
            // 1. S'assurer que la table sessions existe
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS sessions (" +
                "id INT PRIMARY KEY AUTO_INCREMENT, " +
                "title VARCHAR(255), " +
                "level VARCHAR(50), " +
                "date VARCHAR(50), " +
                "time VARCHAR(50), " +
                "duration INT DEFAULT 30, " +
                "students VARCHAR(255), " +
                "status VARCHAR(50) DEFAULT 'En attente')");

            // 2. Vérifier les colonnes manquantes pour qcm
            if (!hasColumn("qcm", "options_count")) {
                try {
                    stmt.executeUpdate("ALTER TABLE qcm ADD COLUMN options_count INT DEFAULT 4");
                } catch (SQLException e) {}
            }
            
            // 3. Vérifier les colonnes manquantes pour sessions
            if (!hasColumn("sessions", "level")) {
                try { stmt.executeUpdate("ALTER TABLE sessions ADD COLUMN level VARCHAR(50)"); } catch (SQLException e) {}
            }
            if (!hasColumn("sessions", "duration")) {
                try { stmt.executeUpdate("ALTER TABLE sessions ADD COLUMN duration INT DEFAULT 30"); } catch (SQLException e) {}
            }

            // 4. S'assurer que la table examen est complète
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS examen (" +
                "num_exam INT PRIMARY KEY AUTO_INCREMENT, " +
                "num_etudiant VARCHAR(50), " +
                "annee_univ VARCHAR(20), " +
                "note INT, " +
                "session_id INT, " +
                "date_examen VARCHAR(50))");
            System.out.println("DEBUG Schema: Table 'examen' ready.");
            
            // Forcer l'ajout des colonnes (sécurité supplémentaire si CREATE TABLE échouait)
            String[] columns = {"session_id", "date_examen", "annee_univ"};
            String[] types = {"INT", "VARCHAR(50)", "VARCHAR(20)"};
            for (int i = 0; i < columns.length; i++) {
                if (!hasColumn("examen", columns[i])) {
                    try {
                        stmt.executeUpdate("ALTER TABLE examen ADD COLUMN " + columns[i] + " " + types[i]);
                        System.out.println("DEBUG Schema: Added missing column " + columns[i] + " to examen");
                    } catch (SQLException e) {
                        // Ignorer si la colonne existe déjà mais hasColumn a échoué
                    }
                }
            }

            // 5. S'assurer que les tables de base existent (pour import SQL)
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS etudiant (" +
                "num_etudiant VARCHAR(50) PRIMARY KEY, " +
                "nom VARCHAR(100), " +
                "prenoms VARCHAR(100), " +
                "niveau VARCHAR(5), " +
                "adr_email VARCHAR(150))");
            
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS qcm (" +
                "num_quest INT PRIMARY KEY AUTO_INCREMENT, " +
                "question TEXT, " +
                "reponse1 TEXT, " +
                "reponse2 TEXT, " +
                "reponse3 TEXT, " +
                "reponse4 TEXT, " +
                "bonne_reponse_index INT, " +
                "module VARCHAR(50), " +
                "options_count INT DEFAULT 4)");

            seedData(conn);
            
        } catch (SQLException e) {
            System.err.println("Database migration error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void reseedDatabase() {
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("DELETE FROM examen");
            stmt.executeUpdate("DELETE FROM etudiant");
            stmt.executeUpdate("DELETE FROM qcm");
            seedData(conn);
            System.out.println("Database refreshed with default students and questions.");
        } catch (SQLException e) {
            System.err.println("Error during database refresh: " + e.getMessage());
        }
    }

    private void seedData(Connection conn) {
        try {
            // Seeding Etudiants if empty
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM etudiant")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    System.out.println("Seeding etudiants...");
                    String insert = "INSERT INTO etudiant (num_etudiant, nom, prenoms, niveau, adr_email) VALUES (?,?,?,?,?)";
                    try (PreparedStatement ps = conn.prepareStatement(insert)) {
                        String[][] data = {
                            {"100H-Tol", "Claudia", "Rataveasy", "M1", "claudiaRataveasy@gmail.com"},
                            {"300H-Tol", "Marie Nomena", "Frandela", "M2", "frandela@gmail.com"},
                            {"500H-Tol", "claudia", "ornella", "L3", "ornellaclaudia0@gmail.com"},
                            {"502H-Tol", "Bella", "Pageot", "L3", "bellapageot@gmail.com"},
                            {"700H-Tol", "Michela", "Miriam", "L2", "michelamiriam@gmail.com"},
                            {"901H-Tol", "Marianah", "Tiavina", "L1", "marianah@gmail.com"},
                            {"902H-Tol", "Albert", "Camus", "L1", "camus@gmail.com"}
                        };
                        for (String[] d : data) {
                            ps.setString(1, d[0]); ps.setString(2, d[1]); ps.setString(3, d[2]);
                            ps.setString(4, d[3]); ps.setString(5, d[4]);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
            }

            // Seeding Questions if empty
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM qcm")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    System.out.println("Seeding qcm...");
                    String insert = "INSERT INTO qcm (question, reponse1, reponse2, reponse3, reponse4, bonne_reponse_index, module, options_count) VALUES (?,?,?,?,?,?,?,?)";
                    try (PreparedStatement ps = conn.prepareStatement(insert)) {
                        Object[][] data = {
                            {"Que signifie JSP ?", "A. Java System Page", "B. Java Server Pages", "C. Java Script Program", "D. Java Source Page", 2, "L3", 4},
                            {"JSP est utilisé pour :", "A. Créer des applications mobiles", "B. Gérer la base de données uniquement", "C. Générer des pages web dynamiques", "D. Compiler du code Java", 3, "L3", 4},
                            {"Quel langage est principalement utilisé dans JSP ?", "A. Python", "B. Java ", "C. C#", "D. PHP", 2, "L3", 4},
                            {"Quelle balise permet d’insérer du code Java dans une page JSP ?", "A. <script>", "B. <php>", "C. <% %> ", "D. <java>", 3, "L3", 4},
                            {"Quelle extension a un fichier JSP ?", "A. .html", "B. .php", "C. .jsp", "D. .js", 3, "L3", 4},
                            {"JSP est exécuté côté :", "A. Client", "B. Serveur ", "C. Navigateur", "D. Mobile", 2, "L3", 4},
                            {"Quel objet JSP est utilisé pour écrire dans la réponse ?", "A. out", "B. response", "C. request", "D. session", 1, "L3", 4},
                            {"Quelle directive JSP est utilisée pour importer des classes ?", "A. <%@ page import=\"...\" %>", "B. <%@ import %>", "C. <%@ include %>", "D. <jsp:import>", 1, "L3", 4},
                            {"Le cycle de vie d'une servlet comprend :", "A. init(), service(), destroy()", "B. start(), run(), stop()", "C. create(), execute(), delete()", "D. load(), process(), unload()", 1, "L3", 4},
                            {"Quelle méthode est appelée une seule fois lors du chargement d'une servlet ?", "A. service()", "B. init()", "C. main()", "D. doGet()", 2, "L3", 4},
                            {"MVC signifie :", "A. Model View Controller", "B. Multiple View Control", "C. Main View Center", "D. Model Variation Control", 1, "L3", 4},
                            {"Linux est :", "A. Un logiciel de traitement de texte", "B. Un système d’exploitation", "C. Un antivirus", "D. Un navigateur", 2, "L1", 4},
                            {"Quelle commande permet d’afficher le contenu d’un dossier ?", "A. show", "B. list", "C. ls", "D. dir", 3, "L1", 4},
                            {"Quelle commande permet de changer de répertoire ?", "A. move", "B. cd ", "C. chdir", "D. dir", 2, "L2", 4},
                            {"quel couleur est le soleil", "rouge", "jaune", "violet", "vert", 2, "L3", 4},
                            {"quel est le couleur du ciel", "verte", "rouge", "jaune", "bleu", 4, "L1", 4},
                            {"la forme de la terre", "ronde", "ovale", "triangle", "carreé", 1, "M2", 4}
                        };
                        for (Object[] d : data) {
                            ps.setString(1, (String)d[0]); ps.setString(2, (String)d[1]); ps.setString(3, (String)d[2]);
                            ps.setString(4, (String)d[3]); ps.setString(5, (String)d[4]); ps.setInt(6, (Integer)d[5]);
                            ps.setString(7, (String)d[6]); ps.setInt(8, (Integer)d[7]);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                        System.out.println("Questions seeded.");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Seeding error: " + e.getMessage());
        }
    }

    private Map<String, String> getColumnMap(ResultSetMetaData metaData) throws SQLException {
        Map<String, String> map = new HashMap<>();
        for (int i = 1; i <= metaData.getColumnCount(); i++) {
            map.put(metaData.getColumnName(i).toLowerCase(), metaData.getColumnName(i));
        }
        return map;
    }

    private Question mapResultSetToQuestion(ResultSet rs, Map<String, String> colMap, boolean hasOptionsCount) throws SQLException {
        String qText = rs.getString(findCol(colMap, "question", "quest", "enonce", "text", "libelle"));
        
        // Recherche ultra-flexible des options - PRIORITÉ AUX NOMS LONGS
        String r1 = rs.getString(findCol(colMap, "reponse1", "rep1", "reponse_1", "reponse_a", "choix1", "choix_a", "option1", "option_a", "libelle_a", "text_a", "r1", "A"));
        String r2 = rs.getString(findCol(colMap, "reponse2", "rep2", "reponse_2", "reponse_b", "choix2", "choix_b", "option2", "option_b", "libelle_b", "text_b", "r2", "B"));
        String r3 = rs.getString(findCol(colMap, "reponse3", "rep3", "reponse_3", "reponse_c", "choix3", "choix_c", "option3", "option_c", "libelle_c", "text_c", "r3", "C"));
        String r4 = rs.getString(findCol(colMap, "reponse4", "rep4", "reponse_4", "reponse_d", "choix4", "choix_d", "option4", "option_d", "libelle_d", "text_d", "r4", "D"));
        
        // Si une option récupérée ressemble à une simple étiquette (ex: "A" ou "A."), 
        // on tente de chercher dans des colonnes alternatives si elles existent
        String[] opts = {r1, r2, r3, r4};
        String[] letters = {"A", "B", "C", "D"};
        for (int i = 0; i < 4; i++) {
            String val = opts[i];
            if (val != null && (val.trim().equalsIgnoreCase(letters[i]) || val.trim().equalsIgnoreCase(letters[i] + "."))) {
                // Tentative de trouver une colonne plus descriptive pour cette option spécifique
                String altCol = findCol(colMap, "rep_" + letters[i], "choix_" + letters[i], "option_" + letters[i] + "_texte", "label_" + letters[i]);
                String altVal = rs.getString(altCol);
                if (altVal != null && !altVal.trim().isEmpty() && !altVal.trim().equalsIgnoreCase(letters[i])) {
                    if (i == 0) r1 = altVal;
                    else if (i == 1) r2 = altVal;
                    else if (i == 2) r3 = altVal;
                    else if (i == 3) r4 = altVal;
                }
            }
        }
        
        // Gestion de la bonne réponse
        String correctCol = findCol(colMap, "bonne_reponse_index", "bonne_reponse", "correct", "rep_correcte", "reponse", "verite", "reponse_valide", "solution", "vrai", "reponse_juste");
        String correctVal = rs.getString(correctCol);
        int correct = 1;
        
        try {
            if (correctVal != null) {
                correctVal = correctVal.trim().toUpperCase();
                if (correctVal.equals("A") || correctVal.equals("1")) correct = 1;
                else if (correctVal.equals("B") || correctVal.equals("2")) correct = 2;
                else if (correctVal.equals("C") || correctVal.equals("3")) correct = 3;
                else if (correctVal.equals("D") || correctVal.equals("4")) correct = 4;
                else correct = Integer.parseInt(correctVal);
            }
        } catch (Exception e) {
            correct = 1; 
        }

        String module = rs.getString(findCol(colMap, "module", "niveau", "categorie", "classe", "matiere", "ue", "label", "discipline"));
        int id = rs.getInt(findCol(colMap, "num_quest", "num", "id", "num_q", "quest_id", "question_id"));
        int optCount = hasOptionsCount ? rs.getInt(colMap.get("options_count")) : 4;

        return new Question(id, qText, r1, r2, r3, r4, correct, module, optCount);
    }

    private String findCol(Map<String, String> map, String... options) {
        for (String opt : options) {
            if (map.containsKey(opt.toLowerCase())) return map.get(opt.toLowerCase());
        }
        return options[0]; 
    }

    private Map<String, String> getTableColumns(String table) {
        Map<String, String> map = new HashMap<>();
        try (Connection conn = DatabaseManager.getConnection();
             ResultSet rs = conn.getMetaData().getColumns(null, null, table, null)) {
            while (rs.next()) {
                String col = rs.getString("COLUMN_NAME");
                map.put(col.toLowerCase(), col);
            }
        } catch (Exception e) {}
        return map;
    }

    /**
     * SECTION ÉTUDIANTS
     */
    public List<Student> getAllStudents() {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM etudiant";
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(mapResultSetToStudent(rs));
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        }
        return list;
    }

    public List<Student> searchStudents(String query) {
        List<Student> list = new ArrayList<>();
        String sql = "SELECT * FROM etudiant WHERE nom LIKE ? OR prenoms LIKE ? OR num_etudiant LIKE ?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String searchTerm = "%" + query + "%";
            ps.setString(1, searchTerm);
            ps.setString(2, searchTerm);
            ps.setString(3, searchTerm);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToStudent(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void createStudent(Student s) throws SQLException {
        String sql = "INSERT INTO etudiant (num_etudiant, nom, prenoms, niveau, adr_email) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getNumEtudiant());
            ps.setString(2, s.getNom());
            ps.setString(3, s.getPrenoms());
            ps.setString(4, s.getNiveau());
            ps.setString(5, s.getAdrEmail());
            ps.executeUpdate();
        }
    }

    public void updateStudent(Student s) throws SQLException {
        String sql = "UPDATE etudiant SET nom=?, prenoms=?, niveau=?, adr_email=? WHERE num_etudiant=?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getNom());
            ps.setString(2, s.getPrenoms());
            ps.setString(3, s.getNiveau());
            ps.setString(4, s.getAdrEmail());
            ps.setString(5, s.getNumEtudiant());
            ps.executeUpdate();
        }
    }

    public void updateStudentWithNewId(String oldId, Student s) throws SQLException {
        // Option simple: UPDATE de la PK. Fonctionne si SQLite/MySQL n'a pas de FK strictes bloquantes 
        // ou si ON UPDATE CASCADE est actif.
        String sql = "UPDATE etudiant SET num_etudiant=?, nom=?, prenoms=?, niveau=?, adr_email=? WHERE num_etudiant=?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getNumEtudiant());
            ps.setString(2, s.getNom());
            ps.setString(3, s.getPrenoms());
            ps.setString(4, s.getNiveau());
            ps.setString(5, s.getAdrEmail());
            ps.setString(6, oldId);
            ps.executeUpdate();
            
            // Mise à jour manuelle des références dans la table 'examen' au cas où CASCADE n'est pas là
            String updateExamSql = "UPDATE examen SET num_etudiant = ? WHERE num_etudiant = ?";
            try (PreparedStatement psExam = conn.prepareStatement(updateExamSql)) {
                psExam.setString(1, s.getNumEtudiant());
                psExam.setString(2, oldId);
                psExam.executeUpdate();
            } catch (SQLException e) {
                // S'ignore si la table examen n'existe pas encore ou erreur mineure
            }
        }
    }

    public void deleteStudent(String id) throws SQLException {
        String sql = "DELETE FROM etudiant WHERE num_etudiant=?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        }
    }

    public Student getStudentById(String id) {
        String sql = "SELECT * FROM etudiant WHERE UPPER(num_etudiant) = UPPER(?)";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToStudent(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Student mapResultSetToStudent(ResultSet rs) throws SQLException {
        return new Student(
            rs.getString("num_etudiant"),
            rs.getString("nom"),
            rs.getString("prenoms"),
            rs.getString("niveau"),
            rs.getString("adr_email")
        );
    }
    
    /**
     * SECTION QUESTIONS (Table: qcm)
     */
    public List<Question> getAllQuestions() {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM qcm";
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            ResultSetMetaData metaData = rs.getMetaData();
            Map<String, String> columnMap = getColumnMap(metaData);
            boolean hasOptionsCount = columnMap.containsKey("options_count");

            while (rs.next()) {
                list.add(mapResultSetToQuestion(rs, columnMap, hasOptionsCount));
            }
        } catch (SQLException e) { 
            System.err.println("Database error in getAllQuestions: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    public void addQuestion(Question q) throws SQLException {
        Map<String, String> colMap = getTableColumns("qcm");
        boolean hasOptions = colMap.containsKey("options_count");
        
        String colQ = findCol(colMap, "question", "quest");
        String colR1 = findCol(colMap, "reponse1", "rep1", "r1");
        String colR2 = findCol(colMap, "reponse2", "rep2", "r2");
        String colR3 = findCol(colMap, "reponse3", "rep3", "r3");
        String colR4 = findCol(colMap, "reponse4", "rep4", "r4");
        String colCorrect = findCol(colMap, "bonne_reponse_index", "bonne_reponse");
        String colModule = findCol(colMap, "module", "niveau");

        StringBuilder sql = new StringBuilder("INSERT INTO `qcm` (");
        sql.append("`").append(colQ).append("`, ");
        sql.append("`").append(colR1).append("`, ");
        sql.append("`").append(colR2).append("`, ");
        sql.append("`").append(colR3).append("`, ");
        sql.append("`").append(colR4).append("`, ");
        sql.append("`").append(colCorrect).append("`, ");
        sql.append("`").append(colModule).append("` ");
        
        if (hasOptions) sql.append(", `options_count` ");
        
        sql.append(") VALUES (?, ?, ?, ?, ?, ?, ?");
        if (hasOptions) sql.append(", ?");
        sql.append(")");

        String finalSql = sql.toString();

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(finalSql)) {
            ps.setString(1, q.getText());
            ps.setString(2, q.getR1());
            ps.setString(3, q.getR2());
            ps.setString(4, q.getR3());
            ps.setString(5, q.getR4());
            ps.setInt(6, q.getCorrectIndex());
            ps.setString(7, q.getModule());
            if (hasOptions) ps.setInt(8, q.getOptionsCount());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Erreur addQuestion SQL: " + finalSql);
            System.err.println("Erreur addQuestion: " + e.getMessage());
            throw e;
        }
    }

    public void updateQuestion(Question q) throws SQLException {
        Map<String, String> colMap = getTableColumns("qcm");
        boolean hasOptions = colMap.containsKey("options_count");
        
        String colQ = findCol(colMap, "question", "quest");
        String colR1 = findCol(colMap, "reponse1", "rep1", "r1");
        String colR2 = findCol(colMap, "reponse2", "rep2", "r2");
        String colR3 = findCol(colMap, "reponse3", "rep3", "r3");
        String colR4 = findCol(colMap, "reponse4", "rep4", "r4");
        String colCorrect = findCol(colMap, "bonne_reponse_index", "bonne_reponse");
        String colModule = findCol(colMap, "module", "niveau");
        String colId = findCol(colMap, "num_quest", "id", "num");

        StringBuilder sql = new StringBuilder("UPDATE `qcm` SET ");
        sql.append("`").append(colQ).append("`=?, ");
        sql.append("`").append(colR1).append("`=?, ");
        sql.append("`").append(colR2).append("`=?, ");
        sql.append("`").append(colR3).append("`=?, ");
        sql.append("`").append(colR4).append("`=?, ");
        sql.append("`").append(colCorrect).append("`=?, ");
        sql.append("`").append(colModule).append("`=?");
        
        if (hasOptions) sql.append(", `options_count`=?");
        sql.append(" WHERE `").append(colId).append("`=?");

        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, q.getText());
            ps.setString(2, q.getR1());
            ps.setString(3, q.getR2());
            ps.setString(4, q.getR3());
            ps.setString(5, q.getR4());
            ps.setInt(6, q.getCorrectIndex());
            ps.setString(7, q.getModule());
            if (hasOptions) {
                ps.setInt(8, q.getOptionsCount());
                ps.setInt(9, q.getId());
            } else {
                ps.setInt(8, q.getId());
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Erreur updateQuestion SQL: " + sql.toString());
            System.err.println("Erreur updateQuestion: " + e.getMessage());
            throw e;
        }
    }

    public void deleteQuestion(int id) throws SQLException {
        String sql = "DELETE FROM qcm WHERE num_quest = ?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private boolean hasColumn(String table, String column) {
        try (Connection conn = DatabaseManager.getConnection();
             ResultSet rs = conn.getMetaData().getColumns(null, null, table, column)) {
            return rs.next();
        } catch (Exception e) {
            return false;
        }
    }

    public List<Question> getQuestionsByLevel(String level) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM qcm WHERE module LIKE ? OR TRIM(module) = ?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String trimmedLevel = (level != null) ? level.trim() : "";
            ps.setString(1, "%" + trimmedLevel + "%");
            ps.setString(2, trimmedLevel);
            
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                Map<String, String> columnMap = getColumnMap(metaData);
                boolean hasOptionsCount = columnMap.containsKey("options_count");

                while (rs.next()) {
                    list.add(mapResultSetToQuestion(rs, columnMap, hasOptionsCount));
                }
            }
        } catch (SQLException e) { 
            System.err.println("Database error in getQuestionsByLevel: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    public List<Question> getRandomQuestions(String level) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM qcm";
        if (level != null && !level.isEmpty()) {
            sql += " WHERE module LIKE ? OR TRIM(module) = ?";
        }
        sql += " ORDER BY RAND() LIMIT 10";
        
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            if (level != null && !level.isEmpty()) {
                pstmt.setString(1, "%" + level + "%");
                pstmt.setString(2, level);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
            
            ResultSetMetaData metaData = rs.getMetaData();
            Map<String, String> columnMap = getColumnMap(metaData);
            boolean hasOptionsCount = columnMap.containsKey("options_count");

            while (rs.next()) {
                list.add(mapResultSetToQuestion(rs, columnMap, hasOptionsCount));
            }
        }
    } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * SECTION EXAMENS ET RÉSULTATS
     */
    public void saveExamResult(String numEtudiant, int note, Integer sessionId, String sessionDate) {
        String sql = "INSERT INTO examen (num_etudiant, annee_univ, note, session_id, date_examen) VALUES (?, ?, ?, ?, ?)";
        String dbPath = "Unknown";
        
        try (Connection conn = DatabaseManager.getConnection()) {
            dbPath = conn.getMetaData().getURL();
            System.out.println(">>> SAVE RESULT START for " + numEtudiant + " | Score: " + note + " | DB: " + dbPath);
            
            // Verification of student existence
            try (PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM etudiant WHERE UPPER(num_etudiant) = UPPER(?)")) {
                check.setString(1, numEtudiant);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        System.err.println("!!! WARNING: Student ID " + numEtudiant + " is NOT in the 'etudiant' table. Result will be saved but orphaned.");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, numEtudiant);
                ps.setString(2, (sessionDate != null && !sessionDate.isEmpty()) ? sessionDate : "2023-2024");
                ps.setInt(3, note);
                if (sessionId != null) ps.setInt(ps.getParameterMetaData().getParameterCount() == 5 ? 4 : 4, sessionId);
                else ps.setNull(4, java.sql.Types.INTEGER);
                
                String now = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                ps.setString(5, now);
                
                int affected = ps.executeUpdate();
                System.out.println(">>> SQL EXEC SUCCESS. Rows affected: " + affected);
                
                // Confirm write visibility
                try (Statement st = conn.createStatement();
                     ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM examen")) {
                    if (rs.next()) {
                        System.out.println(">>> TOTAL ROWS in 'examen' now: " + rs.getInt(1));
                    }
                }
            }
        } catch (SQLException e) { 
            System.err.println("!!! DATABASE ERROR in saveExamResult: " + e.getMessage());
            e.printStackTrace(); 
        }
    }

    public void saveExamResult(String numEtudiant, int note, Integer sessionId) {
        saveExamResult(numEtudiant, note, sessionId, null);
    }

    public List<ExamResult> getRankedResults() {
        List<ExamResult> list = new ArrayList<>();
        // Query with COALESCE to avoid losing results if student metadata is missing
        String sql = "SELECT e.num_etudiant, et.nom, et.prenoms, e.note, " +
                     "COALESCE(et.niveau, 'L1') as niveau, e.date_examen, e.annee_univ " +
                     "FROM examen e LEFT JOIN etudiant et ON UPPER(TRIM(e.num_etudiant)) = UPPER(TRIM(et.num_etudiant)) " +
                     "ORDER BY e.note DESC, e.date_examen DESC";
        
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            System.out.println("DEBUG Database: Executing query to fetch ranked results...");
            int count = 0;
            while (rs.next()) {
                count++;
                String studentId = rs.getString("num_etudiant");
                String nom = rs.getString("nom");
                String prenoms = rs.getString("prenoms");
                String niveau = rs.getString("niveau");
                int note = rs.getInt("note");
                
                System.out.println("DEBUG Ranking Row " + count + ": ID=" + studentId + " | Note=" + note + " | Level=" + niveau);

                String displayName;
                if (nom != null || prenoms != null) {
                    displayName = (prenoms != null ? prenoms + " " : "") + (nom != null ? nom : "");
                } else {
                    displayName = "Candidat (" + (studentId != null ? studentId : "INCONNU") + ")";
                }
                
                String dateExRaw = rs.getString("date_examen");
                if (dateExRaw == null || dateExRaw.isEmpty()) {
                    dateExRaw = rs.getString("annee_univ");
                }
                
                String dateEx = "N/A";
                if (dateExRaw != null && !dateExRaw.isEmpty()) {
                    dateEx = dateExRaw.trim();
                    try {
                        if (dateEx.length() == 10) dateEx += " 00:00:00";
                        else if (dateEx.length() == 16) dateEx += ":00";
                        else if (dateEx.length() > 19) dateEx = dateEx.substring(0, 19);
                        else if (dateEx.length() < 10) {
                            // Fallback pour "2023-2024" ou autres formats courts
                             dateEx = java.time.LocalDate.now().toString() + " 00:00:00";
                        }
                    } catch (Exception e) {}
                }

                // Clean-up niveau (already defined at line 632)
                if (niveau != null) niveau = niveau.trim();
                if (niveau == null || niveau.isEmpty()) niveau = "L1";

                list.add(new ExamResult(studentId, displayName, note, niveau, dateEx));
            }
            System.out.println("Retrieved " + list.size() + " ranked results.");
        } catch (SQLException e) { 
            System.err.println("Database error in getRankedResults: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public List<Examen> getAllResults() {
        List<Examen> list = new ArrayList<>();
        String sql = "SELECT e.*, et.nom, et.prenoms FROM examen e LEFT JOIN etudiant et ON UPPER(e.num_etudiant) = UPPER(et.num_etudiant) ORDER BY note DESC";
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String dateEx = rs.getString("date_examen");
                if (dateEx == null) dateEx = rs.getString("annee_univ"); // fallback
                
                Examen ex = new Examen(rs.getInt("num_exam"), rs.getString("num_etudiant"), rs.getString("annee_univ"), rs.getInt("note"), dateEx);
                String nom = rs.getString("nom");
                String prenoms = rs.getString("prenoms");
                ex.setNomEtudiant((nom != null) ? (prenoms != null ? prenoms + " " + nom : nom) : "Candidat Libre");
                list.add(ex);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Map<String, Object> getActiveSession(String level) {
        refreshSessionsStatus();
        // On récupère toutes les sessions Pending/En cours pour ce niveau précisément
        String sql = "SELECT * FROM sessions WHERE status IN ('En attente', 'En cours') AND UPPER(TRIM(level)) = UPPER(TRIM(?)) ORDER BY date DESC, time DESC";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, level);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String sDate = rs.getString("date");
                    String sTime = rs.getString("time");
                    int sDuration = rs.getInt("duration");
                    String status = rs.getString("status");
                    
                    // Une session "En attente" est considérée comme "Active" si on est dans la fenêtre de connexion
                    if ("En cours".equals(status) || isSessionAvailable(sDate, sTime, sDuration)) {
                        Map<String, Object> s = new HashMap<>();
                        s.put("id", rs.getInt("id"));
                        s.put("level", rs.getString("level"));
                        s.put("duration", sDuration);
                        s.put("title", rs.getString("title"));
                        s.put("date", sDate);
                        s.put("time", sTime);
                        s.put("status", status);
                        return s;
                    }
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean hasParticipated(String studentId, int sessionId) {
        String sql = "SELECT COUNT(*) FROM examen WHERE UPPER(num_etudiant) = UPPER(?) AND session_id = ?";
        try (Connection conn = DatabaseManager.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, studentId);
            ps.setInt(2, sessionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public void refreshSessionsStatus() {
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM sessions")) {
            
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String sDate = rs.getString("date");
                String sTime = rs.getString("time");
                int duration = rs.getInt("duration");
                String currentStatus = rs.getString("status");
                
                String newStatus = currentStatus;
                try {
                    java.time.LocalDateTime start = java.time.LocalDateTime.parse(sDate + " " + sTime, formatter);
                    java.time.LocalDateTime end = start.plusMinutes(duration);
                    
                    if (now.isBefore(start)) {
                        newStatus = "En attente";
                    } else if (now.isAfter(end)) {
                        newStatus = "Terminé";
                    } else {
                        newStatus = "En cours";
                    }
                    
                    if (!newStatus.equals(currentStatus)) {
                        try (PreparedStatement uPs = conn.prepareStatement("UPDATE sessions SET status = ? WHERE id = ?")) {
                            uPs.setString(1, newStatus);
                            uPs.setInt(2, id);
                            uPs.executeUpdate();
                        }
                    }
                } catch (Exception e) {}
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private boolean hasTable(String table) {
        try (Connection conn = DatabaseManager.getConnection();
             ResultSet rs = conn.getMetaData().getTables(null, null, table, null)) {
            return rs.next();
        } catch (Exception e) { return false; }
    }

    private boolean isSessionAvailable(String date, String time, int durationMinutes) {
        try {
            // Formats attendus: date="2023-10-25" time="14:30"
            String dateTimeStr = date + " " + time;
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            java.time.LocalDateTime start = java.time.LocalDateTime.parse(dateTimeStr, formatter);
            
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            
            // On autorise la connexion 30 minutes avant le début (pour s'installer)
            java.time.LocalDateTime entryWindowStart = start.minusMinutes(30);
            // On considère qu'une session expire si on a dépassé l'heure de début + durée + 1h de marge
            java.time.LocalDateTime entryWindowEnd = start.plusMinutes(durationMinutes + 60); 
            
            return now.isAfter(entryWindowStart) && now.isBefore(entryWindowEnd);
        } catch (Exception e) {
            // En cas d'erreur de parsing (ex: date vide), on ne bloque pas par défaut
            return true; 
        }
    }
}
