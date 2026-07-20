# ElimuPath

ElimuPath is a Flutter and Firebase platform that helps students discover
schools and helps schools receive and review student applications. Users select
whether they are joining as a _Student_ or a _School_ during registration,
then receive an experience designed for that account type.

## Main features

### Student experience

- Register and maintain a student profile.
- Select gender and an education level from Senior 1 through Senior 6.
- Browse, search, and filter schools.
- View school details, fees, facilities, available spaces, and combinations.
- Identify approved schools using the verified-school badge.
- Like schools and view them on the _Liked schools_ page.
- Apply to a school and optionally attach a transcript.
- Follow application statuses: submitted, approved, on hold, or denied.

### School experience

- Register a school and its administrator account together.
- Maintain school contact, fee, availability, stage, and facility information.
- View applications submitted specifically to the school.
- Review student information and uploaded transcripts.
- Approve, hold, or deny applications.
- View application totals and status statistics on the dashboard.

## Design

The interface follows the supplied ElimuPath UI/UX design:

- Epilogue typography
- Pale green gradient backgrounds
- Large lightweight headings
- Thin outlined fields and cards
- Black primary actions
- Lime pill-shaped bottom navigation
- Green verification and approval indicators
- Coral denied-status indicators

The app includes 17 different bundled images representing Rwandan schools and
classrooms. Their source and attribution metadata is stored with the school
documents. Bundling the images avoids remote-image throttling and allows them
to display reliably in the emulator.

## Technology

- Flutter and Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage for user uploads
- Firebase Security Rules
- Firebase composite indexes

## Project structure

```text
lib/
  data/       Firebase and demo backend implementations
  models/     User, school, application, announcement, and favorite models
  screens/    Authentication, student, and school administrator screens
  widgets/    Shared ElimuPath UI components
assets/
  fonts/      Epilogue font
  images/     Branding, fallback, and bundled school images
test/         Backend and widget tests
tool/         Firestore data maintenance scripts
```

## Firestore collections

| Collection    | Purpose                                                        |
| ------------- | -------------------------------------------------------------- |
| users         | Student and school administrator profiles                      |
| schools       | School information, verification, facilities, and availability |
| applications  | Student applications and school review status                  |
| favorites     | Student-to-school liked relationships                          |
| announcements | Announcements posted by schools                                |

Document IDs are used as the ERD primary keys. Relationship fields such as
studentId, schoolId, userId, ownerId, and postedBy act as foreign
keys. See [FIRESTORE_SCHEMA.md](FIRESTORE_SCHEMA.md) for the complete schema.

## Firebase project

The checked-in Firebase configuration targets:

```text
elimupath-733f9
```

Install the Firebase CLI and authenticate:

```sh
npm install --global firebase-tools
firebase login
firebase use elimupath-733f9
```

Deploy Firestore rules and indexes:

```sh
firebase deploy --only firestore:rules,firestore:indexes
```

Deploy Storage rules after Firebase Storage has been initialized:

```sh
firebase deploy --only storage
```

### Firebase Storage requirement

Profile pictures, school-uploaded pictures, and transcripts require a Firebase
Storage bucket. Enable billing if Firebase requests it, then open the Firebase
Console for elimupath-733f9, select _Storage, and click \*\*Get started_.

Until Storage is initialized, account details and applications still save, but
optional uploaded files are skipped after a timeout and the app displays a
warning. Bundled school-card images do not require Firebase Storage.

## Run locally

Requirements:

- Flutter SDK compatible with Dart ^3.12.0
- Android Studio or another supported Flutter development environment
- An Android emulator, physical device, browser, or desktop target

Install packages:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

When adding or changing bundled assets, perform a complete rebuild:

```sh
flutter clean
flutter pub get
flutter run
```

Hot reload cannot add new files to an already compiled asset bundle.

## Tests and analysis

```sh
flutter analyze
flutter test
```

The test suite includes document-model mapping and an end-to-end demo backend
flow covering sign-in, favorites, application submission, and school review.

## School data tools

The tool directory contains authenticated maintenance utilities used during
development:

- seed_schools.js creates 15 varied school documents.
- complete_school_data.js fills missing school fields and verifies records.
- assign_school_images.js assigns unique bundled images to live schools.
- download_school_images.js downloads the licensed source images locally.

These scripts modify the live Firebase project. Review their project ID and
data before running them.

Example:

sh
node tool/seed_schools.js

## Account routing

Both account types use the same sign-in page. After authentication:

- student accounts open the For You page.
- schoolAdmin accounts open the school dashboard.

School accounts can manage only their connected school and its applications.
Students can access only their own profile, favorites, and applications.

## Security notes

- Users cannot change their own role or connected school ID.
- Schools cannot mark themselves as verified.
- Favorite document IDs are scoped to the authenticated student.
- Students can create only their own applications.
- A school can read and review only applications addressed to that school.
- Application status is the only review data a school administrator can edit.

## Team

Developed as the Group 39 final project submission.
