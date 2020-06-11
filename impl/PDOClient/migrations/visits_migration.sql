set search_path to er, public;

DO
$$
    begin
        set search_path to er, public;

        ALTER TABLE er_person_visit
            ADD COLUMN ext_id bigint default null;
        comment on column er_person_visit.ext_id is 'Ссылка на внешний идентификатор';
        ALTER TABLE er_person_visit
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_visit_type') then
            drop type if exists public.ext_system_visit_type;
            create type public.ext_system_visit_type as
            (
                "vis_uid"       bigint,
                "mo_id"         bigint,
                "div_id"        bigint,
                "resource_id"   bigint,
                "mo"            text,
                "mo_name"       text,
                "service"       text,
                "emp_fio"       text,
                "vis_date"      date,
                "cost"          numeric(10, 2),
                "status"        integer,
                "status_desc"   text,
                "recommend"     text,
                "source"        text,
                "source_desc"   text,
                "direction_uid" bigint,
                "dir_info"      text,
                "action"        text,
                "FullInfo"      jsonb
            );
        END IF;
    END
$$;


drop function if exists f_mis_person_visit8add(pn_ext_id bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb);
create function f_mis_person_visit8add(pn_ext_id bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_add',null);
    begin
        insert into er.er_person_visit
        (
            id,
            ext_id,
            visit_id,
            mo_id,
            div_id,
            person_id,
            resource_id,
            direction_id,
            service,
            emp_fio,
            vis_date,
            dir_date,
            cost,
            recomendation,
            status_id,
            status_description,
            source_code,
            source_description,
            boked,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext_id,
            pu_visit_id,
            pn_mo_id,
            pn_div_id,
            pn_person_id,
            pn_resource_id,
            pn_direction_id,
            ps_service,
            ps_emp_fio,
            pd_vis_date,
            pd_dir_date,
            pn_cost,
            ps_recomendation,
            pn_status_id,
            ps_status_description,
            ps_source_code,
            ps_source_description,
            pb_boked,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_add',n_id);
    return n_id;
end;
$$;
alter function f_mis_person_visit8add(bigint, uuid, bigint, bigint, bigint, bigint, bigint, text, text, date, date, numeric, text, bigint, text, text, text, boolean, jsonb) owner to dev;


drop function if exists f_mis_person_visit8upd(pn_id bigint, pn_ext_id bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb);
create function f_mis_person_visit8upd(pn_id bigint, pn_ext_id bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_upd',pn_id);
    begin
        update er.er_person_visit t set
                                        ext_id = pn_ext_id,
                                        visit_id = pu_visit_id,
                                        mo_id = pn_mo_id,
                                        div_id = pn_div_id,
                                        person_id = pn_person_id,
                                        resource_id = pn_resource_id,
                                        direction_id = pn_direction_id,
                                        service = ps_service,
                                        emp_fio = ps_emp_fio,
                                        vis_date = pd_vis_date,
                                        dir_date = pd_dir_date,
                                        cost = pn_cost,
                                        recomendation = ps_recomendation,
                                        status_id = pn_status_id,
                                        status_description = ps_status_description,
                                        source_code = ps_source_code,
                                        source_description = ps_source_description,
                                        boked = pb_boked,
                                        add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_visit'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_upd',pn_id);
end;
$$;
alter function f_mis_person_visit8upd(bigint, bigint, uuid, bigint, bigint, bigint, bigint, bigint, text, text, date, date, numeric, text, bigint, text, text, text, boolean, jsonb) owner to dev;


drop function if exists f_mis_person_visit8del(pn_id bigint);
create function f_mis_person_visit8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_del',pn_id);
    begin
        delete from er.er_person_visit t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_visit'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_del',pn_id);
end;
$$;
alter function f_mis_person_visit8del(bigint) owner to dev;

