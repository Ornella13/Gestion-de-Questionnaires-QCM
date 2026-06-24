-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 24, 2026 at 10:44 AM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 8.0.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gestion_questionnaire`
--

-- --------------------------------------------------------

--
-- Table structure for table `details_reponses`
--

CREATE TABLE `details_reponses` (
  `num_exam` int(11) NOT NULL,
  `num_quest` int(11) NOT NULL,
  `reponse_etudiant_index` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `etudiant`
--

CREATE TABLE `etudiant` (
  `num_etudiant` varchar(50) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenoms` varchar(100) NOT NULL,
  `niveau` varchar(10) DEFAULT NULL,
  `adr_email` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `etudiant`
--

INSERT INTO `etudiant` (`num_etudiant`, `nom`, `prenoms`, `niveau`, `adr_email`) VALUES
('100H-Tol', 'Camus', 'Lane', 'M1', 'camus@gmail.com'),
('300H-Tol', 'Claudia', 'Rataveasy', 'M2', 'claudiaRataveasy@gmail.com'),
('502H-Tol', 'Claudio', 'Faniry', 'L3', 'claudio@gmail.com'),
('700H-Tol', 'Mia', 'Valerie', 'L2', 'valerie@gmail.com'),
('901H-Tol', 'Marianah', 'Bella', 'L1', 'marianah@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `examen`
--

CREATE TABLE `examen` (
  `num_exam` int(11) NOT NULL,
  `num_etudiant` varchar(50) DEFAULT NULL,
  `annee_univ` varchar(50) NOT NULL,
  `note` int(11) DEFAULT 0,
  `session_id` int(11) DEFAULT NULL,
  `date_examen` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `examen`
--

INSERT INTO `examen` (`num_exam`, `num_etudiant`, `annee_univ`, `note`, `session_id`, `date_examen`) VALUES
(9, '502H-Tol', '2026-05-18', 8, NULL, '2026-05-18 14:41:25'),
(10, '502H-Tol', '2026-06-24', 8, 7, '2026-06-24 11:43:11');

-- --------------------------------------------------------

--
-- Table structure for table `qcm`
--

CREATE TABLE `qcm` (
  `num_quest` int(11) NOT NULL,
  `question` text NOT NULL,
  `reponse1` text NOT NULL,
  `reponse2` text NOT NULL,
  `reponse3` text NOT NULL,
  `reponse4` text NOT NULL,
  `bonne_reponse_index` int(11) DEFAULT NULL,
  `module` varchar(100) DEFAULT NULL,
  `options_count` int(11) DEFAULT 4
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `qcm`
--

INSERT INTO `qcm` (`num_quest`, `question`, `reponse1`, `reponse2`, `reponse3`, `reponse4`, `bonne_reponse_index`, `module`, `options_count`) VALUES
(1, 'Que signifie HTML ?\r\n. ', 'Hyper Trainer Marking Language', 'Hyper Text Markup Language', 'High Text Markdown Language', 'Hyper Text Marketing Language', 2, 'L3', 4),
(2, 'Quel langage est principalement utilisé pour styliser une page web ?\r\n', 'Python', 'Java', 'CSS', 'SQL', 3, 'L3', 4),
(3, 'Quelle base de données est relationnelle ?\r\n', 'MongoDB', 'Firebase', 'Firebase', 'MySQL', 4, 'L3', 4),
(4, 'Quel symbole est utilisé pour les commentaires en PHP ?\r\n\r\n', '<!-- -->', ' //', '##', '', 2, 'L3', 4),
(5, 'Que signifie CPU ?\r\n', ' Central Process Unit', ' Central Processing Unit', 'Computer Personal Unit', 'Central Program Utility', 2, 'L3', 4),
(6, 'couleur du soleil?', 'rouge', 'verte', 'noire', 'jaune', 4, 'L3', 4),
(7, 'couleur du nuage', 'vert', 'noire', 'blanche', 'violet', 3, 'L3', 4),
(8, 'couleur de la mer', 'rouge', 'vert', 'marron', 'bleu', 4, 'L3', 4),
(9, ' la couleur du ciel', 'verte', 'vert', 'marron', 'bleu', 4, 'L1', 4),
(13, ' Que signifie PC ?\r\n\r\n', ' Personal Computer', 'Private Computer', ' Program Computer', 'Public Computer', 1, 'L1', 4),
(14, ' Quel logiciel sert à naviguer sur Internet ?', 'Word', 'Chrome ', 'Excel', 'Paint', 2, 'L1', 4),
(15, ' Quel langage est utilisé pour créer des pages web ?', 'HTML', 'SQL', ' Java', ' Python', 1, 'L1', 4),
(17, 'Quelle est la capitale de la France ?\r\n', 'Marseille', 'Lyon', ' Paris', ' Nice', 3, 'L1', 4),
(18, 'Quel appareil permet d’imprimer des documents ?\r\n', 'Scanner', 'Clavier', 'Imprimante', ' Souris', 3, 'L3', 4),
(19, 'Quel est le résultat de 9 × 3 ?', '18', ' 21', '27', '30', 3, 'L2', 4),
(20, ' Quelle touche sert à supprimer vers la gauche ?\r\n\r\n', 'Shift', 'Backspace', ' Ctrl ', ' Ctrl Alt', 2, 'L2', 4),
(21, 'Quel animal est appelé le roi de la jungle ?\r\n', 'Tigre', ' Lion Éléphant', ' Éléphant', 'Ours', 2, 'L2', 4),
(22, 'Quelle planète est connue comme la planète rouge ?\r\n', 'Jupiter', ' Mars', 'Saturne', 'Vénus', 2, 'L2', 4),
(23, 'Combien y a-t-il de jours dans une semaine ?', '5', '6', '7', '8', 3, 'M1', 4),
(24, ' Quel est le contraire de “grand” ?\r\n', 'Haut', 'Petit', ' Large', ' Long', 2, 'M1', 4),
(25, ' Quel logiciel sert à écrire des documents ?', ' Excel', 'Word', 'Paint', ' Chrome', 2, 'M1', 4),
(26, 'Quelle couleur obtient-on avec rouge + jaune ?\r\n\r\n', ' Vert', 'Orange', ' Bleu', ' Noir', 2, 'L1', 4),
(27, 'Quel composant affiche les images sur un ordinateur ?', 'Clavier', 'Souris', 'Écran', 'Scanner', 3, 'M2', 4),
(28, 'Quel est le premier mois de l’année ?\r\n', 'Février', 'Janvier', 'Mars', 'Avril', 2, 'M2', 4),
(29, 'Quel appareil prend des photos ?\r\n\r\n', 'Caméra', 'Imprimante', 'Écran', ' Routeur', 1, 'M2', 4),
(30, 'Quel est le plus grand océan du monde ?', 'Atlantique', ' Indien', 'Pacifique', 'Arctique', 3, 'M2', 4),
(31, 'Quelle est la langue officielle de Madagascar ?', ' Espagnol', ' Malagasy', ' Portugais', 'Allemand', 2, 'M2', 4),
(32, 'Quel symbole est utilisé pour l’addition ?\r\n', '-', ' ×', '+', '÷', 3, 'M1', 4),
(33, 'Quel appareil sert à écouter de la musique ?\r\n', 'Casque', ' Scanner', ' Clavier', 'Routeur', 1, 'M1', 4),
(34, 'Quelle saison vient après l’été ?\r\n', ' Printemp', 'D. Saison sèche', 'Automne', 'Printemps', 2, 'L3', 4);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `level` varchar(50) DEFAULT NULL,
  `date` varchar(50) NOT NULL,
  `time` varchar(50) NOT NULL,
  `duration` int(11) DEFAULT 30,
  `students` varchar(255) NOT NULL,
  `status` varchar(50) DEFAULT 'En attente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `title`, `level`, `date`, `time`, `duration`, `students`, `status`) VALUES
(7, 'Examen Final', 'L3', '2026-06-24', '11:41', 5, 'tous les etudiants L3', 'En cours');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `details_reponses`
--
ALTER TABLE `details_reponses`
  ADD PRIMARY KEY (`num_exam`,`num_quest`),
  ADD KEY `num_quest` (`num_quest`);

--
-- Indexes for table `etudiant`
--
ALTER TABLE `etudiant`
  ADD PRIMARY KEY (`num_etudiant`),
  ADD UNIQUE KEY `adr_email` (`adr_email`);

--
-- Indexes for table `examen`
--
ALTER TABLE `examen`
  ADD PRIMARY KEY (`num_exam`),
  ADD KEY `fk_student` (`num_etudiant`),
  ADD KEY `fk_session` (`session_id`);

--
-- Indexes for table `qcm`
--
ALTER TABLE `qcm`
  ADD PRIMARY KEY (`num_quest`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `examen`
--
ALTER TABLE `examen`
  MODIFY `num_exam` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `qcm`
--
ALTER TABLE `qcm`
  MODIFY `num_quest` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `details_reponses`
--
ALTER TABLE `details_reponses`
  ADD CONSTRAINT `details_reponses_ibfk_1` FOREIGN KEY (`num_exam`) REFERENCES `examen` (`num_exam`) ON DELETE CASCADE,
  ADD CONSTRAINT `details_reponses_ibfk_2` FOREIGN KEY (`num_quest`) REFERENCES `qcm` (`num_quest`);

--
-- Constraints for table `examen`
--
ALTER TABLE `examen`
  ADD CONSTRAINT `fk_session` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_student` FOREIGN KEY (`num_etudiant`) REFERENCES `etudiant` (`num_etudiant`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
