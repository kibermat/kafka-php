<?php

namespace KafkaClient\Producer;

use http\Exception;
use Monolog\Logger;
use Monolog\Handler\StreamHandler;


date_default_timezone_set('Europe/Moscow');


class Producer extends \Kafka\Producer
{
    public static $handler;
    private $async;
    private $logsFile = __dir__ . '/Logs/producer.log';
    private $brokerVersion = '1.0.0';
    private $refreshIntervalMs = 10000;
    private $config;
    private $topic;
    private $broker;
    private $arrStream;

    public function __construct($broker, $topic, $data = '', $key = '', $async = false)
    {
        self::$handler = new Logger('producer_logger');
        self::$handler->pushHandler(new StreamHandler($this->logsFile, Logger::DEBUG));

        $this->broker = $broker;
        $this->topic = $topic;

        $this->arrStream = [
            [
                'topic' => $this->topic,
                'value' => '',
                'key' => $key,
            ]
        ];

        $this->async = $async;

        $this->setConfig();
        $this->setMessage($data);
        $this->setLogger(self::$handler);

        if (!$async) {
            parent::__construct();
        } else {
            parent::__construct(function() {
                return [
                    $this->arrStream
                ];
            });
        }

//        $this->success(function($result) {
//           print_r(var_dump($result));
//        });
//
//        $this->error(function($errorCode) {
//            print_r(var_dump($errorCode));
//        });

    }

    /**
     * @param mixed[]|bool $data
     * @return mixed[]|null
     */
    public function send($data = false): ?array
    {
        if ($this->async) {
            return parent::send(true);
        } elseif (!$data) {
           return null;
        } else {
            $this->setMessage($data);
            return parent::send($this->arrStream);
        }
    }

//    public function success(\Closure $success = null): void
//    {
//        if (!$this->async) {
//            return;
//        }
//        parent::success($success);
//    }
//
//    public function error(\Closure $error = null): void
//    {
//        if (!$this->async) {
//            return;
//        }
//        parent::error($error);
//    }

    /**
     * @param $data object|array
     */
    private function setMessage($data)
    {
        if (is_array($data) or is_object($data)) {
            $data = json_encode($data);
        } else {
            $data = json_encode((object) $data);
        }

        $this->arrStream[0]['value'] = $data;
    }

    private function setConfig() {
        $this->config = \Kafka\ConsumerConfig::getInstance();
        $this->config->setMetadataRefreshIntervalMs($this->refreshIntervalMs);
        $this->config->setMetadataBrokerList($this->broker);
        $this->config->setBrokerVersion($this->brokerVersion);
        $this->config->setRequiredAck(1);
        $this->config->setIsAsyn(false);
        $this->config->setProduceInterval(500);
    }
}
