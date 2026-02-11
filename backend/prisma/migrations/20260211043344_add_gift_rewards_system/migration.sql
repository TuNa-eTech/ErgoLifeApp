-- CreateEnum
CREATE TYPE "GiftRewardCategory" AS ENUM ('PRAISE', 'PRIVILEGE', 'EXPERIENCE', 'MOTIVATION');

-- AlterEnum
ALTER TYPE "NotificationType" ADD VALUE 'GIFT_RECEIVED';

-- CreateTable
CREATE TABLE "gift_rewards" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "category" "GiftRewardCategory" NOT NULL,
    "icon" TEXT NOT NULL,
    "cost" INTEGER NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "gift_rewards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gift_reward_translations" (
    "id" TEXT NOT NULL,
    "reward_id" TEXT NOT NULL,
    "locale" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "gift_reward_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gift_transactions" (
    "id" TEXT NOT NULL,
    "sender_id" TEXT NOT NULL,
    "receiver_id" TEXT NOT NULL,
    "house_id" TEXT NOT NULL,
    "reward_id" TEXT NOT NULL,
    "reward_name" TEXT NOT NULL,
    "reward_icon" TEXT NOT NULL,
    "points_spent" INTEGER NOT NULL,
    "message" VARCHAR(100),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gift_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "gift_rewards_key_key" ON "gift_rewards"("key");

-- CreateIndex
CREATE INDEX "gift_rewards_is_active_sort_order_idx" ON "gift_rewards"("is_active", "sort_order");

-- CreateIndex
CREATE UNIQUE INDEX "gift_reward_translations_reward_id_locale_key" ON "gift_reward_translations"("reward_id", "locale");

-- CreateIndex
CREATE INDEX "gift_transactions_sender_id_created_at_idx" ON "gift_transactions"("sender_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "gift_transactions_receiver_id_created_at_idx" ON "gift_transactions"("receiver_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "gift_transactions_house_id_created_at_idx" ON "gift_transactions"("house_id", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "gift_reward_translations" ADD CONSTRAINT "gift_reward_translations_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "gift_rewards"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gift_transactions" ADD CONSTRAINT "gift_transactions_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gift_transactions" ADD CONSTRAINT "gift_transactions_receiver_id_fkey" FOREIGN KEY ("receiver_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gift_transactions" ADD CONSTRAINT "gift_transactions_house_id_fkey" FOREIGN KEY ("house_id") REFERENCES "houses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gift_transactions" ADD CONSTRAINT "gift_transactions_reward_id_fkey" FOREIGN KEY ("reward_id") REFERENCES "gift_rewards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
