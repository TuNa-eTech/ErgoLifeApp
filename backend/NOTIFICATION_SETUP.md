# Backend Notification System - Setup Guide

## Status: ✅ Code Complete - Pending Database Migration

### What Has Been Created

#### 1. Database Schema (`prisma/schema.prisma`)
- ✅ Added `NotificationType` enum (14 types)
- ✅ Added `NotificationPriority` enum
- ✅ Added `Notification` model with all required fields
- ✅ Added indexes for query optimization
- ✅ Added relation to `User` model

#### 2. FCM Service (`src/firebase/fcm.service.ts`)
- ✅ Send notification to single device
- ✅ Send notification to multiple devices (multicast)
- ✅ Send notification to topic (for house-based notifications)
- ✅ Subscribe/unsubscribe to topics
- ✅ Error handling for invalid tokens

#### 3. Notifications Module
- ✅ DTOs with validation (`dto/notification.dto.ts`)
- ✅ Service with CRUD operations (`notifications.service.ts`)
- ✅ Controller with REST API endpoints (`notifications.controller.ts`)
- ✅ Module configuration (`notifications.module.ts`)

#### 4. Streak Reminder Service (`streak-reminder.service.ts`)
- ✅ Daily cron job (20:00 GMT+7)
- ✅ Find users without today's activity
- ✅ Dynamic notification messages based on streak
- ✅ Manual trigger for testing

#### 5. Integration
- ✅ Updated `FirebaseModule` to export `FcmService`
- ✅ Registered `NotificationsModule` in `app.module.ts`
- ✅ Installed `@nestjs/schedule` for cron jobs

---

## Next Steps - Action Required 🚨

### Step 1: Start Database
The database needs to be running to apply the migration:

```bash
cd /Users/anhtu/MySpace/Personal\ Project/ErgoLifeApp/backend
# Start your PostgreSQL database (Docker or local)
# Example: docker-compose up -d postgres
```

### Step 2: Generate Prisma Client & Run Migration
Once the database is running:

```bash
# Generate Prisma client with new types
npx prisma generate

# Run migration
npx prisma migrate dev --name add_notifications
```

This will:
- Create the `notifications` table
- Add the enum types
- Update Prisma client with `Notification`, `NotificationType`, `NotificationPriority` types
- Fix all TypeScript errors

### Step 3: Verify Installation

```bash
# Check if @nestjs/schedule is installed
npm list @nestjs/schedule

# Should show: @nestjs/schedule@4.x.x
```

### Step 4: Test the Setup

Once database is migrated, you can test:

1. **Start the backend:**
   ```bash
   npm run start:dev
   ```

2. **Test notification endpoint:**
   ```bash
   # Get auth token first by logging in
   # Then test the notification test endpoint
   curl -X POST http://localhost:3000/notifications/test \
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
   ```

3. **Manual trigger streak reminder:**
   You can add this admin endpoint to test streak reminders immediately.

---

## API Endpoints Available

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | Get user's notifications (paginated) |
| GET | `/notifications/unread-count` | Get unread count |
| PATCH | `/notifications/:id/read` | Mark as read |
| PATCH | `/notifications/read-all` | Mark all as read |
| DELETE | `/notifications/:id` | Delete notification |
| POST | `/notifications/test` | Create test notification |

---

## Configuration Needed

### Firebase Admin SDK
The FCM service uses `firebase-admin` which is already installed. Make sure your `ergolife-firebase-adminsdk.json` file is properly configured in the Firebase initialization.

### Timezone
Cron job is set to `Asia/Bangkok` (GMT+7). If you need a different timezone, update in `streak-reminder.service.ts`:

```typescript
@Cron('0 0 20 * * *', {
  timeZone: 'Your/Timezone', // Change this
})
```

---

## What Happens After Migration

Once you run the migration successfully:

1. ✅ All TypeScript errors will be fixed
2. ✅ Prisma client will have `Notification` model
3. ✅ You can create notifications via API
4. ✅ Cron job will run daily at 20:00
5. ✅ FCM push notifications will be sent

---

## Testing Checklist

After migration:

- [ ] Database migration successful
- [ ] Prisma client regenerated
- [ ] Backend starts without errors
- [ ] Create test notification via `/notifications/test`
- [ ] Verify notification saved in database
- [ ] Check if FCM push was sent (if user has FCM token)
- [ ] Test streak reminder manually

---

## Troubleshooting

**Issue: Database connection error**
- Solution: Make sure PostgreSQL is running on `localhost:4433`

**Issue: FCM errors**
- Solution: Verify Firebase Admin SDK credentials
- Check `ergolife-firebase-adminsdk.json` is valid

**Issue: Cron not running**
- Solution: Check server timezone matches cron timezone
- Verify `@nestjs/schedule` is installed

---

**Ready to proceed?** Let me know once the database is running, and I'll help you run the migration! 🚀
