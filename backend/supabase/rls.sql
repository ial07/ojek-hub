-- OjekHub Row Level Security Policies
-- Run AFTER schema.sql

-- ===========================================
-- ENABLE RLS ON ALL TABLES
-- ===========================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_config ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- USERS POLICIES
-- ===========================================

-- Users can read own profile
CREATE POLICY "users_select_own" ON users
    FOR SELECT USING (auth.uid() = id);

-- Users can update own profile (name, phone, location only)
CREATE POLICY "users_update_own" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert own profile during onboarding
CREATE POLICY "users_insert_own" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ===========================================
-- ORDERS POLICIES
-- ===========================================

-- Employers can create orders
CREATE POLICY "orders_insert_employer" ON orders
    FOR INSERT WITH CHECK (
        auth.uid() = employer_id AND
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role IN ('farmer', 'warehouse')
        )
    );

-- Employers see own orders
CREATE POLICY "orders_select_employer" ON orders
    FOR SELECT USING (employer_id = auth.uid());

-- Workers see open orders matching their type
CREATE POLICY "orders_select_worker" ON orders
    FOR SELECT USING (
        status = 'open' AND
        worker_type = (
            SELECT worker_type FROM users WHERE id = auth.uid()
        )
    );

-- Employers can update own orders (close)
CREATE POLICY "orders_update_employer" ON orders
    FOR UPDATE USING (employer_id = auth.uid());

-- Employers can delete own orders
CREATE POLICY "orders_delete_employer" ON orders
    FOR DELETE USING (employer_id = auth.uid());

-- ===========================================
-- ORDER QUEUE POLICIES
-- ===========================================

-- Workers can join queue
CREATE POLICY "queue_insert_worker" ON order_queue
    FOR INSERT WITH CHECK (
        auth.uid() = worker_id AND
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'worker'
        )
    );

-- Workers see own queue entries
CREATE POLICY "queue_select_worker" ON order_queue
    FOR SELECT USING (worker_id = auth.uid());

-- Employers see queue for own orders
CREATE POLICY "queue_select_employer" ON order_queue
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE id = order_id 
            AND employer_id = auth.uid()
        )
    );

-- Workers can leave queue (delete own entries)
CREATE POLICY "queue_delete_worker" ON order_queue
    FOR DELETE USING (worker_id = auth.uid());

-- ===========================================
-- PRICING CONFIG POLICIES
-- ===========================================

-- Everyone can read pricing
CREATE POLICY "pricing_select_all" ON pricing_config
    FOR SELECT USING (true);
