<?php

namespace KafkaClient\Producer;

use KafkaClient\Producer\Producer as Producer;


class ProducerFactory
{

    /**
     * @var Producer[]
     */
    protected static $producers = array();

    /**
     * @param Producer $producer
     * @return void
     */
    public static function pushProducer(Producer $producer)
    {
        if (!self::getProducer($producer->getTopic())) {
            self::$producers[$producer->getTopic()] = $producer;
        }
    }

    /**
     * @param string $topic
     * @return Producer $producer
     */
    public static function getProducer($topic)
    {
        return isset(self::$producers[$topic]) ? self::$producers[$topic] : null;
    }

    /**
     * @param string $topic
     * @return void
     */
    public static function removeProducer($topic)
    {
        if (\array_key_exists($topic, self::$producers)) {
            unset(self::$producers[$topic]);
        }
    }
}