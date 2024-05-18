-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "citext";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CreateEnum
CREATE TYPE "BreedingCycleStatus" AS ENUM ('ACTIVE', 'ENDED');

-- CreateEnum
CREATE TYPE "ConnectionStatus" AS ENUM ('CONNECTED', 'DISCONNECTED');

-- CreateEnum
CREATE TYPE "AuthorizationStatus" AS ENUM ('STARTED', 'SUCCESSFUL', 'FAILED');

-- CreateTable
CREATE TABLE "weight" (
    "id" TEXT NOT NULL,
    "serial_no" CITEXT NOT NULL,
    "manufacture_date" TIMESTAMP(3),
    "connection_status" "ConnectionStatus",
    "last_location_id" TEXT,
    "active_breeding_cycle_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "weight_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "location" (
    "id" TEXT NOT NULL,
    "weight_id" TEXT,
    "coordinate" point NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "location_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_weight" (
    "weight_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "authorization_id" TEXT NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_weight_pkey" PRIMARY KEY ("weight_id","user_id","authorization_id")
);

-- CreateTable
CREATE TABLE "authorization" (
    "id" TEXT NOT NULL,
    "status" "AuthorizationStatus" NOT NULL DEFAULT 'STARTED',
    "verification_code" VARCHAR(255),
    "attempts_left" INTEGER NOT NULL DEFAULT 3,
    "blocked" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "authorization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user" (
    "id" TEXT NOT NULL,
    "external_id" TEXT NOT NULL,
    "first_name" VARCHAR(50) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL,
    "email" CITEXT NOT NULL,
    "phone" VARCHAR(50) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL,
    "updated_at" TIMESTAMP(3),

    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "measurement" (
    "id" TEXT NOT NULL,
    "weight_id" TEXT NOT NULL,
    "value" DECIMAL(7,2) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "measurement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_stats_measurement" (
    "measurement_id" TEXT NOT NULL,
    "daily_stats_id" TEXT NOT NULL,
    "valid" BOOLEAN NOT NULL DEFAULT true
);

-- CreateTable
CREATE TABLE "daily_stats" (
    "id" TEXT NOT NULL,
    "weight_id" TEXT NOT NULL,
    "breeding_cycle_id" TEXT NOT NULL,
    "average_weight" DECIMAL(7,2) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "daily_stats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "breeding_cycle_weight" (
    "breeding_cycle_id" TEXT NOT NULL,
    "weight_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "breeding_cycle" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "last_stats_id" TEXT,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3),
    "status" "BreedingCycleStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "breeding_cycle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "weight_serial_no_key" ON "weight"("serial_no");

-- CreateIndex
CREATE UNIQUE INDEX "weight_last_location_id_key" ON "weight"("last_location_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_external_id_key" ON "user"("external_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_email_key" ON "user"("email");

-- CreateIndex
CREATE UNIQUE INDEX "user_phone_key" ON "user"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "daily_stats_measurement_daily_stats_id_measurement_id_key" ON "daily_stats_measurement"("daily_stats_id", "measurement_id");

-- CreateIndex
CREATE UNIQUE INDEX "breeding_cycle_weight_breeding_cycle_id_weight_id_key" ON "breeding_cycle_weight"("breeding_cycle_id", "weight_id");

-- CreateIndex
CREATE UNIQUE INDEX "breeding_cycle_last_stats_id_key" ON "breeding_cycle"("last_stats_id");

-- AddForeignKey
ALTER TABLE "weight" ADD CONSTRAINT "weight_last_location_id_fkey" FOREIGN KEY ("last_location_id") REFERENCES "location"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weight" ADD CONSTRAINT "weight_active_breeding_cycle_id_fkey" FOREIGN KEY ("active_breeding_cycle_id") REFERENCES "breeding_cycle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "location" ADD CONSTRAINT "location_weight_id_fkey" FOREIGN KEY ("weight_id") REFERENCES "weight"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_weight" ADD CONSTRAINT "user_weight_weight_id_fkey" FOREIGN KEY ("weight_id") REFERENCES "weight"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_weight" ADD CONSTRAINT "user_weight_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_weight" ADD CONSTRAINT "user_weight_authorization_id_fkey" FOREIGN KEY ("authorization_id") REFERENCES "authorization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "measurement" ADD CONSTRAINT "measurement_weight_id_fkey" FOREIGN KEY ("weight_id") REFERENCES "weight"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_stats_measurement" ADD CONSTRAINT "daily_stats_measurement_measurement_id_fkey" FOREIGN KEY ("measurement_id") REFERENCES "measurement"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_stats_measurement" ADD CONSTRAINT "daily_stats_measurement_daily_stats_id_fkey" FOREIGN KEY ("daily_stats_id") REFERENCES "daily_stats"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_stats" ADD CONSTRAINT "daily_stats_weight_id_fkey" FOREIGN KEY ("weight_id") REFERENCES "weight"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_stats" ADD CONSTRAINT "daily_stats_breeding_cycle_id_fkey" FOREIGN KEY ("breeding_cycle_id") REFERENCES "breeding_cycle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "breeding_cycle_weight" ADD CONSTRAINT "breeding_cycle_weight_breeding_cycle_id_fkey" FOREIGN KEY ("breeding_cycle_id") REFERENCES "breeding_cycle"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "breeding_cycle_weight" ADD CONSTRAINT "breeding_cycle_weight_weight_id_fkey" FOREIGN KEY ("weight_id") REFERENCES "weight"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "breeding_cycle" ADD CONSTRAINT "breeding_cycle_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "breeding_cycle" ADD CONSTRAINT "breeding_cycle_last_stats_id_fkey" FOREIGN KEY ("last_stats_id") REFERENCES "daily_stats"("id") ON DELETE SET NULL ON UPDATE CASCADE;
