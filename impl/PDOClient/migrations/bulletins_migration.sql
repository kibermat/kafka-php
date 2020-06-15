set search_path to er, public;

DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_bulletin_type') then
            drop type if exists public.ext_system_bulletin_type;
            create type public.ext_system_bulletin_type as
            (
                "bull_uid"      bigint,
                "mo_uid"        bigint,
                "visit_uid"     bigint,
                "types"         integer,
                "code"          text,
                "description"   text,
                "datecreate"    date,
                "dateend"       date,
                "FullInfo"      jsonb
            );
        END IF;
    END
$$;


DO
$$
    begin
        set search_path to er, public;

        ALTER TABLE er_person_bulletin
            ADD COLUMN ext_id bigint default null;
        comment on column er_person_bulletin.ext_id is 'Ссылка на внешний идентификатор';
        ALTER TABLE er_person_bulletin
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


drop function if exists f_mis_person_bulletin8add( pn_ext bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb);
create function f_mis_person_bulletin8add(pn_ext bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_add',null);
    begin
        insert into er.er_person_bulletin
        (
            id,
            ext_id,
            bull_id,
            person_id,
            mo_id,
            bul_number,
            type,
            kind,
            date_begin,
            emp_fio,
            date_free_begin,
            date_fee_end,
            visit_id,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext,
            pu_bull_id,
            pn_person_id,
            pn_mo_id,
            ps_bul_number,
            pn_type,
            pn_kind,
            pd_date_begin,
            ps_emp_fio,
            pd_date_free_begin,
            pd_date_fee_end,
            pn_visit_id,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_add',n_id);
    return n_id;
end;
$$;
alter function f_mis_person_bulletin8add(bigint, uuid, bigint, bigint, text, integer, integer, date, text, date, date, bigint, jsonb) owner to dev;


drop function if exists f_mis_person_bulletin8upd(pn_id bigint, pn_ext_id bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb);
create function f_mis_person_bulletin8upd(pn_id bigint, pn_ext_id bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_upd',pn_id);
    begin
        update er.er_person_bulletin t set
                                           bull_id = pu_bull_id,
                                           ext_id = pn_ext_id,
                                           person_id = pn_person_id,
                                           mo_id = pn_mo_id,
                                           bul_number = ps_bul_number,
                                           type = pn_type,
                                           kind = pn_kind,
                                           date_begin = pd_date_begin,
                                           emp_fio = ps_emp_fio,
                                           date_free_begin = pd_date_free_begin,
                                           date_fee_end = pd_date_fee_end,
                                           visit_id = pn_visit_id,
                                           add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_bulletin'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_upd',pn_id);
end;
$$;
alter function f_mis_person_bulletin8upd(bigint, bigint, uuid, bigint, bigint, text, integer, integer, date, text, date, date, bigint, jsonb) owner to dev;


drop function if exists f_mis_person_bulletin8del(pn_id bigint);
create function f_mis_person_bulletin8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_del',pn_id);
    begin
        delete from er.er_person_bulletin t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_bulletin'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_del',pn_id);
end;
$$;
alter function f_mis_person_bulletin8del(bigint) owner to dev;


