#download the trydb-traits data, place it in the 'data' folder and run this script.
#sed 's/\"//g;s/\s\+$//g' data/31728.txt > data/31728_noQuotes.txt #sqlite3 does not accept quotes. To further clean the data, remove white spaces at the end of each line
sqlite3 data/trydbAll.sqlite < data/schema.sql
echo '.mode tabs\n.separator "\\t"\n.header off\n.import data/31728_noQuotes.txt trydbAll' | sqlite3 data/trydbAll.sqlite
echo "database created!"
