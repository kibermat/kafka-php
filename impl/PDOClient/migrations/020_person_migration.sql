
DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_person_type') then
            --drop type if exists ext_system_person_type;
            create type kafka.ext_system_person_type as
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


drop function if exists kafka.f_ext_persons8add(pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text);
create function kafka.f_ext_persons8add(pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text,
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
alter function kafka.f_ext_persons8add(bigint, uuid, text, text, text, date, integer, text, text) owner to dev;


drop function if exists kafka.f_ext_persons8upd(pn_id bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text);
create function kafka.f_ext_persons8upd(pn_id bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text,
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
alter function kafka.f_ext_persons8upd(bigint, bigint, uuid, text, text, text, date, integer, text, text) owner to dev;


drop function if exists kafka.f_ext_persons8find(ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, ps_snils text, out id bigint);
create function kafka.f_ext_persons8find(ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, ps_snils text,
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
alter function kafka.f_ext_persons8find(text, text, text, date, text, out bigint) owner to dev;


drop function if exists kafka.f_ext_persons8del(pn_id bigint);
create function kafka.f_ext_persons8del(pn_id bigint) returns void
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
alter function kafka.f_ext_persons8del(bigint) owner to dev;

