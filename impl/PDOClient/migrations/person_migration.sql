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

        DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;

    END LOOP;

    CLOSE cur_res;

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;

--select public.kafka_load_person('get-about-me')