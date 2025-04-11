Create database PROJECT;
use PROJECT;
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country_code CHAR(2) NOT NULL,
    user_type ENUM('freelancer', 'client', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    account_status ENUM('active', 'suspended', 'inactive')     DEFAULT 'active',
    profile_image VARCHAR(255) NULL,
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_country (country_code)
);
describe Users;
CREATE TABLE FreelancerProfiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    bio TEXT NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL,
    total_earnings DECIMAL(15,2) DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    completion_rate DECIMAL(5,2) DEFAULT 0.00,
    visibility BOOLEAN DEFAULT TRUE,
    title VARCHAR(100) NULL,
    experience_level ENUM('entry', 'intermediate', 'expert') NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_hourly_rate (hourly_rate),
    INDEX idx_rating (rating)
);
describe FreelancerProfiles;

CREATE TABLE ClientProfiles (
    profile_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    company_name VARCHAR(100) NULL,
    company_website VARCHAR(255) NULL,
    company_description TEXT NULL,
    company_size ENUM('individual', 'small', 'medium', 'large') NULL,
    industry VARCHAR(100) NULL,
    payment_verified BOOLEAN DEFAULT FALSE,
    total_spent DECIMAL(15,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
describe ClientProfiles;
CREATE TABLE Skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(50) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    popularity INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    INDEX idx_skill_name (skill_name),
    INDEX idx_popularity (popularity)
);
describe Skills;
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT NULL,
    category_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    icon VARCHAR(100) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    FOREIGN KEY (parent_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent (parent_id),
    INDEX idx_active (is_active)
);
describe Categories;

CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category_id INT NOT NULL,
    subcategory_id INT NULL,
    budget_min DECIMAL(10,2) NULL,
    budget_max DECIMAL(10,2) NULL,
    is_fixed_price BOOLEAN DEFAULT TRUE,
    hourly_rate_min DECIMAL(10,2) NULL,
    hourly_rate_max DECIMAL(10,2) NULL,
    duration ENUM('less_than_week', 'one_week_to_month', 'one_to_three_months', 'three_to_six_months', 'more_than_six_months') NULL,
    experience_level ENUM('entry', 'intermediate', 'expert', 'any') DEFAULT 'any',
    status ENUM('draft', 'open', 'in_progress', 'completed', 'cancelled') DEFAULT 'draft',
    visibility ENUM('public', 'invite_only', 'private') DEFAULT 'public',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deadline DATE NULL,
    FOREIGN KEY (client_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (subcategory_id) REFERENCES Categories(category_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at),
    INDEX idx_category (category_id)
);
describe Projects;
CREATE TABLE ProjectSkills (
    project_skill_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    skill_id INT NOT NULL,
    importance ENUM('required', 'preferred', 'nice_to_have') DEFAULT 'required',
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id) ON DELETE CASCADE,
    UNIQUE KEY unique_project_skill (project_id, skill_id)
);
describe ProjectSkills;
CREATE TABLE Proposals (
    proposal_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    freelancer_id INT NOT NULL,
    cover_letter TEXT NOT NULL,
    bid_amount DECIMAL(10,2) NOT NULL,
    estimated_duration INT NOT NULL, -- in days
    status ENUM('pending', 'shortlisted', 'rejected', 'accepted', 'withdrawn') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_highlighted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (freelancer_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_project_freelancer (project_id, freelancer_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
);
describe Proposals;
CREATE TABLE PortfolioItems (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT NULL,
    project_url VARCHAR(255) NULL,
    image_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date DATE NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
);
describe PortfolioItems;
CREATE TABLE Contracts (
    contract_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    client_id INT NOT NULL,
    freelancer_id INT NOT NULL,
    proposal_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    contract_type ENUM('fixed', 'hourly') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status ENUM('active', 'completed', 'terminated', 'disputed') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (client_id) REFERENCES Users(user_id),
    FOREIGN KEY (freelancer_id) REFERENCES Users(user_id),
    FOREIGN KEY (proposal_id) REFERENCES Proposals(proposal_id),
    INDEX idx_project (project_id),
    INDEX idx_status (status)
);
describe Contracts;
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    contract_id INT ,
    amount DECIMAL(10,2),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_method VARCHAR(50) NULL,
    transaction_id VARCHAR(100) NULL,
    platform_fee DECIMAL(10,2),
    freelancer_amount DECIMAL(10,2),
    FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id),
    INDEX idx_status (status),
    INDEX idx_date (payment_date)
);
describe Payments;
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    contract_id INT,
    reviewer_id INT,
    reviewee_id INT,
    rating DECIMAL(3,2),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id),
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id),
    FOREIGN KEY (reviewee_id) REFERENCES Users(user_id),
    UNIQUE KEY unique_review (contract_id, reviewer_id, reviewee_id),
    INDEX idx_reviewee_rating (reviewee_id, rating)
);
describe Reviews;
CREATE TABLE Messages (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    contract_id INT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
    FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id) ON DELETE SET NULL,
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_sent_at (sent_at)
);
describe Messages;
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('message', 'proposal', 'contract', 'payment', 'review', 'system') NOT NULL,
    reference_id INT NULL, -- ID of related entity (message_id, proposal_id, etc.)
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read),
    INDEX idx_created (created_at)
);
describe Notifications;

INSERT INTO Users (email, password_hash, first_name, last_name, country_code, user_type) VALUES
('ravi.kumar@metgig.com', '$2y$10$randomstring1', 'Ravi', 'Kumar', 'IN', 'freelancer'),
('priya.sharma@metgig.com', '$2y$10$anotherrandom2', 'Priya', 'Sharma', 'IN', 'client'),
('amit.patel@metgig.com', '$2y$10$yetanother3', 'Amit', 'Patel', 'IN', 'freelancer'),
('sneha.verma@metgig.com', '$2y$10$random4again', 'Sneha', 'Verma', 'IN', 'client'),
('karan.singh@metgig.com', '$2y$10$uniquehash5', 'Karan', 'Singh', 'IN', 'freelancer'),
('deepika.gupta@metgig.com', '$2y$10$securepass6', 'Deepika', 'Gupta', 'IN', 'client'),
('vikas.yadav@metgig.com', '$2y$10$strongone7', 'Vikas', 'Yadav', 'IN', 'freelancer'),
('anjali.rai@metgig.com', '$2y$10$complex8key', 'Anjali', 'Rai', 'IN', 'client'),
('suresh.pillai@metgig.com', '$2y$10$alphanumeric9', 'Suresh', 'Pillai', 'IN', 'freelancer'),
('nisha.joshi@metgig.com', '$2y$10$randommix10', 'Nisha', 'Joshi', 'IN', 'admin');
select * from Users;

INSERT INTO FreelancerProfiles (user_id, bio, hourly_rate, title, experience_level) VALUES
(1, 'Experienced web developer with a passion for React.', 25.50, 'React Developer', 'expert'),
(3, 'Creative graphic designer specializing in branding.', 32.75, 'Graphic Designer', 'intermediate'),
(5, 'Skilled content writer for blogs and articles.', 18.00, 'Content Writer', 'entry'),
(7, 'Expert in data analysis and visualization.', 38.20, 'Data Analyst', 'expert'),
(9, 'Mobile app developer for Android and iOS.', 41.99, 'Mobile App Developer', 'intermediate'),
(1, 'Also proficient in Node.js and backend development.', 29.00, 'Full-stack Developer', 'expert'),
(3, 'Has designed logos and marketing materials for various startups.', 31.50, 'Brand Identity Designer', 'intermediate'),
(5, 'Can write engaging and SEO-friendly content.', 23.10, 'SEO Content Specialist', 'intermediate'),
(7, 'Uses Python and SQL for data manipulation.', 36.45, 'Business Intelligence Analyst', 'intermediate'),
(9, 'Familiar with Flutter and React Native frameworks.', 43.60, 'Cross-platform App Developer', 'expert');
select * from FreelancerProfiles;

INSERT INTO ClientProfiles (user_id, company_name, company_website, company_description, company_size, industry, payment_verified) VALUES
(2, 'Tech Solutions India', 'www.techsolutions.metgig.com', 'Leading IT consulting firm.', 'large', 'Information Technology', TRUE),
(4, 'Creative Designs Studio', 'www.creativedesigns.metgig.com', 'Boutique design agency.', 'small', 'Design', FALSE),
(6, 'Global Marketing Ltd', 'www.globalmarketing.metgig.com', 'International marketing agency.', 'medium', 'Marketing', TRUE),
(8, 'Software Innovations', 'www.softwareinnovations.metgig.com', 'Innovative software development company.', 'medium', 'Software Development', TRUE),
(10, 'Alpha Corp', 'www.alphacorp.metgig.com', 'Diversified conglomerate.', 'large', 'Various', TRUE),
(2, 'E-Commerce Ventures', 'www.ecomventures.metgig.com', 'Online retail platform.', 'medium', 'E-commerce', TRUE),
(4, 'Artistic Minds', NULL, 'Freelance art collective.', 'individual', 'Arts and Crafts', FALSE),
(6, 'Digital Reach Agency', 'www.digitalreach.metgig.com', 'Specialized in digital marketing.', 'small', 'Marketing', TRUE),
(8, 'Web Development Hub', 'www.webdevhub.metgig.com', 'Focuses on custom web applications.', 'small', 'Web Development', TRUE),
(10, 'Beta Industries', NULL, 'Manufacturing and distribution.', 'large', 'Manufacturing', TRUE);
select * from ClientProfiles;

-- Re-inserting the 10 new skills into the Skills table

INSERT INTO Skills (skill_name, category_id, popularity) VALUES
('Python', 1, 92),
('UI/UX Design', 2, 88),
('Technical Writing', 3, 75),
('Machine Learning', 4, 97),
('iOS Development', 5, 85),
('Node.js', 1, 95),
('Motion Graphics', 2, 79),
('Copywriting', 3, 81),
('Data Mining', 4, 90),
('React Native', 5, 83);

-- You can then verify the insertion with this query:
SELECT * FROM Skills;
INSERT INTO Categories (category_id, category_name) VALUES
(11, 'Customer Service'),
(12, 'Legal'),
(13, 'Architecture & Engineering'),
(14, 'Education & Training'),
(15, 'Human Resources'),
(16, 'Sales'),
(17, 'Accounting'),
(18, 'Translation'),
(19, 'Video & Animation'),
(20, 'Photography');


INSERT INTO Projects (client_id, title, description, category_id, is_fixed_price, budget_min, budget_max, duration, experience_level, status) VALUES
(2, 'Develop a Python Script for Data Processing', 'Need a Python script to automate data cleaning and processing.', 1, TRUE, 800.00, 1500.00, 'one_week_to_month', 'intermediate', 'open'),
(4, 'Redesign Mobile App UI', 'Looking for a UI/UX designer to improve the user interface of our mobile application.', 2, TRUE, 1200.00, 2500.00, 'one_to_three_months', 'intermediate', 'open'),
(6, 'Write a White Paper on Cloud Security', 'Seeking a technical writer to create a comprehensive white paper on cloud security best practices.', 3, TRUE, 1000.00, 2000.00, 'one_month', 'expert', 'open'),
(8, 'Build a Machine Learning Model for Recommendation', 'Looking for a machine learning expert to build a recommendation engine.', 4, FALSE, 40.00, 80.00, 'three_to_six_months', 'expert', 'open'),
(10, 'Develop a Native iOS App with Swift', 'Need an iOS developer to build a native application using Swift.', 5, FALSE, 35.00, 70.00, 'three_to_six_months', 'intermediate', 'open'),
(2, 'Create Explainer Videos for Our Product', 'Looking for a video editor to create short explainer videos.', 19, TRUE, 500.00, 1200.00, 'one_week_to_month', 'entry', 'open'),
(4, 'Design Social Media Posts for a Campaign', 'Need a designer to create engaging social media visuals for an upcoming campaign.', 2, TRUE, 300.00, 600.00, 'less_than_week', 'intermediate', 'open'),
(6, 'Translate Marketing Materials to Tamil', 'Seeking a translator for our marketing brochures and website content.', 18, TRUE, 400.00, 900.00, 'one_week_to_month', 'intermediate', 'open'),
(8, 'Implement Data Mining Techniques for Customer Insights', 'Looking for a data scientist to apply data mining techniques to extract customer insights.', 4, FALSE, 50.00, 90.00, 'one_to_three_months', 'expert', 'open'),
(10, 'Develop a React Native Mobile App', 'Need a developer to build a cross-platform mobile app using React Native.', 5, FALSE, 45.00, 85.00, 'three_to_six_months', 'intermediate', 'open');

INSERT INTO ProjectSkills (project_id, skill_id, importance) VALUES
(11, 11, 'required'), (11, 6, 'preferred'),
(12, 12, 'required'), (12, 2, 'required'),
(13, 13, 'required'), (13, 3, 'required'),
(14, 14, 'required'), (14, 4, 'required'),
(15, 15, 'required'), (15, 5, 'required'),
(16, 19, 'required'), (16, 2, 'nice_to_have'),
(17, 2, 'required'), (17, 7, 'required'),
(18, 18, 'required'), (18, 3, 'preferred'),
(19, 14, 'required'), (19, 9, 'required'),
(20, 15, 'required'), (20, 10, 'required');

INSERT INTO Proposals (project_id, freelancer_id, cover_letter, bid_amount, estimated_duration, status) VALUES
(11, 1, 'I have experience in Python scripting for data tasks.', 1200.00, 15, 'pending'),
(12, 3, 'My UI/UX designs are user-centric and modern.', 2000.00, 45, 'pending'),
(13, 5, 'I can write a well-researched white paper on cloud security.', 1800.00, 30, 'pending'),
(14, 7, 'I have built several recommendation systems using machine learning.', 70.00, 90, 'pending'),
(15, 9, 'I am proficient in Swift and iOS development.', 65.00, 120, 'pending'),
(11, 9, 'I also have some experience with data analysis using Python.', 1100.00, 20, 'pending'),
(12, 5, 'I can also create wireframes and prototypes for mobile apps.', 1800.00, 50, 'pending'),
(13, 1, 'My technical writing skills are well-suited for this task.', 1600.00, 35, 'pending'),
(14, 3, 'I have a strong understanding of various machine learning algorithms.', 75.00, 100, 'pending'),
(15, 1, 'I have also worked on cross-platform app development.', 60.00, 130, 'pending');

INSERT INTO PortfolioItems (user_id, title, description, project_url, image_url, completion_date, is_featured) VALUES
(1, 'Data Processing Script in Python', 'Automated data cleaning and transformation using Python.', 'www.github.com/datascripts', 'python_script_thumb.png', '2025-03-01', TRUE),
(3, 'Mobile App UI Redesign Concept', 'Conceptual redesign of a popular mobile app interface.', 'www.behance.net/mobileui', 'mobile_ui_redesign.jpg', '2025-02-10', TRUE),
(5, 'White Paper on Network Security', 'Authored a detailed white paper on network security protocols.', NULL, 'network_security_wp.pdf', '2025-01-25', FALSE),
(7, 'Movie Recommendation System', 'Developed a recommendation system for movies using collaborative filtering.', 'www.github.com/recommendersys', 'recommendation_system.png', '2024-12-20', TRUE),
(9, 'Task Management iOS App', 'Developed a native iOS application for managing daily tasks.', 'www.github.com/iostasks', 'ios_task_app.png', '2024-11-15', FALSE),
(1, 'Web Scraping Tool in Python', 'Created a tool to scrape data from various websites.', 'www.github.com/webscraper', 'web_scraping_tool.png', '2025-04-05', TRUE),
(3, 'E-commerce Website Mockups', 'Designed mockups for a new e-commerce platform.', 'www.figma.com/ecommerce', 'ecommerce_mockups.png', '2025-03-20', FALSE),
(5, 'Blog Posts on Content Marketing', 'Wrote a series of blog posts on various aspects of content marketing.', 'www.exampleblog.com/marketing', 'content_marketing_thumb.jpg', '2025-02-01', FALSE),
(7, 'Customer Churn Prediction Model (Presentation)', 'Created a presentation summarizing a customer churn prediction model.', NULL, 'churn_prediction_slides.pdf', '2025-01-10', FALSE),
(9, 'Cross-Platform To-Do App', 'Developed a to-do application using React Native.', 'www.github.com/reactnativedo', 'react_native_todo.png', '2024-10-25', TRUE);

INSERT INTO Contracts (project_id, client_id, freelancer_id, proposal_id, title, description, contract_type, amount, start_date, end_date, status) VALUES
(11, 2, 3, 20, 'React Native Mobile App Development', 'Developing a cross-platform mobile app using React Native.', 'hourly', 80.00, '2025-05-18', '2025-08-18', 'active'),
(12, 4, 5, 17, 'Social Media Graphics for New Product', 'Creating engaging social media visuals for a product launch.', 'fixed', 550.00, '2025-05-22', '2025-05-29', 'active'),
(13, 6, 1, 18, 'Hindi Translation of Website Content', 'Translating all website content accurately to Hindi.', 'fixed', 950.00, '2025-05-26', '2025-06-16', 'active'),
(14, 8, 9, 19, 'Data Analysis for Marketing Campaign', 'Analyzing campaign data to provide insights and recommendations.', 'hourly', 90.00, '2025-05-30', '2025-08-30', 'active'),
(15, 10, 7, 14, 'Machine Learning Model for Customer Retention', 'Building a model to predict and improve customer retention.', 'hourly', 110.00, '2025-06-03', '2025-09-03', 'active'),
(16, 2, 9, 15, 'iOS App Development for Inventory Management', 'Developing a native iOS app to manage inventory.', 'hourly', 75.00, '2025-06-07', '2025-09-07', 'active'),
(17, 4, 1, 11, 'Python Script for Report Generation', 'Creating a Python script to automate weekly report generation.', 'fixed', 1400.00, '2025-06-11', '2025-06-25', 'active'),
(18, 6, 3, 12, 'UI/UX Improvement for Web Application', 'Improving the user interface and experience of the web application.', 'fixed', 2800.00, '2025-06-15', '2025-07-30', 'active'),
(19, 8, 5, 13, 'Technical Documentation for Software API', 'Writing clear and concise technical documentation for the software API.', 'fixed', 1600.00, '2025-06-19', '2025-07-19', 'active'),
(20, 10, 7, 14, 'Data Mining for Sales Trend Analysis', 'Applying data mining techniques to identify key sales trends.', 'hourly', 85.00, '2025-06-23', '2025-09-23', 'active');

INSERT INTO Payments (contract_id, amount, status, payment_method, transaction_id, platform_fee, freelancer_amount) VALUES
(21, 4000.00, 'completed', 'Credit Card', 'txn12345', 200.00, 3800.00),
(22, 550.00, 'completed', 'UPI', 'upi67890', 27.50, 522.50),
(23, 950.00, 'completed', 'Net Banking', 'netbank111', 47.50, 902.50),
(24, 2700.00, 'completed', 'Credit Card', 'txn22233', 135.00, 2565.00),
(25, 5500.00, 'completed', 'UPI', 'upi44455', 275.00, 5225.00),
(26, 3750.00, 'completed', 'Net Banking', 'netbank666', 187.50, 3562.50),
(27, 700.00, 'completed', 'Credit Card', 'txn77788', 35.00, 665.00),
(28, 1400.00, 'completed', 'UPI', 'upi99900', 70.00, 1330.00),
(29, 4800.00, 'completed', 'Net Banking', 'netbankabc', 240.00, 4560.00),
(30, 2550.00, 'completed', 'Credit Card', 'txndefg', 127.50, 2422.50);

INSERT INTO Reviews (contract_id, reviewer_id, reviewee_id, rating, comment) VALUES
(21, 2, 1, 4.8, 'Excellent work on the React Native app!'),
(22, 4, 3, 4.5, 'Great social media graphics, very creative.'),
(23, 6, 5, 4.9, 'Accurate and professional Hindi translation.'),
(24, 8, 9, 4.7, 'Provided valuable insights from the marketing data.'),
(25, 10, 7, 5.0, 'The customer retention model is very effective.'),
(26, 10, 9, 4.6, 'Good job on the iOS inventory management app.'),
(27, 2, 1, 4.3, 'The Python script is working perfectly.'),
(28, 4, 3, 4.8, 'Significant improvement in the web application UI/UX.'),
(29, 6, 5, 4.7, 'Clear and well-written API documentation.'),
(30, 8, 7, 4.9, 'Very helpful analysis of the sales trends.');

INSERT INTO Messages (sender_id, receiver_id, contract_id, message_text) VALUES
(1, 2, 21, 'Hi, the first milestone of the React Native app is complete.'),
(3, 4, 22, 'Here are the initial social media graphic designs for your review.'),
(5, 6, 23, 'The Hindi translation of the website content is now finished.'),
(9, 8, 24, 'Attached is the report on the marketing campaign data analysis.'),
(7, 10, 25, 'The machine learning model for customer retention is deployed.'),
(9, 10, 26, 'The iOS inventory management app is ready for testing.'),
(1, 2, 27, 'The Python script for report generation has been implemented.'),
(3, 4, 28, 'Please take a look at the updated UI/UX of the web application.'),
(5, 6, 29, 'I have completed the technical documentation for the API.'),
(7, 8, 30, 'Here is the analysis of the recent sales trends.');

INSERT INTO Notifications (user_id, notification_type, reference_id, message) VALUES
(2, 'contract', 21, 'New contract started: React Native Mobile App Development'),
(4, 'proposal', 17, 'New proposal received for Social Media Graphics'),
(6, 'payment', 1, 'Payment completed for contract ID 21'),
(1, 'message', 1, 'New message received regarding React Native app'),
(10, 'review', 1, 'New review received for your work on contract ID 25'),
(9, 'contract', 26, 'New contract started: iOS App Development'),
(2, 'proposal', 11, 'Your proposal was accepted for Python Script'),
(4, 'message', 2, 'Feedback on the social media graphic designs'),
(6, 'payment', 2, 'Payment completed for contract ID 22'),
(7, 'contract', 30, 'New contract started: Data Mining for Sales Trend Analysis');

