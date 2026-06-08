-- Endeavor Tea Works — schema DDL
-- Target: MotherDuck database `endeavor_tea_works`, schema `main`
-- 23 tables, organized by dependency level.
--
-- Note: when executing this against MotherDuck, FK constraints cannot use
-- fully-qualified database names. Either run with `USE endeavor_tea_works;`
-- as the first statement and unqualified table refs, or strip the database
-- prefix from REFERENCES clauses. The fully-qualified form below is for
-- documentation; the version actually executed used `USE` + unqualified refs.

CREATE DATABASE IF NOT EXISTS endeavor_tea_works;

-- ============================================================
-- LEVEL 0: Foundation (no FK dependencies)
-- ============================================================

CREATE TABLE endeavor_tea_works.main.warehouses (
    warehouse_id   BIGINT PRIMARY KEY,
    name           VARCHAR NOT NULL,
    warehouse_type VARCHAR NOT NULL,  -- blendery, dc, copacker
    state          VARCHAR NOT NULL
);

CREATE TABLE endeavor_tea_works.main.suppliers (
    supplier_id   BIGINT PRIMARY KEY,
    name          VARCHAR NOT NULL,
    country       VARCHAR NOT NULL,
    supplier_type VARCHAR NOT NULL  -- origin, packaging, ingredient
);

CREATE TABLE endeavor_tea_works.main.products (
    product_id              BIGINT PRIMARY KEY,
    sku                     VARCHAR NOT NULL UNIQUE,
    name                    VARCHAR NOT NULL,
    product_line            VARCHAR NOT NULL,  -- Classics, Wellness, Single-Estate Reserve
    format                  VARCHAR NOT NULL,  -- loose, sachet, bagged, bulk
    msrp                    DECIMAL(10, 2) NOT NULL,
    wholesale_default_price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE endeavor_tea_works.main.customers (
    customer_id         BIGINT PRIMARY KEY,
    parent_customer_id  BIGINT REFERENCES endeavor_tea_works.main.customers(customer_id),
    name                VARCHAR NOT NULL,
    channel             VARCHAR NOT NULL,   -- dtc, wholesale_retail, wholesale_cafe, foodservice
    state               VARCHAR,            -- US state code (geo segmentation); NULL for international
    acquired_at         DATE,               -- signup or first-order date; underpins cohort analysis
    acquisition_source  VARCHAR             -- organic, paid_search, paid_social, referral, email, other; DTC-only
);

-- ============================================================
-- LEVEL 1
-- ============================================================

CREATE TABLE endeavor_tea_works.main.materials (
    material_id         BIGINT PRIMARY KEY,
    primary_supplier_id BIGINT REFERENCES endeavor_tea_works.main.suppliers(supplier_id),
    material_type       VARCHAR NOT NULL,  -- raw, packaging
    name                VARCHAR NOT NULL,
    origin              VARCHAR,
    unit_of_measure     VARCHAR NOT NULL   -- kg, lb, each
);

CREATE TABLE endeavor_tea_works.main.inventory_locations (
    location_id  BIGINT PRIMARY KEY,
    warehouse_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    zone         VARCHAR NOT NULL,
    aisle        VARCHAR,
    bin          VARCHAR
);

CREATE TABLE endeavor_tea_works.main.employees (
    employee_id          BIGINT PRIMARY KEY,
    primary_warehouse_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    role                 VARCHAR NOT NULL,
    employment_type      VARCHAR NOT NULL,  -- full_time, part_time, temp, contractor
    hourly_wage          DECIMAL(10, 2) NOT NULL,
    hired_at             DATE NOT NULL,
    terminated_at        DATE
);

-- ============================================================
-- LEVEL 2
-- ============================================================

CREATE TABLE endeavor_tea_works.main.recipe_components (
    product_id      BIGINT NOT NULL REFERENCES endeavor_tea_works.main.products(product_id),
    material_id     BIGINT NOT NULL REFERENCES endeavor_tea_works.main.materials(material_id),
    qty_per_unit    DECIMAL(14, 4) NOT NULL,
    unit_of_measure VARCHAR NOT NULL,
    PRIMARY KEY (product_id, material_id)
);

CREATE TABLE endeavor_tea_works.main.subscriptions (
    subscription_id BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL REFERENCES endeavor_tea_works.main.customers(customer_id),
    product_id      BIGINT NOT NULL REFERENCES endeavor_tea_works.main.products(product_id),
    cadence         VARCHAR NOT NULL,  -- monthly, quarterly
    started_at      DATE NOT NULL,
    cancelled_at    DATE,
    status          VARCHAR NOT NULL   -- active, paused, cancelled
);

CREATE TABLE endeavor_tea_works.main.purchase_orders (
    po_id                    BIGINT PRIMARY KEY,
    supplier_id              BIGINT NOT NULL REFERENCES endeavor_tea_works.main.suppliers(supplier_id),
    destination_warehouse_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    order_date               DATE NOT NULL,
    expected_arrival         DATE,
    status                   VARCHAR NOT NULL  -- created, in_transit, received, closed, cancelled
);

CREATE TABLE endeavor_tea_works.main.production_runs (
    run_id            BIGINT PRIMARY KEY,
    target_product_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.products(product_id),
    warehouse_id      BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    started_at        TIMESTAMP NOT NULL,
    completed_at      TIMESTAMP,
    target_qty        DECIMAL(14, 4) NOT NULL,
    actual_qty        DECIMAL(14, 4),
    status            VARCHAR NOT NULL  -- planned, in_progress, completed, cancelled
);

CREATE TABLE endeavor_tea_works.main.license_plates (
    lp_id               BIGINT PRIMARY KEY,
    current_location_id BIGINT REFERENCES endeavor_tea_works.main.inventory_locations(location_id),
    status              VARCHAR NOT NULL,  -- staged, stored, picked, shipped, scrapped
    created_at          TIMESTAMP NOT NULL
);

-- ============================================================
-- LEVEL 3
-- ============================================================

CREATE TABLE endeavor_tea_works.main.purchase_order_lines (
    pol_id       BIGINT PRIMARY KEY,
    po_id        BIGINT NOT NULL REFERENCES endeavor_tea_works.main.purchase_orders(po_id),
    material_id  BIGINT NOT NULL REFERENCES endeavor_tea_works.main.materials(material_id),
    qty_ordered  DECIMAL(14, 4) NOT NULL,
    qty_received DECIMAL(14, 4) NOT NULL DEFAULT 0,
    unit_cost    DECIMAL(10, 2)
);

CREATE TABLE endeavor_tea_works.main.sales_orders (
    so_id                BIGINT PRIMARY KEY,
    customer_id          BIGINT NOT NULL REFERENCES endeavor_tea_works.main.customers(customer_id),
    subscription_id      BIGINT REFERENCES endeavor_tea_works.main.subscriptions(subscription_id),
    origin_warehouse_id  BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    order_date           DATE NOT NULL,
    status               VARCHAR NOT NULL,                  -- created, picking, packed, shipped, delivered, cancelled
    channel              VARCHAR NOT NULL,                  -- dtc, wholesale_retail, wholesale_cafe, foodservice
    is_gift              BOOLEAN NOT NULL DEFAULT FALSE,
    ship_state           VARCHAR                            -- nullable; populated when ship-to differs from customer.state
);

CREATE TABLE endeavor_tea_works.main.lots (
    lot_id                      BIGINT PRIMARY KEY,
    lot_source                  VARCHAR NOT NULL,  -- vendor, production
    material_id                 BIGINT REFERENCES endeavor_tea_works.main.materials(material_id),
    product_id                  BIGINT REFERENCES endeavor_tea_works.main.products(product_id),
    production_run_id           BIGINT REFERENCES endeavor_tea_works.main.production_runs(run_id),
    vendor_lot_code             VARCHAR,
    harvest_or_manufacture_date DATE,
    expiration_date             DATE,
    received_at                 TIMESTAMP
);

CREATE TABLE endeavor_tea_works.main.shipments (
    shipment_id         BIGINT PRIMARY KEY,
    so_id               BIGINT NOT NULL REFERENCES endeavor_tea_works.main.sales_orders(so_id),
    origin_warehouse_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    carrier             VARCHAR,
    tracking_number     VARCHAR,
    shipped_at          TIMESTAMP,
    delivered_at        TIMESTAMP,
    status              VARCHAR NOT NULL  -- pending, in_transit, delivered, exception
);

-- ============================================================
-- LEVEL 4
-- ============================================================

CREATE TABLE endeavor_tea_works.main.sales_order_lines (
    sol_id      BIGINT PRIMARY KEY,
    so_id       BIGINT NOT NULL REFERENCES endeavor_tea_works.main.sales_orders(so_id),
    product_id  BIGINT NOT NULL REFERENCES endeavor_tea_works.main.products(product_id),
    qty_ordered DECIMAL(14, 4) NOT NULL,
    qty_shipped DECIMAL(14, 4) NOT NULL DEFAULT 0,
    unit_price  DECIMAL(10, 2) NOT NULL
);

CREATE TABLE endeavor_tea_works.main.production_inputs (
    input_id     BIGINT PRIMARY KEY,
    run_id       BIGINT NOT NULL REFERENCES endeavor_tea_works.main.production_runs(run_id),
    material_id  BIGINT NOT NULL REFERENCES endeavor_tea_works.main.materials(material_id),
    lot_id       BIGINT NOT NULL REFERENCES endeavor_tea_works.main.lots(lot_id),
    qty_consumed DECIMAL(14, 4) NOT NULL
);

CREATE TABLE endeavor_tea_works.main.production_outputs (
    output_id    BIGINT PRIMARY KEY,
    run_id       BIGINT NOT NULL REFERENCES endeavor_tea_works.main.production_runs(run_id),
    product_id   BIGINT NOT NULL REFERENCES endeavor_tea_works.main.products(product_id),
    lot_id       BIGINT NOT NULL REFERENCES endeavor_tea_works.main.lots(lot_id),
    qty_produced DECIMAL(14, 4) NOT NULL
);

CREATE TABLE endeavor_tea_works.main.lp_contents (
    lp_id  BIGINT NOT NULL REFERENCES endeavor_tea_works.main.license_plates(lp_id),
    lot_id BIGINT NOT NULL REFERENCES endeavor_tea_works.main.lots(lot_id),
    qty    DECIMAL(14, 4) NOT NULL,
    PRIMARY KEY (lp_id, lot_id)
);

CREATE TABLE endeavor_tea_works.main.tasks (
    task_id        BIGINT PRIMARY KEY,
    warehouse_id   BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    employee_id    BIGINT REFERENCES endeavor_tea_works.main.employees(employee_id),
    task_type      VARCHAR NOT NULL,  -- receive, putaway, pick, pack, load, ship, blend, package
    related_po_id  BIGINT REFERENCES endeavor_tea_works.main.purchase_orders(po_id),
    related_so_id  BIGINT REFERENCES endeavor_tea_works.main.sales_orders(so_id),
    related_run_id BIGINT REFERENCES endeavor_tea_works.main.production_runs(run_id),
    started_at     TIMESTAMP,
    completed_at   TIMESTAMP,
    status         VARCHAR NOT NULL   -- pending, in_progress, completed, cancelled
);

CREATE TABLE endeavor_tea_works.main.labor_hours (
    labor_id       BIGINT PRIMARY KEY,
    employee_id    BIGINT NOT NULL REFERENCES endeavor_tea_works.main.employees(employee_id),
    warehouse_id   BIGINT NOT NULL REFERENCES endeavor_tea_works.main.warehouses(warehouse_id),
    shift_date     DATE NOT NULL,
    clock_in       TIMESTAMP NOT NULL,
    clock_out      TIMESTAMP,
    activity_type  VARCHAR NOT NULL  -- receive, blend, pack, pick, ship, inventory, qa, admin, meeting, training, break, idle
);

-- ============================================================
-- LEVEL 5
-- ============================================================

CREATE TABLE endeavor_tea_works.main.inventory_movements (
    movement_id      BIGINT PRIMARY KEY,
    lp_id            BIGINT REFERENCES endeavor_tea_works.main.license_plates(lp_id),
    lot_id           BIGINT NOT NULL REFERENCES endeavor_tea_works.main.lots(lot_id),
    from_location_id BIGINT REFERENCES endeavor_tea_works.main.inventory_locations(location_id),
    to_location_id   BIGINT REFERENCES endeavor_tea_works.main.inventory_locations(location_id),
    movement_type    VARCHAR NOT NULL,  -- receive, putaway, pick, transfer, ship, adjust
    qty              DECIMAL(14, 4) NOT NULL,
    occurred_at      TIMESTAMP NOT NULL,
    task_id          BIGINT REFERENCES endeavor_tea_works.main.tasks(task_id),
    so_id            BIGINT REFERENCES endeavor_tea_works.main.sales_orders(so_id)  -- populated for 'ship' rows; bridges a shipped lot to its sales order/customer
);
