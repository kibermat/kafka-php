<?php
require __DIR__ . '/vendor/autoload.php';

use KafkaClient\Consumer\Consumer;
use KafkaClient\Settings;

use PDOClient\Logger;


$topic1 = 'get-lpu-info';
$topic2 = 'get-profile-info';

$consumer =new Consumer(Settings::BROKER, [$topic1, $topic2], 'main_group');

$db = new Logger('pgsql:host=localhost;port=5432;dbname=er', 'postgres', 'postgres');

$consumer->start(
    function($topic, $part, $message) use ($db) {
        $str_response = $message['message'] ? $message['message']['value'] : null;
        $json_response  = json_decode($str_response);
        if ($json_response->unitcode = 'er') {
            $db->insertResult($topic, $str_response, $json_response->status == 'ok');
        }
        print_r($topic . ' - ' . $json_response->status . PHP_EOL);
    }
);
