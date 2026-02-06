-- AlterTable
ALTER TABLE "users" ADD COLUMN     "activity_time_pattern" JSONB,
ADD COLUMN     "last_reminder_sent_at" TIMESTAMP(3),
ADD COLUMN     "preferred_reminder_time" TIMESTAMP(3);

-- CreateIndex
CREATE INDEX "users_preferred_reminder_time_idx" ON "users"("preferred_reminder_time");
