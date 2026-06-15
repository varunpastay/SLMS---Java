-- Cleanup duplicates then insert clean seed
USE slms_db;
SET @tid = (SELECT id FROM users WHERE email = 'varun23112003@gmail.com');

-- Remove all data for this teacher's courses (proper dependency order)

-- 1. Quiz answers → quiz attempts → quiz questions → quizzes
DELETE qa FROM quiz_answers qa
  JOIN quiz_questions qq ON qa.question_id = qq.id
  JOIN quizzes qz ON qq.quiz_id = qz.id
  JOIN courses c ON qz.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE qa FROM quiz_answers qa
  JOIN quiz_attempts at2 ON qa.attempt_id = at2.id
  JOIN quizzes qz ON at2.quiz_id = qz.id
  JOIN courses c ON qz.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE at2 FROM quiz_attempts at2
  JOIN quizzes qz ON at2.quiz_id = qz.id
  JOIN courses c ON qz.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE qq FROM quiz_questions qq
  JOIN quizzes qz ON qq.quiz_id = qz.id
  JOIN courses c ON qz.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE qz FROM quizzes qz
  JOIN courses c ON qz.course_id = c.id
  WHERE c.teacher_id = @tid;

-- 2. Rubric grades → rubric items → submissions → assignments
DELETE rg FROM rubric_grades rg
  JOIN rubric_items ri ON rg.rubric_item_id = ri.id
  JOIN assignments a ON ri.assignment_id = a.id
  JOIN courses c ON a.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE ri FROM rubric_items ri
  JOIN assignments a ON ri.assignment_id = a.id
  JOIN courses c ON a.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE s FROM submissions s
  JOIN assignments a ON s.assignment_id = a.id
  JOIN courses c ON a.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE a FROM assignments a
  JOIN courses c ON a.course_id = c.id
  WHERE c.teacher_id = @tid;

-- 3. Announcements, feedback, materials, enrollments
DELETE an FROM announcements an
  JOIN courses c ON an.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE f FROM feedback f
  JOIN courses c ON f.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE cm FROM course_materials cm
  JOIN courses c ON cm.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE e FROM enrollments e
  JOIN courses c ON e.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE fp FROM forum_posts fp
  JOIN courses c ON fp.course_id = c.id
  WHERE c.teacher_id = @tid;

DELETE FROM courses WHERE teacher_id = @tid;

-- ═════════════════════════════════════════════════════════════
-- RE-INSERT 10 COURSES
-- ═════════════════════════════════════════════════════════════
SET @cat_prog = (SELECT id FROM categories WHERE name = 'Programming'  LIMIT 1);
SET @cat_math = (SELECT id FROM categories WHERE name = 'Mathematics'  LIMIT 1);
SET @cat_sci  = (SELECT id FROM categories WHERE name = 'Science'      LIMIT 1);
SET @cat_biz  = (SELECT id FROM categories WHERE name = 'Business'     LIMIT 1);
SET @cat_ds   = (SELECT id FROM categories WHERE name = 'Data Science' LIMIT 1);
SET @cat_lang = (SELECT id FROM categories WHERE name = 'Languages'    LIMIT 1);
SET @cat_des  = (SELECT id FROM categories WHERE name = 'Design'       LIMIT 1);

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

SET @c1  = (SELECT id FROM courses WHERE title = 'Java Programming Fundamentals'                AND teacher_id=@tid LIMIT 1);
SET @c2  = (SELECT id FROM courses WHERE title = 'Web Development with HTML, CSS & JavaScript'  AND teacher_id=@tid LIMIT 1);
SET @c3  = (SELECT id FROM courses WHERE title = 'Python for Data Science'                      AND teacher_id=@tid LIMIT 1);
SET @c4  = (SELECT id FROM courses WHERE title = 'Database Design & SQL'                        AND teacher_id=@tid LIMIT 1);
SET @c5  = (SELECT id FROM courses WHERE title = 'Machine Learning Essentials'                  AND teacher_id=@tid LIMIT 1);
SET @c6  = (SELECT id FROM courses WHERE title = 'Calculus & Linear Algebra for Engineers'      AND teacher_id=@tid LIMIT 1);
SET @c7  = (SELECT id FROM courses WHERE title = 'Business Communication & Presentation Skills' AND teacher_id=@tid LIMIT 1);
SET @c8  = (SELECT id FROM courses WHERE title = 'Introduction to Cyber Security'               AND teacher_id=@tid LIMIT 1);
SET @c9  = (SELECT id FROM courses WHERE title = 'UI/UX Design Principles'                      AND teacher_id=@tid LIMIT 1);
SET @c10 = (SELECT id FROM courses WHERE title = 'English for Academic & Professional Purposes' AND teacher_id=@tid LIMIT 1);

-- ═════════════════════════════════════════════════════════════
-- ASSIGNMENTS (2 per course)
-- ═════════════════════════════════════════════════════════════
INSERT INTO assignments (course_id, title, description, due_date, max_marks) VALUES
(@c1,'Hello World & Basic OOP','Write a Java program demonstrating class creation, objects, constructors, and basic inheritance.',DATE_ADD(CURDATE(),INTERVAL 14 DAY),50),
(@c1,'Collections & Exception Handling','Implement a student grade tracker using ArrayList, HashMap, and custom exceptions.',DATE_ADD(CURDATE(),INTERVAL 28 DAY),100),
(@c2,'Personal Portfolio Page','Build a responsive personal portfolio using only HTML5 and CSS3. Must be mobile-friendly.',DATE_ADD(CURDATE(),INTERVAL 10 DAY),50),
(@c2,'Interactive JavaScript Quiz App','Create a client-side quiz app with 10 questions, score tracking, and a timer.',DATE_ADD(CURDATE(),INTERVAL 21 DAY),100),
(@c3,'Data Cleaning with Pandas','Load the CSV dataset, handle missing values, remove duplicates, and produce a cleaned output.',DATE_ADD(CURDATE(),INTERVAL 12 DAY),50),
(@c3,'Exploratory Data Analysis Report','Perform a full EDA on the sales dataset. Submit a Jupyter Notebook with visualisations.',DATE_ADD(CURDATE(),INTERVAL 25 DAY),100),
(@c4,'ER Diagram for a Library System','Design a normalised ER diagram for a public library with entities, relationships, and attributes.',DATE_ADD(CURDATE(),INTERVAL 10 DAY),40),
(@c4,'Complex SQL Queries','Write 15 SQL queries (JOINs, subqueries, aggregations, window functions).',DATE_ADD(CURDATE(),INTERVAL 22 DAY),100),
(@c5,'Linear Regression from Scratch','Implement linear regression using only NumPy. Train on the Boston housing dataset.',DATE_ADD(CURDATE(),INTERVAL 14 DAY),60),
(@c5,'Classification Project','Apply at least 3 classification algorithms and write a report comparing results.',DATE_ADD(CURDATE(),INTERVAL 30 DAY),100),
(@c6,'Differential Calculus Problem Set','Solve 20 problems on limits, derivatives, chain rule, and implicit differentiation.',DATE_ADD(CURDATE(),INTERVAL 7 DAY),40),
(@c6,'Matrix Operations & Eigenvalues','Complete exercises on matrix multiplication, determinants, and eigenvalues.',DATE_ADD(CURDATE(),INTERVAL 21 DAY),60),
(@c7,'Professional Email Writing','Rewrite 5 poorly-written business emails provided in class materials.',DATE_ADD(CURDATE(),INTERVAL 7 DAY),30),
(@c7,'Presentation & Slide Deck','Create a 10-minute presentation on a business topic. Submit slide deck and self-evaluation.',DATE_ADD(CURDATE(),INTERVAL 20 DAY),70),
(@c8,'Threat Modelling Exercise','Perform a threat model for a fictional e-commerce website.',DATE_ADD(CURDATE(),INTERVAL 12 DAY),50),
(@c8,'Capture The Flag (CTF) Write-Up','Solve 3 beginner CTF challenges and submit detailed write-ups.',DATE_ADD(CURDATE(),INTERVAL 25 DAY),100),
(@c9,'Low-Fidelity Wireframes','Design wireframes for a mobile food-delivery app (5 screens) using Figma.',DATE_ADD(CURDATE(),INTERVAL 10 DAY),50),
(@c9,'Usability Testing Report','Conduct usability tests with 3 participants and propose improvements.',DATE_ADD(CURDATE(),INTERVAL 24 DAY),100),
(@c10,'Academic Essay','Write a 600-word academic essay arguing for or against remote work in APA format.',DATE_ADD(CURDATE(),INTERVAL 10 DAY),50),
(@c10,'Business Proposal Letter','Draft a formal business proposal letter (400–500 words) for a new product line.',DATE_ADD(CURDATE(),INTERVAL 21 DAY),50);

-- ═════════════════════════════════════════════════════════════
-- QUIZZES (1 per course)
-- ═════════════════════════════════════════════════════════════
INSERT INTO quizzes (course_id, title, description, time_limit_minutes, pass_percentage) VALUES
(@c1,  'Java Basics Quiz',            'Test your understanding of Java OOP fundamentals.',       20, 60),
(@c2,  'HTML, CSS & JS Fundamentals', 'Check your web development knowledge.',                   20, 60),
(@c3,  'Python & Pandas Essentials',  'Core Python and data manipulation concepts.',             20, 60),
(@c4,  'SQL & Database Theory',       'Relational database design and SQL query knowledge.',     20, 60),
(@c5,  'Machine Learning Concepts',   'Algorithms, model evaluation, and ML theory.',            25, 60),
(@c6,  'Calculus & Linear Algebra',   'Derivatives, integrals, matrices, and vectors.',          30, 60),
(@c7,  'Business Communication',      'Professional writing and communication principles.',      15, 60),
(@c8,  'Cyber Security Fundamentals', 'Security principles, threats, and countermeasures.',      20, 60),
(@c9,  'UI/UX Design Quiz',           'Design thinking, UX principles, and Figma knowledge.',    20, 60),
(@c10, 'English Language & Grammar',  'Grammar, academic writing, and email conventions.',       15, 60);

SET @q1  = (SELECT id FROM quizzes WHERE course_id=@c1  LIMIT 1);
SET @q2  = (SELECT id FROM quizzes WHERE course_id=@c2  LIMIT 1);
SET @q3  = (SELECT id FROM quizzes WHERE course_id=@c3  LIMIT 1);
SET @q4  = (SELECT id FROM quizzes WHERE course_id=@c4  LIMIT 1);
SET @q5  = (SELECT id FROM quizzes WHERE course_id=@c5  LIMIT 1);
SET @q6  = (SELECT id FROM quizzes WHERE course_id=@c6  LIMIT 1);
SET @q7  = (SELECT id FROM quizzes WHERE course_id=@c7  LIMIT 1);
SET @q8  = (SELECT id FROM quizzes WHERE course_id=@c8  LIMIT 1);
SET @q9  = (SELECT id FROM quizzes WHERE course_id=@c9  LIMIT 1);
SET @q10 = (SELECT id FROM quizzes WHERE course_id=@c10 LIMIT 1);

-- ═════════════════════════════════════════════════════════════
-- QUIZ QUESTIONS (5 per quiz)
-- ═════════════════════════════════════════════════════════════
INSERT INTO quiz_questions (quiz_id,question_text,option_a,option_b,option_c,option_d,correct_option,marks) VALUES
(@q1,'Which keyword is used to create a class in Java?','object','class','new','struct','B',2),
(@q1,'What is the default value of an int variable in Java?','null','-1','0','1','C',2),
(@q1,'Which access modifier makes a member accessible only within the same class?','public','protected','default','private','D',2),
(@q1,'What does JVM stand for?','Java Variable Method','Java Virtual Machine','Java Verified Module','Joint Virtual Memory','B',2),
(@q1,'Which collection allows duplicate elements and maintains insertion order?','HashSet','TreeSet','ArrayList','HashMap','C',2),

(@q2,'Which HTML tag is used for the largest heading?','<h6>','<heading>','<h1>','<head>','C',2),
(@q2,'Which CSS property controls the text size?','text-size','font-size','text-style','font-style','B',2),
(@q2,'What does CSS stand for?','Creative Style Sheet','Cascading Style Sheet','Computer Style Sheet','Colorful Style Sheet','B',2),
(@q2,'Which JavaScript method selects an element by its ID?','getElement()','querySelector()','getElementById()','selectById()','C',2),
(@q2,'In CSS Flexbox, which property aligns items along the main axis?','align-items','justify-content','flex-direction','align-content','B',2),

(@q3,'Which Python library is primarily used for data manipulation?','NumPy','Matplotlib','Pandas','SciPy','C',2),
(@q3,'What does df.head() return by default?','Last 5 rows','First 5 rows','First 10 rows','Column names','B',2),
(@q3,'Which function reads a CSV file in Pandas?','pd.load_csv()','pd.read_csv()','pd.open_csv()','pd.import_csv()','B',2),
(@q3,'What is the output type of df["column"] in Pandas?','DataFrame','List','Series','Array','C',2),
(@q3,'Which method removes duplicate rows in a Pandas DataFrame?','df.remove_duplicates()','df.drop_duplicates()','df.unique()','df.distinct()','B',2),

(@q4,'Which SQL clause filters rows AFTER grouping?','WHERE','HAVING','FILTER','GROUP BY','B',2),
(@q4,'Which normal form eliminates partial dependencies?','1NF','2NF','3NF','BCNF','B',2),
(@q4,'What does a PRIMARY KEY constraint ensure?','Uniqueness only','Not null only','Uniqueness and not null','Foreign key reference','C',2),
(@q4,'Which JOIN returns all rows from both tables including non-matching?','INNER JOIN','LEFT JOIN','FULL OUTER JOIN','CROSS JOIN','C',2),
(@q4,'What does TRUNCATE do?','Deletes the table structure','Removes all rows without logging each','Deletes rows with WHERE','Creates a backup','B',2),

(@q5,'Which algorithm is used for classification AND regression?','K-Means','PCA','Decision Tree','DBSCAN','C',2),
(@q5,'What metric measures the proportion of correctly predicted observations?','Precision','Recall','F1-Score','Accuracy','D',2),
(@q5,'Which technique helps prevent overfitting by adding a penalty term?','Cross-validation','Regularisation','Normalisation','Feature engineering','B',2),
(@q5,'K-Means is an example of which type of learning?','Supervised','Reinforcement','Unsupervised','Semi-supervised','C',2),
(@q5,'What does the train-test split primarily help evaluate?','Training speed','Model generalisation','Data quality','Feature count','B',2),

(@q6,'What is the derivative of sin(x)?','-cos(x)','cos(x)','tan(x)','-sin(x)','B',2),
(@q6,'What is the integral of 1/x dx?','x','ln|x| + C','1/x2 + C','e^x + C','B',2),
(@q6,'Which rule differentiates a product of two functions?','Chain rule','Quotient rule','Product rule','Power rule','C',2),
(@q6,'What is the determinant of the identity matrix I2?','0','2','1','-1','C',2),
(@q6,'An eigenvalue satisfies which equation for matrix A?','A + v = 0','Av = v','A = I','det(A) = ','B',2),

(@q7,'Which element is NOT typically in a professional email?','Subject line','Salutation','Personal social media links','Closing','C',2),
(@q7,'Recommended length for a business email body?','As long as needed','3 to 5 sentences per paragraph','At least one page','Under 50 words','B',2),
(@q7,'Which communication style suits formal presentations?','Informal and casual','Structured and clear','Stream of consciousness','Humorous throughout','B',2),
(@q7,'Active voice means the subject ___ the action.','receives','avoids','performs','describes','C',2),
(@q7,'The 7 Cs of communication include all EXCEPT:','Clear','Concise','Creative','Correct','C',2),

(@q8,'What does CIA stand for in information security?','Confidentiality, Integrity, Availability','Control, Identification, Authentication','Cryptography, Intrusion, Access','Central Intelligence Agency','A',2),
(@q8,'Which attack tricks users into revealing sensitive information?','DoS','SQL Injection','Phishing','Man-in-the-Middle','C',2),
(@q8,'What is the purpose of a firewall?','Encrypt data','Monitor and control network traffic','Store passwords','Detect malware','B',2),
(@q8,'Which standard secures web traffic (HTTPS)?','DES','MD5','AES / TLS','Base64','C',2),
(@q8,'What does a VPN primarily provide?','Faster internet','A secure encrypted tunnel','Antivirus protection','Password management','B',2),

(@q9,'What is a wireframe in UI/UX design?','A high-fidelity visual prototype','A basic layout sketch showing structure','A user interview transcript','A style guide','B',2),
(@q9,'Which principle says users should be able to undo actions?','Visibility','User control and freedom','Consistency','Error prevention','B',2),
(@q9,'What does UX stand for?','User Execution','User Experience','Unique Experience','Universal Exchange','B',2),
(@q9,'Which Figma feature enables multiple designers to work simultaneously?','Prototyping','Components','Real-time collaboration','Auto Layout','C',2),
(@q9,'What is the primary goal of a usability test?','Show stakeholders the design','Identify problems real users face','Validate the tech stack','Create a final prototype','B',2),

(@q10,'Which sentence uses correct subject-verb agreement?','The team are playing well.','The team is playing well.','The team were playing well.','The teams is playing well.','B',2),
(@q10,'Which tense describes actions happening right now?','Simple Past','Present Perfect','Present Continuous','Future Simple','C',2),
(@q10,'Which citation style is common in social science academic papers?','MLA','Chicago','APA','Harvard','C',2),
(@q10,'Which word best replaces "show" in formal academic writing?','prove','demonstrate','tell','say','B',2),
(@q10,'Correct salutation when the recipient name is unknown?','Hey there,','Yo,','Dear Sir/Madam,','Hello friend,','C',2);

-- ═════════════════════════════════════════════════════════════
-- ANNOUNCEMENTS (1 per course)
-- ═════════════════════════════════════════════════════════════
INSERT INTO announcements (course_id, author_id, title, body) VALUES
(@c1,  @tid,'Welcome to Java Fundamentals!','Please install JDK 21 and IntelliJ IDEA before the first session. Looking forward to learning with you!'),
(@c2,  @tid,'Portfolio Assignment Released','The first assignment is now live. Use VS Code with the Live Server extension for smooth development.'),
(@c3,  @tid,'Dataset for EDA Assignment','The cleaned dataset has been uploaded under Course Materials. You need Jupyter Notebook and Pandas 2.x.'),
(@c4,  @tid,'Office Hours This Week','Available Wednesday 4–6 PM for doubt-clearing. Bring your ER diagram drafts!'),
(@c5,  @tid,'Recommended Textbook','I recommend "Hands-On Machine Learning" by Aurelien Geron. PDF links are shared in the forum.'),
(@c6,  @tid,'Problem Set Tips','Show all steps in your solutions. Partial credit is given for correct method even if the final answer is wrong.'),
(@c7,  @tid,'Guest Speaker Next Week','A communication expert joins us virtually next Monday at 10 AM. Attendance is mandatory.'),
(@c8,  @tid,'CTF Platform Registration','Register on PicoCTF using your college email before Friday.'),
(@c9,  @tid,'Figma Education Account','Apply for a free Figma Education account at figma.com/education. Your .edu email qualifies.'),
(@c10, @tid,'Essay Submission Format','Submit all essays as PDF. Times New Roman 12pt, double-spaced, 1-inch margins.');

-- ─── Verification ────────────────────────────────────────────
SELECT CONCAT('Teacher ID: ', @tid) AS info;
SELECT CONCAT('Courses: ', COUNT(*)) AS info FROM courses WHERE teacher_id = @tid;
SELECT CONCAT('Assignments: ', COUNT(*)) AS info FROM assignments WHERE course_id IN (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10);
SELECT CONCAT('Quizzes: ', COUNT(*)) AS info FROM quizzes WHERE course_id IN (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10);
SELECT CONCAT('Quiz Questions: ', COUNT(*)) AS info FROM quiz_questions WHERE quiz_id IN (@q1,@q2,@q3,@q4,@q5,@q6,@q7,@q8,@q9,@q10);
SELECT CONCAT('Announcements: ', COUNT(*)) AS info FROM announcements WHERE course_id IN (@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10);
