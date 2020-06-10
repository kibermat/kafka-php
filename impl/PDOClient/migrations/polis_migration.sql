set search_path to er, public;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_polis_type') then
            --drop type if exists public.ext_system_polis_type;
            create type public.ext_system_polis_type as
            (
                "polis_id"    integer,
                "type_id"     integer,
                "kind"        integer,
                "polis_ser"   text,
                "polis_num"   text,
                "p_date_beg"  date,
                "p_date_end"  date
            );
        END IF;
    END
$$;

create index if not exists i_er_person_polis_num
    on er.er_person_polis (pnum, pser);


drop function if exists f_mis_person_polis8add(pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb);
create function f_mis_person_polis8add(pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_add',null);
    begin
        insert into er.er_person_polis
        (
            id,
            polis_id,
            person_id,
            type,
            kind_id,
            pser,
            pnum,
            date_begin,
            date_end,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pu_polis_id,
            pn_person_id,
            pn_type,
            pn_kind_id,
            ps_pser,
            ps_pnum,
            pd_date_begin,
            pd_date_end,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_add',n_id);
    return n_id;
end;
$$;
alter function f_mis_person_polis8add(uuid, bigint, integer, bigint, text, text, date, date, jsonb) owner to dev;


drop function if exists f_mis_person_polis8upd(pn_id bigint, pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb);
create function f_mis_person_polis8upd(pn_id bigint, pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_upd',pn_id);
    begin
        update er.er_person_polis t set
                                        polis_id = pu_polis_id,
                                        person_id = pn_person_id,
                                        type = pn_type,
                                        kind_id = pn_kind_id,
                                        pser = ps_pser,
                                        pnum = ps_pnum,
                                        date_begin = pd_date_begin,
                                        date_end = pd_date_end,
                                        add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_polis'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_upd',pn_id);
end;
$$;
alter function f_mis_person_polis8upd(bigint, uuid, bigint, integer, bigint, text, text, date, date, jsonb) owner to dev;


drop function if exists f_mis_person_polis8find(ps_ser text, ps_num text, pn_kind bigint, out id bigint);
create function f_mis_person_polis8find(ps_ser text, ps_num text, pn_kind bigint default null, out id bigint)
as
'
    select t.id
    from er.er_person_polis t
    where (nullif(trim(ps_ser), '''') is not null or (nullif(trim(ps_num), '''') is not null))
      and (nullif(trim(ps_ser), '''') is null or t.pser = ps_ser)
      and (nullif(trim(ps_num), '''') is null or t.pnum = ps_num)
      and (pn_kind is null or t.kind_id = pn_kind)
    limit 1
'
    LANGUAGE SQL;
alter function f_mis_person_polis8find(text, text, bigint, out bigint) owner to dev;

drop function if exists f_mis_person_polis8del(pn_id bigint);
create function f_mis_person_polis8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_del',pn_id);
    begin
        delete from er.er_person_polis t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_polis'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_del',pn_id);
end;
$$;
alter function f_mis_person_polis8del(bigint) owner to dev;

--select public.kafka_load_person('get-about-me')
