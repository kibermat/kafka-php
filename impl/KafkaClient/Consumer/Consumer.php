<?php

namespace KafkaClient\Consumer;

use Monolog\Logger;
use Monolog\Handler\StreamHandler;


date_default_timezone_set('PRC');


class Consumer extends \Kafka\Consumer
{
    public static $handler;
    private $logsFile = __dir__ . '/Logs/consumer.log';
    private $brokerVersion = '1.0.0';
    private $refreshIntervalMs = 10000;
    private $config;
    private $broker;
    private $topics;
    private $group;

    public function __construct($broker, $topics, $group = null)
    {
        parent::__construct();
        self::$handler = new Logger('consumer_logger');
        self::$handler->pushHandler(new StreamHandler($this->logsFile, Logger::ERROR));

        $this->broker = $broker;
        $this->topics = $topics;
        $this->group = $group;
        $this->setConfig();

        $this->setLogger(self::$handler);

    }

    private function setConfig() {
        $this->config = \Kafka\ConsumerConfig::getInstance();
        $this->config->setMetadataRefreshIntervalMs($this->refreshIntervalMs);
        $this->config->setMetadataBrokerList($this->broker);
        $this->config->setGroupId($this->group);
        $this->config->setBrokerVersion($this->brokerVersion);
        $this->config->setTopics($this->topics);
        $this->config->setOffsetReset('earliest');
    }
}
