
create or replace function public.ref_kafka_result(refcursor) RETURNS refcursor as '
    BEGIN
        OPEN $1 FOR select *
                    from public.kafka_result
                    where method = cast($1 as text) and pg_try_advisory_xact_lock (id)
                    for update;
        RETURN $1;
    END;
' LANGUAGE plpgsql;


DO $$
begin
    if not exists (select true from pg_type where typname = 'lpu_type') then
    --drop type if exists public.lpu_type;
        create type public.lpu_type as
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
END$$;


drop function if exists er.f_mis_mo8upd(pn_id bigint, pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb);
create function er.f_mis_mo8upd(pn_id bigint, pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id bigint default null;
begin
    -- todo LPU ?
    -- perform core.f_bp_before(pn_lpu,null,null,'er_mo_upd',pn_id);
    begin
        update er.er_mo t set
                              hid = pn_hid,
                              mo_uid = pu_mo_uid,
                              code_mo = ps_code_mo,
                              mo_name = ps_mo_name,
                              full_name = ps_full_name,
                              address = ps_address,
                              lat = ps_lat,
                              long = ps_long,
                              without_reg = pb_without_reg,
                              for_kids = pb_for_kids,
                              record_period = pn_record_period,
                              allow_home_call = pb_allow_home_call,
                              add_info = pu_add_info
        where t.id   = pn_id
        ;
        if not found then
            perform core.f_msg_not_found(pn_id, 'er_mo');
        else
            n_id := pn_id;
        end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    -- perform core.f_bp_after(pn_lpu,null,null,'er_mo_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_mo8upd(bigint, bigint, bigint, uuid, text, text, text, text, text, text, boolean, boolean, integer, boolean, jsonb) owner to dev;


drop function if exists er.f_mis_mo8add(pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb);
create function er.f_mis_mo8add(pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb) returns bigint
	security definer
	language plpgsql
as $$
declare
  n_id                  bigint;
begin
  -- todo LPU ?
  --perform core.f_bp_before(pn_lpu,null,null,'er_mo_add',null);
  begin
    insert into er.er_mo
    (
      id,
      hid,
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
      add_info
    )
    values
    (
      pn_lpu,
      pn_hid,
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
      pu_add_info
    ) returning id into n_id;
  exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
  end;
  -- perform core.f_bp_after(pn_lpu,null,null,'er_mo_add',n_id);
  return n_id;
end;
$$;
alter function er.f_mis_mo8add(bigint, bigint, uuid, text, text, text, text, text, text, boolean, boolean, integer, boolean, jsonb) owner to dev;


drop function if exists  er.f_mis_mo8find(pn_id bigint);
create or replace function er.f_mis_mo8find(pn_id bigint) returns uuid
    security definer
    language plpgsql
as
$$
declare
    u_uid  uuid;
begin
    select t.mo_uid
    into u_uid
    from er.er_mo t
    where t.id = pn_id
    limit 1;

    return u_uid;
end;
$$;
alter function er.f_mis_mo8find(bigint) owner to dev;


drop function if exists er.f_mis_mo8del(pn_id bigint);
create function er.f_mis_mo8del(pn_id bigint) returns void
	security definer
	language plpgsql
as $$
begin
  --perform core.f_bp_before(pn_lpu,null,null,'er_mo_del',pn_id);
  begin
    delete from er.er_mo t
     where t.id   = pn_id;
    if not found then
        perform core.f_msg_not_found(pn_id, 'er_mo');
    end if;
  exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
  end;
  --perform core.f_bp_after(pn_lpu,null,null,'er_mo_del',pn_id);

end;
$$;
alter function er.f_mis_mo8del(bigint) owner to dev;



CREATE OR REPLACE FUNCTION public.kafka_load_lpu(p_topic text)
    RETURNS void AS
$$
DECLARE
    n_cnt     INT DEFAULT 0;
    rec_res   RECORD;
    json_body jsonb;
    cur_res   CURSOR (p_topic TEXT)
        FOR select *
            from public.kafka_result
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

        with cte as (
            select t.*, er.f_mis_mo8find(t.lpu_id) as mo_uuid
            from jsonb_populate_recordset(null::public.lpy_type,
                                          json_body -> 'response' -> 'Result' -> 'ResultSet') as t
                 left join er.er_mo as mo on mo.id = t.lpu_hid
            where (t.lpu_hid is null or mo.id is not null)
                 and t.lpu_name is not null
            order by t.lpu_hid nulls first
        ), ins as (
            select
                er.f_mis_mo8add(
                               lpu_id,
                               lpu_hid,
                               uuid_generate_v1(),
                               lpu_code,
                               lpu_name,
                               full_name,
                               address,
                               lat,
                               long,
                               without_reg,
                               for_kids,
                               record_period,
                               allow_home_call,
                               "FullInfo"::jsonb
                           )
            from cte
             where mo_uuid is null and "action" = 'add'
        ), upd as (
            select er.f_mis_mo8upd(
                           lpu_id,
                           lpu_id,
                           lpu_hid,
                           mo_uuid,
                           lpu_code,
                           lpu_name,
                           full_name,
                           address,
                           lat,
                           long,
                           without_reg,
                           for_kids,
                           record_period,
                           allow_home_call,
                           "FullInfo"::jsonb
                       )
            from cte
            where mo_uuid is not null and action = 'upd'
        ), del as (
            select er.f_mis_mo8del(lpu_id)
            from cte
            where mo_uuid is not null and action = 'del'
        ), cnt as (
            select count(1) as n from ins
            union all
            select count(1) as n from upd
            union all
            select count(1) as n from del
        ) select sum(n) into n_cnt
        from cnt;

        DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;

    END LOOP;

    CLOSE cur_res;

END;
$$
    LANGUAGE plpgsql;

--select public.kafka_load_lpu('get_lpu_info');


