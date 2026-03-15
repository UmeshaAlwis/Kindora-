export interface Config {
  port: number;
  nodeEnv: string;
  databaseUrl: string;
  firebaseProjectId: string;
  jwtSecret: string;
}

export function validateConfig(): Config {
  const requiredEnvVars = [
    'DB_HOST',
    'DB_PORT',
    'DB_USER',
    'DB_PASSWORD',
    'DB_NAME',
    'FIREBASE_PROJECT_ID',
    'JWT_SECRET',
  ];

  const missingVars = requiredEnvVars.filter(
    (envVar) => !process.env[envVar]
  );

  if (missingVars.length > 0) {
    console.warn(
      `Missing environment variables: ${missingVars.join(', ')}. Using defaults or will fail at runtime.`
    );
  }

  return {
    port: parseInt(process.env.PORT || '5000', 10),
    nodeEnv: process.env.NODE_ENV || 'development',
    databaseUrl: process.env.DATABASE_URL || '',
    firebaseProjectId: process.env.FIREBASE_PROJECT_ID || '',
    jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
  };
}
