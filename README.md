# Zabbix Data Collector

The Zabbix data collector is a script that is designed to collect data directly from the Zabbix database and output the data for processing in csv format. 

## Configuration

At the start of the script the database connection information is held. This will need to be changed to match your installation details. An example of this is:

```
username=zabbix
database=zabbix
password=mypassword
hostname=10.10.0.1
```

## Usage

Its usage is as follows: 

```
./zabbix_data_collector.sh <Hostname> <Metric> <Start_time_unix_time> <end_time_unix_time>
```

An example of this is: 

```
./zabbix_data_collector.sh testnode1 power 1439337600 1439373722
```

The script ./get_time_stamp.sh can be used to find the current unix time as an aid. Otherwise online tools such as [unixtimestamp.com](https://www.unixtimestamp.com/) may be used instead.

The ./merge.sh script can be used to aggregate together several metrics files together into a single file called all.csv.

## File Output

The output of the script is a csv file with the following naming pattern, which records the input used to obtain the file:

```
<Hostname>_<Metric>_<Start_time_unix_time>_<end_time_unix_time>.csv
```

In the event the metric name is not found the script will output a list of possible metrics for the specified host in a file with the following name:

```
<Hostname>_items_list.csv
```

