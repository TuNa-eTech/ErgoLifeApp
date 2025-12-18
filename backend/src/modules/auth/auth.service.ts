import {
  Injectable,
  UnauthorizedException,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService, FirebaseUserInfo } from '../../firebase';
import { AuthProvider } from '@prisma/client';
import { AuthResponseDto, UserDto } from './dto';

export interface JwtPayload {
  sub: string; // User ID
  firebaseUid: string;
  email: string | null;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly prismaService: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async socialLogin(idToken: string): Promise<AuthResponseDto> {
    // 1. Verify Firebase ID Token
    let firebaseUserInfo: FirebaseUserInfo;
    try {
      const decodedToken = await this.firebaseService.verifyIdToken(idToken);
      firebaseUserInfo = this.firebaseService.extractUserInfo(decodedToken);
    } catch (error) {
      this.logger.error('Invalid Firebase ID token', error);
      throw new UnauthorizedException('Invalid ID token');
    }

    // 2. Determine provider
    const provider = this.mapProvider(firebaseUserInfo.provider);

    // 3. Upsert user in database
    let user;
    try {
      user = await this.prismaService.user.upsert({
        where: { firebaseUid: firebaseUserInfo.uid },
        update: {
          email: firebaseUserInfo.email,
          name: firebaseUserInfo.name,
          avatarUrl: firebaseUserInfo.picture,
        },
        create: {
          firebaseUid: firebaseUserInfo.uid,
          provider,
          email: firebaseUserInfo.email,
          name: firebaseUserInfo.name,
          avatarUrl: firebaseUserInfo.picture,
        },
      });
    } catch (error) {
      this.logger.error('Failed to upsert user', error);
      throw new InternalServerErrorException('Failed to create or update user');
    }

    // 4. Generate JWT token
    const payload: JwtPayload = {
      sub: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
    };
    const accessToken = this.jwtService.sign(payload);

    // 5. Return response
    return {
      accessToken,
      user: this.mapUserToDto(user),
    };
  }

  async getMe(userId: string): Promise<UserDto> {
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.mapUserToDto(user);
  }

  private mapProvider(provider: 'google.com' | 'apple.com'): AuthProvider {
    switch (provider) {
      case 'google.com':
        return AuthProvider.GOOGLE;
      case 'apple.com':
        return AuthProvider.APPLE;
      default:
        return AuthProvider.GOOGLE;
    }
  }

  private mapUserToDto(user: {
    id: string;
    firebaseUid: string;
    provider: AuthProvider;
    email: string | null;
    name: string | null;
    avatarId: number | null;
    avatarUrl: string | null;
  }): UserDto {
    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      provider: user.provider,
      email: user.email,
      name: user.name,
      avatarId: user.avatarId,
      avatarUrl: user.avatarUrl,
    };
  }
}
