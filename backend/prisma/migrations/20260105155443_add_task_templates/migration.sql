-- DropIndex
DROP INDEX "public"."custom_tasks_user_id_created_at_idx";

-- AlterTable
ALTER TABLE "custom_tasks" ADD COLUMN     "animation" TEXT,
ADD COLUMN     "color" TEXT NOT NULL DEFAULT '#FF6A00',
ADD COLUMN     "is_hidden" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "sort_order" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "template_id" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "has_seeded_tasks" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "task_templates" (
    "id" TEXT NOT NULL,
    "mets_value" DOUBLE PRECISION NOT NULL,
    "default_duration" INTEGER NOT NULL,
    "icon" TEXT NOT NULL DEFAULT 'fitness_center',
    "animation" TEXT,
    "color" TEXT NOT NULL DEFAULT '#FF6A00',
    "category" TEXT NOT NULL DEFAULT 'general',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "task_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_template_translations" (
    "id" TEXT NOT NULL,
    "template_id" TEXT NOT NULL,
    "locale" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "task_template_translations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "task_templates_is_active_sort_order_idx" ON "task_templates"("is_active", "sort_order");

-- CreateIndex
CREATE UNIQUE INDEX "task_template_translations_template_id_locale_key" ON "task_template_translations"("template_id", "locale");

-- CreateIndex
CREATE INDEX "custom_tasks_user_id_is_hidden_sort_order_idx" ON "custom_tasks"("user_id", "is_hidden", "sort_order");

-- AddForeignKey
ALTER TABLE "task_template_translations" ADD CONSTRAINT "task_template_translations_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "task_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;
