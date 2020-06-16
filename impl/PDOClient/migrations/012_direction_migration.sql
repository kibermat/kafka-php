
DO
$$
    begin

        ALTER TABLE er.er_directions
            ADD COLUMN ext_id bigint default null;
        comment on column er.er_directions.ext_id is 'Ссылка на внешний идентификатор';

        ALTER TABLE er.er_directions
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES kafka.ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_directions_type') then
            --drop type if exists ext_system_directions_type;
            create type kafka.ext_system_directions_type as
            (
                id         bigint,
                type       text,
                kind       text,
                dir_numb   text,
                lpu        bigint,
                div        bigint,
                lpu_name   text,
                allow      boolean,
                date_begin date,
                date_end   date,
                action     text,
                profile_id bigint,
                "FullInfo" jsonb
            );
        END IF;
    END
$$;


-- auto-generated definition
create table if not exists er.er_direction_type
(
    id    bigint not null
        constraint pk_er_direction_type
            primary key,
    label text   not null
);


insert into er.er_direction_type(id, label)
select t.*
from (values (1, 'Поликлиника'), (2, 'Стационар')) as t(id, label)
         left join er.er_direction_type d using (id)
where d.id is null;
comment on table er.er_direction_type is 'Тип направления ';
comment on column er.er_direction_type.id is 'Id';
alter table er.er_directions owner to dev;

DO
$$
    begin
        ALTER TABLE er.er_directions
            ADD CONSTRAINT fk_er_direction_type_id FOREIGN KEY (dir_type) REFERENCES er_direction_type (id) ON DELETE RESTRICT;
    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


drop function if exists kafka.f_ext_directions8add(pn_ext_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb);
create function kafka.f_ext_directions8add(pn_ext_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text,
                                        pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint,
                                        pn_profile_id bigint, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_add',null);
    begin
        insert into er.er_directions
        (id,
         ext_id,
         dir_uid,
         person_id,
         dir_numb,
         dir_type,
         dir_kind,
         mo_id,
         div_id,
         profile_id,
         add_info)
        values (core.f_gen_id(),
                pn_ext_id,
                pu_dir_uid,
                pn_person_id,
                ps_dir_numb,
                pn_dir_type,
                ps_dir_kind,
                pn_mo_id,
                pn_div_id,
                pn_profile_id,
                pu_add_info)
        returning id into n_id;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_directions_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_directions8add(bigint, uuid, bigint, text, bigint, text, bigint, bigint, bigint, jsonb) owner to dev;


drop function if exists kafka.f_ext_directions8upd(pn_id bigint, pn_ext_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb);
create function kafka.f_ext_directions8upd(pn_id bigint, pn_ext_id bigint, pu_dir_uid uuid, pn_person_id bigint,
                                        ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint,
                                        pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_upd',pn_id);
    begin
        update er.er_directions t
        set ext_id     = pn_ext_id,
            dir_uid    = pu_dir_uid,
            person_id  = pn_person_id,
            dir_numb   = ps_dir_numb,
            dir_type   = pn_dir_type,
            dir_kind   = ps_dir_kind,
            mo_id      = pn_mo_id,
            div_id     = pn_div_id,
            profile_id = pn_profile_id,
            add_info   = pu_add_info
        where t.id = pn_id;

        if not found then
            perform core.f_msg_not_found(pn_id, 'er_directions');
        else
            n_id := pn_id;
        end if;

    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_directions_upd',pn_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_directions8upd(bigint, bigint, uuid, bigint, text, bigint, text, bigint, bigint, bigint, jsonb) owner to dev;


drop function if exists kafka.f_ext_directions8del(pn_id bigint);
create function kafka.f_ext_directions8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_del',pn_id);
    begin
        delete
        from er.er_directions t
        where t.id = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_directions'); end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_directions_del',pn_id);
end;
$$;
alter function kafka.f_ext_directions8del(pn_id bigint) owner to dev;


drop function if exists kafka.f_kafka_load_derections(p_topic text);
CREATE OR REPLACE FUNCTION kafka.f_kafka_load_derections(p_topic text)
    RETURNS int AS
$$
DECLARE
    n_cnt           INT DEFAULT 0;
    s_mis_code      VARCHAR;
    s_type          VARCHAR;
    n_system        INTEGER;
    n_entity        INTEGER;
    rec_res         RECORD;
    json_body       jsonb;
    n_person_id     bigint;
    n_ext_person_id bigint;
    cur_res CURSOR (p_topic TEXT)
        FOR select *
            from kafka.kafka_queue
            where method = p_topic
              and success
              and pg_try_advisory_xact_lock(id)
                for update;
BEGIN
    OPEN cur_res(p_topic);

    LOOP
        FETCH cur_res INTO rec_res;

        EXIT WHEN NOT FOUND;

        json_body := rec_res.data;
        s_type := 'er_direction';
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;
        n_ext_person_id := cast((json_body -> 'response' -> 'agent_id' ->> 0) as bigint);

        select "system", "entity"
        into n_system, n_entity
        from kafka.f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        n_person_id := kafka.f_ext_person8find(n_ext_person_id);

        if n_person_id is null then
            raise exception 'Нет агента. Идентификатор внешней системы % ', n_ext_person_id;
        end if;

        with map as (
            select t.*,
                   kafka.f_ext_entity_values8find(n_system, n_entity, t.lpu)             as mo_ext_id,
                   kafka.f_ext_entity_values8find(n_system, n_entity, t.div)             as div_ext_id,
                   kafka.f_ext_entity_values8find(n_system, n_entity, t.profile_id)      as profile_ext_id,
                   kafka.f_ext_entity_values8rebuild(n_system, n_entity, t.id, "action") as ext_id
            from jsonb_populate_recordset(null::kafka.ext_system_directions_type,
                                          json_body -> 'response' -> 'ResultSet' -> 'RowSet') as t
        ),
             cte as (
                 select t.*,
                        dir_type.id as dir_type
                 from map as t
                          left join lateral (select id
                                             from er.er_direction_type
                                             where lower(label) = lower(t."type")) as dir_type on true
                          left join er.er_mo mo on (t.mo_ext_id = mo.ext_id)
                          left join er.er_mo div on (t.div_ext_id = div.ext_id)
                          left join er.er_profiles pr on (t.profile_ext_id = pr.ext_id)
                 where (t.lpu is null or mo.id is not null)
                   and (t.div is null or div.id is not null)
                   and (t.profile_id is null or pr.id is not null)
             ),
             ins as (
                 select kafka.f_ext_directions8add(
                                t.ext_id::bigint,
                                uuid_generate_v1(),
                                n_person_id::bigint,
                                t.dir_numb::text,
                                t.dir_type::bigint,
                                t.kind::text,
                                t.lpu::bigint,
                                t.div::bigint,
                                t.profile_id::bigint,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          left join er.er_directions as d using (ext_id)
                 where d.id is null
                   and t."action" = 'add'
             ),
             upd as (
                 select kafka.f_ext_directions8upd(
                                t.id::bigint,
                                t.ext_id,
                                d.dir_uid,
                                n_person_id::bigint,
                                t.dir_numb::text,
                                t.dir_type::bigint,
                                t.kind::text,
                                t.lpu::bigint,
                                t.div::bigint,
                                t.profile_id::bigint,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          join er.er_directions as d using (ext_id)
                 where action = 'upd'
             ),
             cnt as (
                 select count(1) as n
                 from ins
                 union all
                 select count(1) as n
                 from upd
             )
        select sum(n)
        into n_cnt
        from cnt;

        if n_cnt > 0 then
            DELETE FROM kafka.kafka_queue WHERE CURRENT OF cur_res;
        end if;

    END LOOP;

    CLOSE cur_res;

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;


--select kafka.f_kafka_load_derections('get-direction-info');

