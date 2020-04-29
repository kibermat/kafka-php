
set search_path to er, public;

DO $$
    begin
        set search_path to er, public;

        ALTER TABLE er_profiles ADD COLUMN ext_id bigint default null;
        comment on column er_profiles.ext_id is 'Ссылка на внешний идентификатор';
        ALTER TABLE er_profiles ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY ( ext_id ) REFERENCES ext_entity_values( id ) ON DELETE CASCADE;

    exception when others then raise notice 'pass %', sqlerrm;
    END$$;

DO $$
begin
    if not exists (select true from pg_type where typname = 'ext_system_profile_type') then
    --drop type if exists public.ext_system_profile_type;
        create type public.ext_system_profile_type as
        (
            "id"              bigint,
            "name"            text,
            "match_profile"   text,
            "action"          text,
            "FullInfo"        jsonb
        );
    END IF;
END$$;


drop function if exists er.f_mis_profiles8add(pn_ext_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb)
create function er.f_mis_profiles8add(pn_ext_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb) returns bigint
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
      ext_id,
      profile_uid,
      "name",
      match_profile,
      add_info
    )
    values
    (
      core.f_gen_id(),
      pn_ext_id,
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
alter function er.f_mis_profiles8add( bigint, uuid, text, text, jsonb) owner to dev;


drop function if exists er.f_mis_profiles8upd(pn_id bigint, pn_ext_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb);
create function er.f_mis_profiles8upd(pn_id bigint, pn_ext_id bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb) returns bigint
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
                                    ext_id = pn_ext_id,
                                    profile_uid = pu_profile_uid,
                                    name = ps_name,
                                    match_profile = ps_match_profile,
                                    add_info = pu_add_info
        where t.id = pn_id;

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
alter function er.f_mis_profiles8upd(bigint, bigint, uuid, text, text, jsonb) owner to dev;


drop function if exists er.f_mis_profiles8del(pn_id bigint);
create function er.f_mis_profiles8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_profiles_del',pn_id);
    begin
        delete from er.er_profiles t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_profiles'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_profiles_del',pn_id);
end;
$$;
alter function er.f_mis_profiles8del(bigint) owner to dev;


drop function if exists public.kafka_load_profile(p_topic text);
CREATE OR REPLACE FUNCTION public.kafka_load_profile(p_topic text)
    RETURNS int AS
$$
DECLARE
    n_cnt     INT DEFAULT 0;
    s_mis_code    VARCHAR;
    s_type     VARCHAR;
    n_system   INTEGER;
    n_entity   INTEGER;
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
        s_type := 'er_profiles';
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;

        select "system", "entity"
          into n_system, n_entity
        from f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        with cte as (
            select t.*,
                   f_ext_entity_values8rebuild(n_system, n_entity, t.id, "action") as ext_id
            from jsonb_populate_recordset(null::public.ext_system_profile_type,
                                          json_body -> 'response' -> 'Result' -> 'ResultSet') as t
            where t.name is not null
        ), ins as (
            select er.f_mis_profiles8add(
                       t.ext_id,
                       uuid_generate_v1(),
                       t.name,
                       t.match_profile,
                       t."FullInfo"::jsonb
                   )
            from cte as t
                left join er.er_profiles as p on t.ext_id = p.ext_id
             where p.id is null and "action" = 'add'
        ), upd as (
            select er.f_mis_profiles8upd(
                       t.id,
                       t.ext_id,
                       p.profile_uid,
                       t.name,
                       t.match_profile,
                       t."FullInfo"::jsonb
                   )
            from cte as t
                left join er.er_profiles as p on t.ext_id = p.ext_id
            where p.id is not null and action = 'upd'
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

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;


--select public.kafka_load_profile('get-profile-info')