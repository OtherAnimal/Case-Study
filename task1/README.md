## Diagrams
- [ER Diagram](er_diagram.png)
- [Star Schema](star_schema.png)
- [GCP Architecture](gcp_architecture.png)

## Design Decisions

Several decisions were made beyond the literal task requirements to produce a complete and realistic e-commerce data model:
* Entity names (Produkty, Kategórie, Zákazníci, Objednávky a Transakcie) are translated into English to improve compatibility with other systems & avoid ambiguity. Also the task specifies 5 core entities. I've added Address and OrderItem as they are structurally necessary for the e-commerce model.
* "keys" not "ids" - in a data warehouse you use surrogate keys (integer sequences) separate from the source system IDs.
* Transaction data is currently modeled within fact_orders for simplicity. In a production environment with refunds, partial payments, or multi-payment orders, I would extract fact_transactions as a separate fact table, forming a Galaxy Schema with shared dimensions (dim_customer, dim_date). This would better support financial reconciliation reporting.
GCS > BigQuery: load job is used as the production approach, external table as useful for quick exploration or initial validation


## Discussion Questions
a. Ako by ste v BigQuery riešili historické zmeny (SCD Type 2) pri adrese zákazníka?

* Slowly Changing Dimension Type 2 (Add New Row/History) - It adds the new row with the new address_key (but with the same address_id); & marks old row as expired. To make this approach work - I’d also add valid_from, valid_to, is_current columns in dim_address. 

b. Ktoré stĺpce by ste zvolili pre Partitioning a Clustering v BigQuery na optimalizáciu ceny a výkonu?

* Partition by: order_date
* Cluster by: customer_id, product_id, category_id
* Reason: In e-commerce, analysts often focus on date filters first and then focus on specific customers or products. Partitioning by order_date means BigQuery scans only relevant date ranges, directly reducing cost since BigQuery charges per bytes scanned.

