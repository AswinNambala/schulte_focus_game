# Google Play Store Publication Checklist & Setup Guide

This guide details all necessary configurations in the **Google Play Console** for **Schulte Focus** (`com.aswinnambala.schulte_focus`).

---

## 1. App Details & Store Listing
- **App Name:** Schulte Focus: Vision & Speed
- **Short Description (78/80 chars):**  
  `Train peripheral vision, focus, and visual reaction speed with Schulte tables.`
- **Full Description:** (See `store/full_description.txt`)
- **Category:** Games > Puzzle / Brain Games OR Education
- **Tags:** Brain Training, Concentration, Focus, Speed Reading, Puzzle

---

## 2. Store Listing Graphics
- **App Icon:** 512 x 512 px, 32-bit PNG with alpha (max 1 MB).
- **Feature Graphic:** 1024 x 500 px, JPG or 24-bit PNG (no alpha).
- **Screenshots:**
  - Phone: Minimum 2 screenshots (16:9 or 18:9, e.g., 1080x1920 or 1080x2400).
  - 7-inch tablet: Minimum 1 screenshot (optional but recommended).
  - 10-inch tablet: Minimum 1 screenshot (optional but recommended).

---

## 3. Policy & Content Rating (IARC)
- **Privacy Policy URL:** `https://schulte-focus-2026.web.app/privacy-policy`
- **Account Deletion URL:** `https://schulte-focus-2026.web.app/delete-account`
- **Target Audience:** Age 13 and up.
- **IARC Content Rating Questionnaire:**
  - Category: Consumer / Utility / Game
  - Violence: **No**
  - Fear / Horror: **No**
  - Sexual Content / Nudity: **No**
  - Simulated Gambling: **No**
  - Language: **No**
  - Controlled Substances: **No**
  - Location Sharing: **No**
  - User Interactions: Only anonymous focus performance stats stored in own cloud account.
  - Expected Rating: **PEGI 3 / ESRB Everyone**.

---

## 4. Google Play App Signing & Firebase Integration
> ⚠️ **CRITICAL STEP FOR GOOGLE SIGN-IN TO WORK FROM PLAY STORE:**
1. When uploading the release App Bundle (`app-release.aab`), Google Play App Signing will generate a **Play App Signing Key**.
2. In Google Play Console, navigate to:  
   **Release > Setup > App signing**.
3. Copy the **App signing key certificate SHA-1 and SHA-256 fingerprints**.
4. In Firebase Console (or via Firebase CLI):  
   Add the Play Signing SHA-1 and SHA-256 fingerprints:
   ```bash
   firebase apps:android:sha:create 1:2533456476:android:fc2543d687aae6fead4499 <PLAY_SIGNING_SHA1> --project schulte-focus-2026
   firebase apps:android:sha:create 1:2533456476:android:fc2543d687aae6fead4499 <PLAY_SIGNING_SHA256> --project schulte-focus-2026
   ```
5. Re-download `google-services.json` and replace it in `android/app/`.

---

## 5. Closed Testing Requirements (Personal Developer Accounts)
- Since November 2023, Google requires personal developer accounts to run a **Closed Test** with at least **12 testers** who have opted in for at least **14 consecutive days** before applying for production access.
- Steps:
  1. Go to **Testing > Closed testing**.
  2. Create an **Alpha / Closed Track**.
  3. Upload `app-release.aab`.
  4. Create an email list of at least 12 testers (or Google Group).
  5. Share the opt-in link with your testers.
  6. Maintain the test for 14 continuous days.
  7. Apply for production release access in Play Console dashboard.
