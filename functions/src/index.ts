
import { onRequest } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';

// Import your custom Cloud Functions
import { createUserWithRole } from './users/createUserWithRole';

// Example HTTP function (you can remove this if unused)
export const helloWorld = onRequest((request, response) => {
  logger.info('Hello logs!', { structuredData: true });
  response.send('Hello from Firebase!');
});

// Export the user management function
export { createUserWithRole };
