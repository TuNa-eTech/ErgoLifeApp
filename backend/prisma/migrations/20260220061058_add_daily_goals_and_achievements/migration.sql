-- AlterEnum
ALTER TYPE "NotificationType" ADD VALUE 'BADGE_UNLOCKED';

-- CreateTable
CREATE TABLE "daily_goals" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "target_ep" INTEGER NOT NULL DEFAULT 500,
    "target_duration" INTEGER NOT NULL DEFAULT 30,
    "target_activities" INTEGER NOT NULL DEFAULT 2,
    "current_ep" INTEGER NOT NULL DEFAULT 0,
    "current_duration" INTEGER NOT NULL DEFAULT 0,
    "current_activities" INTEGER NOT NULL DEFAULT 0,
    "is_perfect_day" BOOLEAN NOT NULL DEFAULT false,
    "completed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "daily_goals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_goal_settings" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "target_ep" INTEGER NOT NULL DEFAULT 500,
    "target_duration" INTEGER NOT NULL DEFAULT 30,
    "target_activities" INTEGER NOT NULL DEFAULT 2,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_goal_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "badge_definitions" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "color" TEXT NOT NULL DEFAULT '#FF6A00',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "condition_type" TEXT NOT NULL,
    "condition_value" INTEGER NOT NULL,
    "rarity" TEXT NOT NULL DEFAULT 'COMMON',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "badge_definitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "badge_translations" (
    "id" TEXT NOT NULL,
    "badge_id" TEXT NOT NULL,
    "locale" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "badge_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_badges" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "badge_id" TEXT NOT NULL,
    "unlocked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_badges_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "daily_goals_user_id_date_idx" ON "daily_goals"("user_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "daily_goals_user_id_date_key" ON "daily_goals"("user_id", "date");

-- CreateIndex
CREATE UNIQUE INDEX "user_goal_settings_user_id_key" ON "user_goal_settings"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "badge_definitions_code_key" ON "badge_definitions"("code");

-- CreateIndex
CREATE INDEX "badge_definitions_is_active_sort_order_idx" ON "badge_definitions"("is_active", "sort_order");

-- CreateIndex
CREATE UNIQUE INDEX "badge_translations_badge_id_locale_key" ON "badge_translations"("badge_id", "locale");

-- CreateIndex
CREATE INDEX "user_badges_user_id_idx" ON "user_badges"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_badges_user_id_badge_id_key" ON "user_badges"("user_id", "badge_id");

-- AddForeignKey
ALTER TABLE "daily_goals" ADD CONSTRAINT "daily_goals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_goal_settings" ADD CONSTRAINT "user_goal_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "badge_translations" ADD CONSTRAINT "badge_translations_badge_id_fkey" FOREIGN KEY ("badge_id") REFERENCES "badge_definitions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_badges" ADD CONSTRAINT "user_badges_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_badges" ADD CONSTRAINT "user_badges_badge_id_fkey" FOREIGN KEY ("badge_id") REFERENCES "badge_definitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
