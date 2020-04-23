
DO $$
begin
    if not exists (select true from pg_type where typname = 'resource_person') then
    --drop type if exists public.resource_person;
       create type public.resource_person as
        (
            "id"          text,
            "name"            text,
            "reg_allow"       bool,
            "allow"           bool,
            "FullInfo"        jsonb
        );
    END IF;
END$$;

drop function if exists er.f_mis_persons_resources8add(pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb);
create function er.f_mis_persons_resources8add(pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_add',null);
    begin
        insert into er.er_persons_resources
        (
            id,
            resource_id,
            person_id,
            reg_allow,
            is_allow,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_resource_id,
            pn_person_id,
            pb_reg_allow,
            pb_is_allow,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_add',n_id);
    return n_id;
end;
$$;
alter function er.f_mis_persons_resources8add(bigint, bigint, boolean, boolean, jsonb) owner to dev;


drop function if exists er.f_mis_persons_resources8upd(pn_id bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb);
create function er.f_mis_persons_resources8upd(pn_id bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id bigint default null;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
    begin
        update er.er_persons_resources t set
                                             resource_id = pn_resource_id,
                                             person_id = pn_person_id,
                                             reg_allow = pb_reg_allow,
                                             is_allow = pb_is_allow,
                                             add_info = pu_add_info
        where t.id   = pn_id;
        if not found then
            perform core.f_msg_not_found(pn_id, 'er_persons_resources');
        else
            n_id := pn_id;
        end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_persons_resources8upd(bigint, bigint, bigint, boolean, boolean, jsonb) owner to dev;


drop function if exists er.f_mis_persons_resources8del(pn_id bigint);
create function er.f_mis_persons_resources8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_del',pn_id);
    begin
        delete from er.er_persons_resources t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_del',pn_id);
end;
$$;
alter function er.f_mis_persons_resources8del(bigint) owner to dev;


drop function if exists  er.f_mis_persons_resources8find(pn_resource_id bigint, pn_person_id bigint);
create or replace function er.f_mis_persons_resources8find(pn_resource_id bigint, pn_person_id bigint) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id  bigint;
begin
    select t.id
    into n_id
    from er.er_persons_resources t
    where t.resource_id = pn_resource_id
        and t.person_id = pn_person_id
    limit 1;

    return n_id;
end;
$$;
alter function er.f_mis_persons_resources8find(bigint, bigint) owner to dev;


CREATE OR REPLACE FUNCTION public.kafka_load_resource_person(p_topic text)
    RETURNS void AS
$$
DECLARE
    n_cnt     INT DEFAULT 0;
    arr_ids   BIGINT[];
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

        with response as (
            select t.*, t."allow" as is_allow, coalesce(t."reg_allow", false) as is_reg_allow,
                   cast(split_part(t.id, '.', 2) as bigint) as resource_id,
                   split_part(t.id, '.', 1) as snils
            from jsonb_populate_recordset(
                         null::public.resource_person,
                         json_body -> 'response' -> 'ResultSet' -> 'RowSet'
                     ) as t
        ), cte as (
            select t.*
            from response as t
                     join er.er_persons as per on per.id = n_person_id
                     join er.er_resources as res on res.id = t.resource_id
        ), ins as (
            select
                er.f_mis_persons_resources8add(
                        resource_id,
                        n_person_id,
                        is_reg_allow,
                        is_allow,
                        "FullInfo"::jsonb
                    ) as id
            from cte
        ) select array_agg(id) into arr_ids from ins;

        if array_length(arr_ids, 1) > 0 then
            with del as (
                select er.f_mis_persons_resources8del(pr.id)
                from er.er_persons_resources pr
                where pr.person_id = n_person_id
                  and not (pr.id = any(arr_ids))
            ) select count(1) into n_cnt from del;

            DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;
        end if;

    END LOOP;

    CLOSE cur_res;

END;
$$
    LANGUAGE plpgsql;
