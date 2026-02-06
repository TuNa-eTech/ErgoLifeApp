# Personalized Streak Reminder Timing - Design Proposal

## Problem with Current Approach

**Fixed Time (20:00 GMT+7):**
- ❌ Không cá nhân hóa theo thói quen của từng user
- ❌ User có thể đang bận hoặc đã hoàn thành task trước đó
- ❌ Không tối ưu engagement rate

## Proposed Solution: Smart Personalized Timing

### Concept
Thay vì gửi notification cố định lúc 20:00, hệ thống sẽ:
1. **Học thói quen** của user dựa trên lịch sử hoạt động
2. **Gửi reminder** trước khoảng 1-2 giờ so với thời gian thường hoạt động
3. **Skip reminder** nếu user đã hoàn thành task trong ngày

---

## Database Schema Changes

### Add to User Model:

```prisma
model User {
  // ... existing fields
  
  // Personalized notification timing
  preferredReminderTime  DateTime?  @map("preferred_reminder_time") // Learned from activity patterns
  lastReminderSentAt     DateTime?  @map("last_reminder_sent_at")
  activityTimePattern    Json?      @map("activity_time_pattern")   // Store hourly activity distribution
  
  // ... existing relations
}
```

**activityTimePattern example:**
```json
{
  "hourly_distribution": {
    "07": 5,  // Completed 5 tasks at 7am
    "08": 12, // Completed 12 tasks at 8am
    "09": 8,  // ...
    "18": 15, // Peak activity at 6pm
    "19": 10,
    "20": 6
  },
  "most_active_hour": 18,
  "typical_start_hour": 7,
  "last_updated": "2026-02-05T08:00:00Z"
}
```

---

## Implementation Approach

### Phase 1: Learn User Patterns (Background Job)

**Daily Analysis Cron (runs at midnight):**
```typescript
@Cron('0 0 * * *', { timeZone: 'Asia/Bangkok' })
async analyzeUserActivityPatterns() {
  // Get all users with activities
  const users = await this.prisma.user.findMany({
    where: { activities: { some: {} } },
    include: {
      activities: {
        where: {
          completedAt: {
            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
          },
        },
      },
    },
  });

  for (const user of users) {
    const pattern = this.calculateActivityPattern(user.activities);
    const preferredTime = this.calculateOptimalReminderTime(pattern);
    
    await this.prisma.user.update({
      where: { id: user.id },
      data: {
        activityTimePattern: pattern,
        preferredReminderTime: preferredTime,
      },
    });
  }
}

private calculateActivityPattern(activities: Activity[]) {
  const hourlyDistribution = {};
  
  activities.forEach(activity => {
    const hour = new Date(activity.completedAt).getHours();
    hourlyDistribution[hour] = (hourlyDistribution[hour] || 0) + 1;
  });
  
  // Find peak hour
  const mostActiveHour = Object.entries(hourlyDistribution)
    .sort(([, a], [, b]) => b - a)[0][0];
  
  return {
    hourly_distribution: hourlyDistribution,
    most_active_hour: parseInt(mostActiveHour),
    typical_start_hour: this.findEarliestActiveHour(hourlyDistribution),
    last_updated: new Date(),
  };
}

private calculateOptimalReminderTime(pattern: any): Date {
  const today = new Date();
  const mostActiveHour = pattern.most_active_hour || 18;
  
  // Send reminder 1 hour before peak activity time
  const reminderHour = Math.max(7, mostActiveHour - 1);
  
  today.setHours(reminderHour, 0, 0, 0);
  return today;
}
```

### Phase 2: Smart Reminder Sending

**Hourly Check (every hour):**
```typescript
@Cron('0 * * * *') // Every hour
async sendPersonalizedStreakReminders() {
  const now = new Date();
  const currentHour = now.getHours();
  
  // Find users whose preferred reminder time matches current hour
  const usersToRemind = await this.prisma.user.findMany({
    where: {
      fcmToken: { not: null },
      currentStreak: { gt: 0 },
      OR: [
        // Users with learned preference
        {
          preferredReminderTime: {
            gte: new Date(now.setMinutes(0, 0, 0)),
            lt: new Date(now.setMinutes(59, 59, 999)),
          },
        },
        // Fallback for new users (send at 20:00)
        {
          AND: [
            { preferredReminderTime: null },
            { /* currentHour === 20 */ },
          ],
        },
      ],
    },
    include: {
      activities: {
        where: {
          completedAt: {
            gte: this.getStartOfToday(),
            lte: this.getEndOfToday(),
          },
        },
        take: 1,
      },
    },
  });
  
  for (const user of usersToRemind) {
    // Skip if user already completed activity today
    if (user.activities.length > 0) {
      this.logger.debug(`User ${user.id} already active today, skipping reminder`);
      continue;
    }
    
    // Skip if reminder was already sent today
    if (this.wasReminderSentToday(user.lastReminderSentAt)) {
      continue;
    }
    
    // Send personalized reminder
    await this.sendStreakReminder(user);
    
    // Update last reminder sent time
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastReminderSentAt: now },
    });
  }
}

private wasReminderSentToday(lastSentAt: Date | null): boolean {
  if (!lastSentAt) return false;
  
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return lastSentAt >= today;
}
```

---

## Algorithm Logic

### 1. New Users (No Activity History)
```
Default: Send at 20:00 (current behavior)
After 7 days: Start learning pattern
After 14 days: Switch to personalized timing
```

### 2. Active Users (Has Activity History)
```
Step 1: Analyze last 30 days of activity
Step 2: Find most common activity hour (e.g., 18:00)
Step 3: Calculate reminder time = peak_hour - 1 hour (e.g., 17:00)
Step 4: Update preferredReminderTime
```

### 3. Edge Cases
```
- User completes task before reminder → Skip today's reminder
- User changes schedule → Re-analyze pattern weekly
- User has irregular schedule → Use median activity time
- No pattern detected → Fallback to 20:00
```

---

## Benefits

### 1. Higher Engagement
✅ User receives reminder when they're most likely to be active
✅ Reminder comes at "right time" based on their habit

### 2. Reduced Notification Fatigue
✅ No reminder if already completed task
✅ Avoids sending during user's busy hours

### 3. Adaptive System
✅ Learns and adjusts over time
✅ Handles schedule changes automatically

### 4. Personalized Experience
✅ Each user gets unique timing
✅ Feels less "robotic" and more thoughtful

---

## Implementation Timeline

### Phase 1: Foundation (Week 1)
- [ ] Add database fields to User model
- [ ] Migration for new columns
- [ ] Update User schema

### Phase 2: Pattern Learning (Week 2)
- [ ] Create activity pattern analyzer
- [ ] Daily cron job to calculate patterns
- [ ] Store patterns in database

### Phase 3: Smart Sending (Week 3)
- [ ] Update streak reminder to use personalized timing
- [ ] Hourly check instead of fixed time
- [ ] Skip logic if already active today

### Phase 4: Testing & Refinement (Week 4)
- [ ] Test with different user patterns
- [ ] A/B test: Fixed time vs Personalized
- [ ] Analyze engagement metrics
- [ ] Fine-tune algorithm

---

## Migration Path

### Database Migration:
```sql
-- Add new columns to users table
ALTER TABLE users 
ADD COLUMN preferred_reminder_time TIMESTAMP,
ADD COLUMN last_reminder_sent_at TIMESTAMP,
ADD COLUMN activity_time_pattern JSONB;

-- Create index for efficient queries
CREATE INDEX idx_users_reminder_time 
ON users(preferred_reminder_time) 
WHERE preferred_reminder_time IS NOT NULL;
```

---

## Metrics to Track

After implementation, monitor:

1. **Engagement Rate**
   - % of users who complete task after reminder
   - Compare: Fixed time vs Personalized

2. **Reminder Effectiveness**
   - Time between reminder and task completion
   - Optimal reminder lead time

3. **User Satisfaction**
   - Notification not marked as spam
   - Reminder timing feedback

---

## Example User Journey

### User: "Anh Tú"

**Week 1-2 (Learning Phase):**
```
Mon: Completes task at 08:00
Tue: Completes task at 07:30
Wed: Completes task at 18:00
Thu: Completes task at 08:15
Fri: Completes task at 19:00
Sat: Completes task at 09:00
Sun: Completes task at 10:00

System learns: Peak activity = 08:00 (weekdays), 09:00 (weekends)
Sets: preferredReminderTime = 07:00 (1 hour before)
```

**Week 3+ (Personalized):**
```
Mon 07:00: ⏰ Reminder sent
Mon 08:10: ✅ Task completed

Tue 06:50: ✅ Task already completed (early bird!)
Tue 07:00: 🚫 Reminder SKIPPED (already active)

Wed 07:00: ⏰ Reminder sent
Wed 20:00: ❌ No task completed yet
Wed 21:00: 🔥 Follow-up reminder (last chance)
```

---

## Fallback Strategy

If personalized timing doesn't work:

1. **Week 1**: Fixed 20:00 (default)
2. **Week 2**: Still 20:00, but start tracking
3. **Week 3**: Switch to personalized if pattern detected
4. **Week 4+**: Continue personalized, re-analyze monthly

---

## Technical Considerations

### Performance
- Hourly cron job queries only users with matching hour
- Index on `preferredReminderTime` for fast lookup
- Background pattern analysis (low priority)

### Scalability
- Pattern analysis: ~1 second per 1000 users
- Reminder sending: Same as current (FCM batch)
- Storage: ~200 bytes per user for pattern JSON

### Privacy
- Activity patterns stored locally (not shared)
- User can opt-out via preferences
- Clear data retention policy (30 days)

---

## Next Steps

**Immediate (Can do now):**
1. ✅ Enhanced reminder messages (DONE!)
2. Add database schema for pattern tracking

**Short-term (Next sprint):**
3. Implement pattern learning algorithm
4. Update cron job to hourly checks
5. A/B test with 10% of users

**Long-term (Future):**
6. ML-based optimal timing prediction
7. User manual override for reminder time
8. Multiple reminder windows per day

---

**Want to implement this?** We can start with Phase 1 (database schema) whenever you're ready! 🚀
