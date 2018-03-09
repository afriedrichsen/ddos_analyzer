-- This is a Hive program. Hive is an SQL-like language that compiles
-- into Hadoop Map/Reduce jobs. It's very popular among analysts at
-- Facebook, because it allows them to query enormous Hadoop data
-- stores using a language much like SQL.

-- Our logs are stored on the Hadoop Distributed File System, in the
-- directory /logs/randomhacks.net/access.  They're ordinary Apache
-- logs in *.gz format.
--
-- We want to pretend that these gzipped log files are a database table,
-- and use a regular expression to split lines into database columns.
CREATE EXTERNAL TABLE access(
  host STRING,
  identity STRING,
  user STRING,
  time STRING,
  request STRING,
  status STRING,
  size STRING,
  referer STRING,
  agent STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
  'input.regex' = '([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?'
)
STORED AS TEXTFILE

LOCATION '/user/cloudera/ddos_analyzer/events';

-- We want to store our logs in HBase, which is designed to hold tables
-- with billions of rows and millions of columns. HBase stores rows
-- sorted by primary key, so you can efficiently read all records within
-- a given range of keys.
--
-- Here, our key is a Unix time stamp, and we assume that it always has
-- the same number of digits (hey, this was a dodgy late night hack).
-- So we could easily grab all the records from a specific time period.
--
-- We store our data in 3 column families: "m" for metadata, "r" for
-- referrer data, and "a" for user-agent data. This allows us to only
-- load a subset of columns for a given query.
CREATE EXTERNAL TABLE access_hbase(
  key STRING,          -- Unix time + ":" + unique identifier.
  host STRING,         -- The IP address of the host making the request.
  identity STRING,     -- ??? (raw log data)
  user STRING,         -- ??? (raw log data)
  time BIGINT,         -- Unix time, UTC.
  method STRING,       -- "GET", etc.
  path STRING,         -- "/logo.png", etc.
  protocol STRING,     -- "HTTP/1.1", etc.
  status SMALLINT,     -- 200, 404, etc.
  size BIGINT,         -- Response size, in bytes.
  referer_host STRING, -- "www.google.com", etc.
  referer STRING,      -- Full referrer string.
  agent STRING)        -- Full agent string.
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES (
  'hbase.columns.mapping' = ':key,m:host,m:identity,m:user,m:time,m:method,m:path,m:protocol,m:status,m:size,r:referer_host,r:referer,a:agent'
)
TBLPROPERTIES ('hbase.table.name' = 'access');


-- Here is a table for hosts that we believes are part of a ddos campaign/attack.
--
CREATE EXTERNAL TABLE ddos_hosts(
key STRING,          -- Unix time + ":" + unique identifier.
host STRING,         -- The IP address of the host making the request.
date_added BIGINT    -- Unix time
)        -- Full agent string.
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES('hbase.columns.mapping' = ':key,m:host,m:date_added')
TBLPROPERTIES('hbase.table.name' = 'ddos_hosts');

-- Copy our data from raw Apache log files to HBase, cleaning it up as we go.  This is basically
-- a pseudo-SQL query which calls a few Java helpers.
INSERT OVERWRITE TABLE access_hbase
SELECT concat(cast(unix_timestamp(time, '[dd/MMM/yyyy:HH:mm:ss Z]') AS STRING), ':', reflect('java.util.UUID','randomUUID')) AS key,
  host,
  regexp_replace(identity,'"',''),
  regexp_replace(user,'"',''),
  unix_timestamp(time, '[dd/MMM/yyyy:HH:mm:ss Z]'),
       regexp_extract(regexp_replace(request,'"',''), '([^ ]*) ([^ ]*) ([^\"]*)', 1) AS method,
       regexp_extract(regexp_replace(request,'"',''), '([^ ]*) ([^ ]*) ([^\"]*)', 2) AS path,
       regexp_extract(regexp_replace(request,'"',''), '([^ ]*) ([^ ]*) ([^\"]*)', 3) AS protocol,
       cast(status AS SMALLINT) AS status,
       cast(size AS BIGINT) AS size,
       regexp_extract(regexp_replace(referer,'"',''), '[^:]+:?/+([^/]*).*', 1) AS referer_host,
       regexp_replace(referer,'"','') AS referer,
  regexp_replace(agent,'"','')
FROM access
WHERE unix_timestamp(time, '[dd/MMM/yyyy:HH:mm:ss Z]') IS NOT NULL;


-- Find the 50 visiting hosts.
SELECT host, count(*) AS cnt
FROM access_hbase GROUP BY host
ORDER BY cnt DESC LIMIT 50;


INSERT OVERWRITE TABLE ddos_hosts
SELECT key, host,CURRENT_TIMESTAMP()
from access_hbase
WHERE host is not null
AND host not in ('NULL')
group by key, host having count(*) > 30
