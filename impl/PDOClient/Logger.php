<?php

namespace PDOClient;

use PDO;


class Logger
{
    private static $dbh;

    public function __construct($dsn, $user = null, $pass = null)
    {
        self::$dbh = new PDO($dsn, $user, $pass);

        $this->createResult();

    }

    public function __destruct()
    {
    }

    protected function createResult() {
        self::$dbh->exec('
               create table if not exists kafka.kafka_queue (
                    id serial primary key, 
                    method varchar(255) not null,
                    "data" jsonb, 
                    success boolean default null,
                    ssid uuid default uuid_generate_v1(),
                    message text default null,
                    version numeric(3,1) default 1, 
                    create_time timestamp default current_timestamp
               );
        ');
    }

    public function insertResult($method, $data, $success = null, $ssid = null, $message = null, $version = null)
    {
        if (!$data) {
            return;
        }

        $sql = 'insert into  kafka.kafka_queue (method, "data", success, ssid, message, version)
                    values (:method, :data, :success, :ssid, :message, :version)';

        $sth = self::$dbh->prepare($sql, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));

        return $sth->execute(array(
                ':method' => $method,
                ':data' => $data,
                ':success' => $success,
                ':ssid' => $ssid,
                ':message' => $message,
                ':version' => $version
            ));

    }

}

//$db = new Logger('pgsql:host=localhost;port=5432;dbname=er', 'postgres', 'postgres');
//$db->insertResult('test_method', '{ "customer": "Doe", "items": {"product": "Beer","q": 6}}');
