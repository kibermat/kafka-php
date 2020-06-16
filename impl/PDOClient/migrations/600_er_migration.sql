--[u:er.er_directions:a]
--[u:er.er_directions:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_directions','Направления','er_directions',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Направления','er');
--[b:er.er_directions_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_directions_add','er_directions','Направления : Добавление','add','er.f_er_directions8add');
--[b:er.er_directions_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_directions_upd','er_directions','Направления : Исправление','upd','er.f_er_directions8upd');
--[b:er.er_directions_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_directions_del','er_directions','Направления : Удаление','del','er.f_er_directions8del');
--[b:er.er_directions_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_directions_mod','er_directions','Направления : Модификация','mod','er.f_er_directions8mod');
--[t:er.er_directions:n]
create table er.er_directions (
                                  id bigint not null
    ,dir_uid uuid not null
    ,person_id bigint not null
    ,dir_numb text
    ,dir_type bigint
    ,dir_kind text
    ,mo_id bigint
    ,div_id bigint
    ,profile_id bigint
    ,add_info jsonb
    ,constraint fk_er_directions_div_id FOREIGN KEY (div_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_directions_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_directions_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_directions_profile_id FOREIGN KEY (profile_id) REFERENCES er.er_profiles(id)
    ,constraint pk_er_directions PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_directions is 'Направления';
comment on column er.er_directions.id is 'Id';
comment on column er.er_directions.dir_uid is 'Идентификатор направления';
comment on column er.er_directions.person_id is 'Идентификатор контрагента';
comment on column er.er_directions.dir_numb is 'Номер направления';
comment on column er.er_directions.dir_type is 'Тип направления';
comment on column er.er_directions.dir_kind is 'Вид направления';
comment on column er.er_directions.mo_id is 'Краткое наименование учреждения';
comment on column er.er_directions.div_id is 'Полное наименование учреждения';
comment on column er.er_directions.profile_id is 'Идентификатор профиля врача';
comment on column er.er_directions.add_info is 'Детальная информация о направлении';
CREATE INDEX i_er_directions_div_id ON er.er_directions USING btree (div_id);
CREATE INDEX i_er_directions_mo_id ON er.er_directions USING btree (mo_id);
CREATE INDEX i_er_directions_person_id ON er.er_directions USING btree (person_id);
CREATE INDEX i_er_directions_profile_id ON er.er_directions USING btree (profile_id);
alter table er.er_directions owner to dev;
--[v:er.v_er_directions:n]
create or replace view er.v_er_directions as
SELECT t.id,
       t.dir_uid,
       t.person_id,
       t.dir_numb,
       t.dir_type,
       t.dir_kind,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.div_id,
       t2.code_mo AS div_id_code_mo,
       t.profile_id,
       t.add_info
FROM er.er_directions t
         LEFT JOIN er.er_mo t1 ON t.mo_id = t1.id
         LEFT JOIN er.er_mo t2 ON t.div_id = t2.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_directions'::text));
--[f:er.f_er_directions8add:n]
CREATE OR REPLACE FUNCTION er.f_er_directions8add(pn_lpu bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_directions_add',null);
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
            core.f_gen_id(),
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
    perform core.f_bp_after(pn_lpu,null,null,'er_directions_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_directions8del:n]
CREATE OR REPLACE FUNCTION er.f_er_directions8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_directions_del',pn_id);
    begin
        delete from er.er_directions t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_directions'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_directions_del',pn_id);
end;
$function$
;
--[f:er.f_er_directions8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_directions8mod(pn_id bigint, pn_lpu bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_directions8add(pn_lpu := pn_lpu,
                                       pu_dir_uid := pu_dir_uid,
                                       pn_person_id := pn_person_id,
                                       ps_dir_numb := ps_dir_numb,
                                       pn_dir_type := pn_dir_type,
                                       ps_dir_kind := ps_dir_kind,
                                       pn_mo_id := pn_mo_id,
                                       pn_div_id := pn_div_id,
                                       pn_profile_id := pn_profile_id,
                                       pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_directions8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                       pu_dir_uid := pu_dir_uid,
                                       pn_person_id := pn_person_id,
                                       ps_dir_numb := ps_dir_numb,
                                       pn_dir_type := pn_dir_type,
                                       ps_dir_kind := ps_dir_kind,
                                       pn_mo_id := pn_mo_id,
                                       pn_div_id := pn_div_id,
                                       pn_profile_id := pn_profile_id,
                                       pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_directions8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_directions8upd(pn_id bigint, pn_lpu bigint, pu_dir_uid uuid, pn_person_id bigint, ps_dir_numb text, pn_dir_type bigint, ps_dir_kind text, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_directions_upd',pn_id);
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
        if not found then perform core.f_msg_not_found(pn_id, 'er_directions'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_directions_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_directions_a:n]
CREATE TRIGGER tr_er_directions_a AFTER INSERT OR DELETE OR UPDATE ON er.er_directions FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_dispansary:a]
--[u:er.er_dispansary:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_dispansary','Аптека','er_dispansary',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Аптека','er');
--[b:er.er_dispansary_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_dispansary_add','er_dispansary','Аптека : Добавление','add','er.f_er_dispansary8add');
--[b:er.er_dispansary_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_dispansary_upd','er_dispansary','Аптека : Исправление','upd','er.f_er_dispansary8upd');
--[b:er.er_dispansary_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_dispansary_del','er_dispansary','Аптека : Удаление','del','er.f_er_dispansary8del');
--[b:er.er_dispansary_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_dispansary_mod','er_dispansary','Аптека : Модификация','mod','er.f_er_dispansary8mod');
--[t:er.er_dispansary:n]
create table er.er_dispansary (
                                  id bigint not null
    ,disp_id uuid not null
    ,disp_name text not null
    ,disp_addr text
    ,lat numeric
    ,long numeric
    ,is_allow boolean default true not null
    ,add_info jsonb
    ,constraint pk_er_dispansary PRIMARY KEY (id)
    ,constraint un_er_dispansary_name_addr UNIQUE (disp_name, disp_addr)

) with (OIDS=FALSE);
comment on table er.er_dispansary is 'Аптека';
comment on column er.er_dispansary.id is 'Id';
comment on column er.er_dispansary.disp_id is 'Идентификатор Аптеки';
comment on column er.er_dispansary.disp_name is 'Наименование Аптеки';
comment on column er.er_dispansary.disp_addr is 'Адрес Аптеки';
comment on column er.er_dispansary.lat is 'Широта';
comment on column er.er_dispansary.long is 'Долгота';
comment on column er.er_dispansary.is_allow is 'Действующая аптека (0 - нет, 1 - да)';
comment on column er.er_dispansary.add_info is 'Дополнительная информация';
alter table er.er_dispansary owner to dev;
--[v:er.v_er_dispansary:n]
create or replace view er.v_er_dispansary as
SELECT t.id,
       t.disp_id,
       t.disp_name,
       t.disp_addr,
       t.lat,
       t.long,
       t.is_allow,
       t.add_info
FROM er.er_dispansary t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_dispansary'::text));
--[f:er.f_er_dispansary8add:n]
CREATE OR REPLACE FUNCTION er.f_er_dispansary8add(pn_lpu bigint, pu_disp_id uuid, ps_disp_name text, ps_disp_addr text, pn_lat numeric, pn_long numeric, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_dispansary_add',null);
    begin
        insert into er.er_dispansary
        (
            id,
            disp_id,
            disp_name,
            disp_addr,
            lat,
            long,
            is_allow,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pu_disp_id,
            ps_disp_name,
            ps_disp_addr,
            pn_lat,
            pn_long,
            pb_is_allow,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_dispansary_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_dispansary8del:n]
CREATE OR REPLACE FUNCTION er.f_er_dispansary8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_dispansary_del',pn_id);
    begin
        delete from er.er_dispansary t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_dispansary'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_dispansary_del',pn_id);
end;
$function$
;
--[f:er.f_er_dispansary8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_dispansary8mod(pn_id bigint, pn_lpu bigint, pu_disp_id uuid, ps_disp_name text, ps_disp_addr text, pn_lat numeric, pn_long numeric, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_dispansary8add(pn_lpu := pn_lpu,
                                       pu_disp_id := pu_disp_id,
                                       ps_disp_name := ps_disp_name,
                                       ps_disp_addr := ps_disp_addr,
                                       pn_lat := pn_lat,
                                       pn_long := pn_long,
                                       pb_is_allow := pb_is_allow,
                                       pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_dispansary8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                       pu_disp_id := pu_disp_id,
                                       ps_disp_name := ps_disp_name,
                                       ps_disp_addr := ps_disp_addr,
                                       pn_lat := pn_lat,
                                       pn_long := pn_long,
                                       pb_is_allow := pb_is_allow,
                                       pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_dispansary8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_dispansary8upd(pn_id bigint, pn_lpu bigint, pu_disp_id uuid, ps_disp_name text, ps_disp_addr text, pn_lat numeric, pn_long numeric, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_dispansary_upd',pn_id);
    begin
        update er.er_dispansary t set
                                      disp_id = pu_disp_id,
                                      disp_name = ps_disp_name,
                                      disp_addr = ps_disp_addr,
                                      lat = pn_lat,
                                      long = pn_long,
                                      is_allow = pb_is_allow,
                                      add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_dispansary'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_dispansary_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_dispansary_a:n]
CREATE TRIGGER tr_er_dispansary_a AFTER INSERT OR DELETE OR UPDATE ON er.er_dispansary FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_drug:a]
--[u:er.er_drug:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_drug','Медикамент','er_drug',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Медикамент','er');
--[b:er.er_drug_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_drug_upd','er_drug','Медикамент : Исправление','upd','er.f_er_drug8upd');
--[b:er.er_drug_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_drug_add','er_drug','Медикамент : Добавление','add','er.f_er_drug8add');
--[b:er.er_drug_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_drug_del','er_drug','Медикамент : Удаление','del','er.f_er_drug8del');
--[b:er.er_drug_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_drug_mod','er_drug','Медикамент : Модификация','mod','er.f_er_drug8mod');
--[t:er.er_drug:n]
create table er.er_drug (
                            id bigint not null
    ,drug_id uuid not null
    ,drug_name text not null
    ,medform text not null
    ,dose numeric not null
    ,dose_mease text not null
    ,pack_numb text not null
    ,is_allow boolean default true not null
    ,add_info jsonb
    ,constraint pk_er_drug PRIMARY KEY (id)
    ,constraint uk_er_drug_medform_dose_dose_mease_pack_numb UNIQUE (medform, dose, dose_mease, pack_numb)

) with (OIDS=FALSE);
comment on table er.er_drug is 'Медикамент';
comment on column er.er_drug.id is 'Id';
comment on column er.er_drug.drug_id is 'Идентификатор медикамент';
comment on column er.er_drug.drug_name is 'Наименование медикамента';
comment on column er.er_drug.medform is 'Форма выпуска';
comment on column er.er_drug.dose is 'Дозировка медикамента';
comment on column er.er_drug.dose_mease is 'Единица измерения дозы';
comment on column er.er_drug.pack_numb is 'Количество препарата в упаковке';
comment on column er.er_drug.is_allow is 'Действующий препарат (0 - нет, 1 - да)';
comment on column er.er_drug.add_info is 'Дополнительная информация';
alter table er.er_drug owner to dev;
--[v:er.v_er_drug:n]
create or replace view er.v_er_drug as
SELECT t.id,
       t.drug_id,
       t.drug_name,
       t.medform,
       t.dose,
       t.dose_mease,
       t.pack_numb,
       t.is_allow,
       t.add_info
FROM er.er_drug t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_drug'::text));
--[f:er.f_er_drug8add:n]
CREATE OR REPLACE FUNCTION er.f_er_drug8add(pn_lpu bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_drug_add',null);
    begin
        insert into er.er_drug
        (
            id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_drug_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_drug8del:n]
CREATE OR REPLACE FUNCTION er.f_er_drug8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_drug_del',pn_id);
    begin
        delete from er.er_drug t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_drug_del',pn_id);
end;
$function$
;
--[f:er.f_er_drug8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_drug8mod(pn_id bigint, pn_lpu bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_drug8add(pn_lpu := pn_lpu,
                                 pu_drug_id := pu_drug_id,
                                 ps_drug_name := ps_drug_name,
                                 ps_medform := ps_medform,
                                 pn_dose := pn_dose,
                                 ps_dose_mease := ps_dose_mease,
                                 ps_pack_numb := ps_pack_numb,
                                 pb_is_allow := pb_is_allow,
                                 pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_drug8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                 pu_drug_id := pu_drug_id,
                                 ps_drug_name := ps_drug_name,
                                 ps_medform := ps_medform,
                                 pn_dose := pn_dose,
                                 ps_dose_mease := ps_dose_mease,
                                 ps_pack_numb := ps_pack_numb,
                                 pb_is_allow := pb_is_allow,
                                 pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_drug8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_drug8upd(pn_id bigint, pn_lpu bigint, pu_drug_id uuid, ps_drug_name text, ps_medform text, pn_dose numeric, ps_dose_mease text, ps_pack_numb text, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_drug_upd',pn_id);
    begin
        update er.er_drug t set
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
    perform core.f_bp_after(pn_lpu,null,null,'er_drug_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_drug_a:n]
CREATE TRIGGER tr_er_drug_a AFTER INSERT OR DELETE OR UPDATE ON er.er_drug FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_elements:a]
--[u:er.er_elements:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_elements','Тип события','er_elements',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,NULL,'er');
--[b:er.er_elements_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_elements_add','er_elements','Тип события : Добавление','add','er.f_er_elements8add');
--[b:er.er_elements_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_elements_upd','er_elements','Тип события : Исправление','upd','er.f_er_elements8upd');
--[b:er.er_elements_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_elements_del','er_elements','Тип события : Удаление','del','er.f_er_elements8del');
--[b:er.er_elements_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_elements_mod','er_elements','Тип события : Модификация','mod','er.f_er_elements8mod');
--[t:er.er_elements:n]
create table er.er_elements (
                                id bigint not null
    ,event_type_uid uuid not null
    ,element text not null
    ,element_table text not null
    ,title text
    ,description text
    ,person text
    ,date_create text
    ,constraint pk_er_elements PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_elements is 'Тип события';
comment on column er.er_elements.id is 'Id';
comment on column er.er_elements.event_type_uid is 'Идентификатор типа Элемента';
comment on column er.er_elements.element is 'Код Элемента';
comment on column er.er_elements.element_table is 'Таблица соответствующая Элементу';
comment on column er.er_elements.title is 'Поля элемента, которые являются заголовком';
comment on column er.er_elements.description is 'Поля элемента, которые являются Описание';
comment on column er.er_elements.person is 'Поле элемента, которое является идентификатором события';
comment on column er.er_elements.date_create is 'Поле элемента, которое является точкой отсчета';
alter table er.er_elements owner to dev;
--[v:er.v_er_elements:n]
create or replace view er.v_er_elements as
SELECT t.id,
       t.event_type_uid,
       t.element,
       t.element_table,
       t.title,
       t.description,
       t.person,
       t.date_create
FROM er.er_elements t
WHERE (EXISTS ( SELECT NULL::text AS text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_elements'::text));
--[f:er.f_er_elements8add:n]
CREATE OR REPLACE FUNCTION er.f_er_elements8add(pn_lpu bigint, pu_event_type_uid uuid, ps_element text, ps_element_table text, ps_title text, ps_description text, ps_person text, ps_date_create text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_elements_add',null);
    begin
        insert into er.er_elements
        (
            id,
            event_type_uid,
            element,
            element_table,
            title,
            description,
            person,
            date_create
        )
        values
        (
            core.f_gen_id(),
            pu_event_type_uid,
            ps_element,
            ps_element_table,
            ps_title,
            ps_description,
            ps_person,
            ps_date_create
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_elements_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_elements8del:n]
CREATE OR REPLACE FUNCTION er.f_er_elements8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_elements_del',pn_id);
    begin
        delete from er.er_elements t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_elements'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_elements_del',pn_id);
end;
$function$
;
--[f:er.f_er_elements8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_elements8mod(pn_id bigint, pn_lpu bigint, pu_event_type_uid uuid, ps_element text, ps_element_table text, ps_title text, ps_description text, ps_person text, ps_date_create text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_elements8add(pn_lpu := pn_lpu,
                                     pu_event_type_uid := pu_event_type_uid,
                                     ps_element := ps_element,
                                     ps_element_table := ps_element_table,
                                     ps_title := ps_title,
                                     ps_description := ps_description,
                                     ps_person := ps_person,
                                     ps_date_create := ps_date_create);
        return n_id;
    else
        perform er.f_er_elements8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                     pu_event_type_uid := pu_event_type_uid,
                                     ps_element := ps_element,
                                     ps_element_table := ps_element_table,
                                     ps_title := ps_title,
                                     ps_description := ps_description,
                                     ps_person := ps_person,
                                     ps_date_create := ps_date_create);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_elements8show_element:n]
CREATE OR REPLACE FUNCTION er.f_er_elements8show_element(pn_id bigint, pn_element_id bigint, ps_field text)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    s_element_table 	         text;
    s_title	         text;
    s_description            text;
    s_person				 text;
    s_date_create			 text;
    s_sql				     text;
    s_ret_value            text;
begin
    /* pn_id - id из таблицы er_elements
     * pn_element_id - id из таблицы er_events из поля element_id
     * ps_field - функция ожидает название поля, значение которого необходимо вернуть:
     * - title
     * - description
     * - date_create */
    begin
        select btrim(t.element_table) as element_table,
               btrim(t.title) as title,
               btrim(t.description) as description,
               btrim(t.person) as person,
               btrim(t.date_create) as date_create
        into s_element_table, s_title, s_description, s_person, s_date_create
        from er.er_elements t
        where t.id = pn_id;
    exception when no_data_found then perform core.f_exc('Запись с id '||pn_id||' не найдена.');
    end;

    if ps_field = 'title' then
        s_sql := 'select ('||s_title|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    elseif ps_field = 'description' then
        s_sql := 'select ('||s_description|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    elseif ps_field = 'date_create' then
        s_sql := 'select ('||s_date_create|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    end if;

    if s_sql is null then return null;
    else
        begin
            execute s_sql using pn_element_id into strict s_ret_value;
        end;
        return s_ret_value;
    end if;
end;
$function$
;
--[f:er.f_er_elements8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_elements8upd(pn_id bigint, pn_lpu bigint, pu_event_type_uid uuid, ps_element text, ps_element_table text, ps_title text, ps_description text, ps_person text, ps_date_create text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_elements_upd',pn_id);
    begin
        update er.er_elements t set
                                    event_type_uid = pu_event_type_uid,
                                    element = ps_element,
                                    element_table = ps_element_table,
                                    title = ps_title,
                                    description = ps_description,
                                    person = ps_person,
                                    date_create = ps_date_create
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_elements'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_elements_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_elements_a:n]
CREATE TRIGGER tr_er_elements_a AFTER INSERT OR DELETE OR UPDATE ON er.er_elements FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_events:a]
--[u:er.er_events:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_events','События','er_events',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'События','er');
--[b:er.er_events_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_events_add','er_events','События : Добавление','add','er.f_er_events8add');
--[b:er.er_events_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_events_upd','er_events','События : Исправление','upd','er.f_er_events8upd');
--[b:er.er_events_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_events_del','er_events','События : Удаление','del','er.f_er_events8del');
--[b:er.er_events_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_events_mod','er_events','События : Модификация','mod','er.f_er_events8mod');
--[t:er.er_events:n]
create table er.er_events (
                              id bigint not null
    ,event_uid uuid not null
    ,person_id bigint not null
    ,state bigint not null
    ,element bigint not null
    ,element_id bigint not null
    ,create_date timestamp without time zone default CURRENT_DATE not null
    ,full_event_data jsonb
    ,ext_state text
    ,constraint fk_er_events_element FOREIGN KEY (element) REFERENCES er.er_elements(id)
    ,constraint fk_er_events_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_events_state FOREIGN KEY (state) REFERENCES er.er_event_states(id)
    ,constraint pk_er_events PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_events is 'События';
comment on column er.er_events.id is 'Id';
comment on column er.er_events.event_uid is 'Идентификатор события';
comment on column er.er_events.person_id is 'Идентификатор пользователя';
comment on column er.er_events.state is 'Состояние события';
comment on column er.er_events.element is 'Раздел';
comment on column er.er_events.element_id is 'Идентификатор раздела';
comment on column er.er_events.create_date is 'Дата создания';
comment on column er.er_events.full_event_data is 'Данные события';
comment on column er.er_events.ext_state is 'Расширенное описание события';
CREATE INDEX i_er_events_element ON er.er_events USING btree (element);
CREATE INDEX i_er_events_person_id ON er.er_events USING btree (person_id);
CREATE INDEX i_er_events_state ON er.er_events USING btree (state);
alter table er.er_events owner to dev;
--[v:er.v_er_events:n]
create or replace view er.v_er_events as
SELECT t.id,
       t.event_uid,
       t.person_id,
       t.state,
       t1.code AS state_code,
       t.element,
       t.element_id,
       t.create_date,
       t.full_event_data,
       t.ext_state
FROM er.er_events t
         JOIN er.er_event_states t1 ON t.state = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_events'::text));
--[f:er.f_er_events8add:n]
CREATE OR REPLACE FUNCTION er.f_er_events8add(pn_lpu bigint, pu_event_uid uuid, pn_person_id bigint, pn_state bigint, pn_element bigint, pn_element_id bigint, pd_create_date timestamp without time zone, pu_full_event_data jsonb, ps_ext_state text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_events_add',null);
    begin
        insert into er.er_events
        (
            id,
            event_uid,
            person_id,
            state,
            element,
            element_id,
            create_date,
            full_event_data,
            ext_state
        )
        values
        (
            core.f_gen_id(),
            pu_event_uid,
            pn_person_id,
            pn_state,
            pn_element,
            pn_element_id,
            pd_create_date,
            pu_full_event_data,
            ps_ext_state
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_events_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_events8del:n]
CREATE OR REPLACE FUNCTION er.f_er_events8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_events_del',pn_id);
    begin
        delete from er.er_events t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_events'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_events_del',pn_id);
end;
$function$
;
--[f:er.f_er_events8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_events8mod(pn_id bigint, pn_lpu bigint, pu_event_uid uuid, pn_person_id bigint, pn_state bigint, pn_element bigint, pn_element_id bigint, pd_create_date timestamp without time zone, pu_full_event_data jsonb, ps_ext_state text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_events8add(pn_lpu := pn_lpu,
                                   pu_event_uid := pu_event_uid,
                                   pn_person_id := pn_person_id,
                                   pn_state := pn_state,
                                   pn_element := pn_element,
                                   pn_element_id := pn_element_id,
                                   pd_create_date := pd_create_date,
                                   pu_full_event_data := pu_full_event_data,
                                   ps_ext_state := ps_ext_state);
        return n_id;
    else
        perform er.f_er_events8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                   pu_event_uid := pu_event_uid,
                                   pn_person_id := pn_person_id,
                                   pn_state := pn_state,
                                   pn_element := pn_element,
                                   pn_element_id := pn_element_id,
                                   pd_create_date := pd_create_date,
                                   pu_full_event_data := pu_full_event_data,
                                   ps_ext_state := ps_ext_state);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_events8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_events8upd(pn_id bigint, pn_lpu bigint, pu_event_uid uuid, pn_person_id bigint, pn_state bigint, pn_element bigint, pn_element_id bigint, pd_create_date timestamp without time zone, pu_full_event_data jsonb, ps_ext_state text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_events_upd',pn_id);
    begin
        update er.er_events t set
                                  event_uid = pu_event_uid,
                                  person_id = pn_person_id,
                                  state = pn_state,
                                  element = pn_element,
                                  element_id = pn_element_id,
                                  create_date = pd_create_date,
                                  full_event_data = pu_full_event_data,
                                  ext_state = ps_ext_state
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_events'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_events_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_events_a:n]
CREATE TRIGGER tr_er_events_a AFTER INSERT OR DELETE OR UPDATE ON er.er_events FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_event_states:a]
--[u:er.er_event_states:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_event_states','Состояние события','er_event_states',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Состояние события','er');
--[b:er.er_event_states_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_event_states_add','er_event_states','Состояние события : Добавление','add','er.f_er_event_states8add');
--[b:er.er_event_states_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_event_states_upd','er_event_states','Состояние события : Исправление','upd','er.f_er_event_states8upd');
--[b:er.er_event_states_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_event_states_del','er_event_states','Состояние события : Удаление','del','er.f_er_event_states8del');
--[b:er.er_event_states_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_event_states_mod','er_event_states','Состояние события : Модификация','mod','er.f_er_event_states8mod');
--[t:er.er_event_states:n]
create table er.er_event_states (
                                    id bigint not null
    ,code text not null
    ,name text not null
    ,description text
    ,constraint ch_er_event_states_co CHECK (code = btrim(code))
    ,constraint pk_er_event_states PRIMARY KEY (id)
    ,constraint uk_er_event_states_code_name UNIQUE (code, name)

) with (OIDS=FALSE);
comment on table er.er_event_states is 'Состояние события';
comment on column er.er_event_states.id is 'Id';
comment on column er.er_event_states.code is 'Код состояния';
comment on column er.er_event_states.name is 'Наименование состояния';
comment on column er.er_event_states.description is 'Описание состояния';
comment on constraint ch_er_event_states_co on er.er_event_states is 'Поле [Код состояния] раздела [Состояние события] не должно содержать незначащие пробелы';
alter table er.er_event_states owner to dev;
--[v:er.v_er_event_states:n]
create or replace view er.v_er_event_states as
SELECT t.id,
       t.code,
       t.name,
       t.description
FROM er.er_event_states t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_event_states'::text));
--[f:er.f_er_event_states8add:n]
CREATE OR REPLACE FUNCTION er.f_er_event_states8add(pn_lpu bigint, ps_code text, ps_name text, ps_description text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_event_states_add',null);
    begin
        insert into er.er_event_states
        (
            id,
            code,
            name,
            description
        )
        values
        (
            core.f_gen_id(),
            ps_code,
            ps_name,
            ps_description
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_event_states_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_event_states8del:n]
CREATE OR REPLACE FUNCTION er.f_er_event_states8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_event_states_del',pn_id);
    begin
        delete from er.er_event_states t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_event_states'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_event_states_del',pn_id);
end;
$function$
;
--[f:er.f_er_event_states8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_event_states8mod(pn_id bigint, pn_lpu bigint, ps_code text, ps_name text, ps_description text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_event_states8add(pn_lpu := pn_lpu,
                                         ps_code := ps_code,
                                         ps_name := ps_name,
                                         ps_description := ps_description);
        return n_id;
    else
        perform er.f_er_event_states8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                         ps_code := ps_code,
                                         ps_name := ps_name,
                                         ps_description := ps_description);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_event_states8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_event_states8upd(pn_id bigint, pn_lpu bigint, ps_code text, ps_name text, ps_description text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_event_states_upd',pn_id);
    begin
        update er.er_event_states t set
                                        code = ps_code,
                                        name = ps_name,
                                        description = ps_description
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_event_states'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_event_states_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_event_states_a:n]
CREATE TRIGGER tr_er_event_states_a AFTER INSERT OR DELETE OR UPDATE ON er.er_event_states FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_mo:a]
--[u:er.er_mo:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_mo','Учреждения','er_mo',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','1'::numeric,'0'::numeric,'Учреждения','er');
--[b:er.er_mo_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_mo_add','er_mo','Учреждения : Добавление','add','er.f_er_mo8add');
--[b:er.er_mo_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_mo_upd','er_mo','Учреждения : Исправление','upd','er.f_er_mo8upd');
--[b:er.er_mo_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_mo_del','er_mo','Учреждения : Удаление','del','er.f_er_mo8del');
--[b:er.er_mo_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_mo_mod','er_mo','Учреждения : Модификация','mod','er.f_er_mo8mod');
--[t:er.er_mo:n]
create table er.er_mo (
                          id bigint not null
    ,hid bigint
    ,mo_uid uuid not null
    ,code_mo text not null
    ,mo_name text not null
    ,full_name text
    ,address text
    ,lat text
    ,long text
    ,without_reg boolean default true not null
    ,for_kids boolean default false not null
    ,record_period integer default 14
    ,allow_home_call boolean default false not null
    ,add_info jsonb
    ,constraint ch_er_mo_hid CHECK (hid IS DISTINCT FROM id)
    ,constraint fk_er_mo_hid FOREIGN KEY (hid) REFERENCES er.er_mo(id)
    ,constraint pk_er_mo PRIMARY KEY (id)
    ,constraint uk_er_mo_uid_code_name UNIQUE (mo_uid, code_mo, mo_name)

) with (OIDS=FALSE);
comment on table er.er_mo is 'Учреждения';
comment on column er.er_mo.id is 'Id';
comment on column er.er_mo.hid is 'Иерархия';
comment on column er.er_mo.mo_uid is 'Идентификатор учреждения';
comment on column er.er_mo.code_mo is 'Региональный код учреждения';
comment on column er.er_mo.mo_name is 'Краткое наименование учреждения';
comment on column er.er_mo.full_name is 'Полное наименование учреждения';
comment on column er.er_mo.address is 'Адрес учреждения';
comment on column er.er_mo.lat is 'Координаты:Широта';
comment on column er.er_mo.long is 'Координаты:Долгота';
comment on column er.er_mo.without_reg is 'Признак запрета запись неприкрепленному населению (0 - запрещена, 1 - разрешена)';
comment on column er.er_mo.for_kids is 'Признак запрета записи совершеннолетнему лицу (0 – разрешена запись лицам, старше 18 лет;1 – запрещена запись лицам, старше 18 лет)';
comment on column er.er_mo.record_period is 'Период доступности записи на прием в учреждение в днях';
comment on column er.er_mo.allow_home_call is 'Вызов врача на дом (0 - недоступен, 1 - доступен)';
comment on column er.er_mo.add_info is 'Детальная информация об учреждении';
comment on constraint ch_er_mo_hid on er.er_mo is 'Запись не должна ссылаться сама на себя';
CREATE INDEX i_er_mo_hid ON er.er_mo USING btree (hid);
alter table er.er_mo owner to dev;
--[v:er.v_er_mo:n]
create or replace view er.v_er_mo as
SELECT t.id,
       t.hid,
       t.mo_uid,
       t.code_mo,
       t.mo_name,
       t.full_name,
       t.address,
       t.lat,
       t.long,
       t.without_reg,
       t.for_kids,
       t.record_period,
       t.allow_home_call,
       t.add_info,
       COALESCE(( SELECT 1
                  FROM er.er_mo h
                  WHERE h.hid = t.id
                  LIMIT 1), 0) AS haschildren
FROM er.er_mo t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_mo'::text));
--[f:er.f_er_mo8add:n]
CREATE OR REPLACE FUNCTION er.f_er_mo8add(pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_mo_add',null);
    begin
        insert into er.er_mo
        (
            id,
            hid,
            mo_uid,
            code_mo,
            mo_name,
            full_name,
            address,
            lat,
            long,
            without_reg,
            for_kids,
            record_period,
            allow_home_call,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_hid,
            pu_mo_uid,
            ps_code_mo,
            ps_mo_name,
            ps_full_name,
            ps_address,
            ps_lat,
            ps_long,
            pb_without_reg,
            pb_for_kids,
            pn_record_period,
            pb_allow_home_call,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_mo_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_mo8del:n]
CREATE OR REPLACE FUNCTION er.f_er_mo8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_mo_del',pn_id);
    begin
        delete from er.er_mo t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_mo'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_mo_del',pn_id);
end;
$function$
;
--[f:er.f_er_mo8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_mo8mod(pn_id bigint, pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_mo8add(pn_lpu := pn_lpu,
                               pn_hid := pn_hid,
                               pu_mo_uid := pu_mo_uid,
                               ps_code_mo := ps_code_mo,
                               ps_mo_name := ps_mo_name,
                               ps_full_name := ps_full_name,
                               ps_address := ps_address,
                               ps_lat := ps_lat,
                               ps_long := ps_long,
                               pb_without_reg := pb_without_reg,
                               pb_for_kids := pb_for_kids,
                               pn_record_period := pn_record_period,
                               pb_allow_home_call := pb_allow_home_call,
                               pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_mo8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                               pn_hid := pn_hid,
                               pu_mo_uid := pu_mo_uid,
                               ps_code_mo := ps_code_mo,
                               ps_mo_name := ps_mo_name,
                               ps_full_name := ps_full_name,
                               ps_address := ps_address,
                               ps_lat := ps_lat,
                               ps_long := ps_long,
                               pb_without_reg := pb_without_reg,
                               pb_for_kids := pb_for_kids,
                               pn_record_period := pn_record_period,
                               pb_allow_home_call := pb_allow_home_call,
                               pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_mo8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_mo8upd(pn_id bigint, pn_lpu bigint, pn_hid bigint, pu_mo_uid uuid, ps_code_mo text, ps_mo_name text, ps_full_name text, ps_address text, ps_lat text, ps_long text, pb_without_reg boolean, pb_for_kids boolean, pn_record_period integer, pb_allow_home_call boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_mo_upd',pn_id);
    begin
        update er.er_mo t set
                              hid = pn_hid,
                              mo_uid = pu_mo_uid,
                              code_mo = ps_code_mo,
                              mo_name = ps_mo_name,
                              full_name = ps_full_name,
                              address = ps_address,
                              lat = ps_lat,
                              long = ps_long,
                              without_reg = pb_without_reg,
                              for_kids = pb_for_kids,
                              record_period = pn_record_period,
                              allow_home_call = pb_allow_home_call,
                              add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_mo'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_mo_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_mo_a:n]
CREATE TRIGGER tr_er_mo_a AFTER INSERT OR DELETE OR UPDATE ON er.er_mo FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_anthropometry:a]
--[u:er.er_person_anthropometry:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_anthropometry','Пользователь: Антропометрия','er_person_anthropometry',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: Антропометрия','er');
--[b:er.er_person_anthropometry_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_add','er_person_anthropometry','Пользователь: Антропометрия : Добавление','add','er.f_er_person_anthropometry8add');
--[b:er.er_person_anthropometry_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_upd','er_person_anthropometry','Пользователь: Антропометрия : Исправление','upd','er.f_er_person_anthropometry8upd');
--[b:er.er_person_anthropometry_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_del','er_person_anthropometry','Пользователь: Антропометрия : Удаление','del','er.f_er_person_anthropometry8del');
--[b:er.er_person_anthropometry_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_mod','er_person_anthropometry','Пользователь: Антропометрия : Модификация','mod','er.f_er_person_anthropometry8mod');
--[t:er.er_person_anthropometry:n]
create table er.er_person_anthropometry (
                                            id bigint not null
    ,anthop_id uuid not null
    ,meas_date date not null
    ,constitution text
    ,person_id bigint not null
    ,constraint fk_er_person_anthropometry_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint pk_er_person_anthropometry PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_anthropometry is 'Пользователь: Антропометрия';
comment on column er.er_person_anthropometry.id is 'Id';
comment on column er.er_person_anthropometry.anthop_id is 'Идентификатор Антропометрии';
comment on column er.er_person_anthropometry.meas_date is 'Дата измерения';
comment on column er.er_person_anthropometry.constitution is 'Телосложение';
comment on column er.er_person_anthropometry.person_id is 'Идентификатор пользователя';
CREATE INDEX i_er_person_anthropometry_person_id ON er.er_person_anthropometry USING btree (person_id);
alter table er.er_person_anthropometry owner to dev;
--[v:er.v_er_person_anthropometry:n]
create or replace view er.v_er_person_anthropometry as
SELECT t.id,
       t.anthop_id,
       t.meas_date,
       t.constitution,
       t.person_id
FROM er.er_person_anthropometry t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_anthropometry'::text));
--[f:er.f_er_person_anthropometry8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry8add(pn_lpu bigint, pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_add',null);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_anthropometry8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_del',pn_id);
    begin
        delete from er.er_person_anthropometry t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_anthropometry'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_anthropometry8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry8mod(pn_id bigint, pn_lpu bigint, pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_anthropometry8add(pn_lpu := pn_lpu,
                                                 pu_anthop_id := pu_anthop_id,
                                                 pd_meas_date := pd_meas_date,
                                                 ps_constitution := ps_constitution,
                                                 pn_person_id := pn_person_id);
        return n_id;
    else
        perform er.f_er_person_anthropometry8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                                 pu_anthop_id := pu_anthop_id,
                                                 pd_meas_date := pd_meas_date,
                                                 ps_constitution := ps_constitution,
                                                 pn_person_id := pn_person_id);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_anthropometry8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry8upd(pn_id bigint, pn_lpu bigint, pu_anthop_id uuid, pd_meas_date date, ps_constitution text, pn_person_id bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_upd',pn_id);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_anthropometry_a:n]
CREATE TRIGGER tr_er_person_anthropometry_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_anthropometry FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_anthropometry_sp:a]
--[u:er.er_person_anthropometry_sp:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_anthropometry_sp','Пользователь: Антропометрия: Спецификация','er_person_anthropometry_sp','er_person_anthropometry','0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: Антропометрия: Спецификация','er');
--[b:er.er_person_anthropometry_sp_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_sp_add','er_person_anthropometry_sp','Пользователь: Антропометрия: Спецификация : Добавление','add','er.f_er_person_anthropometry_sp8add');
--[b:er.er_person_anthropometry_sp_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_sp_upd','er_person_anthropometry_sp','Пользователь: Антропометрия: Спецификация : Исправление','upd','er.f_er_person_anthropometry_sp8upd');
--[b:er.er_person_anthropometry_sp_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_sp_del','er_person_anthropometry_sp','Пользователь: Антропометрия: Спецификация : Удаление','del','er.f_er_person_anthropometry_sp8del');
--[b:er.er_person_anthropometry_sp_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_anthropometry_sp_mod','er_person_anthropometry_sp','Пользователь: Антропометрия: Спецификация : Модификация','mod','er.f_er_person_anthropometry_sp8mod');
--[t:er.er_person_anthropometry_sp:n]
create table er.er_person_anthropometry_sp (
                                               id bigint not null
    ,pid bigint not null
    ,anthrop_sp_id uuid not null
    ,anthrop text not null
    ,a_value numeric not null
    ,meas_name text not null
    ,constraint fk_er_person_anthropometry_sp_pid FOREIGN KEY (pid) REFERENCES er.er_person_anthropometry(id)
    ,constraint pk_er_person_anthropometry_sp PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_anthropometry_sp is 'Пользователь: Антропометрия: Спецификация';
comment on column er.er_person_anthropometry_sp.id is 'Id';
comment on column er.er_person_anthropometry_sp.pid is 'Пользователь: Антропометрия';
comment on column er.er_person_anthropometry_sp.anthrop_sp_id is 'Идентификатор спецификации';
comment on column er.er_person_anthropometry_sp.anthrop is 'Параметр физического развития';
comment on column er.er_person_anthropometry_sp.a_value is 'Значение';
comment on column er.er_person_anthropometry_sp.meas_name is 'Единица измерения';
CREATE INDEX i_er_person_anthropometry_sp_pid ON er.er_person_anthropometry_sp USING btree (pid);
alter table er.er_person_anthropometry_sp owner to dev;
--[v:er.v_er_person_anthropometry_sp:n]
create or replace view er.v_er_person_anthropometry_sp as
SELECT t.id,
       t.pid,
       t.anthrop_sp_id,
       t.anthrop,
       t.a_value,
       t.meas_name
FROM er.er_person_anthropometry_sp t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_anthropometry_sp'::text));
--[f:er.f_er_person_anthropometry_sp8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry_sp8add(pn_lpu bigint, pn_pid bigint, pu_anthrop_sp_id uuid, ps_anthrop text, pn_a_value numeric, ps_meas_name text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_sp_add',null);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_sp_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_anthropometry_sp8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry_sp8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_sp_del',pn_id);
    begin
        delete from er.er_person_anthropometry_sp t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_anthropometry_sp'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_sp_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_anthropometry_sp8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry_sp8mod(pn_id bigint, pn_lpu bigint, pn_pid bigint, pu_anthrop_sp_id uuid, ps_anthrop text, pn_a_value numeric, ps_meas_name text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_anthropometry_sp8add(pn_lpu := pn_lpu,
                                                    pn_pid := pn_pid,
                                                    pu_anthrop_sp_id := pu_anthrop_sp_id,
                                                    ps_anthrop := ps_anthrop,
                                                    pn_a_value := pn_a_value,
                                                    ps_meas_name := ps_meas_name);
        return n_id;
    else
        perform er.f_er_person_anthropometry_sp8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                                    pu_anthrop_sp_id := pu_anthrop_sp_id,
                                                    ps_anthrop := ps_anthrop,
                                                    pn_a_value := pn_a_value,
                                                    ps_meas_name := ps_meas_name);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_anthropometry_sp8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_anthropometry_sp8upd(pn_id bigint, pn_lpu bigint, pu_anthrop_sp_id uuid, ps_anthrop text, pn_a_value numeric, ps_meas_name text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_anthropometry_sp_upd',pn_id);
    begin
        update er.er_person_anthropometry_sp t set
                                                   anthrop_sp_id = pu_anthrop_sp_id,
                                                   anthrop = ps_anthrop,
                                                   a_value = pn_a_value,
                                                   meas_name = ps_meas_name
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_anthropometry_sp'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_anthropometry_sp_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_anthropometry_sp_a:n]
CREATE TRIGGER tr_er_person_anthropometry_sp_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_anthropometry_sp FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_bulletin:a]
--[u:er.er_person_bulletin:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_bulletin','Пользователь: Листки нетрудоспособности','er_person_bulletin',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: Листки нетрудоспособности','er');
--[b:er.er_person_bulletin_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_bulletin_add','er_person_bulletin','Пользователь: Листки нетрудоспособности : Добавление','add','er.f_er_person_bulletin8add');
--[b:er.er_person_bulletin_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_bulletin_upd','er_person_bulletin','Пользователь: Листки нетрудоспособности : Исправление','upd','er.f_er_person_bulletin8upd');
--[b:er.er_person_bulletin_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_bulletin_del','er_person_bulletin','Пользователь: Листки нетрудоспособности : Удаление','del','er.f_er_person_bulletin8del');
--[b:er.er_person_bulletin_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_bulletin_mod','er_person_bulletin','Пользователь: Листки нетрудоспособности : Модификация','mod','er.f_er_person_bulletin8mod');
--[t:er.er_person_bulletin:n]
create table er.er_person_bulletin (
                                       id bigint not null
    ,bull_id uuid not null
    ,person_id bigint not null
    ,mo_id bigint not null
    ,bul_number text not null
    ,type integer default 2 not null
    ,kind integer default 0 not null
    ,date_begin date
    ,emp_fio text
    ,date_free_begin date not null
    ,date_fee_end date
    ,visit_id bigint
    ,add_info jsonb
    ,constraint fk_er_person_bulletin_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_person_bulletin_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_person_bulletin_visit_id FOREIGN KEY (visit_id) REFERENCES er.er_person_visit(id)
    ,constraint pk_er_person_bulletin PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_bulletin is 'Пользователь: Листки нетрудоспособности';
comment on column er.er_person_bulletin.id is 'Id';
comment on column er.er_person_bulletin.bull_id is 'Идентификатор ЛН';
comment on column er.er_person_bulletin.person_id is 'Идентификатор пользователя';
comment on column er.er_person_bulletin.mo_id is 'Идентификатор учреждения';
comment on column er.er_person_bulletin.bul_number is 'Номер ЛН';
comment on column er.er_person_bulletin.type is 'Признак прикрепления (0 - по совмест.,1 - продолжение,2 - основной)';
comment on column er.er_person_bulletin.kind is 'Вид ЛН (0 - ЛН, 1 - ЭЛН)';
comment on column er.er_person_bulletin.date_begin is 'Дата выдачи ЛН';
comment on column er.er_person_bulletin.emp_fio is 'ФИО врача выдавшего ЛН';
comment on column er.er_person_bulletin.date_free_begin is 'Дата начала освобождения от работы';
comment on column er.er_person_bulletin.date_fee_end is 'Дата окончания освобождения от работы';
comment on column er.er_person_bulletin.visit_id is 'Идентификатор посещения, на котором выдан ЛН';
comment on column er.er_person_bulletin.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_bulletin_mo_id ON er.er_person_bulletin USING btree (mo_id);
CREATE INDEX i_er_person_bulletin_person_id ON er.er_person_bulletin USING btree (person_id);
CREATE INDEX i_er_person_bulletin_visit_id ON er.er_person_bulletin USING btree (visit_id);
alter table er.er_person_bulletin owner to dev;
--[v:er.v_er_person_bulletin:n]
create or replace view er.v_er_person_bulletin as
SELECT t.id,
       t.bull_id,
       t.person_id,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.bul_number,
       t.type,
       t.kind,
       t.date_begin,
       t.emp_fio,
       t.date_free_begin,
       t.date_fee_end,
       t.visit_id,
       t.add_info
FROM er.er_person_bulletin t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_bulletin'::text));
--[f:er.f_er_person_bulletin8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_bulletin8add(pn_lpu bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_add',null);
    begin
        insert into er.er_person_bulletin
        (
            id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_bulletin8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_bulletin8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_del',pn_id);
    begin
        delete from er.er_person_bulletin t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_bulletin'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_bulletin8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_bulletin8mod(pn_id bigint, pn_lpu bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_bulletin8add(pn_lpu := pn_lpu,
                                            pu_bull_id := pu_bull_id,
                                            pn_person_id := pn_person_id,
                                            pn_mo_id := pn_mo_id,
                                            ps_bul_number := ps_bul_number,
                                            pn_type := pn_type,
                                            pn_kind := pn_kind,
                                            pd_date_begin := pd_date_begin,
                                            ps_emp_fio := ps_emp_fio,
                                            pd_date_free_begin := pd_date_free_begin,
                                            pd_date_fee_end := pd_date_fee_end,
                                            pn_visit_id := pn_visit_id,
                                            pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_bulletin8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                            pu_bull_id := pu_bull_id,
                                            pn_person_id := pn_person_id,
                                            pn_mo_id := pn_mo_id,
                                            ps_bul_number := ps_bul_number,
                                            pn_type := pn_type,
                                            pn_kind := pn_kind,
                                            pd_date_begin := pd_date_begin,
                                            ps_emp_fio := ps_emp_fio,
                                            pd_date_free_begin := pd_date_free_begin,
                                            pd_date_fee_end := pd_date_fee_end,
                                            pn_visit_id := pn_visit_id,
                                            pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_bulletin8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_bulletin8upd(pn_id bigint, pn_lpu bigint, pu_bull_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_bul_number text, pn_type integer, pn_kind integer, pd_date_begin date, ps_emp_fio text, pd_date_free_begin date, pd_date_fee_end date, pn_visit_id bigint, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_bulletin_upd',pn_id);
    begin
        update er.er_person_bulletin t set
                                           bull_id = pu_bull_id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_bulletin_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_bulletin_a:n]
CREATE TRIGGER tr_er_person_bulletin_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_bulletin FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_polis:a]
--[u:er.er_person_polis:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_polis','Пользователь: полис','er_person_polis',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: полис','er');
--[b:er.er_person_polis_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_polis_add','er_person_polis','Пользователь: полис : Добавление','add','er.f_er_person_polis8add');
--[b:er.er_person_polis_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_polis_upd','er_person_polis','Пользователь: полис : Исправление','upd','er.f_er_person_polis8upd');
--[b:er.er_person_polis_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_polis_del','er_person_polis','Пользователь: полис : Удаление','del','er.f_er_person_polis8del');
--[b:er.er_person_polis_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_polis_mod','er_person_polis','Пользователь: полис : Модификация','mod','er.f_er_person_polis8mod');
--[t:er.er_person_polis:n]
create table er.er_person_polis (
                                    id bigint not null
    ,polis_id uuid not null
    ,person_id bigint not null
    ,type integer default 1 not null
    ,kind_id bigint not null
    ,pser text
    ,pnum text not null
    ,date_begin date not null
    ,date_end date
    ,add_info jsonb not null
    ,constraint fk_er_person_polis_kind_id FOREIGN KEY (kind_id) REFERENCES er.er_polis_kind(id)
    ,constraint fk_er_person_polis_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint pk_er_person_polis PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_polis is 'Пользователь: полис';
comment on column er.er_person_polis.id is 'Id';
comment on column er.er_person_polis.polis_id is 'Идентификатор полиса';
comment on column er.er_person_polis.person_id is 'Идентификатор пользователя';
comment on column er.er_person_polis.type is 'Тип полиса (1 - ОМС, 2 - ДМС)';
comment on column er.er_person_polis.kind_id is 'Вид полиса';
comment on column er.er_person_polis.pser is 'Серия полиса';
comment on column er.er_person_polis.pnum is 'Номер полиса';
comment on column er.er_person_polis.date_begin is 'Дата начала действия полиса';
comment on column er.er_person_polis.date_end is 'Дата окончания действия полиса';
comment on column er.er_person_polis.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_polis_kind_id ON er.er_person_polis USING btree (kind_id);
CREATE INDEX i_er_person_polis_person_id ON er.er_person_polis USING btree (person_id);
alter table er.er_person_polis owner to dev;
--[v:er.v_er_person_polis:n]
create or replace view er.v_er_person_polis as
SELECT t.id,
       t.polis_id,
       t.person_id,
       t.type,
       t.kind_id,
       t1.code AS kind_id_code,
       t.pser,
       t.pnum,
       t.date_begin,
       t.date_end,
       t.add_info
FROM er.er_person_polis t
         JOIN er.er_polis_kind t1 ON t.kind_id = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_polis'::text));
--[f:er.f_er_person_polis8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_polis8add(pn_lpu bigint, pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_add',null);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_polis8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_polis8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_del',pn_id);
    begin
        delete from er.er_person_polis t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_polis'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_polis8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_polis8mod(pn_id bigint, pn_lpu bigint, pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_polis8add(pn_lpu := pn_lpu,
                                         pu_polis_id := pu_polis_id,
                                         pn_person_id := pn_person_id,
                                         pn_type := pn_type,
                                         pn_kind_id := pn_kind_id,
                                         ps_pser := ps_pser,
                                         ps_pnum := ps_pnum,
                                         pd_date_begin := pd_date_begin,
                                         pd_date_end := pd_date_end,
                                         pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_polis8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                         pu_polis_id := pu_polis_id,
                                         pn_person_id := pn_person_id,
                                         pn_type := pn_type,
                                         pn_kind_id := pn_kind_id,
                                         ps_pser := ps_pser,
                                         ps_pnum := ps_pnum,
                                         pd_date_begin := pd_date_begin,
                                         pd_date_end := pd_date_end,
                                         pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_polis8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_polis8upd(pn_id bigint, pn_lpu bigint, pu_polis_id uuid, pn_person_id bigint, pn_type integer, pn_kind_id bigint, ps_pser text, ps_pnum text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_polis_upd',pn_id);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_polis_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_polis_a:n]
CREATE TRIGGER tr_er_person_polis_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_polis FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_recipe:a]
--[u:er.er_person_recipe:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_recipe','Пользователь: рецепты','er_person_recipe',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Список всех рецептов доступных пользователю','er');
--[b:er.er_person_recipe_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_recipe_add','er_person_recipe','Пользователь: рецепты : Добавление','add','er.f_er_person_recipe8add');
--[b:er.er_person_recipe_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_recipe_upd','er_person_recipe','Пользователь: рецепты : Исправление','upd','er.f_er_person_recipe8upd');
--[b:er.er_person_recipe_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_recipe_del','er_person_recipe','Пользователь: рецепты : Удаление','del','er.f_er_person_recipe8del');
--[b:er.er_person_recipe_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_recipe_mod','er_person_recipe','Пользователь: рецепты : Модификация','mod','er.f_er_person_recipe8mod');
--[t:er.er_person_recipe:n]
create table er.er_person_recipe (
                                     id bigint not null
    ,recipe_id uuid not null
    ,person_id bigint not null
    ,mo_id bigint not null
    ,discount boolean default false not null
    ,dispensary_id bigint
    ,visit_id bigint
    ,r_ser text
    ,r_num text
    ,date_create date default CURRENT_DATE not null
    ,exp_period integer
    ,emp_fio text
    ,recomendation text
    ,add_info jsonb
    ,constraint fk_er_person_recipe_dispensary_id FOREIGN KEY (dispensary_id) REFERENCES er.er_dispansary(id)
    ,constraint fk_er_person_recipe_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_person_recipe_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_person_recipe_visit_id FOREIGN KEY (visit_id) REFERENCES er.er_person_visit(id)
    ,constraint pk_er_person_recipe PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_recipe is 'Пользователь: рецепты';
comment on column er.er_person_recipe.id is 'Id';
comment on column er.er_person_recipe.recipe_id is 'Идентификатор рецепта';
comment on column er.er_person_recipe.person_id is 'Идентификатор пользователя';
comment on column er.er_person_recipe.mo_id is 'Идентификатор учреждения';
comment on column er.er_person_recipe.discount is 'Признак льготного рецепта (0 - нет, 1 - да)';
comment on column er.er_person_recipe.dispensary_id is 'Идентификатор аптеки';
comment on column er.er_person_recipe.visit_id is 'Идентификатор посещения, на котором был выдан рецепт';
comment on column er.er_person_recipe.r_ser is 'Серия рецепта';
comment on column er.er_person_recipe.r_num is 'Номер рецепта';
comment on column er.er_person_recipe.date_create is 'Дата создания';
comment on column er.er_person_recipe.exp_period is 'Длительность действия рецепта в днях';
comment on column er.er_person_recipe.emp_fio is 'ФИО врача, выдавшего рецепт';
comment on column er.er_person_recipe.recomendation is 'Рекомендации по приему препарата';
comment on column er.er_person_recipe.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_recipe_dispensary_id ON er.er_person_recipe USING btree (dispensary_id);
CREATE INDEX i_er_person_recipe_mo_id ON er.er_person_recipe USING btree (mo_id);
CREATE INDEX i_er_person_recipe_person_id ON er.er_person_recipe USING btree (person_id);
CREATE INDEX i_er_person_recipe_visit_id ON er.er_person_recipe USING btree (visit_id);
alter table er.er_person_recipe owner to dev;
--[v:er.v_er_person_recipe:n]
create or replace view er.v_er_person_recipe as
SELECT t.id,
       t.recipe_id,
       t.person_id,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.discount,
       t.dispensary_id,
       t.visit_id,
       t.r_ser,
       t.r_num,
       t.date_create,
       t.exp_period,
       t.emp_fio,
       t.recomendation,
       t.add_info
FROM er.er_person_recipe t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_recipe'::text));
--[f:er.f_er_person_recipe8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_recipe8add(pn_lpu bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_add',null);
    begin
        insert into er.er_person_recipe
        (
            id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_recipe8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_recipe8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_del',pn_id);
    begin
        delete from er.er_person_recipe t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_recipe'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_recipe8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_recipe8mod(pn_id bigint, pn_lpu bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_recipe8add(pn_lpu := pn_lpu,
                                          pu_recipe_id := pu_recipe_id,
                                          pn_person_id := pn_person_id,
                                          pn_mo_id := pn_mo_id,
                                          pb_discount := pb_discount,
                                          pn_dispensary_id := pn_dispensary_id,
                                          pn_visit_id := pn_visit_id,
                                          ps_r_ser := ps_r_ser,
                                          ps_r_num := ps_r_num,
                                          pd_date_create := pd_date_create,
                                          pn_exp_period := pn_exp_period,
                                          ps_emp_fio := ps_emp_fio,
                                          ps_recomendation := ps_recomendation,
                                          pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_recipe8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                          pu_recipe_id := pu_recipe_id,
                                          pn_person_id := pn_person_id,
                                          pn_mo_id := pn_mo_id,
                                          pb_discount := pb_discount,
                                          pn_dispensary_id := pn_dispensary_id,
                                          pn_visit_id := pn_visit_id,
                                          ps_r_ser := ps_r_ser,
                                          ps_r_num := ps_r_num,
                                          pd_date_create := pd_date_create,
                                          pn_exp_period := pn_exp_period,
                                          ps_emp_fio := ps_emp_fio,
                                          ps_recomendation := ps_recomendation,
                                          pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_recipe8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_recipe8upd(pn_id bigint, pn_lpu bigint, pu_recipe_id uuid, pn_person_id bigint, pn_mo_id bigint, pb_discount boolean, pn_dispensary_id bigint, pn_visit_id bigint, ps_r_ser text, ps_r_num text, pd_date_create date, pn_exp_period integer, ps_emp_fio text, ps_recomendation text, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_recipe_upd',pn_id);
    begin
        update er.er_person_recipe t set
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_recipe_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_recipe_a:n]
CREATE TRIGGER tr_er_person_recipe_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_recipe FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_persons:a]
--[u:er.er_persons:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_persons','Информация о пользователе','er_persons',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Таблица содержит пользователей и их персональную информацию. Информация в данную таблицу попадает после аутентификации и авторизации, импорта пользователей из внешних систем','er');
--[b:er.er_persons_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_add','er_persons','Информация о пользователе : Добавление','add','er.f_er_persons8add');
--[b:er.er_persons_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_upd','er_persons','Информация о пользователе : Исправление','upd','er.f_er_persons8upd');
--[b:er.er_persons_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_del','er_persons','Информация о пользователе : Удаление','del','er.f_er_persons8del');
--[b:er.er_persons_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_mod','er_persons','Информация о пользователе : Модификация','mod','er.f_er_persons8mod');
--[t:er.er_persons:n]
create table er.er_persons (
                               id bigint not null
    ,er_users bigint not null
    ,pers_uid uuid not null
    ,fname text
    ,mname text
    ,lname text
    ,birth_date date
    ,sex integer
    ,id_doc text
    ,snils text
    ,constraint fk_er_persons_core_users FOREIGN KEY (er_users) REFERENCES core.users(id)
    ,constraint pk_er_persons PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_persons is 'Информация о пользователе';
comment on column er.er_persons.id is 'Id';
comment on column er.er_persons.er_users is 'Пользователь ЕР';
comment on column er.er_persons.pers_uid is 'Идентификатор Пользователя';
comment on column er.er_persons.fname is 'Имя';
comment on column er.er_persons.mname is 'Отчество';
comment on column er.er_persons.lname is 'Фамилия';
comment on column er.er_persons.birth_date is 'Дата рождения';
comment on column er.er_persons.sex is 'Пол';
comment on column er.er_persons.id_doc is 'Номер документа';
comment on column er.er_persons.snils is 'СНИЛС';
CREATE INDEX i_er_persons_er_users ON er.er_persons USING btree (er_users);
alter table er.er_persons owner to dev;
--[v:er.v_er_persons:n]
create or replace view er.v_er_persons as
SELECT t.id,
       t.er_users,
       t.pers_uid,
       t.fname,
       t.mname,
       t.lname,
       t.birth_date,
       t.sex,
       t.id_doc,
       t.snils
FROM er.er_persons t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_persons'::text));
--[f:er.f_er_persons8add:n]
CREATE OR REPLACE FUNCTION er.f_er_persons8add(pn_lpu bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    -- perform core.f_bp_before(pn_lpu,null,null,'er_persons_add',null);
    begin
        insert into er.er_persons
        (
            id,
            er_users,
            pers_uid,
            fname,
            mname,
            lname,
            birth_date,
            sex,
            id_doc,
            snils
        )
        values
        (
            core.f_gen_id(),
            pn_er_users,
            pu_pers_uid,
            ps_fname,
            ps_mname,
            ps_lname,
            pd_birth_date,
            pn_sex,
            ps_id_doc,
            ps_snils
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    --perform core.f_bp_after(pn_lpu,null,null,'er_persons_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_persons8del:n]
CREATE OR REPLACE FUNCTION er.f_er_persons8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_persons_del',pn_id);
    begin
        delete from er.er_persons t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_persons_del',pn_id);
end;
$function$
;
--[f:er.f_er_persons8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_persons8mod(pn_id bigint, pn_lpu bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_persons8add(pn_lpu := pn_lpu,
                                    pn_er_users := pn_er_users,
                                    pu_pers_uid := pu_pers_uid,
                                    ps_fname := ps_fname,
                                    ps_mname := ps_mname,
                                    ps_lname := ps_lname,
                                    pd_birth_date := pd_birth_date,
                                    pn_sex := pn_sex,
                                    ps_id_doc := ps_id_doc,
                                    ps_snils := ps_snils);
        return n_id;
    else
        perform er.f_er_persons8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                    pn_er_users := pn_er_users,
                                    pu_pers_uid := pu_pers_uid,
                                    ps_fname := ps_fname,
                                    ps_mname := ps_mname,
                                    ps_lname := ps_lname,
                                    pd_birth_date := pd_birth_date,
                                    pn_sex := pn_sex,
                                    ps_id_doc := ps_id_doc,
                                    ps_snils := ps_snils);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_persons8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_persons8upd(pn_id bigint, pn_lpu bigint, pn_er_users bigint, pu_pers_uid uuid, ps_fname text, ps_mname text, ps_lname text, pd_birth_date date, pn_sex integer, ps_id_doc text, ps_snils text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_persons_upd',pn_id);
    begin
        update er.er_persons t set
                                   er_users = pn_er_users,
                                   pers_uid = pu_pers_uid,
                                   fname = ps_fname,
                                   mname = ps_mname,
                                   lname = ps_lname,
                                   birth_date = pd_birth_date,
                                   sex = pn_sex,
                                   id_doc = ps_id_doc,
                                   snils = ps_snils
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_persons_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_persons_a:n]
CREATE TRIGGER tr_er_persons_a AFTER INSERT OR DELETE OR UPDATE ON er.er_persons FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_sites:a]
--[u:er.er_person_sites:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_sites',' Пользователь: участки','er_person_sites',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: участки','er');
--[b:er.er_person_sites_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_sites_add','er_person_sites',' Пользователь: участки : Добавление','add','er.f_er_person_sites8add');
--[b:er.er_person_sites_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_sites_upd','er_person_sites',' Пользователь: участки : Исправление','upd','er.f_er_person_sites8upd');
--[b:er.er_person_sites_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_sites_del','er_person_sites',' Пользователь: участки : Удаление','del','er.f_er_person_sites8del');
--[b:er.er_person_sites_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_sites_mod','er_person_sites',' Пользователь: участки : Модификация','mod','er.f_er_person_sites8mod');
--[t:er.er_person_sites:n]
create table er.er_person_sites (
                                    id bigint not null
    ,sites_id bigint not null
    ,person_id bigint not null
    ,is_allow boolean default true not null
    ,purpose text
    ,type text
    ,add_info jsonb
    ,constraint fk_er_person_sites_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_person_sites_sites_id FOREIGN KEY (sites_id) REFERENCES er.er_sites(id)
    ,constraint pk_er_person_sites PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_sites is 'Пользователь: участки';
comment on column er.er_person_sites.id is 'Id';
comment on column er.er_person_sites.sites_id is 'Идентификатор участка';
comment on column er.er_person_sites.person_id is 'Идентификатор пользователя';
comment on column er.er_person_sites.is_allow is 'Доступ к этому участку (0 - нет, 1 - да)';
comment on column er.er_person_sites.purpose is 'Цель прикрепления';
comment on column er.er_person_sites.type is 'Тип прикрепления';
comment on column er.er_person_sites.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_sites_person_id ON er.er_person_sites USING btree (person_id);
CREATE INDEX i_er_person_sites_sites_id ON er.er_person_sites USING btree (sites_id);
alter table er.er_person_sites owner to dev;
--[v:er.v_er_person_sites:n]
create or replace view er.v_er_person_sites as
SELECT t.id,
       t.sites_id,
       t.person_id,
       t.is_allow,
       t.purpose,
       t.type,
       t.add_info
FROM er.er_person_sites t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_sites'::text));
--[f:er.f_er_person_sites8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_sites8add(pn_lpu bigint, pn_sites_id bigint, pn_person_id bigint, pb_is_allow boolean, ps_purpose text, ps_type text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_sites_add',null);
    begin
        insert into er.er_person_sites
        (
            id,
            sites_id,
            person_id,
            is_allow,
            purpose,
            type,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pn_sites_id,
            pn_person_id,
            pb_is_allow,
            ps_purpose,
            ps_type,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_sites_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_sites8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_sites8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_sites_del',pn_id);
    begin
        delete from er.er_person_sites t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_sites_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_sites8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_sites8mod(pn_id bigint, pn_lpu bigint, pn_sites_id bigint, pn_person_id bigint, pb_is_allow boolean, ps_purpose text, ps_type text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_sites8add(pn_lpu := pn_lpu,
                                         pn_sites_id := pn_sites_id,
                                         pn_person_id := pn_person_id,
                                         pb_is_allow := pb_is_allow,
                                         ps_purpose := ps_purpose,
                                         ps_type := ps_type,
                                         pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_sites8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                         pn_sites_id := pn_sites_id,
                                         pn_person_id := pn_person_id,
                                         pb_is_allow := pb_is_allow,
                                         ps_purpose := ps_purpose,
                                         ps_type := ps_type,
                                         pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_sites8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_sites8upd(pn_id bigint, pn_lpu bigint, pn_sites_id bigint, pn_person_id bigint, pb_is_allow boolean, ps_purpose text, ps_type text, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_sites_upd',pn_id);
    begin
        update er.er_person_sites t set
                                        sites_id = pn_sites_id,
                                        person_id = pn_person_id,
                                        is_allow = pb_is_allow,
                                        purpose = ps_purpose,
                                        type = ps_type,
                                        add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_sites_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_sites_a:n]
CREATE TRIGGER tr_er_person_sites_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_sites FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_persons_resources:a]
--[u:er.er_persons_resources:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_persons_resources','Связь пользователя с ресурсами','er_persons_resources',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Список ресурсов (врачей/услуг), которые доступны контрагенту','er');
--[b:er.er_persons_resources_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_resources_add','er_persons_resources','Связь пользователя с ресурсами : Добавление','add','er.f_er_persons_resources8add');
--[b:er.er_persons_resources_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_resources_upd','er_persons_resources','Связь пользователя с ресурсами : Исправление','upd','er.f_er_persons_resources8upd');
--[b:er.er_persons_resources_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_resources_del','er_persons_resources','Связь пользователя с ресурсами : Удаление','del','er.f_er_persons_resources8del');
--[b:er.er_persons_resources_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_persons_resources_mod','er_persons_resources','Связь пользователя с ресурсами : Модификация','mod','er.f_er_persons_resources8mod');
--[t:er.er_persons_resources:n]
create table er.er_persons_resources (
                                         id bigint not null
    ,resource_id bigint not null
    ,person_id bigint not null
    ,reg_allow boolean default false not null
    ,is_allow boolean default true not null
    ,add_info jsonb
    ,constraint fk_er_persons_resources_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_persons_resources_resource_id FOREIGN KEY (resource_id) REFERENCES er.er_resources(id)
    ,constraint pk_er_persons_resources PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_persons_resources is 'Связь пользователя с ресурсами';
comment on column er.er_persons_resources.id is 'Id';
comment on column er.er_persons_resources.resource_id is 'Идентификатор ресурса';
comment on column er.er_persons_resources.person_id is 'Идентификатор контрагента';
comment on column er.er_persons_resources.reg_allow is 'Является ли данный ресурс участковым врачом, для пользователя';
comment on column er.er_persons_resources.is_allow is 'Доступ к ресурсу (0 - нет, 1 - да)';
comment on column er.er_persons_resources.add_info is 'Детальная информация о ресурсе';
CREATE INDEX i_er_persons_resources_person_id ON er.er_persons_resources USING btree (person_id);
CREATE INDEX i_er_persons_resources_resource_id ON er.er_persons_resources USING btree (resource_id);
alter table er.er_persons_resources owner to dev;
--[v:er.v_er_persons_resources:n]
create or replace view er.v_er_persons_resources as
SELECT t.id,
       t.resource_id,
       t.person_id,
       t.reg_allow,
       t.is_allow,
       t.add_info
FROM er.er_persons_resources t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_persons_resources'::text));
--[f:er.f_er_persons_resources8add:n]
CREATE OR REPLACE FUNCTION er.f_er_persons_resources8add(pn_lpu bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_add',null);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_persons_resources8del:n]
CREATE OR REPLACE FUNCTION er.f_er_persons_resources8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_del',pn_id);
    begin
        delete from er.er_persons_resources t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_del',pn_id);
end;
$function$
;
--[f:er.f_er_persons_resources8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_persons_resources8mod(pn_id bigint, pn_lpu bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_persons_resources8add(pn_lpu := pn_lpu,
                                              pn_resource_id := pn_resource_id,
                                              pn_person_id := pn_person_id,
                                              pb_reg_allow := pb_reg_allow,
                                              pb_is_allow := pb_is_allow,
                                              pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_persons_resources8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                              pn_resource_id := pn_resource_id,
                                              pn_person_id := pn_person_id,
                                              pb_reg_allow := pb_reg_allow,
                                              pb_is_allow := pb_is_allow,
                                              pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_persons_resources8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_persons_resources8upd(pn_id bigint, pn_lpu bigint, pn_resource_id bigint, pn_person_id bigint, pb_reg_allow boolean, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
    begin
        update er.er_persons_resources t set
                                             resource_id = pn_resource_id,
                                             person_id = pn_person_id,
                                             reg_allow = pb_reg_allow,
                                             is_allow = pb_is_allow,
                                             add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_persons_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_persons_resources_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_persons_resources_a:n]
CREATE TRIGGER tr_er_persons_resources_a AFTER INSERT OR DELETE OR UPDATE ON er.er_persons_resources FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_vaccination:a]
--[u:er.er_person_vaccination:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_vaccination','Пользователь: вакцинация','er_person_vaccination',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: вакцинация','er');
--[b:er.er_person_vaccination_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_vaccination_add','er_person_vaccination','Пользователь: вакцинация : Добавление','add','er.f_er_person_vaccination8add');
--[b:er.er_person_vaccination_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_vaccination_upd','er_person_vaccination','Пользователь: вакцинация : Исправление','upd','er.f_er_person_vaccination8upd');
--[b:er.er_person_vaccination_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_vaccination_del','er_person_vaccination','Пользователь: вакцинация : Удаление','del','er.f_er_person_vaccination8del');
--[b:er.er_person_vaccination_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_vaccination_mod','er_person_vaccination','Пользователь: вакцинация : Модификация','mod','er.f_er_person_vaccination8mod');
--[t:er.er_person_vaccination:n]
create table er.er_person_vaccination (
                                          id bigint not null
    ,vac_id uuid not null
    ,person_id bigint not null
    ,mo_id bigint not null
    ,vac_info text
    ,plan_date date not null
    ,vac_type bigint
    ,is_allow boolean
    ,add_info jsonb
    ,constraint fk_er_person_vaccination_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_person_vaccination_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint pk_er_person_vaccination PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_vaccination is 'Пользователь: вакцинация';
comment on column er.er_person_vaccination.id is 'Id';
comment on column er.er_person_vaccination.vac_id is 'Идентификатор Вакцинации';
comment on column er.er_person_vaccination.person_id is 'Идентификатор пользователя';
comment on column er.er_person_vaccination.mo_id is 'Идентификатор учреждения, в котором будет произведена вакцинация';
comment on column er.er_person_vaccination.vac_info is 'Информация о вакцинации';
comment on column er.er_person_vaccination.plan_date is 'Запланированная дата вакцинации';
comment on column er.er_person_vaccination.vac_type is 'Тип вакцинации';
comment on column er.er_person_vaccination.is_allow is 'Актуальность вакцинации (0 - нет, 1 - да)';
comment on column er.er_person_vaccination.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_vaccination_mo_id ON er.er_person_vaccination USING btree (mo_id);
CREATE INDEX i_er_person_vaccination_person_id ON er.er_person_vaccination USING btree (person_id);
alter table er.er_person_vaccination owner to dev;
--[v:er.v_er_person_vaccination:n]
create or replace view er.v_er_person_vaccination as
SELECT t.id,
       t.vac_id,
       t.person_id,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.vac_info,
       t.plan_date,
       t.vac_type,
       t.is_allow,
       t.add_info
FROM er.er_person_vaccination t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_vaccination'::text));
--[f:er.f_er_person_vaccination8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_vaccination8add(pn_lpu bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_add',null);
    begin
        insert into er.er_person_vaccination
        (
            id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_vaccination8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_vaccination8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_del',pn_id);
    begin
        delete from er.er_person_vaccination t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_vaccination'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_vaccination8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_vaccination8mod(pn_id bigint, pn_lpu bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_vaccination8add(pn_lpu := pn_lpu,
                                               pu_vac_id := pu_vac_id,
                                               pn_person_id := pn_person_id,
                                               pn_mo_id := pn_mo_id,
                                               ps_vac_info := ps_vac_info,
                                               pd_plan_date := pd_plan_date,
                                               pn_vac_type := pn_vac_type,
                                               pb_is_allow := pb_is_allow,
                                               pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_vaccination8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                               pu_vac_id := pu_vac_id,
                                               pn_person_id := pn_person_id,
                                               pn_mo_id := pn_mo_id,
                                               ps_vac_info := ps_vac_info,
                                               pd_plan_date := pd_plan_date,
                                               pn_vac_type := pn_vac_type,
                                               pb_is_allow := pb_is_allow,
                                               pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_vaccination8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_vaccination8upd(pn_id bigint, pn_lpu bigint, pu_vac_id uuid, pn_person_id bigint, pn_mo_id bigint, ps_vac_info text, pd_plan_date date, pn_vac_type bigint, pb_is_allow boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_vaccination_upd',pn_id);
    begin
        update er.er_person_vaccination t set
                                              vac_id = pu_vac_id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_vaccination_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_vaccination_a:n]
CREATE TRIGGER tr_er_person_vaccination_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_vaccination FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_person_visit:a]
--[u:er.er_person_visit:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_person_visit','Пользователь: История посещений','er_person_visit',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Пользователь: История посещений','er');
--[b:er.er_person_visit_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_visit_add','er_person_visit','Пользователь: История посещений : Добавление','add','er.f_er_person_visit8add');
--[b:er.er_person_visit_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_visit_upd','er_person_visit','Пользователь: История посещений : Исправление','upd','er.f_er_person_visit8upd');
--[b:er.er_person_visit_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_visit_del','er_person_visit','Пользователь: История посещений : Удаление','del','er.f_er_person_visit8del');
--[b:er.er_person_visit_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_person_visit_mod','er_person_visit','Пользователь: История посещений : Модификация','mod','er.f_er_person_visit8mod');
--[t:er.er_person_visit:n]
create table er.er_person_visit (
                                    id bigint not null
    ,visit_id uuid not null
    ,mo_id bigint not null
    ,div_id bigint not null
    ,person_id bigint not null
    ,resource_id bigint
    ,direction_id bigint
    ,service text not null
    ,emp_fio text
    ,vis_date date
    ,dir_date date not null
    ,cost numeric default 0 not null
    ,recomendation text
    ,status_id bigint not null
    ,status_description text
    ,source_code text not null
    ,source_description text
    ,boked boolean default true not null
    ,add_info jsonb
    ,constraint fk_er_person_visit_direction_id FOREIGN KEY (direction_id) REFERENCES er.er_directions(id)
    ,constraint fk_er_person_visit_div_id FOREIGN KEY (div_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_person_visit_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_person_visit_person_id FOREIGN KEY (person_id) REFERENCES er.er_persons(id)
    ,constraint fk_er_person_visit_resource_id FOREIGN KEY (resource_id) REFERENCES er.er_resources(id)
    ,constraint fk_er_person_visit_status_id FOREIGN KEY (status_id) REFERENCES er.er_visit_status(id)
    ,constraint pk_er_person_visit PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_person_visit is 'Пользователь: История посещений';
comment on column er.er_person_visit.id is 'Id';
comment on column er.er_person_visit.visit_id is 'Идентификатор записи';
comment on column er.er_person_visit.mo_id is 'Идентификатор учреждения';
comment on column er.er_person_visit.div_id is 'Идентификатор Подразделения';
comment on column er.er_person_visit.person_id is 'Идентификатор Пользователя';
comment on column er.er_person_visit.resource_id is 'Идентификатор ресурса, на котором была запись';
comment on column er.er_person_visit.direction_id is 'Идентификатор направления, по которому была произведена запись';
comment on column er.er_person_visit.service is 'Наименование услуги';
comment on column er.er_person_visit.emp_fio is 'ФИО Врача, оказавший услугу';
comment on column er.er_person_visit.vis_date is 'Дата оказания';
comment on column er.er_person_visit.dir_date is 'Дата посещения';
comment on column er.er_person_visit.cost is 'Стоимость услуги в рублях';
comment on column er.er_person_visit.recomendation is 'Рекомендации врача';
comment on column er.er_person_visit.status_id is 'Статус посещения';
comment on column er.er_person_visit.status_description is 'Описание статуса';
comment on column er.er_person_visit.source_code is 'Источник записи на посещение';
comment on column er.er_person_visit.source_description is 'Описание источника записи';
comment on column er.er_person_visit.boked is 'Признак бронирования';
comment on column er.er_person_visit.add_info is 'Дополнительная информация';
CREATE INDEX i_er_person_visit_direction_id ON er.er_person_visit USING btree (direction_id);
CREATE INDEX i_er_person_visit_div_id ON er.er_person_visit USING btree (div_id);
CREATE INDEX i_er_person_visit_mo_id ON er.er_person_visit USING btree (mo_id);
CREATE INDEX i_er_person_visit_person_id ON er.er_person_visit USING btree (person_id);
CREATE INDEX i_er_person_visit_resource_id ON er.er_person_visit USING btree (resource_id);
CREATE INDEX i_er_person_visit_status_id ON er.er_person_visit USING btree (status_id);
alter table er.er_person_visit owner to dev;
--[v:er.v_er_person_visit:n]
create or replace view er.v_er_person_visit as
SELECT t.id,
       t.visit_id,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.div_id,
       t2.code_mo AS div_id_code_mo,
       t.person_id,
       t.resource_id,
       t.direction_id,
       t.service,
       t.emp_fio,
       t.vis_date,
       t.dir_date,
       t.cost,
       t.recomendation,
       t.status_id,
       t.status_description,
       t.source_code,
       t.source_description,
       t.boked,
       t.add_info
FROM er.er_person_visit t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
         JOIN er.er_mo t2 ON t.div_id = t2.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_person_visit'::text));
--[f:er.f_er_person_visit8add:n]
CREATE OR REPLACE FUNCTION er.f_er_person_visit8add(pn_lpu bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_add',null);
    begin
        insert into er.er_person_visit
        (
            id,
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_person_visit8del:n]
CREATE OR REPLACE FUNCTION er.f_er_person_visit8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_del',pn_id);
    begin
        delete from er.er_person_visit t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_person_visit'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_del',pn_id);
end;
$function$
;
--[f:er.f_er_person_visit8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_person_visit8mod(pn_id bigint, pn_lpu bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_person_visit8add(pn_lpu := pn_lpu,
                                         pu_visit_id := pu_visit_id,
                                         pn_mo_id := pn_mo_id,
                                         pn_div_id := pn_div_id,
                                         pn_person_id := pn_person_id,
                                         pn_resource_id := pn_resource_id,
                                         pn_direction_id := pn_direction_id,
                                         ps_service := ps_service,
                                         ps_emp_fio := ps_emp_fio,
                                         pd_vis_date := pd_vis_date,
                                         pd_dir_date := pd_dir_date,
                                         pn_cost := pn_cost,
                                         ps_recomendation := ps_recomendation,
                                         pn_status_id := pn_status_id,
                                         ps_status_description := ps_status_description,
                                         ps_source_code := ps_source_code,
                                         ps_source_description := ps_source_description,
                                         pb_boked := pb_boked,
                                         pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_person_visit8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                         pu_visit_id := pu_visit_id,
                                         pn_mo_id := pn_mo_id,
                                         pn_div_id := pn_div_id,
                                         pn_person_id := pn_person_id,
                                         pn_resource_id := pn_resource_id,
                                         pn_direction_id := pn_direction_id,
                                         ps_service := ps_service,
                                         ps_emp_fio := ps_emp_fio,
                                         pd_vis_date := pd_vis_date,
                                         pd_dir_date := pd_dir_date,
                                         pn_cost := pn_cost,
                                         ps_recomendation := ps_recomendation,
                                         pn_status_id := pn_status_id,
                                         ps_status_description := ps_status_description,
                                         ps_source_code := ps_source_code,
                                         ps_source_description := ps_source_description,
                                         pb_boked := pb_boked,
                                         pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_person_visit8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_person_visit8upd(pn_id bigint, pn_lpu bigint, pu_visit_id uuid, pn_mo_id bigint, pn_div_id bigint, pn_person_id bigint, pn_resource_id bigint, pn_direction_id bigint, ps_service text, ps_emp_fio text, pd_vis_date date, pd_dir_date date, pn_cost numeric, ps_recomendation text, pn_status_id bigint, ps_status_description text, ps_source_code text, ps_source_description text, pb_boked boolean, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_person_visit_upd',pn_id);
    begin
        update er.er_person_visit t set
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
    perform core.f_bp_after(pn_lpu,null,null,'er_person_visit_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_person_visit_a:n]
CREATE TRIGGER tr_er_person_visit_a AFTER INSERT OR DELETE OR UPDATE ON er.er_person_visit FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_polis_kind:a]
--[u:er.er_polis_kind:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_polis_kind','Вид полиса','er_polis_kind',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Вид полиса','er');
--[b:er.er_polis_kind_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_polis_kind_add','er_polis_kind','Вид полиса : Добавление','add','er.f_er_polis_kind8add');
--[b:er.er_polis_kind_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_polis_kind_upd','er_polis_kind','Вид полиса : Исправление','upd','er.f_er_polis_kind8upd');
--[b:er.er_polis_kind_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_polis_kind_del','er_polis_kind','Вид полиса : Удаление','del','er.f_er_polis_kind8del');
--[b:er.er_polis_kind_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_polis_kind_mod','er_polis_kind','Вид полиса : Модификация','mod','er.f_er_polis_kind8mod');
--[t:er.er_polis_kind:n]
create table er.er_polis_kind (
                                  id bigint not null
    ,code integer not null
    ,kname text not null
    ,constraint ch_er_polis_kind_co CHECK (code::text = btrim(code::text))
    ,constraint pk_er_polis_kind PRIMARY KEY (id)
    ,constraint uk_er_polis_kind_co UNIQUE (code)

) with (OIDS=FALSE);
comment on table er.er_polis_kind is 'Вид полиса';
comment on column er.er_polis_kind.id is 'Id';
comment on column er.er_polis_kind.code is 'Код';
comment on column er.er_polis_kind.kname is 'Наименование';
comment on constraint ch_er_polis_kind_co on er.er_polis_kind is 'Поле [Код] раздела [Вид полиса] не должно содержать незначащие пробелы';
alter table er.er_polis_kind owner to dev;
--[v:er.v_er_polis_kind:n]
create or replace view er.v_er_polis_kind as
SELECT t.id,
       t.code,
       t.kname
FROM er.er_polis_kind t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_polis_kind'::text));
--[f:er.f_er_polis_kind8add:n]
CREATE OR REPLACE FUNCTION er.f_er_polis_kind8add(pn_lpu bigint, pn_code integer, ps_kname text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_polis_kind_add',null);
    begin
        insert into er.er_polis_kind
        (
            id,
            code,
            kname
        )
        values
        (
            core.f_gen_id(),
            pn_code,
            ps_kname
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_polis_kind_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_polis_kind8del:n]
CREATE OR REPLACE FUNCTION er.f_er_polis_kind8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_polis_kind_del',pn_id);
    begin
        delete from er.er_polis_kind t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_polis_kind'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_polis_kind_del',pn_id);
end;
$function$
;
--[f:er.f_er_polis_kind8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_polis_kind8mod(pn_id bigint, pn_lpu bigint, pn_code integer, ps_kname text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_polis_kind8add(pn_lpu := pn_lpu,
                                       pn_code := pn_code,
                                       ps_kname := ps_kname);
        return n_id;
    else
        perform er.f_er_polis_kind8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                       pn_code := pn_code,
                                       ps_kname := ps_kname);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_polis_kind8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_polis_kind8upd(pn_id bigint, pn_lpu bigint, pn_code integer, ps_kname text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_polis_kind_upd',pn_id);
    begin
        update er.er_polis_kind t set
                                      code = pn_code,
                                      kname = ps_kname
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_polis_kind'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_polis_kind_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_polis_kind_a:n]
CREATE TRIGGER tr_er_polis_kind_a AFTER INSERT OR DELETE OR UPDATE ON er.er_polis_kind FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_profiles:a]
--[u:er.er_profiles:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_profiles','Профиль','er_profiles',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Список профилей врачей','er');
--[b:er.er_profiles_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_profiles_add','er_profiles','Профиль : Добавление','add','er.f_er_profiles8add');
--[b:er.er_profiles_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_profiles_upd','er_profiles','Профиль : Исправление','upd','er.f_er_profiles8upd');
--[b:er.er_profiles_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_profiles_del','er_profiles','Профиль : Удаление','del','er.f_er_profiles8del');
--[b:er.er_profiles_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_profiles_mod','er_profiles','Профиль : Модификация','mod','er.f_er_profiles8mod');
--[t:er.er_profiles:n]
create table er.er_profiles (
                                id bigint not null
    ,profile_uid uuid not null
    ,name text not null
    ,match_profile text
    ,add_info jsonb
    ,constraint pk_er_profiles PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_profiles is 'Профиль';
comment on column er.er_profiles.id is 'Id';
comment on column er.er_profiles.profile_uid is 'Идентификатор профиля';
comment on column er.er_profiles.name is 'Наименование профиля';
comment on column er.er_profiles.match_profile is 'Соответствие профиля в мобильном приложении и МИС';
comment on column er.er_profiles.add_info is 'Детальная информация о профиле';
alter table er.er_profiles owner to dev;
--[v:er.v_er_profiles:n]
create or replace view er.v_er_profiles as
SELECT t.id,
       t.profile_uid,
       t.name,
       t.match_profile,
       t.add_info
FROM er.er_profiles t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_profiles'::text));
--[f:er.f_er_profiles8add:n]
CREATE OR REPLACE FUNCTION er.f_er_profiles8add(pn_lpu bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_profiles_add',null);
    begin
        insert into er.er_profiles
        (
            id,
            profile_uid,
            name,
            match_profile,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pu_profile_uid,
            ps_name,
            ps_match_profile,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_profiles_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_profiles8del:n]
CREATE OR REPLACE FUNCTION er.f_er_profiles8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_profiles_del',pn_id);
    begin
        delete from er.er_profiles t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_profiles'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_profiles_del',pn_id);
end;
$function$
;
--[f:er.f_er_profiles8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_profiles8mod(pn_id bigint, pn_lpu bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_profiles8add(pn_lpu := pn_lpu,
                                     pu_profile_uid := pu_profile_uid,
                                     ps_name := ps_name,
                                     ps_match_profile := ps_match_profile,
                                     pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_profiles8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                     pu_profile_uid := pu_profile_uid,
                                     ps_name := ps_name,
                                     ps_match_profile := ps_match_profile,
                                     pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_profiles8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_profiles8upd(pn_id bigint, pn_lpu bigint, pu_profile_uid uuid, ps_name text, ps_match_profile text, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_profiles_upd',pn_id);
    begin
        update er.er_profiles t set
                                    profile_uid = pu_profile_uid,
                                    name = ps_name,
                                    match_profile = ps_match_profile,
                                    add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_profiles'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_profiles_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_profiles_a:n]
CREATE TRIGGER tr_er_profiles_a AFTER INSERT OR DELETE OR UPDATE ON er.er_profiles FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_recipe_drug:a]
--[u:er.er_recipe_drug:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_recipe_drug','Рецепты: Медикаменты','er_recipe_drug',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Рецепты: Медикаменты','er');
--[b:er.er_recipe_drug_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_recipe_drug_add','er_recipe_drug','Рецепты: Медикаменты : Добавление','add','er.f_er_recipe_drug8add');
--[b:er.er_recipe_drug_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_recipe_drug_upd','er_recipe_drug','Рецепты: Медикаменты : Исправление','upd','er.f_er_recipe_drug8upd');
--[b:er.er_recipe_drug_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_recipe_drug_del','er_recipe_drug','Рецепты: Медикаменты : Удаление','del','er.f_er_recipe_drug8del');
--[b:er.er_recipe_drug_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_recipe_drug_mod','er_recipe_drug','Рецепты: Медикаменты : Модификация','mod','er.f_er_recipe_drug8mod');
--[t:er.er_recipe_drug:n]
create table er.er_recipe_drug (
                                   id bigint not null
    ,drug_id bigint not null
    ,recipe_id bigint not null
    ,pack_count text not null
    ,use_method text
    ,recomendation text
    ,constraint fk_er_recipe_drug_drug_id FOREIGN KEY (drug_id) REFERENCES er.er_drug(id)
    ,constraint fk_er_recipe_drug_recipe_id FOREIGN KEY (recipe_id) REFERENCES er.er_person_recipe(id)
    ,constraint pk_er_recipe_drug PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_recipe_drug is 'Рецепты: Медикаменты';
comment on column er.er_recipe_drug.id is 'Id';
comment on column er.er_recipe_drug.drug_id is 'Идентификатор медикамента';
comment on column er.er_recipe_drug.recipe_id is 'Идентификатор Рецепта';
comment on column er.er_recipe_drug.pack_count is 'Количество упаковок';
comment on column er.er_recipe_drug.use_method is 'Режим приема препарата';
comment on column er.er_recipe_drug.recomendation is 'Рекомендации по приему препатрата';
CREATE INDEX i_er_recipe_drug_drug_id ON er.er_recipe_drug USING btree (drug_id);
CREATE INDEX i_er_recipe_drug_recipe_id ON er.er_recipe_drug USING btree (recipe_id);
alter table er.er_recipe_drug owner to dev;
--[v:er.v_er_recipe_drug:n]
create or replace view er.v_er_recipe_drug as
SELECT t.id,
       t.drug_id,
       t1.medform AS drug_id_medform,
       t.recipe_id,
       t.pack_count,
       t.use_method,
       t.recomendation
FROM er.er_recipe_drug t
         JOIN er.er_drug t1 ON t.drug_id = t1.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_recipe_drug'::text));
--[f:er.f_er_recipe_drug8add:n]
CREATE OR REPLACE FUNCTION er.f_er_recipe_drug8add(pn_lpu bigint, pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_add',null);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_recipe_drug8del:n]
CREATE OR REPLACE FUNCTION er.f_er_recipe_drug8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_del',pn_id);
    begin
        delete from er.er_recipe_drug t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_recipe_drug'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_del',pn_id);
end;
$function$
;
--[f:er.f_er_recipe_drug8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_recipe_drug8mod(pn_id bigint, pn_lpu bigint, pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_recipe_drug8add(pn_lpu := pn_lpu,
                                        pn_drug_id := pn_drug_id,
                                        pn_recipe_id := pn_recipe_id,
                                        ps_pack_count := ps_pack_count,
                                        ps_use_method := ps_use_method,
                                        ps_recomendation := ps_recomendation);
        return n_id;
    else
        perform er.f_er_recipe_drug8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                        pn_drug_id := pn_drug_id,
                                        pn_recipe_id := pn_recipe_id,
                                        ps_pack_count := ps_pack_count,
                                        ps_use_method := ps_use_method,
                                        ps_recomendation := ps_recomendation);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_recipe_drug8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_recipe_drug8upd(pn_id bigint, pn_lpu bigint, pn_drug_id bigint, pn_recipe_id bigint, ps_pack_count text, ps_use_method text, ps_recomendation text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_recipe_drug_upd',pn_id);
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
    perform core.f_bp_after(pn_lpu,null,null,'er_recipe_drug_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_recipe_drug_a:n]
CREATE TRIGGER tr_er_recipe_drug_a AFTER INSERT OR DELETE OR UPDATE ON er.er_recipe_drug FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_resources:a]
--[u:er.er_resources:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_resources','Справочник ресурсов (врачей/услуг)','er_resources',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Справочник ресурсов (врачей/услуг)','er');
--[b:er.er_resources_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_resources_add','er_resources','Справочник ресурсов (врачей/услуг) : Добавление','add','er.f_er_resources8add');
--[b:er.er_resources_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_resources_upd','er_resources','Справочник ресурсов (врачей/услуг) : Исправление','upd','er.f_er_resources8upd');
--[b:er.er_resources_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_resources_del','er_resources','Справочник ресурсов (врачей/услуг) : Удаление','del','er.f_er_resources8del');
--[b:er.er_resources_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_resources_mod','er_resources','Справочник ресурсов (врачей/услуг) : Модификация','mod','er.f_er_resources8mod');
--[t:er.er_resources:n]
create table er.er_resources (
                                 id bigint not null
    ,resource_uid uuid not null
    ,mo_id bigint not null
    ,div_id bigint not null
    ,profile_id bigint not null
    ,name text not null
    ,address text
    ,notification text
    ,hint text
    ,is_free boolean not null
    ,is_paid boolean not null
    ,price numeric default 0 not null
    ,department text
    ,room text
    ,service text
    ,site_id bigint
    ,emp_sname text
    ,emp_fname text
    ,emp_lname text
    ,record_period integer default 14 not null
    ,time_to_elapse integer default 0 not null
    ,allow_wait_list boolean default false not null
    ,wait_list_msg text
    ,add_info jsonb
    ,constraint fk_er_resources_div_id FOREIGN KEY (div_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_resources_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_resources_profile_id FOREIGN KEY (profile_id) REFERENCES er.er_profiles(id)
    ,constraint fk_er_resources_site_id FOREIGN KEY (site_id) REFERENCES er.er_sites(id)
    ,constraint pk_er_resources PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_resources is 'Справочник ресурсов (врачей/услуг)';
comment on column er.er_resources.id is 'Id';
comment on column er.er_resources.resource_uid is 'Идентификатор ресурса';
comment on column er.er_resources.mo_id is 'Идентификатор учреждения';
comment on column er.er_resources.div_id is 'Идентификатор учреждения';
comment on column er.er_resources.profile_id is 'Идентификатор профиля';
comment on column er.er_resources.name is 'Наименование ресурса';
comment on column er.er_resources.address is 'Адрес кабинета';
comment on column er.er_resources.notification is 'Текст уведомления при записи';
comment on column er.er_resources.hint is 'Дополнительная информация о ресурсе';
comment on column er.er_resources.is_free is 'Бесплатный прием (0 – нет;1 – да)';
comment on column er.er_resources.is_paid is 'Платный прием (0 – нет;1 – да)';
comment on column er.er_resources.price is 'Цена приема в рублях';
comment on column er.er_resources.department is 'Наименование отделения, в котором принимает врач';
comment on column er.er_resources.room is 'Наименование кабинета, в котором принимает врач';
comment on column er.er_resources.service is 'Наименование услуги';
comment on column er.er_resources.site_id is 'Идентификатор участка, за которым закреплен врач';
comment on column er.er_resources.emp_sname is 'Фамилия врача';
comment on column er.er_resources.emp_fname is 'Имя врача';
comment on column er.er_resources.emp_lname is 'Отчество врача';
comment on column er.er_resources.record_period is 'Период доступности записи в днях';
comment on column er.er_resources.time_to_elapse is 'Количество минут, через которые будет доступна запись в Регистратуре';
comment on column er.er_resources.allow_wait_list is 'Признак доступности записи в очередь ожидания (0 – нет;1 – да)';
comment on column er.er_resources.wait_list_msg is 'Текст сообщения при записи в очередь ожидания';
comment on column er.er_resources.add_info is 'Детальная информация о ресурсе';
CREATE INDEX i_er_resources_div_id ON er.er_resources USING btree (div_id);
CREATE INDEX i_er_resources_mo_id ON er.er_resources USING btree (mo_id);
CREATE INDEX i_er_resources_profile_id ON er.er_resources USING btree (profile_id);
CREATE INDEX i_er_resources_site_id ON er.er_resources USING btree (site_id);
alter table er.er_resources owner to dev;
--[v:er.v_er_resources:n]
create or replace view er.v_er_resources as
SELECT t.id,
       t.resource_uid,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.div_id,
       t2.code_mo AS div_id_code_mo,
       t.profile_id,
       t.name,
       t.address,
       t.notification,
       t.hint,
       t.is_free,
       t.is_paid,
       t.price,
       t.department,
       t.room,
       t.service,
       t.site_id,
       t.emp_sname,
       t.emp_fname,
       t.emp_lname,
       t.record_period,
       t.time_to_elapse,
       t.allow_wait_list,
       t.wait_list_msg,
       t.add_info
FROM er.er_resources t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
         JOIN er.er_mo t2 ON t.div_id = t2.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_resources'::text));
--[f:er.f_er_resources8add:n]
CREATE OR REPLACE FUNCTION er.f_er_resources8add(pn_lpu bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_resources_add',null);
    begin
        insert into er.er_resources
        (
            id,
            resource_uid,
            mo_id,
            div_id,
            profile_id,
            name,
            address,
            notification,
            hint,
            is_free,
            is_paid,
            price,
            department,
            room,
            service,
            site_id,
            emp_sname,
            emp_fname,
            emp_lname,
            record_period,
            time_to_elapse,
            allow_wait_list,
            wait_list_msg,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pu_resource_uid,
            pn_mo_id,
            pn_div_id,
            pn_profile_id,
            ps_name,
            ps_address,
            ps_notification,
            ps_hint,
            pb_is_free,
            pb_is_paid,
            pn_price,
            ps_department,
            ps_room,
            ps_service,
            pn_site_id,
            ps_emp_sname,
            ps_emp_fname,
            ps_emp_lname,
            pn_record_period,
            pn_time_to_elapse,
            pb_allow_wait_list,
            ps_wait_list_msg,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_resources_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_resources8del:n]
CREATE OR REPLACE FUNCTION er.f_er_resources8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_resources_del',pn_id);
    begin
        delete from er.er_resources t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_resources_del',pn_id);
end;
$function$
;
--[f:er.f_er_resources8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_resources8mod(pn_id bigint, pn_lpu bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_resources8add(pn_lpu := pn_lpu,
                                      pu_resource_uid := pu_resource_uid,
                                      pn_mo_id := pn_mo_id,
                                      pn_div_id := pn_div_id,
                                      pn_profile_id := pn_profile_id,
                                      ps_name := ps_name,
                                      ps_address := ps_address,
                                      ps_notification := ps_notification,
                                      ps_hint := ps_hint,
                                      pb_is_free := pb_is_free,
                                      pb_is_paid := pb_is_paid,
                                      pn_price := pn_price,
                                      ps_department := ps_department,
                                      ps_room := ps_room,
                                      ps_service := ps_service,
                                      pn_site_id := pn_site_id,
                                      ps_emp_sname := ps_emp_sname,
                                      ps_emp_fname := ps_emp_fname,
                                      ps_emp_lname := ps_emp_lname,
                                      pn_record_period := pn_record_period,
                                      pn_time_to_elapse := pn_time_to_elapse,
                                      pb_allow_wait_list := pb_allow_wait_list,
                                      ps_wait_list_msg := ps_wait_list_msg,
                                      pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_resources8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                      pu_resource_uid := pu_resource_uid,
                                      pn_mo_id := pn_mo_id,
                                      pn_div_id := pn_div_id,
                                      pn_profile_id := pn_profile_id,
                                      ps_name := ps_name,
                                      ps_address := ps_address,
                                      ps_notification := ps_notification,
                                      ps_hint := ps_hint,
                                      pb_is_free := pb_is_free,
                                      pb_is_paid := pb_is_paid,
                                      pn_price := pn_price,
                                      ps_department := ps_department,
                                      ps_room := ps_room,
                                      ps_service := ps_service,
                                      pn_site_id := pn_site_id,
                                      ps_emp_sname := ps_emp_sname,
                                      ps_emp_fname := ps_emp_fname,
                                      ps_emp_lname := ps_emp_lname,
                                      pn_record_period := pn_record_period,
                                      pn_time_to_elapse := pn_time_to_elapse,
                                      pb_allow_wait_list := pb_allow_wait_list,
                                      ps_wait_list_msg := ps_wait_list_msg,
                                      pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_resources8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_resources8upd(pn_id bigint, pn_lpu bigint, pu_resource_uid uuid, pn_mo_id bigint, pn_div_id bigint, pn_profile_id bigint, ps_name text, ps_address text, ps_notification text, ps_hint text, pb_is_free boolean, pb_is_paid boolean, pn_price numeric, ps_department text, ps_room text, ps_service text, pn_site_id bigint, ps_emp_sname text, ps_emp_fname text, ps_emp_lname text, pn_record_period integer, pn_time_to_elapse integer, pb_allow_wait_list boolean, ps_wait_list_msg text, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_resources_upd',pn_id);
    begin
        update er.er_resources t set
                                     resource_uid = pu_resource_uid,
                                     mo_id = pn_mo_id,
                                     div_id = pn_div_id,
                                     profile_id = pn_profile_id,
                                     name = ps_name,
                                     address = ps_address,
                                     notification = ps_notification,
                                     hint = ps_hint,
                                     is_free = pb_is_free,
                                     is_paid = pb_is_paid,
                                     price = pn_price,
                                     department = ps_department,
                                     room = ps_room,
                                     service = ps_service,
                                     site_id = pn_site_id,
                                     emp_sname = ps_emp_sname,
                                     emp_fname = ps_emp_fname,
                                     emp_lname = ps_emp_lname,
                                     record_period = pn_record_period,
                                     time_to_elapse = pn_time_to_elapse,
                                     allow_wait_list = pb_allow_wait_list,
                                     wait_list_msg = ps_wait_list_msg,
                                     add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_resources'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_resources_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_resources_a:n]
CREATE TRIGGER tr_er_resources_a AFTER INSERT OR DELETE OR UPDATE ON er.er_resources FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_sites:a]
--[u:er.er_sites:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module) values ('er_sites','Участки','er_sites',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Список участков','er');
--[b:er.er_sites_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_sites_add','er_sites','Участки : Добавление','add','er.f_er_sites8add');
--[b:er.er_sites_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_sites_upd','er_sites','Участки : Исправление','upd','er.f_er_sites8upd');
--[b:er.er_sites_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_sites_del','er_sites','Участки : Удаление','del','er.f_er_sites8del');
--[b:er.er_sites_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_sites_mod','er_sites','Участки : Модификация','mod','er.f_er_sites8mod');
--[t:er.er_sites:n]
create table er.er_sites (
                             id bigint not null
    ,site_id uuid not null
    ,mo_id bigint not null
    ,div_id bigint not null
    ,site_code text not null
    ,site_name text
    ,date_begin date default CURRENT_DATE not null
    ,date_end date
    ,add_info jsonb
    ,constraint fk_er_sites_div_id FOREIGN KEY (div_id) REFERENCES er.er_mo(id)
    ,constraint fk_er_sites_mo_id FOREIGN KEY (mo_id) REFERENCES er.er_mo(id)
    ,constraint pk_er_sites PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_sites is 'Участки';
comment on column er.er_sites.id is 'Id';
comment on column er.er_sites.site_id is 'Идентификатор участка';
comment on column er.er_sites.mo_id is 'Идентификатор ЛПУ';
comment on column er.er_sites.div_id is 'Идентификатор подразделения';
comment on column er.er_sites.site_code is 'Код участка';
comment on column er.er_sites.site_name is 'Наименование участка';
comment on column er.er_sites.date_begin is 'Дата начала действия';
comment on column er.er_sites.date_end is 'Дата окончания действия';
comment on column er.er_sites.add_info is 'Дополнительная информация';
CREATE INDEX i_er_sites_div_id ON er.er_sites USING btree (div_id);
CREATE INDEX i_er_sites_mo_id ON er.er_sites USING btree (mo_id);
alter table er.er_sites owner to dev;
--[v:er.v_er_sites:n]
create or replace view er.v_er_sites as
SELECT t.id,
       t.site_id,
       t.mo_id,
       t1.code_mo AS mo_id_code_mo,
       t.div_id,
       t2.code_mo AS div_id_code_mo,
       t.site_code,
       t.site_name,
       t.date_begin,
       t.date_end,
       t.add_info
FROM er.er_sites t
         JOIN er.er_mo t1 ON t.mo_id = t1.id
         JOIN er.er_mo t2 ON t.div_id = t2.id
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_sites'::text));
--[f:er.f_er_sites8add:n]
CREATE OR REPLACE FUNCTION er.f_er_sites8add(pn_lpu bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_sites_add',null);
    begin
        insert into er.er_sites
        (
            id,
            site_id,
            mo_id,
            div_id,
            site_code,
            site_name,
            date_begin,
            date_end,
            add_info
        )
        values
        (
            core.f_gen_id(),
            pu_site_id,
            pn_mo_id,
            pn_div_id,
            ps_site_code,
            ps_site_name,
            pd_date_begin,
            pd_date_end,
            pu_add_info
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_sites_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_sites8del:n]
CREATE OR REPLACE FUNCTION er.f_er_sites8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_sites_del',pn_id);
    begin
        delete from er.er_sites t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_sites_del',pn_id);
end;
$function$
;
--[f:er.f_er_sites8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_sites8mod(pn_id bigint, pn_lpu bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_sites8add(pn_lpu := pn_lpu,
                                  pu_site_id := pu_site_id,
                                  pn_mo_id := pn_mo_id,
                                  pn_div_id := pn_div_id,
                                  ps_site_code := ps_site_code,
                                  ps_site_name := ps_site_name,
                                  pd_date_begin := pd_date_begin,
                                  pd_date_end := pd_date_end,
                                  pu_add_info := pu_add_info);
        return n_id;
    else
        perform er.f_er_sites8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                  pu_site_id := pu_site_id,
                                  pn_mo_id := pn_mo_id,
                                  pn_div_id := pn_div_id,
                                  ps_site_code := ps_site_code,
                                  ps_site_name := ps_site_name,
                                  pd_date_begin := pd_date_begin,
                                  pd_date_end := pd_date_end,
                                  pu_add_info := pu_add_info);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_sites8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_sites8upd(pn_id bigint, pn_lpu bigint, pu_site_id uuid, pn_mo_id bigint, pn_div_id bigint, ps_site_code text, ps_site_name text, pd_date_begin date, pd_date_end date, pu_add_info jsonb)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_sites_upd',pn_id);
    begin
        update er.er_sites t set
                                 site_id = pu_site_id,
                                 mo_id = pn_mo_id,
                                 div_id = pn_div_id,
                                 site_code = ps_site_code,
                                 site_name = ps_site_name,
                                 date_begin = pd_date_begin,
                                 date_end = pd_date_end,
                                 add_info = pu_add_info
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_sites'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_sites_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_sites_a:n]
CREATE TRIGGER tr_er_sites_a AFTER INSERT OR DELETE OR UPDATE ON er.er_sites FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[u:er.er_visit_status:a]
--[u:er.er_visit_status:n]
insert into core.unitlist(unitcode,unitname,tablename,parentunitcode,use_catalogs,ver_lpu,use_joindocs,use_unitprop,use_reports,use_userprocs,is_system,schemaname,use_hierarchy,use_chronics,show_info,module)
values ('er_visit_status','Посещение: статус','er_visit_status',NULL,'0'::numeric,'2'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'1'::numeric,'er','0'::numeric,'0'::numeric,'Посещение: статус','er');
--[b:er.er_visit_status_add:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_visit_status_add','er_visit_status','Посещение: статус : Добавление','add','er.f_er_visit_status8add');
--[b:er.er_visit_status_upd:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_visit_status_upd','er_visit_status','Посещение: статус : Исправление','upd','er.f_er_visit_status8upd');
--[b:er.er_visit_status_del:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_visit_status_del','er_visit_status','Посещение: статус : Удаление','del','er.f_er_visit_status8del');
--[b:er.er_visit_status_mod:n]
insert into core.unitbps (unitbpcode,unitcode,unitbpname,standard_action,execproc) values ('er_visit_status_mod','er_visit_status','Посещение: статус : Модификация','mod','er.f_er_visit_status8mod');
--[t:er.er_visit_status:n]
create table er.er_visit_status (
                                    id bigint not null
    ,scode integer not null
    ,sname text not null
    ,constraint pk_er_visit_status PRIMARY KEY (id)

) with (OIDS=FALSE);
comment on table er.er_visit_status is 'Посещение: статус';
comment on column er.er_visit_status.id is 'Id';
comment on column er.er_visit_status.scode is 'Код статуса';
comment on column er.er_visit_status.sname is 'Наименование статуса';
alter table er.er_visit_status owner to dev;
--[v:er.v_er_visit_status:n]
create or replace view er.v_er_visit_status as
SELECT t.id,
       t.scode,
       t.sname
FROM er.er_visit_status t
WHERE (EXISTS ( SELECT NULL::text
                FROM core.v_urprivs ur
                WHERE ur.lpu IS NULL AND ur.version IS NULL AND ur.unitcode::text = 'er_visit_status'::text));
--[f:er.f_er_visit_status8add:n]
CREATE OR REPLACE FUNCTION er.f_er_visit_status8add(pn_lpu bigint, pn_scode integer, ps_sname text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_visit_status_add',null);
    begin
        insert into er.er_visit_status
        (
            id,
            scode,
            sname
        )
        values
        (
            core.f_gen_id(),
            pn_scode,
            ps_sname
        ) returning id into n_id;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'A');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_visit_status_add',n_id);
    return n_id;
end;
$function$
;
--[f:er.f_er_visit_status8del:n]
CREATE OR REPLACE FUNCTION er.f_er_visit_status8del(pn_id bigint, pn_lpu bigint)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_visit_status_del',pn_id);
    begin
        delete from er.er_visit_status t
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_visit_status'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'D');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_visit_status_del',pn_id);
end;
$function$
;
--[f:er.f_er_visit_status8mod:n]
CREATE OR REPLACE FUNCTION er.f_er_visit_status8mod(pn_id bigint, pn_lpu bigint, pn_scode integer, ps_sname text)
    RETURNS bigint
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
declare
    n_id                  bigint;
begin
    if pn_id is null then
        n_id := er.f_er_visit_status8add(pn_lpu := pn_lpu,
                                         pn_scode := pn_scode,
                                         ps_sname := ps_sname);
        return n_id;
    else
        perform er.f_er_visit_status8upd(pn_id := pn_id,pn_lpu := pn_lpu,
                                         pn_scode := pn_scode,
                                         ps_sname := ps_sname);
        return pn_id;
    end if;
end;
$function$
;
--[f:er.f_er_visit_status8upd:n]
CREATE OR REPLACE FUNCTION er.f_er_visit_status8upd(pn_id bigint, pn_lpu bigint, pn_scode integer, ps_sname text)
    RETURNS void
    LANGUAGE plpgsql
    SECURITY DEFINER
AS $function$
begin
    perform core.f_bp_before(pn_lpu,null,null,'er_visit_status_upd',pn_id);
    begin
        update er.er_visit_status t set
                                        scode = pn_scode,
                                        sname = ps_sname
        where t.id   = pn_id;
        if not found then perform core.f_msg_not_found(pn_id, 'er_visit_status'); end if;
    exception when others then perform core.f_msg_errors(sqlstate,sqlerrm,'U');
    end;
    perform core.f_bp_after(pn_lpu,null,null,'er_visit_status_upd',pn_id);
end;
$function$
;
--[tr:er.tr_er_visit_status_a:n]
CREATE TRIGGER tr_er_visit_status_a AFTER INSERT OR DELETE OR UPDATE ON er.er_visit_status FOR EACH ROW EXECUTE PROCEDURE core.f_trigger_a();

--[f:er.f_er_elements8show_element:u]
CREATE OR REPLACE FUNCTION er.f_er_elements8show_element(pn_id bigint, pn_element_id bigint, ps_field text)
    RETURNS text
    LANGUAGE plpgsql
AS $function$
declare
    s_element_table 	         text;
    s_title	         text;
    s_description            text;
    s_person				 text;
    s_date_create			 text;
    s_sql				     text;
    s_ret_value            text;
begin
    /* pn_id - id из таблицы er_elements
     * pn_element_id - id из таблицы er_events из поля element_id
     * ps_field - функция ожидает название поля, значение которого необходимо вернуть:
     * - title
     * - description
     * - date_create */
    begin
        select btrim(t.element_table) as element_table,
               btrim(t.title) as title,
               btrim(t.description) as description,
               btrim(t.person) as person,
               btrim(t.date_create) as date_create
        into s_element_table, s_title, s_description, s_person, s_date_create
        from er.er_elements t
        where t.id = pn_id;
    exception when no_data_found then perform core.f_exc('Запись с id '||pn_id||' не найдена.');
    end;

    if ps_field = 'title' then
        s_sql := 'select ('||s_title|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    elseif ps_field = 'description' then
        s_sql := 'select ('||s_description|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    elseif ps_field = 'date_create' then
        s_sql := 'select ('||s_date_create|| ')::text from '||s_element_table||' where  ' || s_person || ' = $1::bigint';
    end if;

    if s_sql is null then return null;
    else
        begin
            execute s_sql using pn_element_id into strict s_ret_value;
        end;
        return s_ret_value;
    end if;
end;
$function$
;
