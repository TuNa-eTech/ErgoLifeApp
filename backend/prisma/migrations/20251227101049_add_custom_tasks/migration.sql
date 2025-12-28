-- CreateTable
CREATE TABLE "custom_tasks" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "exercise_name" TEXT NOT NULL,
    "task_description" TEXT,
    "duration_minutes" INTEGER NOT NULL,
    "mets_value" DOUBLE PRECISION NOT NULL DEFAULT 3.5,
    "icon" TEXT NOT NULL DEFAULT 'fitness_center',
    "is_favorite" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "custom_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "custom_tasks_user_id_created_at_idx" ON "custom_tasks"("user_id", "created_at");

-- AddForeignKey
ALTER TABLE "custom_tasks" ADD CONSTRAINT "custom_tasks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
