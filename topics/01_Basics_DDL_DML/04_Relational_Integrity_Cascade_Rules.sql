-- Topic Query Reference: 2026-06-20
-- Foreign Key Cascading Actions (ON DELETE CASCADE, ON UPDATE CASCADE)
CREATE TABLE customer_orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_total NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES verified_accounts(account_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
