

create schema if not exists kafka;


create table if not exists kafka.kafka_queue
(
    id          serial       not null
        constraint kafka_queue_pkey
            primary key,
    method      varchar(255) not null,
    data        jsonb,
    success     boolean,
    ssid        uuid          default uuid_generate_v1(),
    message     text,
    version     numeric(3, 1) default 1,
    create_time timestamp     default CURRENT_TIMESTAMP
);

alter table kafka.kafka_queue owner to dev;


