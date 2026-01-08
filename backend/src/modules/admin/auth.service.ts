import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  private readonly ADMIN_USER = {
    username: process.env.ADMIN_USERNAME || 'admin',
    password: process.env.ADMIN_PASSWORD || 'ErgoAdmin@2024', // Default hardcoded password if env not set
  };

  constructor(private jwtService: JwtService) {}

  async validateUser(username: string, pass: string): Promise<any> {
    if (
      username === this.ADMIN_USER.username &&
      pass === this.ADMIN_USER.password
    ) {
      const { password, ...result } = this.ADMIN_USER;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { username: user.username, sub: 'admin' };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
