set search_path to er, public;

DO
$$
    begin
        set search_path to er, public;

        ALTER TABLE er_persons_resources
            ADD COLUMN ext_id bigint default null;
        comment on column er_persons_resources.ext_id is 'Идентификатор на внешней системе';
        ALTER TABLE er_persons_resources
            ADD CONSTRAINT fk_ext_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;

commit;
set search_path to public;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_resource_person_type') then
            --drop type if exists public.ext_system_resource_person_type;
            create type public.ext_system_resource_person_type as
            (
                "id"        text,
                "name"      text,
                "action"    text,
                "reg_allow" bool,
                "allow"     bool,
                "FullInfo"  jsonb
            );
        END IF;
    END
$$;

drop function if exists er.f_mis_persons_resources8add(pn_ext_id bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb);
create function er.f_mis_persons_resources8add(pn_ext_id bigint, pn_resource_id bigint, pn_person_id bigint,
                                               pb_reg_allow boolean, pb_is_allow boolean,
                                               pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_add',null);
    begin
        insert into er.er_persons_resources
        (id,
         ext_id,
         resource_id,
         person_id,
         reg_allow,
         is_allow,
         add_info)
        values (core.f_gen_id(),
                pn_ext_id,
                pn_resource_id,
                pn_person_id,
                pb_reg_allow,
                pb_is_allow,
                pu_add_info)
        returning id into n_id;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_add',n_id);
    return n_id;
end;
$$;
alter function er.f_mis_persons_resources8add(bigint, bigint, bigint, boolean, boolean, jsonb) owner to dev;


drop function if exists er.f_mis_persons_resources8upd(pn_id bigint, pn_ext_id bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb);
create function er.f_mis_persons_resources8upd(pn_id bigint, pn_ext_id bigint, pn_resource_id bigint,
                                               pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean,
                                               pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as
$$
declare
    n_id bigint default null;
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
    begin
        update er.er_persons_resources t
        set ext_id      = pn_ext_id,
            resource_id = pn_resource_id,
            person_id   = pn_person_id,
            reg_allow   = pb_reg_allow,
            is_allow    = pb_is_allow,
            add_info    = pu_add_info
        where t.id = pn_id;

        if not found then
            perform core.f_msg_not_found(pn_id, 'er_persons_resources');
        else
            n_id := pn_id;
        end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'U');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
    return n_id;
end;
$$;
alter function er.f_mis_persons_resources8upd(bigint, bigint, bigint, bigint, boolean, boolean, jsonb) owner to dev;


drop function if exists er.f_mis_persons_resources8del(pn_id bigint);
create function er.f_mis_persons_resources8del(pn_id bigint) returns void
    security definer
    language plpgsql
as
$$
begin
    --perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_del',pn_id);
    begin
        delete
        from er.er_persons_resources t
        where t.id = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons_resources'); end if;
    exception
        when others then perform core.f_msg_errors(sqlstate, sqlerrm, 'D');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_del',pn_id);
end;
$$;
alter function er.f_mis_persons_resources8del(bigint) owner to dev;

drop function if exists public.kafka_load_resource_person(p_topic text);
CREATE OR REPLACE FUNCTION public.kafka_load_resource_person(p_topic text)
    RETURNS integer AS
$$
DECLARE
    n_cnt           INT DEFAULT 0;
    s_mis_code      VARCHAR;
    s_type          VARCHAR;
    n_system        INTEGER;
    n_entity        INTEGER;
    arr_ids         BIGINT[];
    rec_res         RECORD;
    json_body       jsonb;
    n_person_id     bigint;
    n_ext_person_id bigint;
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
        -- TODO  PersonId
        n_ext_person_id := cast((json_body -> 'response' -> 'agent_id' ->> 0) as bigint);
        s_mis_code := json_body -> 'response' -> 'mis_code' ->> 0;
        s_type := 'er_persons_resource';

        select "system", "entity"
        into n_system, n_entity
        from f_ext_system_entities8find(s_mis_code, p_topic);

        if not found then
            raise exception 'Нет реализации % для внешней системы %', p_topic, s_mis_code;
        end if;

        -- TODO Find AgentId
        select id
        into n_person_id
        from er.er_persons
        where id = n_ext_person_id;

        if not found then
            raise notice 'Нет агента. Идентификатор внешней системы % ', n_ext_person_id;
            return n_cnt;
        end if;

        with response as (
            select t.*,
                   t."allow"                                                                              as is_allow,
                   coalesce(t."reg_allow", false)                                                         as is_reg_allow,
                   case when t."action" is null then 'add' else t."action" end                            as "action_res",
                   split_part(t.id, '.', 1)                                                               as snils,
                   cast(split_part(t.id, '.', 2) as bigint)                                               as res_id,
                   cast(concat(n_person_id, split_part(t.id, '.', 2)) as bigint)                          as _id,
                   f_ext_entity_values8find(n_system, n_entity,
                                            cast(split_part(t.id, '.', 2) as bigint))                     as resource_ext_id
            from jsonb_populate_recordset(
                         null::public.ext_system_resource_person_type,
                         json_body -> 'response' -> 'ResultSet' -> 'RowSet'
                     ) as t
        ),
             cte as (
                 select f_ext_entity_values8rebuild(n_system, n_entity, t._id, "action_res") as ext_id,
                        res.id                                                               as resource_id,
                        t.*
                 from response as t
                          join er.er_resources as res on res.ext_id = t.resource_ext_id
             ),
             ins as (
                 select er.f_mis_persons_resources8add(
                                ext_id,
                                resource_id,
                                n_person_id,
                                is_reg_allow,
                                is_allow,
                                "FullInfo"::jsonb
                            ) as id
                 from cte
             )
        select array_agg(id)
        into arr_ids
        from ins;

        if array_length(arr_ids, 1) > 0 then
            with del as (
                select er.f_mis_persons_resources8del(pr.id)
                from er.er_persons_resources pr
                where pr.person_id = n_person_id
                  and not (pr.id = any (arr_ids))
            )
            select count(1)
            into n_cnt
            from del;

            DELETE FROM public.kafka_result WHERE CURRENT OF cur_res;
        end if;

    END LOOP;

    CLOSE cur_res;

    return n_cnt;

END;
$$
    LANGUAGE plpgsql;

