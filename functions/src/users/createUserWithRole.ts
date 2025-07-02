import { https } from 'firebase-functions';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';

export const createUserWithRole = onCall(async (request) => {
  const { email, password, role } = request.data;

  if (!email || !password || !role) {
    throw new https.HttpsError('invalid-argument', 'Missing email, password, or role.');
  }

  const allowedRoles = ['admin', 'clinician'];
  if (!allowedRoles.includes(role)) {
    throw new https.HttpsError('permission-denied', 'Invalid role assignment.');
  }

  try {
    // Create Firebase Auth user
    const userRecord = await getAuth().createUser({
      email,
      password,
    });

    // Assign custom claims
    await getAuth().setCustomUserClaims(userRecord.uid, { role });

    // Store user metadata in Firestore
    await getFirestore().collection('users').doc(userRecord.uid).set({
      email,
      role,
      createdAt: new Date().toISOString(),
      source: 'adminPanel',
    });

    return {
      success: true,
      uid: userRecord.uid,
    };
  } catch (error: any) {
    console.error('Error creating user:', error);
    throw new https.HttpsError('internal', error.message || 'Unknown error');
  }
});
