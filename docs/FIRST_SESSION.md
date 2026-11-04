# First session checklist

1. Extract this folder somewhere simple, such as `C:\Projects\financial-working-capital-analytics`.
2. Open GitHub Desktop and add the extracted folder as a local repository. If starting a new repository, create it in this folder and use a README already present.
3. Commit the starter project and supplied synthetic CSVs. Push it to GitHub.
4. Open SSMS and run `sql/00_create_database.sql`.
5. Import the seven CSV files from `data/` with SSMS **Tasks > Import Flat File**. Import them into `FinancialOpsDB` and name the tables exactly as the CSV basenames.
6. Run `sql/01_data_quality_checks.sql`. Check that table counts look reasonable and duplicate/orphan queries return no rows.
7. Run the SQL analysis scripts in order.
8. Install Pandas if needed: `python -m pip install pandas`.
9. From the project root, run: `python python/validate_data.py`.
10. Save your query outputs/screenshots and commit each meaningful milestone.

If SSMS gives a datatype-inference problem during import, inspect the preview carefully. Use INT for IDs/quantity, DATE for dates, DECIMAL(18,2) for monetary amounts, and NVARCHAR for text. Do not overwrite your existing `ProductFunnelDB`.
