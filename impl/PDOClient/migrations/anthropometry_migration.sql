
DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_anthropometry_type') then
            --drop type if exists kafka.ext_system_anthropometry_type;
            create type kafka.ext_system_anthropometry_type as
            (
                "meas_date"     date,
                "constitution"  text,
                "action"        text,
                "specification" jsonb
            );
        END IF;
    END
$$;

DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_anthropometry_sp_type') then
            --drop type if exists ext_system_anthropometry_sp_type;
            create type kafka.ext_system_anthropometry_sp_type as
            (
                "anthrop"     text,
                "a_value"     numeric(10,2),
                "meas_name"   text
            );
        END IF;
    END
$$;

drop function if exists kafka.f_ext_person_anthropometry8add( pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint);
create function kafka.f_ext_person_anthropometry8add( pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_add',null);
    begin
        insert into er.er_person_anthropometry
        (
            id,
            anthop_id,
            meas_date,
            constitution,
            person_id
        )
        values
        (
            core.f_gen_id(),
            pu_anthop_id,
            pd_meas_date,
            ps_constitution,
            pn_person_id
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_person_anthropometry8add( uuid, date, text, bigint) owner to dev;

drop function if exists kafka.f_ext_person_anthropometry8upd(pn_id bigint, pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint);
create function kafka.f_ext_person_anthropometry8upd(pn_id bigint, pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_upd',pn_id);
    begin
        update er.er_person_anthropometry t set
                                                anthop_id = pu_anthop_id,
                                                meas_date = pd_meas_date,
                                                constitution = ps_constitution,
                                                person_id = pn_person_id
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_anthropometry'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_upd',pn_id);
end;
$$;
alter function kafka.f_ext_person_anthropometry8upd(bigint, uuid, date, text, bigint) owner to dev;

drop function if exists kafka.f_ext_person_anthropometry8del(pn_id bigint);
create function kafka.f_ext_person_anthropometry8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_del',pn_id);
    begin
        delete from er.er_person_anthropometry t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_anthropometry'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_del',pn_id);
end;
$$;
alter function kafka.f_ext_person_anthropometry8del(pn_id bigint) owner to dev;

drop function if exists kafka.f_ext_person_anthropometry_sp8add(pn_pid bigint, pu_anthrop_sp_id uuid, ps_anthrop text, pn_a_value numeric, ps_meas_name text);
create function kafka.f_ext_person_anthropometry_sp8add(pn_pid bigint, pu_anthrop_sp_id uuid, ps_anthrop text, pn_a_value numeric, ps_meas_name text) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_sp_add',null);
    begin
        insert into er.er_person_anthropometry_sp
        (
            id,
            pid,
            anthrop_sp_id,
            anthrop,
            a_value,
            meas_name
        )
        values
        (
            core.f_gen_id(),
            pn_pid,
            pu_anthrop_sp_id,
            ps_anthrop,
            pn_a_value,
            ps_meas_name
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_sp_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_person_anthropometry_sp8add(bigint, uuid, text, numeric, text) owner to dev;


