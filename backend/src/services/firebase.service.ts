import * as admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

export async function initializeFirebase() {
  try {
    // Check if all required Firebase credentials are available
    const hasAllCredentials = 
      process.env.FIREBASE_PROJECT_ID && 
      process.env.FIREBASE_PRIVATE_KEY && 
      process.env.FIREBASE_CLIENT_EMAIL;

    if (!hasAllCredentials) {
      console.warn('⚠️  Firebase credentials not fully configured. Skipping Firebase initialization for development.');
      console.warn('Set FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL to enable Firebase.');
      // Return a mock admin object for development
      return {
        apps: [],
        initializeApp: () => {},
        auth: () => ({ verifyIdToken: async () => ({}), createUser: async () => ({}) }),
        firestore: () => ({}),
        storage: () => ({}),
        messaging: () => ({}),
      };
    }

    const firebaseConfig = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    };

    if (admin.apps.length === 0) {
      admin.initializeApp({
        credential: admin.credential.cert(firebaseConfig as any),
        databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`,
      });
    }

    return admin;
  } catch (error) {
    console.error('Firebase initialization error:', error);
    if (process.env.NODE_ENV === 'development') {
      console.warn('⚠️  Running in offline/development mode without Firebase');
      return {
        apps: [],
        initializeApp: () => {},
        auth: () => ({ verifyIdToken: async () => ({}), createUser: async () => ({}) }),
        firestore: () => ({}),
        storage: () => ({}),
        messaging: () => ({}),
      };
    }
    throw error;
  }
}

export function getFirebaseAuth() {
  return admin.auth();
}

export function getFirestoreDB() {
  return admin.firestore();
}

export function getFirebaseStorage() {
  return admin.storage();
}

export function getFirebaseMessaging() {
  return admin.messaging();
}
