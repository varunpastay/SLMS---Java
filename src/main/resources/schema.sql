-- SLMS Database Schema
-- Run this script in MySQL before starting the application.

CREATE DATABASE IF NOT EXISTS slms_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE slms_db;

-- Users (roles: ADMIN, TEACHER, STUDENT)
CREATE TABLE IF NOT EXISTS users (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    username     VARCHAR(150) UNIQUE NOT NULL,
    email        VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role         ENUM('ADMIN','TEACHER','STUDENT') NOT NULL DEFAULT 'STUDENT',
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    bio          TEXT,
    profile_pic  VARCHAR(255),
    is_active    BOOLEAN DEFAULT TRUE,
    date_joined  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE IF NOT EXISTS categories (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50)
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    teacher_id   INT NOT NULL,
    category_id  INT,
    thumbnail    VARCHAR(255),
    youtube_url  VARCHAR(500),
    is_published BOOLEAN DEFAULT FALSE,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id)  REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Course Materials
CREATE TABLE IF NOT EXISTS course_materials (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    course_id     INT NOT NULL,
    title         VARCHAR(255),
    file_path     VARCHAR(255),
    material_type VARCHAR(50),
    uploaded_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Enrollments
CREATE TABLE IF NOT EXISTS enrollments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    course_id   INT NOT NULL,
    enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed   BOOLEAN DEFAULT FALSE,
    UNIQUE KEY unique_enrollment (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id)
);

-- Assignments
CREATE TABLE IF NOT EXISTS assignments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    course_id   INT NOT NULL,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    due_date    DATETIME,
    max_marks   INT DEFAULT 100,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Submissions
CREATE TABLE IF NOT EXISTS submissions (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id  INT NOT NULL,
    student_id     INT NOT NULL,
    file_path      VARCHAR(255),
    submitted_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    marks_obtained DECIMAL(5,2),
    feedback       TEXT,
    graded_at      DATETIME,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id)    REFERENCES users(id)
);

-- Quizzes
CREATE TABLE IF NOT EXISTS quizzes (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    course_id           INT NOT NULL,
    title               VARCHAR(255) NOT NULL,
    description         TEXT,
    time_limit_minutes  INT DEFAULT 30,
    pass_percentage     INT DEFAULT 60,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Quiz Questions
CREATE TABLE IF NOT EXISTS quiz_questions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id         INT NOT NULL,
    question_text   TEXT NOT NULL,
    option_a        VARCHAR(500),
    option_b        VARCHAR(500),
    option_c        VARCHAR(500),
    option_d        VARCHAR(500),
    correct_option  CHAR(1),
    marks           INT DEFAULT 1,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);

-- Quiz Attempts
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id      INT NOT NULL,
    student_id   INT NOT NULL,
    score        DECIMAL(5,2),
    passed       BOOLEAN,
    attempted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id)    REFERENCES quizzes(id),
    FOREIGN KEY (student_id) REFERENCES users(id)
);

-- Quiz Answers
CREATE TABLE IF NOT EXISTS quiz_answers (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    attempt_id      INT NOT NULL,
    question_id     INT NOT NULL,
    selected_option CHAR(1),
    FOREIGN KEY (attempt_id)  REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES quiz_questions(id)
);

-- Forum Posts
CREATE TABLE IF NOT EXISTS forum_posts (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    course_id  INT,
    author_id  INT NOT NULL,
    title      VARCHAR(255) NOT NULL,
    body       TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Forum Comments
CREATE TABLE IF NOT EXISTS forum_comments (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    post_id    INT NOT NULL,
    author_id  INT NOT NULL,
    body       TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id)   REFERENCES forum_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Chat Messages
CREATE TABLE IF NOT EXISTS chat_messages (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT NOT NULL,
    receiver_id INT NOT NULL,
    message     TEXT NOT NULL,
    sent_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_read     BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id)   REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    message    TEXT NOT NULL,
    is_read    BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Feedback
CREATE TABLE IF NOT EXISTS feedback (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    teacher_id INT NOT NULL,
    course_id  INT NOT NULL,
    rating     INT CHECK (rating BETWEEN 1 AND 5),
    comment    TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id),
    UNIQUE KEY unique_feedback (student_id, course_id)
);

-- Certificates
CREATE TABLE IF NOT EXISTS certificates (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    student_id       INT NOT NULL,
    course_id        INT NOT NULL,
    issued_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    certificate_code VARCHAR(50) UNIQUE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id),
    UNIQUE KEY unique_cert (student_id, course_id)
);

-- Announcements (teacher posts to enrolled students)
CREATE TABLE IF NOT EXISTS announcements (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    course_id  INT NOT NULL,
    author_id  INT NOT NULL,
    title      VARCHAR(255) NOT NULL,
    body       TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Password reset tokens
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    token      VARCHAR(64) UNIQUE NOT NULL,
    expires_at DATETIME NOT NULL,
    used       BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Assignment rubric items
CREATE TABLE IF NOT EXISTS rubric_items (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    criterion     VARCHAR(255) NOT NULL,
    max_marks     INT NOT NULL,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

-- Per-criterion grades for a submission
CREATE TABLE IF NOT EXISTS rubric_grades (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    submission_id  INT NOT NULL,
    rubric_item_id INT NOT NULL,
    marks_awarded  DECIMAL(5,2) NOT NULL DEFAULT 0,
    UNIQUE KEY unique_rubric_grade (submission_id, rubric_item_id),
    FOREIGN KEY (submission_id)  REFERENCES submissions(id) ON DELETE CASCADE,
    FOREIGN KEY (rubric_item_id) REFERENCES rubric_items(id) ON DELETE CASCADE
);

-- Activity / audit log
CREATE TABLE IF NOT EXISTS activity_logs (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT,
    action     VARCHAR(100) NOT NULL,
    details    TEXT,
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ── Teacher Registration Requests ────────────────────────────────────────────
-- Holds teacher sign-up requests until an admin approves or rejects them

CREATE TABLE IF NOT EXISTS teacher_requests (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    username      VARCHAR(150) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    reason        TEXT,
    status        ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
    reviewed_by   INT,
    reviewed_at   DATETIME,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ── OMR Evaluation Tables ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS omr_evaluations (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    teacher_id        INT NOT NULL,
    course_id         INT,
    title             VARCHAR(255) NOT NULL,
    total_questions   INT NOT NULL,
    marks_per_correct DECIMAL(5,2) DEFAULT 1.00,
    negative_marks    DECIMAL(5,2) DEFAULT 0.00,
    answer_key        TEXT NOT NULL,
    total_marks       DECIMAL(7,2) NOT NULL,
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS omr_results (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    evaluation_id       INT NOT NULL,
    student_id          INT,
    student_identifier  VARCHAR(255) NOT NULL,
    student_name        VARCHAR(255),
    responses           TEXT NOT NULL,
    correct_count       INT DEFAULT 0,
    wrong_count         INT DEFAULT 0,
    unattempted_count   INT DEFAULT 0,
    marks_obtained      DECIMAL(7,2) DEFAULT 0,
    percentage          DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (evaluation_id) REFERENCES omr_evaluations(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id)    REFERENCES users(id) ON DELETE SET NULL
);

-- ── NoteWise Tables ──────────────────────────────────────────────────────────

-- Stores each note-upload analysis session per student
CREATE TABLE IF NOT EXISTS notewise_sessions (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    image_path     VARCHAR(255),
    topic          VARCHAR(255),
    difficulty     VARCHAR(50),
    study_minutes  INT DEFAULT 10,
    extracted_text MEDIUMTEXT,
    concepts       TEXT,
    summary        TEXT,
    explanation    MEDIUMTEXT,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Stores AI-generated quiz questions (answers kept server-side)
CREATE TABLE IF NOT EXISTS notewise_quizzes (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    session_id     INT NOT NULL,
    student_id     INT NOT NULL,
    questions_json MEDIUMTEXT NOT NULL,
    score          INT DEFAULT 0,
    total          INT DEFAULT 0,
    completed      BOOLEAN DEFAULT FALSE,
    attempted_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES notewise_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(id)
);

-- XP, streaks, and badge progress per student
CREATE TABLE IF NOT EXISTS notewise_xp (
    student_id  INT PRIMARY KEY,
    total_xp    INT DEFAULT 0,
    streak_days INT DEFAULT 0,
    last_active DATE,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── End NoteWise Tables ───────────────────────────────────────────────────

-- ── Attendance ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL,
    course_id       INT NOT NULL,
    attendance_date DATE NOT NULL,
    status          ENUM('PRESENT','ABSENT','LATE') NOT NULL DEFAULT 'PRESENT',
    marked_by       INT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_attendance (student_id, course_id, attendance_date),
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (marked_by)  REFERENCES users(id) ON DELETE SET NULL
);

-- ── Flashcards ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS flashcards (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    course_id   INT,
    front_text  TEXT NOT NULL,
    back_text   TEXT NOT NULL,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE SET NULL
);

-- ── Study Goals ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS study_goals (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    course_id     INT,
    title         VARCHAR(255) NOT NULL,
    subject       VARCHAR(255),
    target_date   DATE,
    daily_minutes INT DEFAULT 60,
    status        ENUM('IN_PROGRESS','COMPLETED') DEFAULT 'IN_PROGRESS',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE SET NULL
);

-- ── Study Sessions ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS study_sessions (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    student_id       INT NOT NULL,
    course_id        INT,
    date             DATE NOT NULL,
    minutes_studied  INT NOT NULL DEFAULT 0,
    subject          VARCHAR(255),
    notes            TEXT,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE SET NULL
);

-- ── Broadcasts (Admin Announcements) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS broadcasts (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT NOT NULL,
    title       VARCHAR(255) NOT NULL,
    message     TEXT NOT NULL,
    target_role ENUM('ALL','STUDENT','TEACHER','ADMIN') DEFAULT 'ALL',
    sent_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Course Approval Columns ──────────────────────────────────────────────────
ALTER TABLE courses ADD COLUMN IF NOT EXISTS approval_status ENUM('DRAFT','PENDING','APPROVED','REJECTED') DEFAULT 'DRAFT';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS rejection_note TEXT;

-- ── Seed: default admin account (password: Admin@123)
INSERT IGNORE INTO users (username, email, password_hash, role, first_name, last_name, is_active)
VALUES ('admin', 'admin@slms.com',
        '$2a$12$RpCnYHJXq.E6lQBJTLrpGOHqBFuXFGMFd4RO5oiKjH9hJwEv7yAjq',
        'ADMIN', 'System', 'Admin', TRUE);

-- Seed: sample categories
INSERT IGNORE INTO categories (name, icon) VALUES
  ('Programming',   'bi-code-slash'),
  ('Mathematics',   'bi-calculator'),
  ('Science',       'bi-flask'),
  ('Languages',     'bi-translate'),
  ('Business',      'bi-briefcase'),
  ('Design',        'bi-palette'),
  ('Data Science',  'bi-bar-chart'),
  ('Other',         'bi-grid');
