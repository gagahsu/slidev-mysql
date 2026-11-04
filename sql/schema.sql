-- 動態問卷系統 schema（對應 SURVEY-SPEC.md §3；MySQL 8.4）
SET NAMES utf8mb4;
DROP DATABASE IF EXISTS dynamic_survey;
CREATE DATABASE dynamic_survey
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE dynamic_survey;

CREATE TABLE users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(50)  NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  password   VARCHAR(100) NOT NULL,
  phone      VARCHAR(20),
  role       VARCHAR(10)  NOT NULL DEFAULT 'USER',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN'))
) ENGINE=InnoDB;

CREATE TABLE surveys (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(50) NOT NULL,
  description VARCHAR(300),
  start_date  DATE        NOT NULL,
  end_date    DATE        NOT NULL,
  published   TINYINT     NOT NULL DEFAULT 0,
  created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_survey_dates CHECK (end_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE questions (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  survey_id   INT          NOT NULL,
  title       VARCHAR(200) NOT NULL,
  type        VARCHAR(10)  NOT NULL,
  required    TINYINT      NOT NULL DEFAULT 0,
  order_index INT          NOT NULL,
  INDEX idx_questions_survey (survey_id),
  CONSTRAINT chk_question_type CHECK (type IN ('SINGLE', 'MULTI', 'TEXT')),
  FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE options (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT          NOT NULL,
  label       VARCHAR(100) NOT NULL,
  order_index INT          NOT NULL,
  INDEX idx_options_question (question_id),
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE survey_responses (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  survey_id    INT          NOT NULL,
  user_id      INT,
  name         VARCHAR(50)  NOT NULL,
  phone        VARCHAR(20)  NOT NULL,
  email        VARCHAR(100) NOT NULL,
  age          INT,
  submitted_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_survey_email (survey_id, email),
  CONSTRAINT chk_response_age CHECK (age IS NULL OR age BETWEEN 1 AND 120),
  FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE response_answers (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  response_id INT NOT NULL,
  question_id INT NOT NULL,
  answer_text VARCHAR(500),
  INDEX idx_answers_response (response_id),
  INDEX idx_answers_question (question_id),
  FOREIGN KEY (response_id) REFERENCES survey_responses(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id)        ON DELETE CASCADE
) ENGINE=InnoDB;
