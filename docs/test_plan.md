# TechFix: Test Plan

Environment: Flutter web (Chrome and Edge) and/or Android. Accounts needed: one customer, one technician, one admin.

| ID  | Feature                       | Steps                           | Expected result                            | Pass? |
| --- | ----------------------------- | ------------------------------- | ------------------------------------------ | ----- |
| T1  | Register                      | Fill valid form                 | Account created, verification screen shown |       |
| T2  | Register duplicate            | Reuse an email                  | "Email already registered"                 |       |
| T3  | Weak password                 | Enter 3 characters              | Validation error                           |       |
| T4  | Email verification            | Click link, tap "I've verified" | Home screen opens                          |       |
| T5  | Login wrong password          | Wrong password                  | Generic error, no crash                    |       |
| T6  | Forgot password               | Enter registered email          | Confirmation message, email received       |       |
| T7  | Google sign-in                | Continue with Google            | Logged in, profile created                 |       |
| T8  | Role routing                  | Log in as each role             | Customer, technician, admin homes open     |       |
| T9  | Logout                        | Tap logout                      | Returns to login                           |       |
| T10 | Create request                | Fill form, submit               | Appears in list as Submitted               |       |
| T11 | Upload media                  | Add 3 photos and a video        | Visible in request details                 |       |
| T12 | Validation                    | Submit empty form               | Field errors shown                         |       |
| T13 | Cancel request                | Cancel a Submitted request      | Status Cancelled                           |       |
| T14 | Accept request                | Technician accepts              | Status Assigned, customer notified         |       |
| T15 | Reject request                | Technician rejects              | Hidden for that technician only            |       |
| T16 | Update status                 | Technician changes status       | Customer sees live update                  |       |
| T17 | Chat                          | Send messages both ways         | Instant delivery, ticks update             |       |
| T18 | Review                        | Rate a Completed request        | Review saved, average updates              |       |
| T19 | Review blocked                | Open non-completed request      | No rate button                             |       |
| T20 | Notifications                 | Perform T10, T14, T16, T17      | Bell badge shows, mark read works          |       |
| T21 | Admin users                   | Change a user's role            | New role applies after re-login            |       |
| T22 | Admin categories              | Add, rename, delete             | Customer dropdown updates live             |       |
| T23 | Admin requests                | Filter by status                | Correct list                               |       |
| T24 | Security: customer vs admin   | Customer tries admin actions    | Denied by rules                            |       |
| T25 | Security: stranger reads chat | Third user reads a chat         | permission-denied                          |       |
| T26 | Theme                         | Toggle light/dark               | All screens readable                       |       |

Record the date, tester and any defects below the table.
