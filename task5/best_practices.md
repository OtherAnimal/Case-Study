1. Používanie hardcoded hodnôt v ETL procesoch pre biznis pravidlá.
_**Bad practice:** If a business rule changes (tax rate, discount threshold, country code) - you should modify and redeploy code instead of updating a config. Risk of inconsistency across pipelines if the same value is hardcoded in multiple places. **Better:** store business rules in a configuration table or environment variables. Change the config, not the code._

2. Neindexovanie stĺpcov, ktoré sú často dotazované vo veľkých tabuľkách.
_**Bad practice:** significantly increases query time. Personally I experimented with indexes & timing. Reasonable indexing for the most often queried columns significantly improves the timing. Meanwhile indexing of all the columns requires more storage space & - so it’s a tradeoff between speed & storage.  Indexes also slow down write operations (INSERT/UPDATE) - one more reason to index selectively, not everything. **Better:** index the most queried columns._

3. Ukladanie logov a záloh na rovnaký server ako produkčná databáza.
_**Very bad practice:** high risk in losing data. E.g: server disk failure, ransomware attack, accidental deletion - all wipe production data & its backup simultaneously. **Better:**separate storage service, ideally choose different geographic regions._

4. Používanie zdieľaných servisných účtov na pripojenie k databázam v ETL nástrojoch.
_**Bad practice.** No accountability - you can't audit which ETL job or person caused an issue. If credentials leak, all connected systems are compromised simultaneously. Rotating credentials affects everything connected. **Better:** dedicated service account per ETL job with minimum required permissions only._

5. Budovanie dátových kanálov bez implementácie mechanizmov na opakovanie alebo zotavenie pri zlyhaní.
_**Bad practice.** Without retries, temporary failures (network failure, API timeout, rate limiting) cause permanent data gaps. For e-commerce  service this means missing orders in the DWH. **Better:** implement exponential backoff retries, idempotent pipeline steps, and dead letter queues for failed records._

6. Povoľovanie priameho prístupu ku zdrojovým dátam všetkým členom tímu bez kontroly prístupu.
_**Very bad practice.** May result in severe security issues, occasional data deletions, etc. **Better:** Least privilege practices should be used instead._

7. Vynechanie validácie schémy pri načítavaní externých dát.
_**Bad practice.** External APIs can change their response structure without warning: add new fields, rename fields, change types, etc. Without validation the pipeline silently loads damaged or wrong data into the DWH. **Better:** validate schema on read, fail with alert rather than load bad data silently._

8. Používanie zastaraných ETL procesov bez pravidelných revízií optimalizácie.
_**Bad practice.** There might be changes in query patterns, data volume, etc. The same process might start running 2 hours instead of 5 minute (like in task 5). **Better:** schedule regular pipeline reviews (like 1 per 3, months, monitor processes performance)._

9. Nepremazanie alebo neodstránenie zastaraných tabuliek a pohľadov z dátového skladu.
_**Bad practice.** Require excessive storage space, might become a source of confusion - like what data is the source of truth?_
_**Better:** maintain an up-to-date data catalog, use clear naming convention._

10. Nenastavenie upozornení na zlyhané úlohy alebo oneskorenia kanálov.
_**Bad practice.** Silent failures are the worst ones. The data flow stops but no one notices, & the further business decisions are based on the old data. **Better:** alert on job failure or anomaly detection._

11. Ukladanie citlivých údajov bez šifrovania pri ukladaní alebo prenose.
_**Very bad:** severe security, privacy & following legal, financial & eputationl risks. There are multiple examples of leaked data (like the Equifax breach). Besides, GDPR specifically mandates encryption of personal data at rest and in transit - non-compliance means regulatory fines, not just reputational damage._

12. Ignorovanie obmedzení dátových typov pri vytváraní schém v dátovom sklade.
_**Bad practice.** For example, storing a date as VARCHAR means you can't do date arithmetic, sorting is alphabetical not chronological, invalid values like "yesterday" or "N/A" get stored silently. **Better:** define specific types on every column. Use the most restrictive type that fits the data. Fail on type mismatch at data fetching, data types shouldn’t be casted silently._

13. Povoľovanie kruhových závislostí medzi ETL úlohami.
_**Bad practice.** Job A waits for Job B which waits for Job A => deadlock. Thus the pipeline never completes. Extremely hard to debug in production._

14. Vykonávanie transformácií priamo na produkčných databázach namiesto staging vrstiev.
_**Bad practice:** high risk of negatively affecting product database with significant impact on the revenue. This approach also violates the principle of separation of concerns: raw data should never touch production data directly._

15. Výber dátového modelu (napr. hviezdica vs. snehová vločka) bez zohľadnenia použitia.
_**Bad practice.** Schema choice should be grounded by common query patterns. Star schema - for faster queries, more storage. Is used for small to medium size data. Good for BI reporting. Snowflake - more strict, less redundancy. Is used for large & complex DWH._

16. Používanie VARCHAR(MAX) ako predvoleného dátového typu pre textové polia.
_**Bad.** Might affect query performance, storage capacity & allow odd data._

17. Pridávanie všetkých stĺpcov zo zdrojového systému do dátového skladu bez ohľadu na ich relevantnosť.
_**Bad.** Increases storage cost, creates odd noise for the analysts, & might add sensitive data to DWH (that shouldn’t be there) by chance. **Better:** select specific columns during extraction. Document the reasons why the columns are included. Be cautious with sensitive data columns._

18. Vynechanie partitioningu alebo clusteringu pre veľké faktové tabuľky.
_**Bad:** might lead to the worse database performance (like in task 4)._

19. Vývoj a nasadenie zmien v pipeline bez verzovania alebo testovania.
_**Bad:** can’t roll back the changes if something goes wrong. **Good practice** - blue-green deployment that reduces downtime risk & allows instant rollback._

20. Používanie SELECT * v transformáciách smerujúcich do BigQuery.
_**Bad:**** in production practice database performance significantly degradates because all the data is being retrieved instead of only necessary ones, no index-related optimisation is used._

21. Ukladanie servisných účtov k GCP (JSON keys) priamo v repozitári na GitHub
_**Very bad.** Potential security issue. The keys should be stored in .env files locally & never committed to a repository. For a production level system - the best practice is to use Secrets Management Services (like Google Secret Manager)._

22. Implementácia dbt (data build tool) na orchestráciu transformácií v BigQuery namiesto čistých SQL skriptov v Keboole.
_**Depends on the team needs.** For a smaller team with more straightforward  pipelines - SQL scripts in Keboola might be ok. If the pipelines are more complex & team is larger - dbt might be better choice. So it’s worth adding additional power & complexity of dbt when it's needed._

23. Vynechanie validácie schémy pri načítavaní externých JSON dát.
_**Bad practice.** JSON data are flexible & schema-less by themselves (no strict types, validation rules, etc.). Without validation there is a good chance to get missing values, type errors or wrong data. Better: validate the schema for every load. Use alerts for errors._
