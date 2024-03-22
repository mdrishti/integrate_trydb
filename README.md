This repository contains scripts for integrating species and subsequent traits data from trydb with taxonomic ids from gbif, otol, ncbi and wikidata. At the moment, data for only 25 traits was downloaded from TRY-db. The csv file retrieved was first converted to sqlite database, followed by an on-disk approach (duckdb) to access the data. This was done to scale the current code for future data integration.

**Prerequisites:**

I. For smooth running of the scripts (R,shell), install R (version 4.1.2) and the following R-packages :

a) For accessing taxonomic ids from wikidata, with mappings from gbif and ncbi (taxizedb) and from open treel of life (rotl)
`install.packages(c("taxizedb", "rotl"))`

b) For data manipulation, install dplyr and dbplyr (backend wrapper to convert dplyr code into SQL)
`install.packages(c("dplyr", "dbplyr"))`

c) For the on-disk approach of accessing and querying databases, duckdb's API client for R
`install.packages("duckdb")`

and [duckdb](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=package_manager)

d) For building a Virtual Knowledge Graph (VKG), download [Ontop-cli/Ontop-protege bundle (version 5.1.2)](https://github.com/ontop/ontop/releases/tag/ontop-5.1.2)



II. If you are not working on linux, then also install sqlite3 package (comes by default with ubuntu).

**Execution to map the TRY plant species name to the gbif, ncbi, wikidata and otol ids**
`sh make_sqlitedb.sh`
`Rscript trySpecies.R`

**Execution to build a duckdb database for Ontop and build the knowledge graph**
`duckdb Ontop_input.db -c "IMPORT DATABASE 'data/Ontop_input_db'"`
`#Set the path in data/Ontop_input_db/duckdb.properties`
`sh run_ontop.sh`


