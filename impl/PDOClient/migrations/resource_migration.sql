set search_path to er, public;


DO
$$
    begin
        set search_path to er, public;

        ALTER TABLE er_resources
            ADD COLUMN ext_id bigint default null;
        comment on column er_resources.ext_id is 'Ссылка на внешний идентификатор';
        ALTER TABLE er_resources
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;

commit;
set search_path to public;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_resource_row_type') then
            --drop type if exists public.ext_system_resource_row_type;
            create type public.ext_system_resource_row_type as
            (
                "lpu_id"   bigint,
                "div_id"   bigint,
                "resource" jsonb
            );
        END IF;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_resources_type') then
            --drop type if exists public.ext_system_resources_type;
            create type public.ext_system_resources_type as
            (
                "id"               bigint,
                "profile_id"       bigint,
                "name"             text,
                "address"          text,
                "notification"     text,
                "hint"             text,
                "is_free"          boolean,
                "is_paid"          boolean,
                "price"            numeric,
                "department"       text,
                "room"             text,
                "service"          text,
                "site_id"          bigint,
                "site_name"        text,
                "doctor_surname"   text,
                "doctor_firstname" text,
                "doctor_lastname"  text,
                "record_period"    integer,
                "time_to_elapse"   integer,
                "allow_wait_list"  boolean,
                "wait_list_msg"    text,
                "action"           text,
                "FullInfo"         jsonb
            );
        END IF;
    END
$$;


drop function if exists er.f_mis_resources8add(pn_ext_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb);
create function er.f_mis_resources8add(pn_ext_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint,
                                       pn_profile_id bigint, ps_name text, ps_address text, ps_notification text,
                                       ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric,
                                       ps_department text, ps_room text, ps_service text, pn_site_id bigint,
                                       ps_emp_sname text, ps_emp_fname text, ps_emp_lname text,
                                       pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean,
                                       ps_wait_list_msg text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_add',null);
    begin
        insert into er.er_resources
        (id,
         ext_id,
         resource_uid,
         mo_id,
         div_id,
         profile_id,
         "name",
         address,
         notification,
         hint,
         is_free,
         is_paid,
         price,
         department,
         room,
         service,
         site_id,
         emp_sname,
         emp_fname,
         emp_lname,
         record_period,
         time_to_elapse,
         allow_wait_list,
         wait_list_msg,
         add_info)
        values (core.f_gen_id(),
                pn_ext_id,
                pu_resource_uid,
                pn_mo_id,
                pn_div_id,
                pn_profile_id,
                ps_name,
                ps_address,
                ps_notification,
                ps_hint,
                pb_is_free,
                pb_is_paid,
                pn_price,
                ps_department,
                ps_room,
                ps_service,
                pn_site_id,
                ps_emp_sname,
                ps_emp_fname,
                ps_emp_lname,
                pn_record_period,
                pn_time_to_elapse,
                pb_allow_wait_list,
                ps_wait_list_msg,
                pu_add_info)
        returning id into n_id;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_add',n_id);
    return n_id;
end;
$$;
alter function er.f_mis_resources8add(bigint, uuid, bigint, bigint, bigint, text, text, text, text, boolean, boolean, numeric, text, text, text, bigint, text, text, text, integer, integer, boolean, text, jsonb) owner to dev;


drop function if exists er.f_mis_resources8upd(pn_id bigint, pn_ext_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb);
create function er.f_mis_resources8upd(pn_id bigint, pn_ext_id bigint, pu_resource_uid uuid, pn_mo_id bigint,
                                       pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text,
                                       ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean,
                                       pn_price numeric, ps_department text, ps_room text, ps_service text,
                                       pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text,
                                       pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean,
                                       ps_wait_list_msg text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_upd',pn_id);
    begin
        update er.er_resources t
        set ext_id          = pn_ext_id,
            resource_uid    = pu_resource_uid,
            mo_id           = pn_mo_id,
            div_id          = pn_div_id,
            profile_id      = pn_profile_id,
            name            = ps_name,
            address         = ps_address,
            notification    = ps_notification,
            hint            = ps_hint,
            is_free         = pb_is_free,
            is_paid         = pb_is_paid,
            price           = pn_price,
            department      = ps_department,
            room            = ps_room,
            service         = ps_service,
            site_id         = pn_site_id,
            emp_sname       = ps_emp_sname,
            emp_fname       = ps_emp_fname,
            emp_lname       = ps_emp_lname,
            record_period   = pn_record_period,
            time_to_elapse  = pn_time_to_elapse,
            allow_wait_list = pb_allow_wait_list,
            wait_list_msg   = ps_wait_list_msg,
            add_info        = pu_add_info
        where t.id = pn_id;

        if not found then
            perform core.f_msg_not_found(pn_id, 'er_resources');
        else
            n_id := pn_id;
        end if;

    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'U');
    end;

    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_resources8upd(bigint, bigint, uuid, bigint, bigint, bigint, text, text, text, text, boolean, boolean, numeric, text, text, text, bigint, text, text, text, integer, integer, boolean, text, jsonb) owner to dev;


drop function if exists er.f_mis_resources8del(pn_id bigint);
create function er.f_mis_resources8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_del',pn_id);
    begin
        delete
        from er.er_resources t
        where t.id = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_resources'); end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_del',pn_id);
end;
$$;
alter function er.f_mis_resources8del(bigint) owner to dev;


create or replace function public.kafka_load_resources(p_topic text)
    RETURNS integer as
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
begin
    open cur_res(p_topic);

    loop
        fetch cur_res into rec_res;

        exit when not FOUND;

        json_body := rec_res.data;

        s_type := 'er_resources';
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;

        select "system", "entity"
        into n_system, n_entity
        from f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        -- TODO Find SiteId
--         select id
-- --        into n_site_id
-- --      from er.er_sites
-- --       where id = n_ext_site_id;

        with resources as (
            select t.*,
                   f_ext_entity_values8find(n_system, n_entity, t.lpu_id) as mo_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t.div_id) as div_ext_id
            from jsonb_populate_recordset(null::public.ext_system_resource_row_type,
                                          json_body -> 'response' -> 'ResultSet' -> 'Rowset') as t
        ),
             ext as (
                 select f_ext_entity_values8find(n_system, n_entity, t.profile_id)      as profile_ext_id,
                        f_ext_entity_values8rebuild(n_system, n_entity, t.id, "action") as ext_id,
                        case when t."action" is null then 'add' else t."action" end     as "action_res",
                        mo.id                                                           as lpu_id,
                        div.id                                                          as div_id,
                        t.*
                 from resources
                          join jsonb_populate_recordset(null::public.ext_system_resources_type, resource) as t on true
                          left join er.er_mo mo ON (resources.mo_ext_id = mo.ext_id)
                          left join er.er_mo div ON (resources.div_ext_id = div.ext_id)
                 where (resources.lpu_id is null or mo.id is not null)
                   and (resources.div_id is null or div.id is not null)
             ),
             cte as (
                 select ext.*
                 from ext
                          left join er.er_profiles pr ON (ext.profile_ext_id = pr.ext_id)
                          left join er.er_sites st ON (ext.site_id = st.id)
                 where (ext.profile_id is null or pr.id is not null)
                   and (ext.site_id is null or st.id is not null)
             ),
             ins as (
                 select er.f_mis_resources8add(
                                t.ext_id,
                                uuid_generate_v1(),
                                t."lpu_id"::bigint,
                                t."div_id"::bigint,
                                t."profile_id"::bigint,
                                t."name"::text,
                                t."address"::text,
                                t."notification"::text,
                                t."hint"::text,
                                t."is_free"::boolean,
                                t."is_paid"::boolean,
                                case when t."price" is null then 0 else t."price" end,
                                t."department"::text,
                                t."room"::text,
                                t."service"::text,
                                t."site_id"::bigint,
                                t."doctor_surname"::text,
                                t."doctor_firstname"::text,
                                t."doctor_lastname"::text,
                                t."record_period"::integer,
                                case when t."time_to_elapse" is null then 0 else t."time_to_elapse" end,
                                case when t."allow_wait_list" is null then false else t."allow_wait_list" end,
                                t."wait_list_msg"::text,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          left join er.er_resources as res on t.ext_id = res.ext_id
                 where res.id is null
                   and "action_res" = 'add'
             ),
             upd as (
                 select er.f_mis_resources8upd(
                                t."id"::bigint,
                                res.resource_uid,
                                t."lpu_id"::bigint,
                                t."div_id"::bigint,
                                t."profile_id"::bigint,
                                t."name"::text,
                                t."address"::text,
                                t."notification"::text,
                                t."hint"::text,
                                t."is_free"::boolean,
                                t."is_paid"::boolean,
                                case when t."price" is null then 0 else t."price" end,
                                t."department"::text,
                                t."room"::text,
                                t."service"::text,
                                t."site_id"::bigint,
                                t."doctor_surname"::text,
                                t."doctor_firstname"::text,
                                t."doctor_lastname"::text,
                                t."record_period"::integer,
                                case when t."time_to_elapse" is null then 0 else t."time_to_elapse" end,
                                case when t."allow_wait_list" is null then false else t."allow_wait_list" end,
                                t."wait_list_msg"::text,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                          left join er.er_resources as res on t.ext_id = res.ext_id
                 where res.resource_uid is not null
                   and action_res = 'upd'
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
            delete from public.kafka_result where current of cur_res;
        end if;

    end loop;

    close cur_res;

    return n_cnt;

end;
$$
    LANGUAGE plpgsql;

