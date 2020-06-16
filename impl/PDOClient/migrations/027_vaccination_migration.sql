
DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_vaccination_type') then
            drop type if exists ext_system_vaccination_type;
            create type kafka.ext_system_vaccination_type as
            (
                "vac_uid"    bigint,
                "mo_uid"     bigint,
                "type"       text,
                "title"      text,
                "mo_name"    text,
                "mo_adr"     text,
                "caption"    text,
                "datecreate" date,
                "FullInfo"   jsonb
            );
        END IF;
    END
$$;


DO
$$
    begin
        ALTER TABLE er.er_person_vaccination
            ADD COLUMN ext_id bigint default null;
        comment on column er.er_person_vaccination.ext_id is 'Ссылка на внешний идентификатор';

        ALTER TABLE er.er_person_vaccination
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES kafka.ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


drop function if exists kafka.f_ext_person_vaccination8add(pn_ext_id bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb);
create function kafka.f_ext_person_vaccination8add(pn_ext_id bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_add',null);
    begin
        insert into er.er_person_vaccination
        (
            id,
            ext_id,
            vac_id,
            person_id,
            mo_id,
            vac_info,
            plan_date,
            vac_type,
            is_allow,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext_id,
            pu_vac_id,
            pn_person_id,
            pn_mo_id,
            ps_vac_info,
            pd_plan_date,
            pn_vac_type,
            pb_is_allow,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_person_vaccination8add(bigint, uuid, bigint, bigint, text, date, bigint, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_person_vaccination8upd(pn_id bigint, pn_ext_id bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb);
create function kafka.f_ext_person_vaccination8upd(pn_id bigint, pn_ext_id bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_upd',pn_id);
    begin
        update er.er_person_vaccination t set
                                              vac_id = pu_vac_id,
                                              ext_id = pn_ext_id,
                                              person_id = pn_person_id,
                                              mo_id = pn_mo_id,
                                              vac_info = ps_vac_info,
                                              plan_date = pd_plan_date,
                                              vac_type = pn_vac_type,
                                              is_allow = pb_is_allow,
                                              add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_vaccination'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_upd',pn_id);
end;
$$;
alter function kafka.f_ext_person_vaccination8upd(bigint, bigint, uuid, bigint, bigint, text, date, bigint, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_person_vaccination8del(pn_id bigint);
create function kafka.f_ext_person_vaccination8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_del',pn_id);
    begin
        delete from er.er_person_vaccination t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_vaccination'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_del',pn_id);
end;
$$;
alter function kafka.f_ext_person_vaccination8del(bigint) owner to dev;



