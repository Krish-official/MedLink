import admin from 'firebase-admin';

let initialized = false;

export function initFirebase() {
  if (initialized) return;

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  // Allow running without Firebase in local dev
  if (!projectId || !clientEmail || !privateKey) {
    console.warn('⚠️ Firebase env vars missing. Push notifications disabled.');
    return;
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  });

  initialized = true;
}

export function firebaseMessaging() {
  initFirebase();
  // @ts-ignore
  return admin.apps?.length ? admin.messaging() : null;
}