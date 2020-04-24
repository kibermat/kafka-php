
DO $$
    begin
        if not exists (select true from pg_type where typname = 'resource_row_type') then
            --drop type if exists public.resource_row_type;
            create type public.resource_row_type as
            (
                "lpu_id"          bigint,
                "div_id"          bigint,
                "resource"        jsonb
            );
        END IF;
 END$$;

DO $$
    begin
        if not exists (select true from pg_type where typname = 'resources_type') then
            --drop type if exists public.resources_type;
            create type public.resources_type as
            (
                "id"              bigint,
                "profile_id"      bigint,
                "name"            text,
                "address"         text,
                "notification"    text,
                "hint"            text,
                "is_free"         boolean,
                "is_paid"         boolean,
                "price"           numeric,
                "department"      text,
                "room"            text,
                "service"         text,
                "site_id"         bigint,
                "site_name"       text,
                "doctor_surname"   text,
                "doctor_firstname" text,
                "doctor_lastname"  text,
                "record_period"   integer,
                "time_to_elapse"  integer,
                "allow_wait_list" boolean,
                "wait_list_msg"   text,
                "action"          text,
                "FullInfo"        jsonb
            );
        END IF;
    END$$;


drop function if exists er.f_mis_resources8find(pn_id bigint);
create or replace function er.f_mis_resources8find(pn_id bigint) returns uuid
    security definer
    language plpgsql
as
$$
declare
    u_uid  uuid;
begin
    select t.resource_uid
    into u_uid
    from er.er_resources t
    where t.id = pn_id
    limit 1;

    return u_uid;
end;
$$;
alter function er.f_mis_resources8find(bigint) owner to dev;


drop function if exists er.f_mis_resources8add(pn_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb);
create function er.f_mis_resources8add(pn_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_add',null);
    begin
        insert into er.er_resources
        (
            id,
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
            add_info
        )
        values
        (
            pn_id,
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
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_add',n_id);
    return n_id;
end;
$$;
alter function er.f_mis_resources8add(bigint, uuid, bigint, bigint, bigint, text, text, text, text, boolean, boolean, numeric, text, text, text, bigint, text, text, text, integer, integer, boolean, text, jsonb) owner to dev;


drop function if exists  er.f_mis_resources8upd(pn_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb);
create function er.f_mis_resources8upd(pn_id bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_upd',pn_id);
    begin
        update er.er_resources t set
                                     resource_uid = pu_resource_uid,
                                     mo_id = pn_mo_id,
                                     div_id = pn_div_id,
                                     profile_id = pn_profile_id,
                                     name = ps_name,
                                     address = ps_address,
                                     notification = ps_notification,
                                     hint = ps_hint,
                                     is_free = pb_is_free,
                                     is_paid = pb_is_paid,
                                     price = pn_price,
                                     department = ps_department,
                                     room = ps_room,
                                     service = ps_service,
                                     site_id = pn_site_id,
                                     emp_sname = ps_emp_sname,
                                     emp_fname = ps_emp_fname,
                                     emp_lname = ps_emp_lname,
                                     record_period = pn_record_period,
                                     time_to_elapse = pn_time_to_elapse,
                                     allow_wait_list = pb_allow_wait_list,
                                     wait_list_msg = ps_wait_list_msg,
                                     add_info = pu_add_info
        where t.id   = pn_id;

        if not found then
            perform core.f_msg_not_found(pn_id, 'er_resources');
        else
            n_id := pn_id;
        end if;

    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;

    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_resources8upd(bigint, uuid, bigint, bigint, bigint, text, text, text, text, boolean, boolean, numeric, text, text, text, bigint, text, text, text, integer, integer, boolean, text, jsonb) owner to dev;


drop function if exists er.f_mis_resources8del(pn_id bigint);
create function er.f_mis_resources8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_resources_del',pn_id);
    begin
        delete from er.er_resources t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_resources_del',pn_id);
end;
$$;
alter function er.f_mis_resources8del(bigint) owner to dev;


create or replace function public.kafka_load_resources(p_topic text)
    RETURNS void as
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
begin
    open cur_res(p_topic);

    loop
        fetch cur_res into rec_res;

        exit when not FOUND;

        json_body := rec_res.data;

        with resources as (
                    select t.*
                    from jsonb_populate_recordset(null::public.resource_row_type,
                            json_body -> 'response' -> 'ResultSet' -> 'Rowset' ) as t
       ), cte as (
        select er.f_mis_resources8find(t.id) as resource_uuid,
               resources.lpu_id as lpu_id,
               resources.div_id as div_id,
               case when t."action" is null then 'add' else  t."action" end as "action_res"
               , t.*
        from resources join jsonb_populate_recordset(null::public.resources_type,  resource) as t on true
            left join er.er_mo mo ON ( resources.lpu_id = mo.id )
            left join er.er_mo div ON ( resources.div_id = div.id )
            left join er.er_profiles pr ON ( t.profile_id = pr.id )
            left join er.er_sites st ON (t.site_id = st.id )
        where
            (resources.lpu_id is null or mo.id is not null ) and
            (resources.div_id is null or div.id is not null) and
            (t.profile_id is null or pr.id is not null) and
            (t.site_id is null or st.id is not null)
        ), ins as (
            select er.f_mis_resources8add(
                           "id"::bigint,
                           uuid_generate_v1(),
                           "lpu_id"::bigint,
                           "div_id"::bigint,
                           "profile_id"::bigint,
                           "name"::text,
                           "address"::text,
                           "notification"::text,
                           "hint"::text,
                           "is_free"::boolean,
                           "is_paid"::boolean,
                           case when "price" is null then 0 else "price" end,
                           "department"::text,
                           "room"::text,
                           "service"::text,
                           "site_id"::bigint,
                           "doctor_surname"::text,
                           "doctor_firstname"::text,
                           "doctor_lastname"::text,
                           "record_period"::integer,
                           case when "time_to_elapse" is null then 0 else "time_to_elapse" end,
                           case when "allow_wait_list" is null then false else "allow_wait_list" end,
                           "wait_list_msg"::text,
                           "FullInfo"::jsonb
                       )

                from cte
                where resource_uuid is null and "action_res" = 'add'
            ), upd as (
                select er.f_mis_resources8upd(
                               "id"::bigint,
                               resource_uuid,
                               "lpu_id"::bigint,
                               "div_id"::bigint,
                               "profile_id"::bigint,
                               "name"::text,
                               "address"::text,
                               "notification"::text,
                               "hint"::text,
                               "is_free"::boolean,
                               "is_paid"::boolean,
                               case when "price" is null then 0 else "price" end,
                               "department"::text,
                               "room"::text,
                               "service"::text,
                               "site_id"::bigint,
                               "doctor_surname"::text,
                               "doctor_firstname"::text,
                               "doctor_lastname"::text,
                               "record_period"::integer,
                               case when "time_to_elapse" is null then 0 else "time_to_elapse" end,
                               case when "allow_wait_list" is null then false else "allow_wait_list" end,
                               "wait_list_msg"::text,
                               "FullInfo"::jsonb
                           )
                from cte
                where resource_uuid is not null and action_res = 'upd'
            ), del as (
                select er.f_mis_resources8del(id)
                from cte
                where resource_uuid is not null and action_res = 'del'
            ), cnt as (
                select count(1) as n from ins
                union all
                select count(1) as n from upd
                union all
                select count(1) as n from del
            )  select sum(n) into n_cnt
            from cnt;

        if n_cnt > 0 then
            delete from public.kafka_result where current of cur_res;
        end if;

    end loop;

    close cur_res;

end;
$$
    LANGUAGE plpgsql;
