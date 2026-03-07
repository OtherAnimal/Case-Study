SQL transformation performance degradation is a common issue. It usually has multiple root causes. It rarely has a single cause - typically it's a combination of growing data volumes, accumulated technical debt, and missing infrastructure optimizations that weren't critical at launch but become bottlenecks with growth.

## The most common root causes:
* Data volume growth - the most obvious reason.The incremental loading implementation allow to process only the most recent data instead of the full table every time)
* No indexes for frequently used columns. Add indexes on columns frequently used in WHERE clauses and JOINs. Index selectively because indexing everything increases write overhead & storage cost.
* No partitioning/clustering (like discussed in task 1). Partitioning / clustering significantly reduces query cost.
* Inefficient SQL queries (like SELECT *, no WHERE filtering, etc.).
* Transformations are performed on production, not on staging.
* JOINS for full tables before filtering. Filter the data before joins whenever it's possible.
* Technical debt in SQL transformation (e.g. the same calculation or joins run several times). 
* Repeated logic might be refactored into CTEs (Common Table Expressions). Regular pipeline audits help catch the debt before it’s excessive.
## Diagnostic steps:
1. Check execution logs - when the degradation starts? Was it gradual?
2. Check recent pipeline changes - has anything been deployed around the degradation start point?
3. Run EXPLAIN / EXPLAIN ANALYZE query to check rows number, partitions, indexes (EXPLAIN ANALYZE should be run as a separate transaction to have possibility to rollback since it’s a real query, not a query plan like EXPLAIN).
4. Check how many rows were fetched before & now.
5. Find the slowest step in the transformation.
6. Check the db schema for changes (like new columns, changes types).

## Prevention approach:
* Set up monitoring (log execution time, row counts for every run). Set alerts on failures or anomaly detections.
* Plan regular pipeline reviews (e.g. 1 per 3 months).

In general, performance degradation is easier & cheaper to prevent than fix. 
