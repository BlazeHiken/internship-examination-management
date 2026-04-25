# Internship & Examination Management System

A full-stack **Java EE** web application for managing internship placements and online examinations. Built with the **MVC architecture** using Servlets, JSP, and JDBC on Apache Tomcat with MySQL.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Backend** | Java 17, Servlets (`@WebServlet`), JSP |
| **Database** | MySQL 8.0, JDBC with DAO pattern |
| **Server** | Apache Tomcat 9.0 |
| **Frontend** | HTML5, CSS3 (Glassmorphism), Vanilla JS |
| **Security** | Servlet Filters, PreparedStatement, Session Management |

---

## Project Architecture

```
src/main/java/com/project/
├── model/          # 11 POJOs (User, Student, Company, Internship, etc.)
├── dao/            # 10 DAOs (UserDAO, ExamDAO, ReportDAO, AuditDAO, etc.)
├── controller/     # 16 Servlets (Login, Exam, Reports, Audit, etc.)
├── filter/         # 4 Filters (Auth, Role, NoCache, Audit)
└── util/           # 2 Utilities (DBConnection, ValidationUtil)

src/main/webapp/
├── login.jsp, register.jsp
├── student/        # 7 JSPs (dashboard, profile, internships, exams, etc.)
└── admin/          # 13 JSPs (dashboard, companies, exams, reports, audit, etc.)
```

---

## Database Schema

**13 tables** with full referential integrity:

```
users ──── students
  │
  ├── audit_logs
  ├── session_tracking
  └── exam_attempts ──── answers
                           │
companies ── internships ──┤
                           │
              applications ── application_logs
                           │
              exams ── questions ── options
```

**Constraints used:** `PRIMARY KEY`, `FOREIGN KEY` (14), `UNIQUE` (7), `ENUM` (4), `ON DELETE CASCADE/SET NULL`, `DEFAULT`, `NOT NULL`

---

## Modules

### 1. Authentication & Session Management
- User registration (student) and login with password validation
- **Single-session enforcement** — `is_logged_in` DB flag prevents concurrent logins
- **Cross-tab session conflict detection** — when another user logs in on the same browser, the stale tab is redirected to login with a descriptive message
- Role-based access control via `AuthFilter` and `RoleFilter`
- `NoCacheFilter` prevents back-button access after logout
- 30-minute session timeout

### 2. Student Module
- Dashboard with navigation cards
- Profile management (name, course, CGPA, phone)
- Browse internships with **CGPA eligibility filtering**
- Apply for internships (duplicate and deadline validation)
- View application status history

### 3. Admin Module
- Dashboard with 7 management sections
- **Company CRUD** — Add, edit, delete partner companies
- **Internship CRUD** — Post listings linked to companies with stipend and deadline
- **Application Processing** — Shortlist, select, or reject with status logging
- **Live search** on applications table (filter by student name, email, company, status)

### 4. Online Examination
- **Exam lifecycle:** Create → Add Questions → Students Take → Evaluate → Results
- **Question types:** MCQ (auto-evaluated) and Subjective (admin-graded)
- **Marks enforcement:** Cannot add questions exceeding exam's total marks
- **Timed exams:** Server-side countdown with auto-submit on expiry
- **Question navigator:** Sidebar with answered/unanswered indicators
- **Answer auto-save:** `INSERT ON DUPLICATE KEY UPDATE` on every navigation
- **Anti-cheat:** Tab-switch detection via `visibilitychange` API with server-side logging
- **Pending evaluation:** Results hidden until all subjective questions are graded

### 5. Reporting (5 Reports)

| Report | Description |
|---|---|
| **R1** | Students selected per company — grouped with summary cards |
| **R2** | Internship-wise application count — status breakdown per listing |
| **R3** | Exam rank list — per-exam student rankings with percentage bars |
| **R4** | Question-wise performance — MCQ accuracy bars, subjective avg marks |
| **R5** | Suspicious activity logs — tab switches, auto-submissions, login attempts |

- SQL queries use multi-table `JOIN`s, `GROUP BY`, `AVG`, `SUM`, `CASE WHEN`, scaled scoring
- Tabbed interface for switching between reports

### 6. Audit & Security
- **AuditFilter** — Auto-logs all POST actions (login, apply, exam submit, admin ops)
- **Session tracking** — Active sessions dashboard with green pulse indicators
- **Tab-switch logging** — Records exam name and switch count per student
- **Audit log viewer** — 50 entries with color-coded action badges
- **Search + pagination** — Filter by user/action/IP, 10 rows per page with navigation

---

## Advanced Features

| Feature | Implementation |
|---|---|
| **Transaction Management** | `setAutoCommit(false)` + `rollback()` in UserDAO, QuestionDAO, ExamAttemptDAO, ApplicationDAO |
| **SQL Injection Prevention** | `PreparedStatement` used in all 10 DAOs — zero string concatenation |
| **Duplicate Prevention** | `UNIQUE` constraints on applications, exam attempts, and answers |
| **Concurrency Handling** | Single-session enforcement, `INSERT ON DUPLICATE KEY UPDATE` for answers |
| **Input Validation** | Server-side (`ValidationUtil`) + client-side (HTML5 `required`, `max`, `pattern`) |
| **Exception Handling** | try-finally for JDBC resource cleanup, try-catch for audit (silent fail) |
| **Search** | Client-side JS filtering on Applications table with live result count |
| **Pagination** | Client-side 10-per-page pagination on Audit Logs with page navigation |
| **Auto-save** | Exam answers saved on every question navigation |
| **Timer** | Server-enforced countdown with client JS sync, warning at <5 min |

---

## Setup & Installation

### Prerequisites
- Java 17+
- Apache Tomcat 9.0
- MySQL 8.0
- MySQL Connector/J 9.6.0

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/BlazeHiken/internship-examination-management.git
   ```

2. **Create the database**
   ```sql
   CREATE DATABASE project;
   USE project;
   SOURCE database/tables.sql;
   ```

3. **Configure database connection**
   Update `src/main/java/com/project/util/DBConnection.java` with your MySQL credentials.

4. **Deploy to Tomcat**
   - Import as a Dynamic Web Project in Eclipse
   - Add Tomcat 9.0 as the target runtime
   - Add `mysql-connector-j-9.6.0.jar` to `WEB-INF/lib`
   - Run on Server

5. **Default admin account**
   ```sql
   INSERT INTO users (name, email, password, role)
   VALUES ('Admin', 'admin@iem.com', 'admin123', 'ADMIN');
   ```

---

## Screenshots

> The application uses a dark glassmorphism UI theme with gradient backgrounds, frosted glass cards, and color-coded status badges across all pages.

---

## Project Structure

```
internship-examination-management/
├── database/
│   └── tables.sql                    # Complete schema (13 tables)
├── src/main/java/com/project/
│   ├── model/                        # User, Student, Company, Internship,
│   │                                 # Application, Exam, Question, Option,
│   │                                 # ExamAttempt, Answer
│   ├── dao/                          # UserDAO, StudentDAO, CompanyDAO,
│   │                                 # InternshipDAO, ApplicationDAO, ExamDAO,
│   │                                 # QuestionDAO, ExamAttemptDAO, ReportDAO,
│   │                                 # AuditDAO
│   ├── controller/                   # LoginServlet, RegisterServlet,
│   │                                 # StudentDashboardServlet, AdminDashboardServlet,
│   │                                 # ProfileServlet, InternshipListServlet,
│   │                                 # InternshipServlet, MyApplicationsServlet,
│   │                                 # ApplicationManageServlet, ExamListServlet,
│   │                                 # ExamServlet, ExamManageServlet,
│   │                                 # ReportServlet, AuditServlet,
│   │                                 # TabSwitchServlet, LogoutServlet
│   ├── filter/                       # AuthFilter, RoleFilter, NoCacheFilter,
│   │                                 # AuditFilter
│   └── util/                         # DBConnection, ValidationUtil
├── src/main/webapp/
│   ├── login.jsp, register.jsp
│   ├── student/                      # dashboard, profile, internships,
│   │                                 # my_applications, exams, exam_page,
│   │                                 # exam_result
│   └── admin/                        # dashboard, companies, company_form,
│                                     # internships, internship_form,
│                                     # applications, exams, exam_form,
│                                     # exam_questions, exam_attempts,
│                                     # evaluate, reports, audit
└── README.md
```
