<?php

require __DIR__ . '/vendor/autoload.php';

use KafkaClient\Producer\Producer;
use KafkaClient\Settings;


$lpu_str = file_get_contents(__DIR__ . '/temp/lpu.json');
$lpu_json = json_decode($lpu_str, true);

$profile_str = file_get_contents(__DIR__ . '/temp/profile.json');
$profile_json = json_decode($profile_str, true);

$async = false;
$topic1 = 'get-lpu-info';
$topic2 = 'get-profile-info';


if ($async) {
    $producer_single =new Producer(Settings::BROKER, $topic1, $lpu_json, '', $async);
    $producer_single->send(true);
} else {

    $producer1 =new Producer(Settings::BROKER, $topic1, '', '', $async);
    $producer1->send($lpu_json);

    $producer2 =new Producer(Settings::BROKER, $topic2, '', '', $async);
    $producer2->send($profile_json);

}
