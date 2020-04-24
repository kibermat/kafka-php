<?php

require __DIR__ . '/vendor/autoload.php';

use KafkaClient\Producer\Producer;
use KafkaClient\Producer\ProducerFactory;
use KafkaClient\Settings;


function getProducer($topic, $data = '', $key = '', $async = false) {
    $producer = ProducerFactory::getProducer($topic);

    if(!$producer) {
        $producer = new Producer(Settings::BROKER, $topic, $data, $key, $async);
        ProducerFactory::pushProducer($producer);
    }
    return $producer;
}


$temp_dir = __DIR__ . '/temp';

$lpu_str = file_get_contents($temp_dir . '/lpu.json');
$lpu_json = json_decode($lpu_str, true);

$profile_str = file_get_contents($temp_dir . '/profile.json');
$profile_json = json_decode($profile_str, true);

$directions_info_str = file_get_contents($temp_dir . '/directions_info.json');
$directions_info_json = json_decode($directions_info_str, true);

$resources_str = file_get_contents($temp_dir . '/resources.json');
$resource_json = json_decode($resources_str, true);

$resource_person_str = file_get_contents($temp_dir . '/resource_person.json');
$resource_person_json = json_decode($resource_person_str, true);


$async = false;
$topic1 = 'get-lpu-info';
$topic2 = 'get-profile-info';
$topic3 = 'get-direction-info';
$topic4 = 'get-resource';
$topic5 = 'get-resource-person';


if ($async) {
    $producer_single =new Producer(Settings::BROKER, $topic1, $lpu_json, '', $async);
    $producer_single->send(true);
} else {

    $producer1 =new Producer(Settings::BROKER, $topic1, '', '', $async);
    $producer1->send($lpu_json);

    $producer2 =new Producer(Settings::BROKER, $topic2, '', '', $async);
    $producer2->send($profile_json);

    $producer3 =new Producer(Settings::BROKER, $topic3, '', '', $async);
    $producer3->send($directions_info_json);

    $producer4 =new Producer(Settings::BROKER, $topic4, '', '', $async);
    $producer4->send($resource_json);

    $producer5 =new Producer(Settings::BROKER, $topic5, '', '', $async);
    $producer5->send($resource_person_json);

}
