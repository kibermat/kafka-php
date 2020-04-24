

DO $$
    begin
        if not exists (select true from pg_type where typname = 'directions_type') then
            --drop type if exists public.directions_type;
            create type public.directions_type as
            (
                "id"              bigint,
                "person_id"       bigint,
                "dir_numb"        text,
                "dir_type"        bigint,
                "dir_kind"        text,
                "mo_id"           bigint,
                "div_id"          bigint,
                "profile_id"      bigint,
                "FullInfo"        jsonb
            );
        END IF;
    END$$;

-- auto-generated definition
create table er.er_direction_type
(
    id         bigint not null
        constraint pk_er_direction_type
            primary key,
    code    int,
    label   text not null
);

insert into  er.er_direction_type(code, label) values
((1, 'Поликлиника'), (2, 'Стационар'));

comment on table er.er_direction_type is 'Тип направления ';

comment on column er_direction_type.id is 'Id';

alter table er_directions
    owner to dev;



drop function if exists  er.f_mis_directions8find(pn_id bigint);
create or replace function er.f_mis_directions8find(pn_id bigint) returns uuid
    security definer
    language plpgsql
as
$$
declare
    u_uid  uuid;
begin
    select t.dir_uid
    into u_uid
    from er.er_directions t
    where t.id = pn_id
    limit 1;

    return u_uid;
end;
$$;
alter function er.f_mis_directions8find(bigint) owner to dev;


drop function if exists  er.f_mis_directions8add(pn_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb);
create function er.f_mis_directions8add(pn_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_add',null);
    begin
        insert into er.er_directions
        (
            id,
            dir_uid,
            person_id,
            dir_numb,
            dir_type,
            dir_kind,
            mo_id,
            div_id,
            profile_id,
            add_info
        )
        values
        (
            pn_id,
            pu_dir_uid,
            pn_person_id,
            ps_dir_numb,
            pn_dir_type,
            ps_dir_kind,
            pn_mo_id,
            pn_div_id,
            pn_profile_id,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_directions_add',n_id);
    return n_id;
end;
$$;
alter function er.f_mis_directions8add(bigint, uuid, bigint, text, bigint, text, bigint, bigint, bigint, jsonb) owner to dev;


drop function if exists  er.f_mis_directions8upd(pn_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb);
create function er.f_mis_directions8upd(pn_id bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id bigint default null;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_upd',pn_id);
    begin
        update er.er_directions t set
                                      dir_uid = pu_dir_uid,
                                      person_id = pn_person_id,
                                      dir_numb = ps_dir_numb,
                                      dir_type = pn_dir_type,
                                      dir_kind = ps_dir_kind,
                                      mo_id = pn_mo_id,
                                      div_id = pn_div_id,
                                      profile_id = pn_profile_id,
                                      add_info = pu_add_info
        where t.id   = pn_id;

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
alter function er.f_mis_directions8upd(bigint, uuid, bigint, text, bigint, text, bigint, bigint, bigint, jsonb) owner to dev;


drop function if exists er.f_mis_directions8del(pn_id bigint);
create function er.f_mis_directions8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_directions_del',pn_id);
    begin
        delete from er.er_directions t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_directions'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_directions_del',pn_id);
end;
$$;
alter function er.f_mis_directions8del(pn_id bigint) owner to dev;


CREATE OR REPLACE FUNCTION public.kafka_load_derections(p_topic text)
    RETURNS int AS
$$
DECLARE
    n_cnt     INT DEFAULT 0;
    rec_res   RECORD;
    json_body jsonb;
    n_person_id bigint;
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
        n_person_id := cast((json_body -> 'response' -> 'agent_id' ->> 0) as bigint);

        with cte as (
                select t.*, er.f_mis_directions8find(t.id) as dir_uuid,
                       case when lower(t."type") = 'поликлиника' then 1 else 2 end as dir_type
                from jsonb_populate_recordset(null::public.directions_type,
                        json_body -> 'response' -> 'ResultSet' -> 'RowSet') as t
                         left join er.er_mo mo       on ( t.lpu = mo.id )
                         left join er.er_mo div      on ( t.div = div.id )
                         left join er.er_profiles pr on ( t.profile_id = pr.id )
                where (t.lpu is null or mo.id is not null) and
                    (t.div is null or div.id is not null) and
                    (t.profile_id is null or pr.id is not null)
                    and exists (select true from er.er_persons where id = n_person_id )
            ), ins as (
                select er.f_mis_directions8add(
                   t.id::bigint,
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
                where t.dir_uuid is null and t."action" = 'add'
            ), upd as (
                select er.f_mis_directions8upd(
                       t.id::bigint,
                       t.dir_uuid,
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
        where dir_uuid is not null and action = 'upd'
    ), del as (
        select er.f_mis_directions8del(id)
        from cte
        where dir_uuid is not null and action = 'del'
    ),  cnt as (
        select count(1) as n from ins
        union all
        select count(1) as n from upd
        union all
        select count(1) as n from del
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


