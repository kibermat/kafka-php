

DO
$$
    begin
        ALTER TABLE er.er_person_recipe
            ADD COLUMN ext_id bigint default null;
        comment on column er.er_person_recipe.ext_id is 'Ссылка на внешний идентификатор';

        ALTER TABLE er.er_person_recipe
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES kafka.ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        ALTER TABLE er.er_drug
            ADD COLUMN ext_id bigint default null;
        comment on column er.er_drug.ext_id is 'Ссылка на внешний идентификатор';

        ALTER TABLE er.er_drug
            ADD CONSTRAINT fk_ext_entity_values_id FOREIGN KEY (ext_id) REFERENCES kafka.ext_entity_values (id) ON DELETE CASCADE;

    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_recipe_type') then
            drop type if exists kafka.ext_system_recipe_type;
            create type kafka.ext_system_recipe_type as
            (
                "recipe_uid" bigint,
                "mo_uid"      bigint,
                "visit_uid"   bigint,
                "type"       text,
                "datecreate" date,
                "code"       text,
                "action"     text,
                "FullInfo"   jsonb,
                "drugs"      jsonb
            );
        END IF;
    END
$$;


DO
$$
    begin
        if not exists(select true from pg_type where typname = 'ext_system_drugs_type') then
            drop type if exists ext_system_drugs_type;
            create type kafka.ext_system_drugs_type as
            (
                "drug_uid"    bigint,
                "drug"        text,
                "pack_count"  integer,
                "description" text,
                "action"      text
            );
        END IF;
    END
$$;


drop function if exists kafka.f_ext_person_recipe8add(pn_ext_id bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb);
create function kafka.f_ext_person_recipe8add(pn_ext_id bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_add',null);
    begin
        insert into er.er_person_recipe
        (
            id,
            ext_id,
            recipe_id,
            person_id,
            mo_id,
            discount,
            dispensary_id,
            visit_id,
            r_ser,
            r_num,
            date_create,
            exp_period,
            emp_fio,
            recomendation,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext_id,
            pu_recipe_id,
            pn_person_id,
            pn_mo_id,
            pb_discount,
            pn_dispensary_id,
            pn_visit_id,
            ps_r_ser,
            ps_r_num,
            pd_date_create,
            pn_exp_period,
            ps_emp_fio,
            ps_recomendation,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_person_recipe8add(bigint, uuid, bigint, bigint, boolean, bigint, bigint, text, text, date, integer, text, text, jsonb) owner to dev;


drop function if exists kafka.f_ext_person_recipe8upd(pn_id bigint, pn_ext_id bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb);
create function kafka.f_ext_person_recipe8upd(pn_id bigint, pn_ext_id bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_upd',pn_id);
    begin
        update er.er_person_recipe t set
                                         ext_id = pn_ext_id,
                                         recipe_id = pu_recipe_id,
                                         person_id = pn_person_id,
                                         mo_id = pn_mo_id,
                                         discount = pb_discount,
                                         dispensary_id = pn_dispensary_id,
                                         visit_id = pn_visit_id,
                                         r_ser = ps_r_ser,
                                         r_num = ps_r_num,
                                         date_create = pd_date_create,
                                         exp_period = pn_exp_period,
                                         emp_fio = ps_emp_fio,
                                         recomendation = ps_recomendation,
                                         add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_recipe'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_upd',pn_id);
end;
$$;
alter function kafka.f_ext_person_recipe8upd(bigint, bigint, uuid, bigint, bigint, boolean, bigint, bigint, text, text, date, integer, text, text, jsonb) owner to dev;


drop function if exists kafka.f_ext_person_recipe8del(pn_id bigint);
create function kafka.f_ext_person_recipe8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_del',pn_id);
    begin
        delete from er.er_person_recipe t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_recipe'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_del',pn_id);
end;
$$;
alter function kafka.f_ext_person_recipe8del(bigint) owner to dev;


drop function if exists kafka.f_ext_recipe_drug8add(pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text);
create function kafka.f_ext_recipe_drug8add(pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_add',null);
    begin
        insert into er.er_recipe_drug
        (
            id,
            drug_id,
            recipe_id,
            pack_count,
            use_method,
            recomendation
        )
        values
        (
            core.f_gen_id(),
            pn_drug_id,
            pn_recipe_id,
            ps_pack_count,
            ps_use_method,
            ps_recomendation
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_recipe_drug8add(pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text) owner to dev;


drop function if exists kafka.f_ext_recipe_drug8upd(pn_id bigint, pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text);
create function kafka.f_ext_recipe_drug8upd(pn_id bigint, pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_upd',pn_id);
    begin
        update er.er_recipe_drug t set
                                       drug_id = pn_drug_id,
                                       recipe_id = pn_recipe_id,
                                       pack_count = ps_pack_count,
                                       use_method = ps_use_method,
                                       recomendation = ps_recomendation
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_recipe_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_upd',pn_id);
end;
$$;
alter function kafka.f_ext_recipe_drug8upd(bigint, bigint, bigint, text, text, text) owner to dev;


drop function if exists kafka.f_ext_recipe_drug8del(pn_id bigint);
create function kafka.f_ext_recipe_drug8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_del',pn_id);
    begin
        delete from er.er_recipe_drug t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_recipe_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_del',pn_id);
end;
$$;
alter function kafka.f_ext_recipe_drug8del(bigint) owner to dev;


drop function if exists kafka.f_ext_drug8add(pn_ext_id bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb);
create function kafka.f_ext_drug8add(pn_ext_id bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb) returns bigint
    security definer
    language plpgsql
as $$
declare
    n_id                  bigint;
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_drug_add',null);
    begin
        insert into er.er_drug
        (
            id,
            ext_id,
            drug_id,
            drug_name,
            medform,
            dose,
            dose_mease,
            pack_numb,
            is_allow,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_ext_id,
            pu_drug_id,
            ps_drug_name,
            ps_medform,
            pn_dose,
            ps_dose_mease,
            ps_pack_numb,
            pb_is_allow,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_drug_add',n_id);
    return n_id;
end;
$$;
alter function kafka.f_ext_drug8add(bigint, uuid, text, text, numeric, text, text, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_drug8upd(pn_id bigint, pn_ext_id bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb);
create function kafka.f_ext_drug8upd(pn_id bigint, pn_ext_id bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_drug_upd',pn_id);
    begin
        update er.er_drug t set
                                ext_id= pn_ext_id,
                                drug_id = pu_drug_id,
                                drug_name = ps_drug_name,
                                medform = ps_medform,
                                dose = pn_dose,
                                dose_mease = ps_dose_mease,
                                pack_numb = ps_pack_numb,
                                is_allow = pb_is_allow,
                                add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_drug_upd',pn_id);
end;
$$;
alter function kafka.f_ext_drug8upd(bigint, bigint, uuid, text, text, numeric, text, text, boolean, jsonb) owner to dev;


drop function if exists kafka.f_ext_drug8del(pn_id bigint);
create function kafka.f_ext_drug8del(pn_id bigint) returns void
    security definer
    language plpgsql
as $$
begin
--     perform core.f_bp_before(pn_lpu,null,null,'er_drug_del',pn_id);
    begin
        delete from er.er_drug t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
--     perform core.f_bp_after(pn_lpu,null,null,'er_drug_del',pn_id);
end;
$$;
alter function kafka.f_ext_drug8del(bigint) owner to dev;


--select kafka.f_kafka_load_recipe('get-about-me')
