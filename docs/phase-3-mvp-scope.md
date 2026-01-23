# OjekHub - Phase 3: MVP Scope

## Technical Stack

| Layer        | Technology             | Deployment        |
| ------------ | ---------------------- | ----------------- |
| **Frontend** | Flutter                | Android APK       |
| **Backend**  | NestJS                 | Vercel Serverless |
| **Database** | Supabase (PostgreSQL)  | Supabase Cloud    |
| **Auth**     | Supabase Auth (Google) | Supabase Cloud    |

---

## MVP Features (Mandatory)

### Authentication

| Feature               | Description                                          |
| --------------------- | ---------------------------------------------------- |
| Google Sign-In        | Login via Google OAuth through Supabase              |
| Role Selection        | First-time users select: Farmer / Warehouse / Worker |
| Worker Type Selection | Workers select: Ojek / Pekerja Harian                |
| Profile Setup         | Name, phone (WhatsApp), location                     |

### Employer Features (Farmer / Warehouse)

| Feature        | Description                                                       |
| -------------- | ----------------------------------------------------------------- |
| Create Job     | Post new job with worker type, count, description, location, date |
| View My Jobs   | List of jobs created by user                                      |
| View Job Queue | See workers who joined each job                                   |
| Worker Contact | Tap to open WhatsApp with worker's number                         |
| Close Job      | Mark job as filled/closed                                         |

### Worker Features

| Feature     | Description                                   |
| ----------- | --------------------------------------------- |
| Job Feed    | View jobs filtered by worker type             |
| Job Details | See job description, location, date, employer |
| Join Queue  | Add self to job queue                         |
| Leave Queue | Remove self from job queue                    |
| My Queue    | View jobs currently joined                    |

### Queue System

| Feature            | Description                     |
| ------------------ | ------------------------------- |
| First-Come Display | Queue ordered by join timestamp |
| Worker Count       | Show joined vs needed count     |
| Queue Status       | Show position in queue          |

### Price Estimation

| Feature             | Description                                     |
| ------------------- | ----------------------------------------------- |
| Fixed Price Display | Show estimated price per worker type            |
| Price Source        | Hardcoded in app config (not editable by users) |

---

## Excluded Features (NOT in MVP)

| Feature                | Reason                                         |
| ---------------------- | ---------------------------------------------- |
| ❌ In-app chat         | WhatsApp is sufficient; reduces complexity     |
| ❌ Payment processing  | Legal/financial complexity; out of scope       |
| ❌ Task tracking       | MVP ends at connection; no progress monitoring |
| ❌ Ratings/reviews     | Requires completed job tracking                |
| ❌ Push notifications  | Can add in v1.1                                |
| ❌ Worker verification | Trust builds organically                       |
| ❌ Multi-role accounts | One role per user simplifies UX                |
| ❌ Job editing         | Delete and recreate instead                    |
| ❌ Search/filter       | Worker type filter is built-in                 |
| ❌ Admin panel         | Manual DB queries for MVP                      |
| ❌ Analytics dashboard | Use Supabase dashboard                         |
| ❌ iOS support         | Android-only for MVP                           |

---

## Definition of Done

### Feature Complete

| Criteria                     | Validation                     |
| ---------------------------- | ------------------------------ |
| All MVP features implemented | Checklist sign-off             |
| Google login works           | Test on real device            |
| Role selection persists      | Logout/login test              |
| Jobs appear in worker feed   | Create job → verify visibility |
| Queue join/leave works       | Multiple worker test           |
| WhatsApp redirect works      | Tap → opens WhatsApp           |

### Quality Criteria

| Criteria                 | Validation           |
| ------------------------ | -------------------- |
| No critical bugs         | Manual QA pass       |
| App doesn't crash        | 30-minute usage test |
| Loads in < 3 seconds     | Stopwatch test       |
| Works on Android 8+      | Test on old device   |
| Works offline gracefully | Airplane mode test   |

### Deployment Criteria

| Criteria                | Validation                 |
| ----------------------- | -------------------------- |
| APK builds successfully | `flutter build apk` passes |
| API deployed to Vercel  | Health check endpoint      |
| Supabase configured     | Auth + DB functional       |
| 5 test users onboarded  | Real device installs       |

---

## Screen Inventory

| Screen                | Role             | Priority |
| --------------------- | ---------------- | -------- |
| Splash                | All              | P0       |
| Login (Google)        | All              | P0       |
| Role Selection        | All              | P0       |
| Worker Type Selection | Worker           | P0       |
| Profile Setup         | All              | P0       |
| Employer Dashboard    | Farmer/Warehouse | P0       |
| Create Job Form       | Farmer/Warehouse | P0       |
| My Jobs List          | Farmer/Warehouse | P0       |
| Job Queue View        | Farmer/Warehouse | P0       |
| Worker Dashboard      | Worker           | P0       |
| Job Feed              | Worker           | P0       |
| Job Detail            | Worker           | P0       |
| My Queue              | Worker           | P0       |

**Total: 13 screens**

---

## API Endpoints

| Method | Endpoint          | Description           |
| ------ | ----------------- | --------------------- |
| POST   | `/auth/google`    | Exchange Google token |
| GET    | `/users/me`       | Get current user      |
| PUT    | `/users/me`       | Update profile        |
| POST   | `/jobs`           | Create job            |
| GET    | `/jobs`           | List jobs (filtered)  |
| GET    | `/jobs/:id`       | Get job details       |
| DELETE | `/jobs/:id`       | Close/delete job      |
| POST   | `/jobs/:id/queue` | Join queue            |
| DELETE | `/jobs/:id/queue` | Leave queue           |
| GET    | `/jobs/:id/queue` | Get queue list        |
| GET    | `/config/prices`  | Get price config      |

**Total: 11 endpoints**
