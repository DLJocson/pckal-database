# PCKAL Sample Data: Numbered Execution Package

**Target:** MySQL 8.0.16+  
**Database:** `pckal_db`  
**Total expected sample records:** 382 across 20 tables (on a clean database)

## Recommended approach: run one master file

1. Create the database and all 20 tables using the finalized schema scripts.
2. Install the finalized triggers, especially the promotion before-insert/update triggers and inventory transaction after-insert trigger, if they are part of the environment being tested.
3. Run `verification/00_check_schema_ready.sql`. It should show `OK` for all 20 tables and all 3 required triggers. If a table or trigger is `MISSING`, finish that setup first.
4. Open and execute **the entire** `run_all/00_seed_all_sample_data.sql` file once.
5. Run `verification/01_verify_row_counts.sql` and `verification/02_verify_referential_integrity.sql`.

The `run_all` script embeds all seven seed parts in the correct dependency order and ends with a row-count summary. It is the easiest option because the user does not have to select parts manually.

## Alternative: execute the numbered parts individually

Run each complete file below in numeric order, waiting for success before starting the next:

| Order | File | Creates sample data for | Depends on |
|---:|---|---|---|
| 01 | `parts/01_roles.sql` | Roles | Schema table `Roles` |
| 02 | `parts/02_categories.sql` | Categories | Schema table `Categories`; parent categories are inserted before children inside the file |
| 03 | `parts/03_users_and_vendors.sql` | Users, User_Roles, Vendors | Roles seeded in 01; schema tables exist |
| 04 | `parts/04_products_and_specs.sql` | Products, CPU_Specifications, GPU_Specifications | Categories seeded in 02; schema tables exist |
| 05 | `parts/05_vendor_listings_and_inventory.sql` | Vendor_Products, Inventory, initial Inventory_Transactions | Users/vendors from 03 and products/specs from 04 |
| 06 | `parts/06_promotions_and_carts.sql` | Promotions, Shopping_Carts, Cart_Items | Listings/inventory from 05; users from 03 |
| 07 | `parts/07_orders_and_transactions.sql` | Orders, Vendor_Orders, Order_Items, Payments, Shipments, Reviews, later inventory transactions | All earlier seed parts |

**Important:** choose the master script OR the seven numbered part files. Do not run both methods on the same populated tables. The seed files use explicit IDs and should not be rerun unchanged on top of existing rows.

## Folder layout

```text
02_sample_data/
├── README_EXECUTION_ORDER.md
├── parts/
│   ├── 01_roles.sql
│   ├── 02_categories.sql
│   ├── 03_users_and_vendors.sql
│   ├── 04_products_and_specs.sql
│   ├── 05_vendor_listings_and_inventory.sql
│   ├── 06_promotions_and_carts.sql
│   └── 07_orders_and_transactions.sql
├── run_all/
│   └── 00_seed_all_sample_data.sql
└── verification/
    ├── 00_check_schema_ready.sql
    ├── 01_verify_row_counts.sql
    └── 02_verify_referential_integrity.sql
```

## Expected final row counts

| Table | Expected | Table | Expected |
|---|---:|---|---:|
| Roles | 3 | Categories | 10 |
| Users | 19 | User_Roles | 20 |
| Vendors | 10 | Products | 26 |
| CPU_Specifications | 10 | GPU_Specifications | 10 |
| Vendor_Products | 36 | Inventory | 36 |
| Inventory_Transactions | 65 | Promotions | 10 |
| Shopping_Carts | 10 | Cart_Items | 19 |
| Orders | 13 | Vendor_Orders | 17 |
| Order_Items | 25 | Payments | 13 |
| Shipments | 16 | Reviews | 14 |

The expected total is **382 rows**. `Roles` intentionally has three rows because the finalized schema defines only `customer`, `vendor`, and `administrator`. The 10-row guideline is met for all other tables.

## Troubleshooting rules

- If the preflight reports a missing table, run the missing schema DDL before seeding.
- If a seed statement fails, stop at the first error. Do not continue with later files, because those files depend on rows that may not have been inserted.
- To restart, use a disposable clean development database and recreate the schema; do not drop or reset a production database for sample-data recovery.
- The inventory scripts recalculate `Inventory.quantity_on_hand` from transaction history. Do not remove the final `UPDATE Inventory` statements.
- The sample file has not been executed against a live MySQL server in this package-generation session. The checks and expected values are provided for execution-time confirmation.
