set search_path to er, public;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_person_type') then
            --drop type if exists public.ext_system_person_type;
            create type public.ext_system_person_type as
            (
                "gender"    integer,
                "snils"     text,
                "lname"     text,
                "fname"     text,
                "mname"     text,
                "birthdate" date
            );
        END IF;
    END
$$;


create index if not exists i_er_persons_er_fio_date
    on er.er_persons (birth_date, lower(lname), lower(fname), lower(mname));


create index if not exists i_er_persons_er_snils
    on er.er_persons (snils);


drop function if exists f_mis_persons8add(pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text);
create function f_mis_persons8add(pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text,
                                  pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    -- perform core.f_bp_before(pn_lpu,null,null,'er_persons_add',null);
    begin
        insert into er.er_persons
        (id,
         er_users,
         pers_uid,
         fname,
         mname,
         lname,
         birth_date,
         sex,
         id_doc,
         snils)
        values (core.f_gen_id(),
                pn_er_users,
                pu_pers_uid,
                ps_fname,
                ps_mname,
                ps_lname,
                pd_birth_date,
                pn_sex,
                ps_id_doc,
                ps_snils)
        returning id into n_id;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_add',n_id);
    return n_id;
end;
$$;
alter function f_mis_persons8add(bigint, uuid, text, text, text, date, integer, text, text) owner to dev;


drop function if exists f_mis_persons8upd(pn_id bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text);
create function f_mis_persons8upd(pn_id bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text,
                                  ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text,
                                  ps_snils text) returns void
    security definer
    language plpgsql
as
$$
begin
    --     perform core.f_bp_before(pn_lpu,null,null,'er_persons_upd',pn_id);
    begin
        update er.er_persons t
        set er_users   = pn_er_users,
            pers_uid   = pu_pers_uid,
            fname      = ps_fname,
            mname      = ps_mname,
            lname      = ps_lname,
            birth_date = pd_birth_date,
            sex        = pn_sex,
            id_doc     = ps_id_doc,
            snils      = ps_snils
        where t.id = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons'); end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_persons_upd',pn_id);
end;
$$;
alter function f_mis_persons8upd(bigint, bigint, uuid, text, text, text, date, integer, text, text) owner to dev;


drop function if exists f_mis_persons8find(ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, ps_snils text, out id bigint);
create function f_mis_persons8find(ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, ps_snils text,
                                   out id bigint)
as
'
    select t.id
    from er.er_persons as t
    where (nullif(trim(ps_snils), '''') is not null or
           (nullif(trim(ps_fname), '''') is not null and nullif(trim(ps_lname), '''') is not null and
            pd_birth_date is not null))
      and (nullif(trim(ps_snils), '''') is null or t.snils = ps_snils)
      and (nullif(trim(ps_fname), '''') is null or lower(t.fname) = lower(trim(ps_fname)))
      and (nullif(trim(ps_mname), '''') is null or lower(t.mname) = lower(trim(ps_mname)))
      and (nullif(trim(ps_lname), '''') is null or lower(t.lname) = lower(trim(ps_lname)))
      and (pd_birth_date is null or t.birth_date = pd_birth_date::date)
    limit 1
'
    LANGUAGE SQL;
alter function f_mis_persons8find(text, text, text, date, text, out bigint) owner to dev;


drop function if exists f_mis_persons8del(pn_id bigint);
create function f_mis_persons8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin
    --     perform core.f_bp_before(null,null,'er_persons_del',pn_id);
    begin
        delete
        from er.er_persons t
        where t.id = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons'); end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'D');
    end;
--     perform core.f_bp_after(null,null,'er_persons_del',pn_id);
end;
$$;
alter function f_mis_persons8del(bigint) owner to dev;


drop function if exists public.kafka_load_person(p_topic text);
CREATE OR REPLACE FUNCTION public.kafka_load_person(p_topic text)
    RETURNS int AS
$$
DECLARE
    n_cnt       INT DEFAULT 0;
    n_person_id bigint default null;
    s_mis_code  VARCHAR;
    u_agent_id  uuid;
    n_user_id   INTEGER;
    s_type      VARCHAR;
    n_system    INTEGER;
    n_entity    INTEGER;
    rec_res     RECORD;
    json_body   jsonb;
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
        s_type := 'er_persons';
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;
        u_agent_id := json_body -> 'response' -> 'agent_id' ->> 0;
        n_user_id := f_users8find(u_agent_id);

        select "system", "entity"
        into n_system, n_entity
        from f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        with patient as (
            select t.*,
                   f_mis_persons8find(t.fname, t.mname, t.lname, t.birthdate, t.snils) as id
            from jsonb_populate_recordset(null::public.ext_system_person_type,
                                          json_body -> 'response' -> 'patient') as t
        ),
             ins_person(id) as (
                 select er.f_mis_persons8add(
                                null,
                                uuid_generate_v1(),
                                t.fname,
                                t.mname,
                                t.lname,
                                t.birthdate,
                                t.gender::integer,
                                null::text,
                                t.snils
                            )
                 from patient as t
                 where t.id is null
             ),
             ins_user_person("user", person) as (
                 select f_user_person8add(n_user_id, p.id, n_system)
                 from ins_person as p
                 where n_user_id is not null
             ),
             upd_person as (
                 select er.f_mis_persons8upd(
                                t.id,
                                p.er_users,
                                p.pers_uid,
                                t.fname,
                                t.mname,
                                t.lname,
                                t.birthdate,
                                t.gender::integer,
                                p.id_doc,
                                t.snils
                            ),
                        f_user_person8add(n_user_id, p.id, n_system)
                 from patient as t
                          join er.er_persons as p using (id)
                 where t.id is not null
             ),
             new_patient as (
                 select id::bigint as id
                 from patient
                 where id is not null
                 union
                 select p.id::bigint as id
                 from ins_person as p,
                      upd_person
                 where p.id is not null
             )
        select id
        into n_person_id
        from new_patient;

        if n_person_id is null then
            raise exception 'Не удалось создать пациента по uuid  %', u_agent_id;
        end if;

        with polis as (
            select t.*,
                   f_mis_person_polis8find(t.polis_ser, t.polis_num, t.kind) as id
            from jsonb_populate_recordset(null::public.ext_system_polis_type,
                                          json_body -> 'response' -> 'policies') as t
        ),
             ins_polis(id) as (
                 select er.f_mis_person_polis8add(
                                t.polis_id,
                                n_person_id,
                                t.type_id,
                                t.kind,
                                t.polis_ser,
                                t.polis_num,
                                t.p_date_beg::date,
                                t.p_date_end::date,
                                null::jsonb
                            )
                 from polis as t
                 where t.id is null
             ),
             upd_polis as (
                 select er.f_mis_person_polis8upd(
                                t.id,
                                t.polis_id,
                                n_person_id,
                                t.type_id,
                                t.kind,
                                t.polis_ser,
                                t.polis_num,
                                t.p_date_beg::date,
                                t.p_date_end::date,
                                null::jsonb
                            )
                 from polis as t
                 where t.id is null
             ),
             cnt as (
                 select count(1) as n
                 from ins_polis
                 union all
                 select count(1) as n
                 from upd_polis
             )
        select sum(n)
        into n_cnt
        from cnt;

        with sites as (
            select t.*,
                   f_ext_entity_values8find(n_system, n_entity, t."LPU_ID")                                as mo_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t."DIV_ID")                                as div_ext_id,
                   f_ext_entity_values8rebuild(n_system, n_entity, t."SITE_ID", coalesce(t.action, 'add')) as ext_id
            from jsonb_populate_recordset(null::public.ext_system_sites_type,
                                          json_body -> 'response' -> 'sites') as t
            where t."SITE_CODE" is not null
        ),
             ext as (
                 select t.*,
                        mo.id  as mo,
                        div.id as div
                 from sites as t
                          left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                          left join er.er_mo div ON (t.div_ext_id = div.ext_id)
             ),
             cte as (
                 select t.*,
                        s.site_id as site_uuid,
                        s.id      as id
                 from ext as t
                          left join er.er_sites as s on s.ext_id = t.ext_id
             ),
             ins_sites(id, ext_id) as (
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
                            ), t.ext_id
                 from cte as t
                          left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                          left join er.er_mo div ON (t.div_ext_id = div.ext_id)
                 where t.id is null
             ),
             upd_sites(none, id, ext_id) as (
                 select er.f_mis_sites8upd(
                                t.id,
                                t.ext_id,
                                t.site_uuid,
                                t.mo,
                                t.div,
                                t."SITE_CODE",
                                t."SITE_NAME",
                                t."DATE_BEGIN"::date,
                                t."DATE_END"::date,
                                t."FullInfo"::jsonb
                            ) as none,
                        t.id, t.ext_id
                 from cte as t
                 where t.id is not null
             ),
             all_sites(id, ext_id) as (
                 select id, ext_id
                 from ins_sites
                 union
                 select id, ext_id
                 from upd_sites
             ),
             ins_person_sites as (
                 select er.f_mis_person_sites8add(
                                ss.id,
                                n_person_id,
                                true,
                                p."PURPOSE",
                                p."TYPE",
                                null::jsonb)
                 from all_sites as ss
                          join cte as p on ss.ext_id = p.ext_id
                          left join er.er_person_sites as ps on ps.sites_id = ss.id
                 where ps.id is null
             ),
             upd_person_sites as (
                 select er.f_mis_person_sites8upd(
                                ps.id,
                                ss.id,
                                n_person_id,
                                true,
                                p."PURPOSE",
                                p."TYPE",
                                p."TYPE",
                                null::jsonb)
                 from er.er_person_sites as ps
                          join all_sites as ss on ps.sites_id = ss.id
                          join cte as p on ss.ext_id = p.ext_id
             ),
             cnt as (
                 select count(1) as n
                 from ins_person_sites
                 union all
                 select count(1) as n
                 from upd_person_sites
             )
        select sum(n)
        into n_cnt
        from cnt;

        with visit as (
            select t.*,
                   f_ext_entity_values8find(n_system, n_entity, t.mo_id) as mo_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t.div_id) as div_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t.direction_uid) as direction_ext_id,
                   f_ext_entity_values8find(n_system, n_entity, t.resource_id) as resource_ext_id,
                   f_ext_entity_values8rebuild(n_system, n_entity, t.vis_uid, coalesce("action", 'add')) as ext_id
            from jsonb_populate_recordset(null::public.ext_system_visit_type,
                                          json_body -> 'response' -> 'visits') as t
            where t.name is not null
        ),
             cte as (
                select
                    ext.*,
                    v.id as old_id,
                    status.id as status_id,
                    mo.id as mo_id,
                    div.id as div_id,
                    dir.id as dir_id,
                    res.id as res_id
                from visit as ext
                         join er.er_mo as mo on mo.ext_id = ext.mo_ext_id
                         join er.er_mo as div on div.ext_id = ext.div_ext_id
                         left join er.er_person_visit as v on v.ext_id = ext.ext_id
                         left join er.er_visit_status as status on status.scode = ext.status
                         left join er.er_directions as dir on dir.ext_id = ext.direction_ext_id
                         left join er.er_resources as res on res.ext_id = ext.resource_ext_id
             ),
             ins as (
                 select er.f_mis_person_visit8add(
                                t.ext_id,
                                uuid_generate_v1(),
                                t.mo_id,
                                t.div_id,
                                n_person_id,
                                t.res_id,
                                t.dir_id,
                                t."service",
                                t.emp_fio,
                                t.vis_date,
                                null::date,
                                t.cost,
                                t.recommend,
                                t.status_id,
                                t.status_desc,
                                t.source,
                                t.source_desc,
                                null::bool,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                 where t.old_id is null
                   and "action" = 'add'
             ),
             upd as (
                 select er.f_mis_person_visit8upd(
                                t.old_id,
                                t.ext_id,
                                uuid_generate_v1(),
                                t.mo_id,
                                t.div_id,
                                n_person_id,
                                t.res_id,
                                t.dir_id,
                                t."service",
                                t.emp_fio,
                                t.vis_date,
                                null::date,
                                t.cost,
                                t.recommend,
                                t.status_id,
                                t.status_desc,
                                t.source,
                                t.source_desc,
                                null::bool,
                                t."FullInfo"::jsonb
                            )
                 from cte as t
                 where t.old_id is not null
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

        with recipes as (
            select t.*,
                   f_ext_entity_values8find(n_system, n_entity, t.mo_id)             as mo_ext_id,
                   f_ext_entity_values8rebuild(n_system, n_entity, t."recipe_uid", coalesce(t.action, 'add')) as ext_id
            from jsonb_populate_recordset(null::public.ext_system_recipe_type,
                                          json_body -> 'response' -> 'recipes') as t
            where t."code" is not null
        ),
             cte as (
                select t.*,
                       s.recipe_id as recipe_uuid,
                       s.id as old_id
                from recipes as t
                         left join er.er_person_recipe as s on s.ext_id = t.ext_id
             ),
             ins_recipes(id, recipe_uid) as (
                 select er.f_mis_person_recipe8add(
                                t.ext_id,
                                uuid_generate_v1(),
                                n_person_id,
                                mo.id,
                                false,
                                null::bigint,
                                t.visit_id,
                                t.code::text,
                                null::text,
                                t.datecreate,
                                null::integer,
                                null::text,
                                null::text,
                                t."FullInfo"::jsonb
                            ) as id, t."recipe_uid"
                 from cte as t
                          left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                 where t.old_id is null
                   and "action" = 'add'
             ),
             upd_recipes(none, id, recipe_uid) as (
                 select er.f_mis_person_recipe8upd(
                                t.old_id,
                                t.ext_id,
                                uuid_generate_v1(),
                                n_person_id,
                                mo.id,
                                false,
                                null::bigint,
                                t.visit_id,
                                t.code::text,
                                null::text,
                                t.datecreate,
                                null::integer,
                                null::text,
                                null::text,
                                t."FullInfo"::jsonb
                            ), t.old_id as id, t."recipe_uid"
                 from cte as t
                          left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                 where t.old_id is not null
             ),
             all_recipes(id, recipe_uid) as (
                 select id, recipe_uid
                 from ins_recipes
                 union
                 select id, recipe_uid
                 from upd_recipes
             ),
             drugs as (
                 select r.*, d.*,
                        f_ext_entity_values8rebuild(n_system, n_entity, d."drug_uid", coalesce(d.action, 'add')) as ext_id
                 from  all_recipes r join cte using (recipe_uid), jsonb_populate_recordset(null::public.ext_system_drugs_type, cte.drugs::jsonb) as d
             ),
             ins_drug(drug_id, recipe_id, use_method, pack_count) as (
                 select er.f_mis_drug8add(
                                t.ext_id,
                                uuid_generate_v1(),
                                t.drug,
                                null::text,
                                null::numeric,
                                null::text,
                                null::text,
                                true,
                                null::jsonb
                            ) as drug_id, t.id as recipe_id, t.description as use_method, t.pack_count
                 from drugs as t
                          left join er.er_drug d using (ext_id)
                 where d.ext_id is null
             ),
             upd_drug (none, drug_id, recipe_id, use_method, pack_count) as (
                 select er.f_mis_drug8upd(
                                d.id,
                                t.ext_id,
                                uuid_generate_v1(),
                                t.drug,
                                null::text,
                                null::numeric,
                                null::text,
                                null::text,
                                true,
                                null::jsonb
                            ) as none, d.id as drug_id, t.id as recipe_id, t.drug_uid, t.recipe_uid
                 from drugs as t
                          join er.er_drug d using (ext_id)
             ),
             recipe_drug as (
                 select drug_id::bigint, recipe_id::bigint, use_method::text, pack_count::text
                 from ins_drug
                 union
                 select drug_id::bigint, recipe_id::bigint, use_method::text, pack_count::text
                 from upd_drug
             ),
             ins_recipe_drug as (
                 select er.f_mis_recipe_drug8add(
                                t.drug_id,
                                t.recipe_id,
                                t.pack_count,
                                t.use_method,
                                null::text
                            )
                 from recipe_drug as t
                          left join er.er_recipe_drug as rd using (drug_id, recipe_id)
                 where rd.id is null
             ),
             upd_recipe_drug as (
                 select er.f_mis_recipe_drug8upd(
                                rd.id,
                                t.drug_id,
                                t.recipe_id,
                                t.pack_count,
                                t.use_method,
                                null::text
                            )
                 from recipe_drug as t
                          left join er.er_recipe_drug as rd using (drug_id, recipe_id)
                 where rd.id is null
             ),
             cnt as (
                 select count(1) as n
                 from ins_recipe_drug
                 union
                 select count(1) as n
                 from upd_recipe_drug
             )
        select sum(n)
        into n_cnt
        from cnt;

        with anthropometry as (
            select t.*
            from jsonb_populate_recordset(null::public.ext_system_anthropometry_type,
                                          json_body -> 'response' -> 'anthropometry') as t
            where t.meas_date is not null
        ),
             ins(id, specification) as (
                 select er.f_mis_person_anthropometry8add(
                                uuid_generate_v1(),
                                t.meas_date,
                                t.constitution,
                                n_person_id
                            ), t.specification::jsonb
                 from anthropometry as t
             ),
             sp as (
                select ins.id, t.*
                from ins, jsonb_populate_recordset(null::public.ext_system_anthropometry_sp_type,
                                                   ins.specification) as t
            ),
             ins_sp(id) as (
                select er.f_mis_person_anthropometry_sp8add(
                               t.id,
                               uuid_generate_v1(),
                               t.anthrop,
                               t.a_value
                           )
                from sp as t
            )
        select count(1)
        into n_cnt
        from ins_sp;

        DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;

    END LOOP;

    CLOSE cur_res;

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;

--select public.kafka_load_person('get-about-me')