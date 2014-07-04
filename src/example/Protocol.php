<?php
require 'autoloader.php';

$data = array(
	'required_ack' => 1,
	'timeout' => 1000,
	'data' => array(
		array(
			'topic_name' => 'test',
			'partitions' => array(
				array(
					'partition_id' => 0,
					'messages' => array(
						'32321`1```````````',
						'message2',
					),
				),
			),
		),
		array(
			'topic_name' => 'test6',
			'partitions' => array(
				array(
					'partition_id' => 2,
					'messages' => array(
						'32321`1```````````',
						'message2',
					),
				),
				array(
					'partition_id' => 5,
					'messages' => array(
						'9932321`1```````````',
						'message2',
					),
				),
			),
		),
	),
);

$conn = new \Kafka\Socket('localhost', '9092');
$conn->connect();
$data = \Kafka\Protocol\Encoder::buildProduceRequest($data);
$conn->write($data);
//var_dump(\Kafka\Protocol\Encoder::unpackInt64($conn->read(8))); // partition count

$dataLen = unpack('N', $conn->read(4));
$dataLen = $dataLen[1];
$data = $conn->read($dataLen);
var_dump(bin2hex($data));
$result = \Kafka\Protocol\Decoder::decodeProduceResponse($data);
var_dump($result);