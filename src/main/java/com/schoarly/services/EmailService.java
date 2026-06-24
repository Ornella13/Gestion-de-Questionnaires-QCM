package com.schoarly.services;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailService {
    private final String username;
    private final String password;
    private final String host;
    private final String port;

    public EmailService() {
        // Charge les variables d'environnement
        this.host = System.getenv("SMTP_HOST") != null ? System.getenv("SMTP_HOST") : "smtp.gmail.com";
        this.port = System.getenv("SMTP_PORT") != null ? System.getenv("SMTP_PORT") : "587";
        this.username = System.getenv("SMTP_USER"); 
        this.password = System.getenv("SMTP_PASS"); 
    }

    public void sendResultEmail(String recipientEmail, String studentName, int score) {
        System.out.println("Tentative d'envoi d'email à : " + recipientEmail);
        
        if (username == null || password == null) {
            System.err.println("ERREUR : SMTP_USER ou SMTP_PASS non défini.");
            return;
        }

        if (recipientEmail == null || recipientEmail.trim().isEmpty()) {
            System.err.println("ERREUR : L'email du destinataire est vide.");
            return;
        }

        Properties prop = new Properties();
        prop.put("mail.smtp.auth", "true");
        prop.put("mail.smtp.starttls.enable", "true");
        prop.put("mail.smtp.host", host);
        prop.put("mail.smtp.port", port);
        prop.put("mail.smtp.ssl.trust", host);
        prop.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(prop, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username, "Zenith Education App"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Votre résultat d'examen - Zenith Education");

            String content = "Bonjour " + studentName + ",\n\n" +
                             "Vous avez terminé votre examen.\n" +
                             "Votre note finale est de : " + score + " / 10.\n\n" +
                             "Cordialement,\nL'équipe Scolarly";

            message.setText(content);

            // Envoi dans un thread séparé
            new Thread(() -> {
                try {
                    Transport.send(message);
                    System.out.println("Email envoyé avec succès à " + recipientEmail);
                } catch (Exception e) {
                    System.err.println("ERREUR lors de l'envoi : " + e.getMessage());
                    e.printStackTrace();
                }
            }).start();

        } catch (Exception e) {
            System.err.println("ERREUR lors de la préparation : " + e.getMessage());
            e.printStackTrace();
        }
    }
}