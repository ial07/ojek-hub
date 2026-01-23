-- OjekHub Seed Data
-- Run AFTER schema.sql and rls.sql

-- ===========================================
-- PRICING CONFIG SEED
-- ===========================================

INSERT INTO pricing_config (worker_type, price_per_day) VALUES
    ('ojek', 100000),
    ('pekerja', 150000)
ON CONFLICT (worker_type) DO UPDATE SET
    price_per_day = EXCLUDED.price_per_day,
    updated_at = NOW();
