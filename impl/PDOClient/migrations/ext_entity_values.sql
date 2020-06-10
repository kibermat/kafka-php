/**
  * Создать таблицу для связи с мис ид
  */

set search_path to public;


CREATE TABLE IF NOT EXISTS ext_systems
(
    id          INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    code        text,
    description text,
    url         text default null
);
COMMENT ON TABLE ext_systems IS 'Внешние системы ';
COMMENT ON COLUMN ext_systems.id IS 'Id';

create or replace function f_ext_systems8add(ps_code text, ps_description text, ps_url text) returns integer
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin

    insert into ext_systems(code, description, url)
    select t.code, t.description, t.url
    from (values (lower(ps_code), ps_description, ps_url)
         ) as t (code, description, url)
             left join ext_systems as e using (code)
    where e.code is null
    returning id into n_id;

    if not found then
        select id into n_id from ext_systems where code = lower(ps_code);
    end if;

    return n_id;
end;
$$;
alter function f_ext_systems8add(ps_code text, ps_description text, ps_url text) owner to dev;

select f_ext_systems8add('mis_bars', 'МИС Барс', 'localhost');
select f_ext_systems8add('meditus', 'Сервис мобилки', 'localhost');


CREATE TABLE IF NOT EXISTS ext_entities
(
    id          INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    code        text,
    description text,
    endpoint    text default null
);
COMMENT ON TABLE ext_entities IS 'Внешние системы - Реализации ';
COMMENT ON COLUMN ext_entities.id IS 'Id';

create or replace function f_ext_entities8add(ps_code varchar, ps_description text, ps_endpoint text default null) returns integer
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin

    insert into ext_entities(code, description, endpoint)
    select t.code, t.description, t.endpoint
    from (values (lower(ps_code), ps_description, ps_endpoint)
         ) as t (code, description, endpoint)
             left join ext_entities as e using (code)
    where e.code is null
    returning id into n_id;

    if not found then
        select id into n_id from ext_entities where code = lower(ps_code);
    end if;

    return n_id;
end;
$$;
alter function f_ext_entities8add(ps_code varchar, ps_description text, ps_endpoint text) owner to dev;

select f_ext_entities8add(t.code, t.description, t.endpoint)
from (values ('get-agent', 'Информация о пользователе', null),
             ('get-lpu-info', 'Справочник ЛПУ и подразделений', null),
             ('get-profile-info', 'Справочник профилей врача', null),
             ('get-direction-info', 'Справочник направлений', null),
             ('get-resource', 'Справочник врачей/услуг', null),
             ('get-resource-person', 'Доступные врачи/услуги пользователю', null),
             ('get-schedule', 'Расписания ', '/med2des/webservice/rpc/er/get_schedule'),
             ('put-appointment', 'Запись на прием', '/med2des/webservice/rpc/er/put_ticket_add'),
             ('get-about-me', 'Первичная загрузка по пациенту', null),
             ('get-sites', 'Участки', null)
     ) as t (code, description, endpoint)
;

CREATE TABLE IF NOT EXISTS ext_system_entities
(
    "system" INTEGER,
    "entity" INTEGER,
    "type"   VARCHAR(30) DEFAULT 'default',
    CONSTRAINT pk_ext_system_entities PRIMARY KEY ("system", "entity"),
    CONSTRAINT fk_ext_system_entities_system FOREIGN KEY ("system") REFERENCES ext_systems (id),
    CONSTRAINT pk_ext_system_entities_entity FOREIGN KEY ("entity") REFERENCES ext_entities (id)
);
COMMENT ON TABLE ext_system_entities IS 'Внешние системы - Реализации ';

create or replace function f_ext_system_entities8add(pn_system integer, pn_entity integer, ps_type varchar) returns integer
    security definer
    language plpgsql
as
$$
declare
    n_id integer default null;
begin

    insert into ext_system_entities("system", "entity", "type")
    select t."system", t."entity", t."type"
    from (values (pn_system, pn_entity, ps_type)
         ) as t ("system", "entity", "type")
             left join ext_system_entities as e using ("system", "entity", "type")
    where e."system" is null
    returning "system" into n_id;

    return n_id;
end;
$$;
alter function f_ext_system_entities8add(pn_system integer, pn_entity integer, ps_type varchar) owner to dev;

select f_ext_system_entities8add(s.id, e.id, 'default'::varchar)
from ext_systems s
         cross join ext_entities e;


create or replace function f_ext_system_entities8find(ps_system text, ps_entity text, OUT "system" integer,
                                                      OUT "entity" integer)
as
'
    select se."system",
           se."entity"
    from ext_system_entities as se
             join ext_entities e on se."entity" = e.id
             join ext_systems s on se."system" = s.id
    where s."code" = lower(ps_system)
      and e."code" = lower(ps_entity)
    limit 1
'
    LANGUAGE SQL;
alter function f_ext_system_entities8find(ps_system text, ps_entity text, OUT "system" integer, OUT "entity" integer) owner to dev;
--select f_ext_system_entities8find('MIS_BARS', 'get-lpu-info');

create or replace function f_ext_system_entities8get_url(pn_system integer, pn_entity integer, OUT "url" text)
as
'
    select concat(s.url, e.endpoint) as "url"
    from ext_system_entities as se
         join ext_entities e on se."entity" = e.id
         join ext_systems s on se."system" = s.id
    where se."system" = pn_system
      and se."entity" = pn_entity
    limit 1
'
    LANGUAGE SQL;
alter function f_ext_system_entities8get_url(pn_system integer, pn_entity integer, OUT "url" text) owner to dev;
-- select f_ext_system_entities8get_url(t.s, t.e)
-- from f_ext_system_entities8find('MIS_BARS', 'get-schedule') as t(s,e);

create or replace function f_ext_system_entities8get_url(ps_system text, ps_entity text, OUT "url" text)
as
'
    select concat(s.url, e.endpoint) as "url"
    from ext_system_entities as se
             join ext_entities e on se."entity" = e.id
             join ext_systems s on se."system" = s.id
    where s."code" = lower(ps_system)
      and e."code" = lower(ps_entity)
    limit 1
'
    LANGUAGE SQL;
alter function f_ext_system_entities8get_url(ps_system text, ps_entity text, OUT "url" text) owner to dev;
-- select f_ext_system_entities8get_url('MIS_BARS', 'get-schedule');


CREATE TABLE IF NOT EXISTS ext_entity_values
(
    id       bigint generated by default as identity
        CONSTRAINT pk_ext_entity_values_id PRIMARY KEY,
    "system" INTEGER,
    "entity" INTEGER,
    "value"  BIGINT NOT NULL,
    CONSTRAINT fk_ext_entity_values_system FOREIGN KEY ("system", "entity") REFERENCES ext_system_entities ("system", "entity")
);
COMMENT ON TABLE ext_entity_values IS 'Внешние системы - Значения ';
COMMENT ON COLUMN ext_entity_values.id IS 'Id';
CREATE INDEX IF NOT EXISTS i_ext_entity_values_id ON ext_entity_values (id);
CREATE UNIQUE INDEX IF NOT EXISTS i_ext_entity_values_sysvalue ON ext_entity_values ("value", "entity", "system");


create or replace function f_ext_entity_values8add(pn_system integer, pn_entity integer, pn_value bigint) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    begin
        insert into ext_entity_values
        ("system",
         "entity",
         "value")
        values (pn_system,
                pn_entity,
                pn_value)
        returning id into n_id;
    end;

    return n_id;
end;
$$;
alter function f_ext_entity_values8add(integer, integer, bigint) owner to dev;

create or replace function f_ext_entity_values8upd(pn_id bigint, pn_system integer, pn_entity integer, pn_value bigint) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    begin
        update ext_entity_values as t
        set (
             "system",
             "entity",
             "value"
                ) =
                (
                 pn_system,
                 pn_entity,
                 pn_value
                    )
        where t.id = pn_id;

        if not found then
            raise 'Запись с идентификаторм % не найдена!', pn_id;
        else
            n_id := pn_id;
        end if;

    end;

    return n_id;
end;
$$;
alter function f_ext_entity_values8upd(bigint, integer, integer, bigint) owner to dev;

drop function if exists f_ext_entity_values8del(pn_id bigint);
create or replace function f_ext_entity_values8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin

    begin
        delete
        from ext_entity_values t
        where t.id = pn_id;

        if not found then
            raise notice 'Запись с идентификаторм % не найдена!', pn_id;
        end if;

    end;
end;
$$;
alter function f_ext_entity_values8del(bigint) owner to dev;

create or replace function f_ext_entity_values8find(pn_system integer, pn_entity integer, pn_value bigint) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    if pn_value is null then
        return n_id;
    end if;

    select t.id
    into n_id
    from ext_entity_values t
    where t."system" = pn_system
      and t."entity" = pn_entity
      and t."value" = pn_value
    limit 1;

    return n_id;
end;
$$;
alter function f_ext_entity_values8find(pn_system integer, pn_entity integer, pn_value bigint) owner to dev;

create or replace function f_ext_entity_values8rebuild(pn_system integer, pn_entity integer, pn_value bigint,
                                                       ps_action varchar) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin

    n_id := f_ext_entity_values8find(pn_system, pn_entity, pn_value);

    if n_id is not null then
        perform f_ext_entity_values8del(n_id);
        n_id := null;
    end if;

    if ps_action in ('add', 'upd') then
        n_id := f_ext_entity_values8add(pn_system, pn_entity, pn_value);
    end if;

    return n_id;
end;
$$;
alter function f_ext_entity_values8rebuild(pn_system integer, pn_entity integer, pn_value bigint, ps_action varchar) owner to dev;


create or replace function f_mis_agent8find(pu_uid uuid, out "agent" varchar)
as
'
    select ag.mis_agent as agent
    from er.er_persons as per
             join er.er_users as er_u on er_u.id = per.er_users
             join er.er_mis_agents as ag on ag.sysuser = er_u.sysuser
    where per.pers_uid = pu_uid
    limit 1
'
    LANGUAGE SQL;
alter function f_mis_agent8find(pu_uid uuid, out "agent" varchar) owner to dev;
--select f_mis_agent8find('0cb40d52-abac-4fef-9f9e-6d64ec53de27');


create or replace function f_mis_person8find(agent bigint, out person_id bigint)
as
'
    select per.id as person_id
    from er.er_mis_agents as ag
             join er.er_users as er_u on er_u.id = ag.er_user
             join er.er_persons as per on per.er_users = er_u.id
    where ag.mis_agent = agent::varchar
    limit 1
'
    LANGUAGE SQL;
alter function f_mis_person8find(agent bigint, out person_id bigint) owner to dev;
--select f_mis_person8find(5900111);
