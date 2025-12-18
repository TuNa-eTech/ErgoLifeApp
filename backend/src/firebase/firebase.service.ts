import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { DecodedIdToken } from 'firebase-admin/auth';

export interface FirebaseUserInfo {
  uid: string;
  email: string | null;
  name: string | null;
  picture: string | null;
  provider: 'google.com' | 'apple.com';
}

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    if (admin.apps.length > 0) {
      this.logger.log('Firebase Admin SDK already initialized');
      return;
    }

    const credentialsPath = this.configService.get<string>(
      'FIREBASE_CREDENTIALS_PATH',
    );

    if (credentialsPath) {
      // Initialize with credentials file
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const path = require('path');
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const fs = require('fs');

      const serviceAccountPath = path.resolve(process.cwd(), credentialsPath);
      const serviceAccount = JSON.parse(
        fs.readFileSync(serviceAccountPath, 'utf8'),
      );

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      this.logger.log('Firebase Admin SDK initialized with credentials file');
    } else {
      // Initialize with environment variables
      const projectId = this.configService.get<string>('FIREBASE_PROJECT_ID');
      const clientEmail = this.configService.get<string>(
        'FIREBASE_CLIENT_EMAIL',
      );
      const privateKey = this.configService
        .get<string>('FIREBASE_PRIVATE_KEY')
        ?.replace(/\\n/g, '\n');

      if (!projectId || !clientEmail || !privateKey) {
        throw new Error(
          'Firebase credentials not configured. Set FIREBASE_CREDENTIALS_PATH or FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY',
        );
      }

      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
      this.logger.log(
        'Firebase Admin SDK initialized with environment variables',
      );
    }
  }

  async verifyIdToken(idToken: string): Promise<DecodedIdToken> {
    try {
      return await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      this.logger.error('Failed to verify ID token', error);
      throw error;
    }
  }

  extractUserInfo(decodedToken: DecodedIdToken): FirebaseUserInfo {
    const firebaseIdentities = decodedToken.firebase?.identities;
    let provider: 'google.com' | 'apple.com' = 'google.com';

    if (decodedToken.firebase?.sign_in_provider === 'apple.com') {
      provider = 'apple.com';
    } else if (decodedToken.firebase?.sign_in_provider === 'google.com') {
      provider = 'google.com';
    }

    return {
      uid: decodedToken.uid,
      email: decodedToken.email || null,
      name: decodedToken.name || null,
      picture: decodedToken.picture || null,
      provider,
    };
  }
}
