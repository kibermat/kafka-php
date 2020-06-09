
set search_path to public;


-- auto-generated definition
create table users
(
    id              serial    not null
        constraint users_pkey
            primary key,
    ssid            uuid default uuid_generate_v4() not null,
    username        varchar(255),
    password        varchar(255),
    email           varchar(255),
    phone           varchar(25) default NULL::character varying,
    first_name      varchar(255),
    middle_name     varchar(255) default null,
    last_name       varchar(255),
    role            varchar(255),
    locale          varchar(25),
    enabled         boolean  default false not null,
    created_at      timestamp,
    created_user_id integer,
    updated_at      timestamp,
    updated_user_id integer
);

alter table users owner to dev;

create index if not exists idx_users_sid
    on users (ssid);


drop function if exists f_users8find(pu_sid uuid, OUT "id" integer);
create function f_users8find(pu_sid uuid, OUT "id" integer)
as
'   select u.id
    from users as u
    where u.ssid = pu_sid
'
    LANGUAGE SQL;
alter function f_users8find(pu_ssid uuid, OUT "id" integer) owner to dev;
