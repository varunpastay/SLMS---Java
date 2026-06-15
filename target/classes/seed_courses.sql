-- =============================================================
-- SLMS Seed Data: Teacher Ravi Shastry + 10 Courses
-- Run against slms_db AFTER running schema.sql
-- =============================================================
USE slms_db;

-- ── Teacher account ──────────────────────────────────────────
-- email: varun23112003@gmail.com  |  password: Varun@123
INSERT IGNORE INTO users
    (username, email, password_hash, role, first_name, last_name, bio, is_active)
VALUES
    ('ravi.shastry', 'varun23112003@gmail.com',
     '$2a$12$tSQWEGwRdcJAQjJSFIDeKevZ40TVOmSQZqxBtO1.wMdnqeUvPnF0C',
     'TEACHER', 'Ravi', 'Shastry',
     'Experienced educator with 10+ years in software and data science.', TRUE);

-- Capture teacher id for subsequent inserts
SET @tid = (SELECT id FROM users WHERE email = 'varun23112003@gmail.com');

-- ── Category IDs (from seed in schema.sql) ───────────────────
SET @cat_prog  = (SELECT id FROM categories WHERE name = 'Programming'  LIMIT 1);
SET @cat_math  = (SELECT id FROM categories WHERE name = 'Mathematics'  LIMIT 1);
SET @cat_sci   = (SELECT id FROM categories WHERE name = 'Science'      LIMIT 1);
SET @cat_biz   = (SELECT id FROM categories WHERE name = 'Business'     LIMIT 1);
SET @cat_ds    = (SELECT id FROM categories WHERE name = 'Data Science' LIMIT 1);
SET @cat_lang  = (SELECT id FROM categories WHERE name = 'Languages'    LIMIT 1);
SET @cat_des   = (SELECT id FROM categories WHERE name = 'Design'       LIMIT 1);

-- ═════════════════════════════════════════════════════════════
-- COURSES
-- ═════════════════════════════════════════════════════════════
INSERT INTO courses (title, description, teacher_id, category_id, is_published) VALUES
('Java Programming Fundamentals',
 'Master the core concepts of Java: OOP, collections, exceptions, file I/O, and more. Ideal for beginners stepping into the world of software development.',
 @tid, @cat_prog, TRUE),

('Web Development with HTML, CSS & JavaScript',
 'Build responsive, modern websites from scratch. Covers HTML5 semantics, CSS Flexbox & Grid, JavaScript ES6+, and DOM manipulation.',
 @tid, @cat_prog, TRUE),

('Python for Data Science',
 'Learn Python from the ground up and apply it to real-world data problems using NumPy, Pandas, and Matplotlib.',
 @tid, @cat_ds, TRUE),

('Database Design & SQL',
 'Understand relational databases, normalisation, ER diagrams, and write efficient SQL queries using MySQL.',
 @tid, @cat_prog, TRUE),

('Machine Learning Essentials',
 'Explore supervised and unsupervised learning algorithms, model evaluation, and hands-on projects using Scikit-learn.',
 @tid, @cat_ds, TRUE),

('Calculus & Linear Algebra for Engineers',
 'A rigorous course covering derivatives, integrals, vectors, matrices, and eigenvalues with engineering applications.',
 @tid, @cat_math, TRUE),

('Business Communication & Presentation Skills',
 'Develop professional writing, public speaking, and presentation skills essential for the modern workplace.',
 @tid, @cat_biz, TRUE),

('Introduction to Cyber Security',
 'Understand common threats, ethical hacking basics, network security, cryptography, and best practices for defending systems.',
 @tid, @cat_sci, TRUE),

('UI/UX Design Principles',
 'Learn user-centred design thinking, wireframing, prototyping with Figma, and usability testing techniques.',
 @tid, @cat_des, TRUE),

('English for Academic & Professional Purposes',
 'Improve academic writing, critical reading, grammar, and professional email communication in English.',
 @tid, @cat_lang, TRUE);

-- Capture course IDs
SET @c1  = (SELECT id FROM courses WHERE title = 'Java Programming Fundamentals'                LIMIT 1);
SET @c2  = (SELECT id FROM courses WHERE title = 'Web Development with HTML, CSS & JavaScript'  LIMIT 1);
SET @c3  = (SELECT id FROM courses WHERE title = 'Python for Data Science'                      LIMIT 1);
SET @c4  = (SELECT id FROM courses WHERE title = 'Database Design & SQL'                        LIMIT 1);
SET @c5  = (SELECT id FROM courses WHERE title = 'Machine Learning Essentials'                  LIMIT 1);
SET @c6  = (SELECT id FROM courses WHERE title = 'Calculus & Linear Algebra for Engineers'      LIMIT 1);
SET @c7  = (SELECT id FROM courses WHERE title = 'Business Communication & Presentation Skills' LIMIT 1);
SET @c8  = (SELECT id FROM courses WHERE title = 'Introduction to Cyber Security'               LIMIT 1);
SET @c9  = (SELECT id FROM courses WHERE title = 'UI/UX Design Principles'                      LIMIT 1);
SET @c10 = (SELECT id FROM courses WHERE title = 'English for Academic & Professional Purposes' LIMIT 1);

-- ═════════════════════════════════════════════════════════════
-- ASSIGNMENTS  (2 per course, with due dates)
-- ═════════════════════════════════════════════════════════════
INSERT INTO assignments (course_id, title, description, due_date, max_marks) VALUES
-- Course 1: Java
(@c1, 'Hello World & Basic OOP',
 'Write a Java program demonstrating class creation, objects, constructors, and basic inheritance. Submit a .zip of your Maven project.',
 DATE_ADD(CURDATE(), INTERVAL 14 DAY), 50),
(@c1, 'Collections & Exception Handling',
 'Implement a student grade tracker using ArrayList, HashMap, and custom exceptions. Include unit tests.',
 DATE_ADD(CURDATE(), INTERVAL 28 DAY), 100),

-- Course 2: Web Dev
(@c2, 'Personal Portfolio Page',
 'Build a responsive personal portfolio using only HTML5 and CSS3. Must be mobile-friendly and pass W3C validation.',
 DATE_ADD(CURDATE(), INTERVAL 10 DAY), 50),
(@c2, 'Interactive JavaScript Quiz App',
 'Create a client-side quiz app with at least 10 questions, score tracking, and a timer using vanilla JavaScript.',
 DATE_ADD(CURDATE(), INTERVAL 21 DAY), 100),

-- Course 3: Python DS
(@c3, 'Data Cleaning with Pandas',
 'Load the provided CSV dataset, handle missing values, remove duplicates, and produce a cleaned output file with summary statistics.',
 DATE_ADD(CURDATE(), INTERVAL 12 DAY), 50),
(@c3, 'Exploratory Data Analysis Report',
 'Perform a full EDA on the provided sales dataset. Submit a Jupyter Notebook with visualisations and written observations.',
 DATE_ADD(CURDATE(), INTERVAL 25 DAY), 100),

-- Course 4: SQL
(@c4, 'ER Diagram for a Library System',
 'Design a normalised ER diagram for a public library. Include entities, relationships, attributes, and explain your design choices.',
 DATE_ADD(CURDATE(), INTERVAL 10 DAY), 40),
(@c4, 'Complex SQL Queries',
 'Write 15 SQL queries (JOINs, subqueries, aggregations, window functions) against the provided university database schema.',
 DATE_ADD(CURDATE(), INTERVAL 22 DAY), 100),

-- Course 5: ML
(@c5, 'Linear Regression from Scratch',
 'Implement linear regression using only NumPy (no Scikit-learn). Train on the Boston housing dataset and report MSE and R².',
 DATE_ADD(CURDATE(), INTERVAL 14 DAY), 60),
(@c5, 'Classification Project',
 'Choose a public dataset, apply at least 3 classification algorithms, tune hyperparameters, and write a report comparing results.',
 DATE_ADD(CURDATE(), INTERVAL 30 DAY), 100),

-- Course 6: Calculus
(@c6, 'Differential Calculus Problem Set',
 'Solve 20 problems on limits, derivatives, chain rule, implicit differentiation, and L\'Hôpital\'s rule. Show all working.',
 DATE_ADD(CURDATE(), INTERVAL 7 DAY), 40),
(@c6, 'Matrix Operations & Eigenvalues',
 'Complete exercises on matrix multiplication, determinants, inverse matrices, and finding eigenvalues/eigenvectors.',
 DATE_ADD(CURDATE(), INTERVAL 21 DAY), 60),

-- Course 7: Business Comm
(@c7, 'Professional Email Writing',
 'Rewrite 5 poorly-written business emails provided in class materials. Justify each change you make.',
 DATE_ADD(CURDATE(), INTERVAL 7 DAY), 30),
(@c7, 'Presentation & Slide Deck',
 'Create a 10-minute presentation on a business topic of your choice. Submit the slide deck and a self-evaluation form.',
 DATE_ADD(CURDATE(), INTERVAL 20 DAY), 70),

-- Course 8: Cyber Security
(@c8, 'Threat Modelling Exercise',
 'Perform a threat model for a fictional e-commerce website. Identify assets, threats, vulnerabilities, and propose countermeasures.',
 DATE_ADD(CURDATE(), INTERVAL 12 DAY), 50),
(@c8, 'Capture The Flag (CTF) Write-Up',
 'Solve 3 beginner CTF challenges from PicoCTF or HackTheBox and submit detailed write-ups explaining your methodology.',
 DATE_ADD(CURDATE(), INTERVAL 25 DAY), 100),

-- Course 9: UI/UX
(@c9, 'Low-Fidelity Wireframes',
 'Design wireframes for a mobile food-delivery app (5 screens minimum) using Figma. Include user flow diagram.',
 DATE_ADD(CURDATE(), INTERVAL 10 DAY), 50),
(@c9, 'Usability Testing Report',
 'Conduct usability tests with 3 participants on your prototype. Record findings and propose improvements.',
 DATE_ADD(CURDATE(), INTERVAL 24 DAY), 100),

-- Course 10: English
(@c10, 'Academic Essay',
 'Write a 600-word academic essay arguing for or against remote work. Follow APA citation format.',
 DATE_ADD(CURDATE(), INTERVAL 10 DAY), 50),
(@c10, 'Business Proposal Letter',
 'Draft a formal business proposal letter (400–500 words) for launching a new product line. Submit in PDF format.',
 DATE_ADD(CURDATE(), INTERVAL 21 DAY), 50);

-- ═════════════════════════════════════════════════════════════
-- QUIZZES  (1 per course)
-- ═════════════════════════════════════════════════════════════
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, pass_percentage) VALUES
(@c1,  'Java Basics Quiz',               'Test your understanding of Java OOP fundamentals.',        20, 60),
(@c2,  'HTML, CSS & JS Fundamentals',    'Check your web development knowledge.',                    20, 60),
(@c3,  'Python & Pandas Essentials',     'Core Python and data manipulation concepts.',              20, 60),
(@c4,  'SQL & Database Theory',          'Relational database design and SQL query knowledge.',      20, 60),
(@c5,  'Machine Learning Concepts',      'Algorithms, model evaluation, and ML theory.',             25, 60),
(@c6,  'Calculus & Linear Algebra',      'Derivatives, integrals, matrices, and vectors.',           30, 60),
(@c7,  'Business Communication',         'Professional writing and communication principles.',       15, 60),
(@c8,  'Cyber Security Fundamentals',    'Security principles, threats, and countermeasures.',       20, 60),
(@c9,  'UI/UX Design Quiz',              'Design thinking, UX principles, and Figma knowledge.',     20, 60),
(@c10, 'English Language & Grammar',     'Grammar, academic writing, and email conventions.',        15, 60);

-- Capture quiz IDs
SET @q1  = (SELECT id FROM quizzes WHERE course_id = @c1  LIMIT 1);
SET @q2  = (SELECT id FROM quizzes WHERE course_id = @c2  LIMIT 1);
SET @q3  = (SELECT id FROM quizzes WHERE course_id = @c3  LIMIT 1);
SET @q4  = (SELECT id FROM quizzes WHERE course_id = @c4  LIMIT 1);
SET @q5  = (SELECT id FROM quizzes WHERE course_id = @c5  LIMIT 1);
SET @q6  = (SELECT id FROM quizzes WHERE course_id = @c6  LIMIT 1);
SET @q7  = (SELECT id FROM quizzes WHERE course_id = @c7  LIMIT 1);
SET @q8  = (SELECT id FROM quizzes WHERE course_id = @c8  LIMIT 1);
SET @q9  = (SELECT id FROM quizzes WHERE course_id = @c9  LIMIT 1);
SET @q10 = (SELECT id FROM quizzes WHERE course_id = @c10 LIMIT 1);

-- ═════════════════════════════════════════════════════════════
-- QUIZ QUESTIONS  (5 per quiz, 2 marks each)
-- ═════════════════════════════════════════════════════════════

-- ── Quiz 1: Java ─────────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q1, 'Which keyword is used to create a class in Java?',
 'object', 'class', 'new', 'struct', 'B', 2),
(@q1, 'What is the default value of an int variable in Java?',
 'null', '-1', '0', '1', 'C', 2),
(@q1, 'Which access modifier makes a member accessible only within the same class?',
 'public', 'protected', 'default', 'private', 'D', 2),
(@q1, 'What does JVM stand for?',
 'Java Variable Method', 'Java Virtual Machine', 'Java Verified Module', 'Joint Virtual Memory', 'B', 2),
(@q1, 'Which collection allows duplicate elements and maintains insertion order?',
 'HashSet', 'TreeSet', 'ArrayList', 'HashMap', 'C', 2);

-- ── Quiz 2: Web Dev ──────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q2, 'Which HTML tag is used for the largest heading?',
 '<h6>', '<heading>', '<h1>', '<head>', 'C', 2),
(@q2, 'Which CSS property controls the text size?',
 'text-size', 'font-size', 'text-style', 'font-style', 'B', 2),
(@q2, 'What does CSS stand for?',
 'Creative Style Sheet', 'Cascading Style Sheet', 'Computer Style Sheet', 'Colorful Style Sheet', 'B', 2),
(@q2, 'Which JavaScript method selects an element by its ID?',
 'getElement()', 'querySelector()', 'getElementById()', 'selectById()', 'C', 2),
(@q2, 'In CSS Flexbox, which property aligns items along the main axis?',
 'align-items', 'justify-content', 'flex-direction', 'align-content', 'B', 2);

-- ── Quiz 3: Python DS ────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q3, 'Which Python library is primarily used for data manipulation?',
 'NumPy', 'Matplotlib', 'Pandas', 'SciPy', 'C', 2),
(@q3, 'What does df.head() return by default?',
 'Last 5 rows', 'First 5 rows', 'First 10 rows', 'Column names', 'B', 2),
(@q3, 'Which function is used to read a CSV file in Pandas?',
 'pd.load_csv()', 'pd.read_csv()', 'pd.open_csv()', 'pd.import_csv()', 'B', 2),
(@q3, 'What is the output type of df["column"] in Pandas?',
 'DataFrame', 'List', 'Series', 'Array', 'C', 2),
(@q3, 'Which method removes duplicate rows in a Pandas DataFrame?',
 'df.remove_duplicates()', 'df.drop_duplicates()', 'df.unique()', 'df.distinct()', 'B', 2);

-- ── Quiz 4: SQL ──────────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q4, 'Which SQL clause filters rows AFTER grouping?',
 'WHERE', 'HAVING', 'FILTER', 'GROUP BY', 'B', 2),
(@q4, 'Which normal form eliminates partial dependencies?',
 '1NF', '2NF', '3NF', 'BCNF', 'B', 2),
(@q4, 'What does a PRIMARY KEY constraint ensure?',
 'Uniqueness only', 'Not null only', 'Uniqueness and not null', 'Foreign key reference', 'C', 2),
(@q4, 'Which JOIN returns all rows from both tables including non-matching rows?',
 'INNER JOIN', 'LEFT JOIN', 'FULL OUTER JOIN', 'CROSS JOIN', 'C', 2),
(@q4, 'What does the SQL command TRUNCATE do?',
 'Deletes the table structure', 'Removes all rows without logging each', 'Deletes rows with a WHERE clause', 'Creates a backup', 'B', 2);

-- ── Quiz 5: Machine Learning ─────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q5, 'Which algorithm is used for classification and regression tasks?',
 'K-Means', 'PCA', 'Decision Tree', 'DBSCAN', 'C', 2),
(@q5, 'What metric measures the proportion of correctly predicted observations?',
 'Precision', 'Recall', 'F1-Score', 'Accuracy', 'D', 2),
(@q5, 'Which technique helps prevent overfitting by adding a penalty term?',
 'Cross-validation', 'Regularisation', 'Normalisation', 'Feature engineering', 'B', 2),
(@q5, 'K-Means is an example of which type of learning?',
 'Supervised', 'Reinforcement', 'Unsupervised', 'Semi-supervised', 'C', 2),
(@q5, 'What does the train-test split primarily help evaluate?',
 'Training speed', 'Model generalisation', 'Data quality', 'Feature count', 'B', 2);

-- ── Quiz 6: Calculus & Linear Algebra ───────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q6, 'What is the derivative of sin(x)?',
 '-cos(x)', 'cos(x)', 'tan(x)', '-sin(x)', 'B', 2),
(@q6, 'What is the integral of 1/x dx?',
 'x', 'ln|x| + C', '1/x² + C', 'e^x + C', 'B', 2),
(@q6, 'Which rule is used to differentiate a product of two functions?',
 'Chain rule', 'Quotient rule', 'Product rule', 'Power rule', 'C', 2),
(@q6, 'What is the determinant of the identity matrix I₂?',
 '0', '2', '1', '-1', 'C', 2),
(@q6, 'An eigenvalue λ satisfies which equation for matrix A?',
 'A + λv = 0', 'Av = λv', 'A = λI', 'det(A) = λ', 'B', 2);

-- ── Quiz 7: Business Communication ──────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q7, 'Which element is NOT typically included in a professional email?',
 'Subject line', 'Salutation', 'Personal social media links', 'Closing', 'C', 2),
(@q7, 'What is the recommended length for a business email body?',
 'As long as needed', 'Concise – 3 to 5 sentences per paragraph', 'At least one page', 'Under 50 words', 'B', 2),
(@q7, 'Which communication style is best for formal presentations?',
 'Informal and casual', 'Structured and clear', 'Stream of consciousness', 'Humorous throughout', 'B', 2),
(@q7, 'Active voice in writing means the subject ___ the action.',
 'receives', 'avoids', 'performs', 'describes', 'C', 2),
(@q7, 'The 7 Cs of communication include all EXCEPT:',
 'Clear', 'Concise', 'Creative', 'Correct', 'C', 2);

-- ── Quiz 8: Cyber Security ───────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q8, 'What does CIA stand for in information security?',
 'Confidentiality, Integrity, Availability', 'Control, Identification, Authentication',
 'Cryptography, Intrusion, Access', 'Central Intelligence Agency', 'A', 2),
(@q8, 'Which attack sends unsolicited messages to trick users into revealing sensitive information?',
 'DoS', 'SQL Injection', 'Phishing', 'Man-in-the-Middle', 'C', 2),
(@q8, 'What is the purpose of a firewall?',
 'Encrypt data', 'Monitor and control incoming/outgoing network traffic', 'Store passwords', 'Detect malware', 'B', 2),
(@q8, 'Which encryption standard is widely used for securing web traffic (HTTPS)?',
 'DES', 'MD5', 'AES / TLS', 'Base64', 'C', 2),
(@q8, 'What does a VPN primarily provide?',
 'Faster internet', 'A secure encrypted tunnel for network traffic', 'Antivirus protection', 'Password management', 'B', 2);

-- ── Quiz 9: UI/UX ────────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q9, 'What is a wireframe in UI/UX design?',
 'A high-fidelity visual prototype', 'A basic layout sketch showing structure', 'A user interview transcript', 'A style guide', 'B', 2),
(@q9, 'Which principle states that users should be able to undo actions?',
 'Visibility', 'User control and freedom', 'Consistency', 'Error prevention', 'B', 2),
(@q9, 'What does UX stand for?',
 'User Execution', 'User Experience', 'Unique Experience', 'Universal Exchange', 'B', 2),
(@q9, 'Which Figma feature lets multiple designers work on the same file simultaneously?',
 'Prototyping', 'Components', 'Real-time collaboration', 'Auto Layout', 'C', 2),
(@q9, 'What is the primary goal of a usability test?',
 'To show stakeholders the design', 'To identify problems real users face', 'To validate the tech stack', 'To create a final prototype', 'B', 2);

-- ── Quiz 10: English ─────────────────────────────────────────
INSERT INTO quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, marks) VALUES
(@q10, 'Which sentence uses the correct subject-verb agreement?',
 'The team are playing well.', 'The team is playing well.', 'The team were playing well.', 'The teams is playing well.', 'B', 2),
(@q10, 'Which tense is used to describe actions happening right now?',
 'Simple Past', 'Present Perfect', 'Present Continuous', 'Future Simple', 'C', 2),
(@q10, 'What citation style is commonly used in academic papers in social sciences?',
 'MLA', 'Chicago', 'APA', 'Harvard', 'C', 2),
(@q10, 'Which word best replaces "show" in a formal academic context?',
 'prove', 'demonstrate', 'tell', 'say', 'B', 2),
(@q10, 'What is the correct salutation for a business email when the recipient name is unknown?',
 'Hey there,', 'Yo,', 'Dear Sir/Madam,', 'Hello friend,', 'C', 2);

-- ═════════════════════════════════════════════════════════════
-- ANNOUNCEMENTS (1 per course)
-- ═════════════════════════════════════════════════════════════
INSERT INTO announcements (course_id, author_id, title, body) VALUES
(@c1,  @tid, 'Welcome to Java Fundamentals!', 'Hi everyone! Please make sure to install JDK 21 and IntelliJ IDEA before the first session. Looking forward to learning with you!'),
(@c2,  @tid, 'Portfolio Assignment Released', 'The first assignment is now live. Use VS Code with the Live Server extension for a smooth development experience.'),
(@c3,  @tid, 'Dataset for EDA Assignment', 'The cleaned dataset has been uploaded under Course Materials. You will need Jupyter Notebook and Pandas 2.x installed.'),
(@c4,  @tid, 'Office Hours This Week', 'I will be available for doubt-clearing sessions on Wednesday 4–6 PM. Bring your ER diagram drafts!'),
(@c5,  @tid, 'Recommended Textbook', 'I recommend "Hands-On Machine Learning" by Aurélien Géron. PDF links are shared in the forum.'),
(@c6,  @tid, 'Problem Set Tips', 'Remember to show all steps in your solutions. Partial credit is given for correct method even if the final answer is wrong.'),
(@c7,  @tid, 'Guest Speaker Next Week', 'We have a communication expert joining us virtually next Monday at 10 AM. Attendance is mandatory.'),
(@c8,  @tid, 'CTF Platform Registration', 'Please register on PicoCTF using your college email before Friday. Credentials shared separately.'),
(@c9,  @tid, 'Figma Education Account', 'Apply for a free Figma Education account at figma.com/education. Your .edu email qualifies you.'),
(@c10, @tid, 'Essay Submission Format', 'All essays must be submitted as PDF files. Use Times New Roman 12pt, double-spaced, with 1-inch margins.');

SELECT CONCAT('✓ Teacher inserted with ID: ', @tid) AS status;
SELECT CONCAT('✓ Courses: ', COUNT(*), ' total') AS status FROM courses WHERE teacher_id = @tid;
SELECT CONCAT('✓ Assignments: ', COUNT(*)) AS status FROM assignments WHERE course_id IN (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10);
SELECT CONCAT('✓ Quizzes: ', COUNT(*)) AS status FROM quizzes WHERE course_id IN (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10);
SELECT CONCAT('✓ Quiz Questions: ', COUNT(*)) AS status FROM quiz_questions WHERE quiz_id IN (@q1,@q2,@q3,@q4,@q5,@q6,@q7,@q8,@q9,@q10);
