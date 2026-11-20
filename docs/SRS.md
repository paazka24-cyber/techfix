# TechFix: Software Requirements Specification

**Project:** TechFix, Device Repair & Technician Booking System
**Author:** [Amin, Abdirizak, Apdifatah, Huzien] | **Course:** [Mobile_App] | **Date:** November 2026

## 1. Introduction

### 1.1 Purpose

TechFix is a mobile application that lets customers request repairs for electronic devices and connect with technicians. Administrators oversee users, requests and categories.

### 1.2 Scope

One Flutter application with role-based access for three roles: Customer, Technician and Admin.

### 1.3 Technology Stack

| Layer            | Technology                                                           |
| ---------------- | -------------------------------------------------------------------- |
| Frontend         | Flutter, Dart, Material 3                                            |
| State management | Riverpod                                                             |
| Authentication   | Firebase Authentication (email/password, Google)                     |
| Database         | Cloud Firestore                                                      |
| Media storage    | Cloudinary (photos and video; Firebase Storage requires a paid plan) |
| Notifications    | In-app notifications (Firestore) and Firebase Cloud Messaging setup  |
| Tools            | VS Code, Git, GitHub                                                 |

## 2. Overall Description

### 2.1 User Classes

- **Customer:** registers, creates and tracks repair requests, chats, rates technicians.
- **Technician:** views open requests, accepts or rejects them, updates repair status, chats, views reviews.
- **Admin:** views all users and requests, manages categories, changes user roles, monitors activity.

### 2.2 Constraints

- Firebase free (Spark) plan: no Cloud Functions and no Firebase Storage.
- Automatic server-side push delivery needs Cloud Functions (Blaze plan). TechFix stores FCM tokens and writes notification documents so this can be added later.

### 2.3 Assumptions

Users have an internet connection and a valid email address.

## 3. Functional Requirements

### 3.1 Authentication

| ID   | Requirement                                                                                   |
| ---- | --------------------------------------------------------------------------------------------- |
| FR-1 | Users shall register with name, email, phone and password. New accounts are always customers. |
| FR-2 | Users shall log in with email/password or Google.                                             |
| FR-3 | Users shall reset a forgotten password by email.                                              |
| FR-4 | Email/password users shall verify their email before accessing the app.                       |
| FR-5 | Users shall log out.                                                                          |
| FR-6 | After login, the app shall open the home screen matching the user's role.                     |

### 3.2 Customer

| ID    | Requirement                                                                                           |
| ----- | ----------------------------------------------------------------------------------------------------- |
| FR-7  | View the list of technicians and their profiles, ratings and reviews.                                 |
| FR-8  | Create a repair request: device type, model, problem description, up to 3 photos, one optional video. |
| FR-9  | Track request progress through the status flow.                                                       |
| FR-10 | Cancel a request while it is Submitted or Assigned.                                                   |
| FR-11 | Chat with the assigned technician.                                                                    |
| FR-12 | Rate and review the technician once the repair is Completed or Delivered (one review per request).    |
| FR-13 | Receive notifications.                                                                                |

### 3.3 Technician

| ID    | Requirement                                          |
| ----- | ---------------------------------------------------- |
| FR-14 | Edit own profile (name, phone, specialization, bio). |
| FR-15 | View open requests, accept or reject them.           |
| FR-16 | Update the status of accepted jobs.                  |
| FR-17 | Chat with the customer of a job.                     |
| FR-18 | View received reviews and average rating.            |
| FR-19 | Receive notifications.                               |

### 3.4 Admin

| ID    | Requirement                                                 |
| ----- | ----------------------------------------------------------- |
| FR-20 | View all users, filtered by role.                           |
| FR-21 | Change a user's role (this is how technicians are created). |
| FR-22 | View all repair requests, filtered by status.               |
| FR-23 | Add, rename and delete device categories.                   |
| FR-24 | View system overview: counts and recent activity.           |

### 3.5 Repair Status Flow

`Submitted → Assigned → In Review → In Progress → Waiting for Parts → Completed → Delivered`, plus `Cancelled`. Statuses are stored as lowercase strings (for example `in_progress`) and converted to labels for display.

### 3.6 Notifications

Notifications are created for: new repair request (to technicians), request accepted, status update, new chat message, repair completed.

## 4. Non-Functional Requirements

| ID    | Requirement                                                                                     |
| ----- | ----------------------------------------------------------------------------------------------- |
| NFR-1 | **Security:** Firestore rules enforce role-based access; no user can change their own role.     |
| NFR-2 | **Usability:** Material 3 interface, light and dark mode, responsive layout.                    |
| NFR-3 | **Performance:** real-time updates through Firestore streams.                                   |
| NFR-4 | **Reliability:** input validation, friendly error messages, loading states.                     |
| NFR-5 | **Maintainability:** layered architecture (screens, providers, repositories, services, models). |

## 5. Architecture

`Screen → Provider (Riverpod) → Repository → Service → Firebase`

```
lib/
  core/ (constants, theme)   models/   services/   repositories/
  providers/   routes/   screens/ (auth, customer, technician, admin, chat, notifications)   widgets/
```

## 6. Limitations and Future Work

- Server-side push delivery via Cloud Functions (needs the Blaze plan).
- Cloudinary unsigned uploads; production would use signed uploads from a server.
- Field-level validation in Firestore rules could be tightened further.
- Unread chat badges and message deletion.
