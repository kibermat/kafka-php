
set search_path to er, public;


DO
$$
    begin
        set search_path to er, public;

        ALTER TABLE er_sites
            ADD COLUMN ext_id bigint default null;
        comment on column er_sites.ext_id is 'Ссылка на внешний идентификатор';
        ALTER TABLE er_sites
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_sites_type') then
             drop type if exists public.ext_system_sites_type;
            create type public.ext_system_sites_type as
            (
                "SITE_ID"     bigint,
                "SITE_CODE"   text,
                "SITE_NAME"   text,
                "LPU_ID"      bigint,
                "DIV_ID"      bigint,
                "PURPOSE"     text,
                "TYPE"        text,
                "DATE_BEGIN"  date,
                "DATE_END"    date,
                "action"      text,
                "FullInfo"    jsonb
            );
        END IF;
    END
$$;


drop function if exists f_mis_sites8add(pn_ext_id bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb);
create function f_mis_sites8add(pn_ext_id bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_sites_add',null);
    begin
        insert into er.er_sites
        (
            id,
            ext_id,
            site_id,
            mo_id,
            div_id,
            site_code,
            site_name,
            date_begin,
            date_end,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext_id,
            pu_site_id,
            pn_mo_id,
            pn_div_id,
            ps_site_code,
            ps_site_name,
            pd_date_begin,
            pd_date_end,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_sites_add',n_id);
    return n_id;
end;
$$;
alter function f_mis_sites8add(bigint, uuid, bigint, bigint, text, text, date, date, jsonb) owner to dev;


drop function if exists f_mis_sites8upd(pn_id bigint, pn_ext_id bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb);
create function f_mis_sites8upd(pn_id bigint, pn_ext_id bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_sites_upd',pn_id);
    begin
        update er.er_sites t set
                                 ext_id = pn_ext_id,
                                 site_id = pu_site_id,
                                 mo_id = pn_mo_id,
                                 div_id = pn_div_id,
                                 site_code = ps_site_code,
                                 site_name = ps_site_name,
                                 date_begin = pd_date_begin,
                                 date_end = pd_date_end,
                                 add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_sites_upd',pn_id);
end;
$$;
alter function f_mis_sites8upd(bigint, bigint, uuid, bigint, bigint, text, text, date, date, jsonb) owner to dev;


drop function if exists  f_mis_sites8del(pn_id bigint);
create function f_mis_sites8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
    --     perform core.f_bp_before(pn_lpu,null,null,'er_sites_del',pn_id);
    begin
        delete from er.er_sites t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_sites_del',pn_id);
end;
$$;
alter function f_mis_sites8del(bigint) owner to dev;


drop function if exists public.kafka_load_sites(p_topic text);
CREATE OR REPLACE FUNCTION public.kafka_load_sites(p_topic text)
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

        with sites as (
            select t.*,
                   f_ext_entity_values8find(n_system, n_entity, t."LPU_ID") as mo_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t."DIV_ID") as div_ext_id,
                   f_ext_entity_values8rebuild(n_system, n_entity, t."SITE_ID", coalesce(t.action, 'add')) as ext_id
            from jsonb_populate_recordset(null::public.ext_system_sites_type,
                                          json_body -> 'response' -> 'sites') as t
            where t."SITE_CODE" is not null
         ), ext as (
            select t.*,
                   mo.id as mo,
                   div.id as div
            from sites as t
                 left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                 left join er.er_mo div ON (t.div_ext_id = div.ext_id)
         ),
         cte as (
              select t.*,
                     s.site_id as site_uuid,
                     s.id as old_id
               from ext as t
                    left join er.er_sites as s on s.ext_id = t.ext_id
         ),
         ins_sites as (
             select er.f_mis_sites8add(
                   t.ext_id,
                   uuid_generate_v1(),
                   mo,
                   div,
                   t."SITE_CODE",
                   t."SITE_NAME",
                   t."DATE_BEGIN"::date,
                   t."DATE_END"::date,
                   t."FullInfo"::jsonb
             )
             from cte as t
                  left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                  left join er.er_mo div ON (t.div_ext_id = div.ext_id)
             where t.site_uuid is null
               and "action" = 'add'
         ),
         upd_sites as (
             select er.f_mis_sites8upd(
                            t.old_id,
                            t.ext_id,
                            t.site_uuid,
                            t.mo,
                            t.div,
                            t."SITE_CODE",
                            t."SITE_NAME",
                            t."DATE_BEGIN"::date,
                            t."DATE_END"::date,
                            t."FullInfo"::jsonb
                        )
             from cte as t
             where t.site_uuid is not null
         ),
         cnt as (
             select count(1) as n
             from ins_sites
             union all
             select count(1) as n
             from upd_sites
         )
        select sum(n)
        into n_cnt
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
