<?php
require __DIR__ . '/vendor/autoload.php';

use KafkaClient\Consumer\Consumer;
use KafkaClient\Settings;

//use PDOClient\Logger;


$topic1 = 'get-lpu-info';
$topic2 = 'get-profile-info';
$topic3 = 'get-direction-info';
$topic4 = 'get-resource';
$topic5 = 'get-resource-person';
$topic_me = 'get-about-me';

$consumer =new Consumer(Settings::BROKER,
    [$topic1, $topic2, $topic3, $topic4, $topic5, $topic_me],
    'er');

//$db = new Logger('pgsql:host=localhost;port=5432;dbname=er', 'postgres', 'postgres');

$consumer->start(
    function($topic, $part, $message) {
        print_r(var_export($message, true));
//        $str_response = $message['message'] ? $message['message']['value'] : null;
//        $json_response  = json_decode($str_response);
//        if ($json_response->unitcode = 'er') {
//            $db->insertResult($topic, $str_response, $json_response->status == 'ok');
//        }
//        print_r($topic . ' part ' .$part. ' - ' . $json_response->status . PHP_EOL);
    }
);
