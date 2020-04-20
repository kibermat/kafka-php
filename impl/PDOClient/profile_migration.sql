

DO $$
begin
    if not exists (select true from pg_type where typname = 'profile_type') then
    --drop type if exists public.profile_type;
        create type public.profile_type as
        (
            "id"              bigint,
            "name"            text,
            "match_profile"   text,
            "action"          text,
            "FullInfo"        jsonb
        );
    END IF;
END$$;


drop function if exists  er.f_mis_profiles8find(pn_id bigint);
create or replace function er.f_mis_profiles8find(pn_id bigint) returns uuid
    security definer
    language plpgsql
as
$$
declare
    u_uid  uuid;
begin
    select t.profile_uid
    into u_uid
    from er.er_profiles t
    where t.id = pn_id
    limit 1;

    return u_uid;
end;
$$;
alter function er.f_mis_profiles8find(bigint) owner to dev;

drop function if exists er.f_mis_profiles8add(pn_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb)
create function er.f_mis_profiles8add(pn_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb) returns bigint
	security definer
	language plpgsql
as $$
declare
  n_id                  bigint;
begin
  -- todo LPU ?
  -- perform core.f_bp_before(pn_lpu,null,null,'er_profiles_add',null);
  begin
    insert into er.er_profiles
    (
      id,
      profile_uid,
      "name",
      match_profile,
      add_info
    )
    values
    (
      pn_id,
      pu_profile_uid,
      ps_name,
      ps_match_profile,
      pu_add_info
    ) returning id into n_id;
  exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
  end;
  -- perform core.f_bp_after(pn_lpu,null,null,'er_profiles_add',n_id);
  return n_id;
end;
$$;
alter function er.f_mis_profiles8add(bigint, uuid, text, text, jsonb) owner to dev;



drop function if exists function er.f_mis_profiles8upd(pn_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb);
create function er.f_mis_profiles8upd(pn_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id bigint default null;
begin
    -- TODO LPU ?
--     perform core.f_bp_before(pn_lpu,null,null,'er_profiles_upd',pn_id);
    begin
        update er.er_profiles t set
                                    profile_uid = pu_profile_uid,
                                    name = ps_name,
                                    match_profile = ps_match_profile,
                                    add_info = pu_add_info
        where t.id   = pn_id;
        if not found then
            perform core.f_msg_not_found(pn_id, 'er_profiles');
        else
            n_id := pn_id;
        end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_profiles_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_profiles8upd(bigint, uuid, text, text, jsonb) owner to dev;


CREATE OR REPLACE FUNCTION public.kafka_load_profile(p_topic text)
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
            select t.*, er.f_mis_profiles8find(t.id) as profile_uuid
            from jsonb_populate_recordset(null::public.profile_type,
                                          json_body -> 'response' -> 'Result' -> 'ResultSet') as t
        ), ins as (
            select er.f_mis_profiles8add(
                       id,
                       uuid_generate_v1(),
                       name,
                       match_profile,
                       "FullInfo"::jsonb
                   )
            from cte
             where profile_uuid is null and "action" = 'add'
        ), upd as (
            select er.f_mis_profiles8upd(
                       id,
                       profile_uuid,
                       name,
                       match_profile,
                       "FullInfo"::jsonb
                   )
            from cte
            where profile_uuid is not null /* action != 'add' */
        ), cnt as (
            select count(1) as n from ins
            union all
            select count(1) as n from upd
        )   select sum(n) into n_cnt
        from cnt;

        if n_cnt > 0 then
            DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;
        end if;

    END LOOP;

    CLOSE cur_res;

END;
$$
    LANGUAGE plpgsql;


