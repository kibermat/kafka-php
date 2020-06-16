

create or replace function kafka.ref_kafka_queue(refcursor) RETURNS refcursor as
'
    BEGIN
        OPEN $1 FOR select *
                    from kafka.kafka_queue
                    where method = cast($1 as text)
                      and pg_try_advisory_xact_lock(id)
                        for update;
        RETURN $1;
    END;
' LANGUAGE plpgsql;


DO
$$
    begin
        ALTER TABLE er.er_mo
            ADD COLUMN ext_id bigint default null;
        comment on column er.er_mo.ext_id is 'Идентификатор на внешней системе';
        ALTER TABLE er.er_mo
            ADD CONSTRAINT fk_ext_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;
    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_lpu_type') then
            --drop type if exists ext_system_lpu_type;
            create type kafka.ext_system_lpu_type as
            (
                "lpu_id"          bigint,
                "lpu_hid"         bigint,
                "lpu_code"        text,
                "lpu_name"        text,
                "full_name"       text,
                "address"         text,
                "lat"             text,
                "long"            text,
                "without_reg"     bool,
                "for_kids"        bool,
                "record_period"   integer,
                "allow_home_call" bool,
                "action"          text,
                "FullInfo"        jsonb
            );
        END IF;
    END
$$;


drop function if exists kafka.f_ext_mo8upd(pn_id bigint, pn_hid bigint, pn_ext_id bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb);
create function kafka.f_ext_mo8upd(pn_id bigint, pn_hid bigint, pn_ext_id bigint, pu_mo_uid uuid, ps_code_mo text,
                                ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text,
                                pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer,
                                pb_allow_home_call boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    -- todo LPU ?
    -- perform core.f_bp_before(pn_lpu,null,null,'er_mo_upd',pn_id);
    begin
        update er.er_mo t
        set hid             = pn_hid,
            mo_uid          = pu_mo_uid,
            ext_id          = pn_ext_id,
            code_mo         = ps_code_mo,
            mo_name         = ps_mo_name,
            full_name       = ps_full_name,
            address         = ps_address,
            lat             = ps_lat,
            long            = ps_long,
            without_reg     = pb_without_reg,
            for_kids        = pb_for_kids,
            record_period   = pn_record_period,
            allow_home_call = pb_allow_home_call,
            add_info        = pu_add_info
        where t.id = pn_id;
        if not found then
            perform core.f_msg_not_found(pn_id, 'er_mo');
        else
            n_id := pn_id;
        end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'U');
    end;
    -- perform core.f_bp_after(pn_lpu,null,null,'er_mo_upd',pn_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_mo8upd(bigint, bigint, bigint, uuid, text, text, text, text, text, text, boolean, boolean, integer, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_mo8add(pn_hid bigint, pn_ext_id bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb);
create function kafka.f_ext_mo8add(pn_hid bigint, pn_ext_id bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text,
                                ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean,
                                pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean,
                                pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    -- todo LPU ?
    --perform core.f_bp_before(pn_lpu,null,null,'er_mo_add',null);
    begin
        insert into er.er_mo
        (id,
         hid,
         ext_id,
         mo_uid,
         code_mo,
         mo_name,
         full_name,
         address,
         lat,
         long,
         without_reg,
         for_kids,
         record_period,
         allow_home_call,
         add_info)
        values (core.f_gen_id(),
                pn_hid,
                pn_ext_id,
                pu_mo_uid,
                ps_code_mo,
                ps_mo_name,
                ps_full_name,
                ps_address,
                ps_lat,
                ps_long,
                pb_without_reg,
                pb_for_kids,
                pn_record_period,
                pb_allow_home_call,
                pu_add_info)
        returning id into n_id;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'A');
    end;
    -- perform core.f_bp_after(pn_lpu,null,null,'er_mo_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_mo8add( bigint, bigint, uuid, text, text, text, text, text, text, boolean, boolean, integer, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_mo8del(pn_id bigint);
create function kafka.f_ext_mo8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_mo_del',pn_id);
    begin
        delete
        from er.er_mo t
        where t.id = pn_id;
        if not found then
            perform core.f_msg_not_found(pn_id, 'er_mo');
        end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_mo_del',pn_id);

end;
$$;
alter function kafka.f_ext_mo8del(bigint) owner to dev;


drop function if exists kafka.f_kafka_load_lpu(p_topic text);
CREATE OR REPLACE FUNCTION kafka.f_kafka_load_lpu(p_topic text)
    RETURNS int AS
$$
DECLARE
    n_cnt      INT DEFAULT 0;
    s_mis_code VARCHAR;
    s_type     VARCHAR;
    n_system   INTEGER;
    n_entity   INTEGER;
    rec_res    RECORD;
    json_body  jsonb;
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

        s_type := 'er_mo';
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;

        select "system", "entity"
        into n_system, n_entity
        from kafka.f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        with cte as (
            select t.*,
                   kafka.f_ext_entity_values8find(n_system, n_entity, t.lpu_hid)             as ext_hid,
                   kafka.f_ext_entity_values8rebuild(n_system, n_entity, t.lpu_id, "action") as ext_id
            from jsonb_populate_recordset(null::kafka.ext_system_lpu_type,
                                          json_body -> 'response' -> 'Result' -> 'ResultSet') as t
            where t.lpu_name is not null
            order by t.lpu_hid nulls first
        ),
             ins as (
                 select kafka.f_ext_mo8add(
                                mo_hid.id,
                                t.ext_id,
                                uuid_generate_v1(),
                                t.lpu_code,
                                t.lpu_name,
                                t.full_name,
                                t.address,
                                t.lat,
                                t.long,
                                t.without_reg,
                                t.for_kids,
                                t.record_period,
                                t.allow_home_call,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          left join er.er_mo as mo_hid on t.ext_hid = mo_hid.ext_id
                 where "action" = 'add'
                   and (lpu_hid is null or ext_hid is not null)
             ),
             upd as (
                 select kafka.f_ext_mo8upd(
                                mo.id,
                                mo_hid.id,
                                t.ext_id,
                                mo.mo_uid,
                                t.lpu_code,
                                t.lpu_name,
                                t.full_name,
                                t.address,
                                t.lat,
                                t.long,
                                t.without_reg,
                                t.for_kids,
                                t.record_period,
                                t.allow_home_call,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          join er.er_mo as mo on t.ext_id = mo.ext_id
                          left join er.er_mo as mo_hid on t.ext_hid = mo_hid.ext_id
                 where t."action" = 'upd'
                   and (t.lpu_hid is null or t.ext_hid is not null)
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

        DELETE FROM kafka.kafka_queue WHERE CURRENT OF cur_res;

    END LOOP;

    CLOSE cur_res;

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;


--select kafka.f_kafka_load_lpu('get-lpu-info');

