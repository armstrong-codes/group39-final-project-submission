# Firestore collections

Firestore document IDs represent every ERD `id` primary key; the `id` is not
duplicated inside the document.

## `users/{userId}`

`fullName` in the ERD is represented by `firstName` and `lastName` in the app.
Documents contain `email`, `role` (`student` or `schoolAdmin`), `photoUrl`,
`schoolId`, and `createdAt`, plus the student profile fields used by the UI.

## `schools/{schoolId}`

Documents contain `name`, `district`, `type`, `gender`, `combinations`,
`schoolFees`, `admissionStatus`, `availableSpots`, `performanceIndex`,
`facilities`, `imageUrls`, `verified`, `ownerId`, contact fields, and
`createdAt`. Existing UI aliases (`location`, `sector`, `isActive`) remain for
backward compatibility.

## `applications/{applicationId}`

Documents contain the foreign keys `studentId` and `schoolId`, the requested
`educationLevel`/combination, previous school, status, and submission/update
timestamps. Student and school snapshot fields are retained so an application
still displays correctly if a related profile later changes.

## `announcements/{announcementId}`

Fields: `schoolId`, `title`, `body`, `postedAt`, and `postedBy`.

## `favorites/{userId}_{schoolId}`

Fields: `userId`, `schoolId`, and `addedAt`. The deterministic document ID
enforces one favorite per user/school pair and makes toggling atomic.

Deploy the schema support with:

```sh
npx firebase-tools deploy --only firestore:rules,firestore:indexes
```

Firestore creates each collection automatically when its first document is
written by the app.
