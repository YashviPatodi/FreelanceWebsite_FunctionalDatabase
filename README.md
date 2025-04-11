# TheMetGig: Connecting Talent

## Overview

TheMetGig is a skill-driven freelance marketplace designed to connect clients with top talent. The platform prioritizes relevant connections, offering role-specific experiences for efficient project management.

## Key Features

*   Skill-Based Matching: Connect with the right freelancers.
*   Role-Specific Dashboards: Tailored experiences for clients & freelancers.
*   Project Management Tools: Streamlined listings, bidding, & evaluation.
*   Comprehensive Profiles: Showcase skills, certifications, & portfolios.

## Tech Stack

*   Frontend: HTML, CSS, JavaScript
*   Backend: Node.js (Planned)
*   Database: SQL (Planned)

## Data Model Highlights

The database schema is designed for scalability and efficiency, emphasizing relationships between key entities:

*   Users: Core data for both clients and freelancers.
    *   *Relationships:* Clients post Projects (1:M); Freelancers submit Proposals (M:N).
*   Profiles: Detailed client and freelancer information.
*   Projects: Represent specific job opportunities.
    *   *Relationships:* Require specific Skills (M:N).
*   Proposals: Freelancer bids on projects.
*   Contracts: Formalize agreements between clients and freelancers.
    *   *Relationships:* Manage Payments and Reviews.
*   Payments: Track financial transactions.
*   Reviews: Provide feedback and ratings.
*   Skills & Categories: Enable precise matching.
*   PortfolioItems: Showcase freelancer capabilities.
