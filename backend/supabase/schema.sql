-- OjekHub Database Schema
-- Compatible with Supabase + Google Auth

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- ENUM TYPES
-- ===========================================

CREATE TYPE user_role AS ENUM ('farmer', 'warehouse', 'worker');
CREATE TYPE worker_type AS ENUM ('ojek', 'daily');
CREATE TYPE order_status AS ENUM ('open', 'closed');

-- ===========================================
-- USERS TABLE
-- ===========================================
-- Uses Supabase Auth UUID as primary key

CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    location VARCHAR(100) NOT NULL,
    role user_role NOT NULL,
    worker_type worker_type,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Workers must have worker_type, employers must NOT have worker_type
    CONSTRAINT worker_type_required CHECK (
        (role = 'worker' AND worker_type IS NOT NULL) OR
        (role != 'worker' AND worker_type IS NULL)
    )
);

-- ===========================================
-- ORDERS TABLE
-- ===========================================

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    worker_type worker_type NOT NULL,
    worker_count INT NOT NULL CHECK (worker_count > 0),
    description TEXT NOT NULL,
    location VARCHAR(100) NOT NULL,
    job_date DATE NOT NULL,
    status order_status DEFAULT 'open',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- ORDER QUEUE TABLE
-- ===========================================
-- FIFO ordering via joined_at timestamp

CREATE TABLE order_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    worker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate joins
    UNIQUE(order_id, worker_id)
);

-- ===========================================
-- PRICING CONFIG TABLE
-- ===========================================

CREATE TABLE pricing_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    worker_type worker_type NOT NULL UNIQUE,
    price_per_day INT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

CREATE INDEX idx_orders_worker_type ON orders(worker_type);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_employer ON orders(employer_id);
CREATE INDEX idx_orders_job_date ON orders(job_date);
CREATE INDEX idx_queue_order ON order_queue(order_id);
CREATE INDEX idx_queue_worker ON order_queue(worker_id);
CREATE INDEX idx_queue_joined_at ON order_queue(joined_at);
