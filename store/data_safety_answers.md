# Google Play Console — Data Safety Form Guide

Complete answers to fill out the Google Play Data Safety questionnaire for **Schulte Focus** (`com.aswinnambala.schulte_focus`).

---

### 1. Data Collection and Security
- **Does your app collect or share any of the required user data types?**  
  👉 **Yes**
- **Is all of the user data collected by your app encrypted in transit?**  
  👉 **Yes** (All communication with Google Firebase Authentication and Firestore uses TLS/SSL).
- **Do you provide a way for users to request that their data be deleted?**  
  👉 **Yes**
- **URL for deletion requests:**  
  👉 `https://schulte-focus-2026.web.app/delete-account` (or `https://<your-domain>/delete-account.html`)

---

### 2. Data Types Collected & Declared

#### A. Personal Info
| Data Type | Collected? | Shared? | Ephemeral? | Required / Optional | Purpose |
|---|---|---|---|---|---|
| **Name** | Yes | No | No | Optional | App functionality, Personalization |
| **Email address** | Yes | No | No | Required | App functionality, Account management |
| **User IDs** (Firebase UID) | Yes | No | No | Required | App functionality, Account management |

#### B. App Activity
| Data Type | Collected? | Shared? | Ephemeral? | Required / Optional | Purpose |
|---|---|---|---|---|---|
| **App interactions** | Yes | No | No | Required | Analytics, Personalization (tracking completion times, levels, streaks) |

#### C. App Info and Performance
| Data Type | Collected? | Shared? | Ephemeral? | Required / Optional | Purpose |
|---|---|---|---|---|---|
| **Crash logs** | Yes | No | No | Required | Analytics, Diagnostics (Firebase Crashlytics) |
| **Diagnostics** | Yes | No | No | Required | Analytics (Firebase Crashlytics & Analytics) |

---

### 3. Deletion Mechanism
- Users can delete their data directly in-app: **Profile > Delete Account**
- Alternatively, users can submit an online request via the public web page.
- On deletion, all user data, authentication credentials, and Firestore documents under `users/{uid}` and `users/{uid}/sessions/*` are permanently erased.
