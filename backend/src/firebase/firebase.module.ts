import { Module, Global } from '@nestjs/common';
import { FirebaseService } from './firebase.service';
import { FcmService } from './fcm.service';

@Global()
@Module({
  providers: [FirebaseService, FcmService],
  exports: [FirebaseService, FcmService],
})
export class FirebaseModule {}
