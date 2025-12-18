import { Module } from '@nestjs/common';
import { AppConfigModule } from './config/config.module';
import { PrismaModule } from './prisma/prisma.module';
import { FirebaseModule } from './firebase';
import { UserModule } from './modules/user/user.module';
import { AuthModule } from './modules/auth/auth.module';

@Module({
  imports: [
    AppConfigModule,
    PrismaModule,
    FirebaseModule,
    AuthModule,
    UserModule,
  ],
})
export class AppModule {}
