#!/bin/bash


tzdata

sudo apt-get update

sudo apt-get install dirmngr -y

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E0C56BD4

echo "deb http://repo.clickhouse.tech/deb/stable/ main/" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

sudo apt-get install clickhouse-server clickhouse-client

sudo service clickhouse-server start

clickhouse-client --password admin --user default --query='SELECT version()'

sudo apt install python-pip -y

sudo pip install clickhouse-cli -y

sudo wget http://sdm.lbl.gov/fastbit/data/star2002-full.csv.gz


sudo zcat star2002-full.csv.gz  > star2002-full.csv

sudo rm star2002-full.csv.gz

clickhouse-client --password admin --user default --format_csv_delimiter="," --query="CREATE DATABASE IF NOT EXISTS tutorial" 

clickhouse-client --password admin --user default

CREATE TABLE tutorial.hilia
(
`antiNucleus` Int8,
`eventFile` Int64,
`eventNumber` Int8,
`eventTime` Float32,
`histFile` Int64,
`multiplicity` Int8,
`NaboveLb` Int8,
`NbelowLb` Int8,
`NLb` Int8,
`primaryTracks` Int8,
`prodTime` Float32,
`Pt` Float32,
`runNumber` Int8,
`vertexX` Float32,
`vertexY` Float32,
`vertexZ` Float32
)
ENGINE = MergeTree()
PARTITION BY eventTime
ORDER BY (eventTime)
SETTINGS index_granularity = 8192

clickhouse-client --password admin --user default --format_csv_delimiter="," --query="INSERT INTO tutorial.test FORMAT CSV" < star2002-full.csv

clickhouse-client --password admin --user default --query="select count(*) from tutorial.test"



use tutorial;

SELECT count(*) FROM test
SELECT count(*) FROM test WHERE eventNumber > 1
SELECT count(*) FROM test WHERE eventNumber > 20000
SELECT count(*) FROM test WHERE eventNumber > 500000
SELECT eventFile, count(*) FROM test GROUP BY eventFile
SELECT eventFile, count(*) FROM test WHERE eventNumber > 525000 GROUP BY eventFile
SELECT eventFile, eventTime, count(*) FROM test WHERE eventNumber > 525000 GROUP BY eventFile, eventTime ORDER BY eventFile DESC, eventTime ASC
SELECT MAX(runNumber) FROM test
SELECT AVG(eventTime) FROM test WHERE eventNumber > 20000
SELECT eventFile, AVG(eventTime), AVG(multiplicity), MAX(runNumber), count(*) FROM test WHERE eventNumber > 20000 GROUP BY eventFile



for i in `seq 1 10`;
do
       echo " Copying File star2002-full$i.csv" 
       sudo cp star2002-full.csv star2002-full$i.csv

done



clickhouse-client --password admin --user default  --query="SELECT table, formatReadableSize(sum(bytes)) as size, min(min_date) as min_date, max(max_date) as max_date FROM system.parts WHERE active GROUP BY table"  



for i in `seq 1 5`;
do
    
    echo " Copying File star2002-full$i.csv" 
    sudo cp star2002-full.csv star2002-full$i.csv
    echo " => I am loading data $i"
    clickhouse-client --password admin --user default --format_csv_delimiter="," --query="INSERT INTO tutorial.hilia FORMAT CSV" < star2002-full$i.csv
    sudo rm -f star2002-full$i.csv
    echo "I have finished with loeading data $i"
done

clickhouse-client --password admin --user default  --query="SELECT table, formatReadableSize(sum(bytes)) as size, min(min_date) as min_date, max(max_date) as max_date FROM system.parts WHERE active GROUP BY table"  







#  https://www.altinity.com/blog/2019/12/28/creating-beautiful-grafana-dashboards-on-clickhouse-a-tutorial


sudo apt-get install -y adduser libfontconfig1
sudo wget https://dl.grafana.com/oss/release/grafana_6.7.2_amd64.deb
sudo dpkg -i grafana_6.7.2_amd64.deb

sudo service grafana-server start

 
sudo grafana-cli plugins install vertamedia-clickhouse-datasource

sudo service grafana-server restart



#sudo chown clickhouse:clickhouse -R /mnt/disk_1/ /mnt/disk_2/ /mnt/disk_3/
#sudo systemctl restart clickhouse-server
#sudo systemctl status clickhouse-server
