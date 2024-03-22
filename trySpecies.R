#################################################################################################
# @Project - TRY-db data integration with ENPKG							#
# @Description - This file is responsible for integrating the data from TRY-db with the ENPKG	#
#################################################################################################

library(rotl)
library(taxizedb)
library(dplyr) 
library(dbplyr)
library(duckdb)
library(arrow) #optional. Yet to decide its applicability

wdir <- "data"
#get data from OTOL
getOtol <- function(df.speciesX) {
	a1 <- unique(df.speciesX$TRY_AccSpeciesName)
	a1 <- tolower(a1)
	#window of 10000 as listed in the description of tnrs_match_names
	df.otol <- tnrs_match_names(names = a1[1:5663],context_name="Land plants")
	for (i in seq(5664,length(a1),10000)) {
        	j <- i + 9999
	        print(i)
        	print(j)
 	        df.tmp <- tnrs_match_names(names = a1[i:j],context_name="Land plants")
        	df.otol <- rbind(df.otol, df.tmp)
	}
	which(!(a1 %in% df.otol$search_string))
	#there are some duplicates, and 23265 names which were not found. In testing phase to figure out an alternative approach for mapping those 23265 names
	df.otol <- na.omit(df.otol) #Omit all those that were not found
	return(df.otolX)
}

#get data from wikidata and subsequent gbif and ncbi ids
getWikidata <- function() {
	db_download_wikidata(verbose = TRUE, overwrite = FALSE) # download wikidata with aggregated taxonomic ids for ncbi and gbif.
	db_path("wikidata") # get the path of the database. optional.
	src <- src_wikidata()  # load wikidata
	df.wikidataX <- data.frame(tbl(src, "wikidata"))
	#sanity check
	x <- filter(df.wikidataX, scientific_name == "Acer campestre")
	print(x)
	return(df.wikidataX)
}

#open TRY db, get the species name############
df.species <- read.csv(paste(wdir,"Try20243712146549_TRY6.0_SpeciesList_TaxonomicHarmonization.csv", sep="/"), header=TRUE, sep=",",row.names=NULL)
df.species.search <- df.species[,c("TRY_AccSpeciesName","TRY_SpeciesID")]

#mapping to wikidata, ncbi, gbif and otol
df.wikidata <- getWikidata()
#df.otol <- getOtol(df.species.search) # In testing still. Don't run just yet!

#match try species data to wikidata taxon names########### 
df.result.left <- inner_join(df.species.search,df.wikidata, by=c("TRY_AccSpeciesName"="scientific_name"), relationship="many-to-many")


#open trait data from TRY-db################## In testing
#the following 3 lines need to be run only once, to install the sqlite extension for duckdb-r
#con <- DBI::dbConnect(duckdb(config=list('allow_unsigned_extensions'='true')))
#dbExecute(con, "INSTALL sqlite") 
#dbExecute(con, "LOAD sqlite") 

#con <- DBI::dbConnect(duckdb(), dbdir=paste(wdir,"trydb.sqlite",sep="/"), read_only=TRUE) 
#sanity check for the smooth operations of the sqlite database
#res1 <- dbGetQuery(con, "SELECT DISTINCT SpeciesName FROM trydb")
#print(res)


#open data from enpkg#########################
df.enpkg <- read.csv(paste(wdir,"enpkgQueryResult_20240311.tsvs",sep="/"), header=TRUE, sep="\t",row.names=NULL)
df.enpkg.uniqTax <- unique(df.enpkg$submitted_taxon)


#match data from enpkg to the trydb traits data####################### In testing
#qry <- sprintf("SELECT * FROM trydb WHERE SpeciesName IN (%s) OR AccSpeciesName IN (%s)",paste(rep("?", length(df.enpkg.uniqTax)), collapse=","), paste(rep("?", length(df.enpkg.uniqTax)), collapse=","))
#res.species <- dbGetQuery(con, qry, params=c(df.enpkg.uniqTax,df.enpkg.uniqTax))
