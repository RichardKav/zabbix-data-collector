#!/bin/bash
host=$1
item=$2
start=$3
end=$4
#Change the zabbix database connection details below so as to match your Zabbix installation.
username=zabbixinfo
database=zabbix
password=readonly
hostname=10.10.0.1

if [ "$#" -ne 4 ]; then
    echo "Usage: zabbix_data_collector.sh hostname item_name start_time end_time"
	echo "e.g.  ./zabbix_data_collector.sh testnode1 power 1439337600 1439373722"
	if [ "$#" -eq 1 ]; then
		mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT it.itemid, it.name, it.key_ from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host'" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > "${host}_items_list.csv"
	fi
	exit 1
fi

echo "Host = " $host
echo "Item = " $item
echo "Start Time = " $start
echo "End Time = " $end

#doubles/ floats

mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT h.itemid, h.clock, i.name, i.key_, h.value FROM items i, history h WHERE h.itemid = i.itemid AND h.itemid = (select it.itemid from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host' AND it.key_ = '$item') AND h.clock >= $start AND h.clock <= $end order by h.clock;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > "${host}_${item}_${start}_${end}.csv"

if [[ -s "${host}_${item}_${start}_${end}.csv" ]] ; then
	echo "The item found was of type double."
	exit 1
fi ;

#integers

mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT h.itemid, h.clock, i.name, i.key_, h.value FROM items i, history_uint h WHERE h.itemid = i.itemid AND h.itemid = (select it.itemid from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host' AND it.key_ = '$item') AND h.clock >= $start AND h.clock <= $end order by h.clock;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > "${host}_${item}_${start}_${end}.csv"

if [[ -s "${host}_${item}_${start}_${end}.csv" ]] ; then
	echo "The item found was of type integer."
	exit 1
fi ;

#Strings

mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT h.itemid, h.clock, i.name, i.key_, h.value FROM items i, history_str h WHERE h.itemid = i.itemid AND h.itemid = (select it.itemid from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host' AND it.key_ = '$item') AND h.clock >= $start AND h.clock <= $end order by h.clock;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > "${host}_${item}_${start}_${end}.csv"

if [[ -s "${host}_${item}_${start}_${end}.csv" ]] ; then
	echo "The item found was of type string."
	exit 1
fi ;

#text

mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT h.itemid, h.clock, i.name, i.key_, h.value FROM items i, history_text h WHERE h.itemid = i.itemid AND h.itemid = (select it.itemid from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host' AND it.key_ = '$item') AND h.clock >= $start AND h.clock <= $end order by h.clock;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > "${host}_${item}_${start}_${end}.csv"

if [[ -s "${host}_${item}_${start}_${end}.csv" ]] ; then
	echo "The item found was of type text."
	exit 1
fi ;

echo "Item not found"
rm "${host}_${item}_${start}_${end}.csv"
echo "Please check the file ${host}_items_list.csv for a list of valid values that can be given for the item parameter."

mysql -h $hostname -u $username -p${password} -D $database --column_names --execute="SELECT it.itemid, it.name, it.key_ from hosts, items it WHERE hosts.hostid = it.hostid and hosts.host = '$host'" > "${host}_items_list.csv"
