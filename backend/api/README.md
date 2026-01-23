# OjekHub API (NestJS)

Backend API for OjekHub connecting Rejang Lebong farmers and workers.

## Tech Stack

- **Framework**: NestJS
- **Database**: Supabase (PostgreSQL)
- **Deployment**: Vercel (Serverless)

## Setup

1. **Install Dependencies**

   ```bash
   npm install
   ```

2. **Environment Variables**
   Copy `.env.example` to `.env` and fill in your Supabase credentials.

   ```bash
   cp .env.example .env
   ```

3. **Run Locally**
   ```bash
   npm run start:dev
   ```

## API Structure

- `api/auth`: Google Login & Registration
- `api/users`: Profile management
- `api/orders`: Job posting & management
- `api/orders/:id/queue`: Queue operations
- `api/workers`: Worker profiles
- `api/pricing`: Fixed price configuration

## Deployment (Vercel)

1. Install Vercel CLI: `npm i -g vercel`
2. Run deploy: `vercel`
3. Set Environment Variables in Vercel Dashboard matching `.env`.

## Database Schema

SQL files located in `../../backend/database`. Run them in Supabase SQL Editor in order:

1. `schema.sql`
2. `rls.sql`
3. `seed.sql`
