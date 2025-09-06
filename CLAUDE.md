# 📰 Digital Bulletin Board

A web-based solution to replace the physical city bulletin board used for publishing public meeting agendas.  
Built with **Quasar Framework (Vue.js)** for the frontend and **AWS** services for the backend.

---

## 📌 Overview

By law, cities must make all meetings/agendas publicly visible at least **48 hours before** the meeting.  
Currently, this is done via a **physical bulletin board** where departments manually post agendas.

The **Digital Bulletin Board** modernizes this process with a secure, web-based system that allows departments to upload agendas, admins to oversee postings, and the public to view them easily online.

---

## 🎯 Goals

- Provide a **public-facing digital display** of all agendas/meetings.
- Enable **city staff** to upload and manage agendas.
- Allow **admins** to oversee, approve, or remove postings.
- Ensure **compliance with 48-hour posting rules**.
- Maintain an **audit trail** of all postings.

---

## ⚙️ Tech Stack

**Frontend**

- Quasar Framework (Vue.js)
- Responsive UI for web + kiosk displays

**Backend (AWS)**

- **Authentication:** Cognito
- **Storage:** S3 for agenda PDFs
- **Database:** DynamoDB for metadata & logs
- **API:** API Gateway + Lambda
- **Notifications:** SNS/SES for confirmations & alerts
- **Hosting:** S3 + CloudFront

---

## 📂 Core Features

### 1. Public Display (Digital Board)

- View upcoming and past meetings.
- Search & filter by department, date, or keywords.
- Auto-refresh for kiosk/TV mode.

### 2. User Side (City Staff)

- Login with Cognito.
- Upload agenda documents (PDF).
- Fill in required meeting details.
- Post automatically (or pending admin approval).

### 3. Admin Side

- Dashboard to oversee all postings.
- Approve/deny/take down agendas.
- Upload on behalf of departments.
- Role management (staff, admin, super admin).
- Audit log of all actions.

---

## 🔒 Compliance & Security

- Immutable timestamps on all postings.
- 48-hour rule enforcement (no late postings).
- Archived postings (no permanent deletion).
- HTTPS via CloudFront.
- Private S3 with signed URLs for document access.

---

## 🚀 Roadmap

**MVP**

- Public board view
- Staff upload form with login
- Admin dashboard for moderation

**Phase 2**

- Enhanced search & filters
- Notifications (staff reminders, admin alerts)
- Archived/public past agendas

**Phase 3**

- Department-level analytics
- API for third-party integrations
- Multi-language support

---

**Edits and Feedback**

- Each agenda item in the bulletin board should display the pdf itself and if the pdf is more than one page it should cycle through each page, lets make this an option that can toggle wether or not to show/display the actual pdf - if need be we can pre-process the pdf into images if it makes it easier

- the details currently displayed for each agenda item is also fine but they can be a small note in the bottom, and for general look up

- the public board should have a "display mode", that strictly just displays the agenda items and nothing else, since this will be displayed on a large screen for the public to see, on display mode the pdf preview should automatically be toggeled on

- there should also be a field that notes when the pdf should be taken down or archived, add a toggle to do this manually or automatically
