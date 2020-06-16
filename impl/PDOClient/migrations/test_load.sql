

select kafka.f_kafka_load_lpu('get-lpu-info');

select kafka.f_kafka_load_profile('get-profile-info');

select kafka.f_kafka_load_derections('get-direction-info');

select kafka.f_kafka_load_resources('get-resource');

select kafka.f_kafka_load_resource_person('get-resource-person');

select kafka.f_kafka_load_person('get-about-me');






with params(
            n_system,
            n_entity,
            n_person_id,
            "json_body"
    ) as (
    select 1,
           9,
           10722,
           '{
             "status": "ok",
             "unitcode": "er",
             "response": {
               "mis_code": "mis_bars",
               "agent_id": "405c91c5-45fc-4701-be0d-82f94a619249",
               "service": null,
               "patient": {
                 "snils": "00000060002",
                 "lname": "Тат",
                 "fname": "Ал",
                 "mname": "М",
                 "birthdate": "01.01.1970"
               },
               "policies": [
                 {
                   "polis_id": "3751682",
                   "type_id": "0",
                   "kind": "1",
                   "polis_ser": "РТ",
                   "polis_num": "0477811",
                   "p_date_beg": "01.03.2017",
                   "p_date_end": null
                 }
               ],
               "sites": [
                 {
                   "SITE_ID": "174723525",
                   "SITE_CODE": "01",
                   "SITE_NAME": "Участок01",
                   "LPU_ID": "10903",
                   "DIV_ID": "10903",
                   "PURPOSE": "Поликлиническая помощь (взрослая)",
                   "TYPE": "1"
                 },
                 {
                   "SITE_ID": "196103410",
                   "SITE_CODE": "number1",
                   "SITE_NAME": "Участок №1",
                   "LPU_ID": "426570",
                   "DIV_ID": "188234088",
                   "PURPOSE": "Поликлиническая помощь (взрослая)",
                   "TYPE": "1"
                 }
               ],
               "recipes": [
                 {
                   "recipe_uid": "175193824",
                   "type": null,
                   "datecreate": "23.03.2018",
                   "code": "011 8",
                   "drugs": [
                     {
                       "drug_uid": "175193825",
                       "drug": "Бусерелин",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175139708",
                   "type": null,
                   "datecreate": "22.03.2018",
                   "code": "011 1",
                   "drugs": [
                     {
                       "drug_uid": "175139709",
                       "drug": "Бусерелин",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175139705",
                   "type": null,
                   "datecreate": "22.03.2018",
                   "code": "011 6",
                   "drugs": [
                     {
                       "drug_uid": "175139706",
                       "drug": "Альфа-токоферол",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175139700",
                   "type": null,
                   "datecreate": "22.03.2018",
                   "code": "011 5",
                   "drugs": [
                     {
                       "drug_uid": "175139701",
                       "drug": "Азатиоприн",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175193851",
                   "type": null,
                   "datecreate": "23.03.2018",
                   "code": "011 9",
                   "drugs": [
                     {
                       "drug_uid": "175193852",
                       "drug": "Зидовудин",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175198845",
                   "type": null,
                   "datecreate": "23.03.2018",
                   "code": "011 10",
                   "drugs": [
                     {
                       "drug_uid": "175198846",
                       "drug": "Аллопуринол",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 },
                 {
                   "recipe_uid": "175198853",
                   "type": null,
                   "datecreate": "23.03.2018",
                   "code": "011 12",
                   "drugs": [
                     {
                       "drug_uid": "175198854",
                       "drug": "Азатиоприн",
                       "pack_count": "1",
                       "description": "по 1 таб. 1 раза в день"
                     }
                   ]
                 }
               ],
               "visits": [
                 {
                   "vis_uid": "221427149",
                   "mo": "Тест \"Городская поликлиника №3\"",
                   "mo_name": "Муниципальное учреждение здравоохранения \"Городская поликлиника №3\"",
                   "service": "Прием (осмотр, консультация) врача-терапевта первичныйТ",
                   "emp_fio": "Иванооов И1И1",
                   "vis_date": "09.04.2019",
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "221425524",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "322273878",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Прием (осмотр, консультация) врача-инфекциониста первичный",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": "08.06.2020",
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "322273495",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "186463915",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Профилактический прием (осмотр, консультация) врача-терапевта",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "185635902",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "МО_анализ_крови_ЛИС",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "185635897",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "МО_глюкоза_ЛИС в составе биохимии",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "185635900",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "МО_холестерин_ЛИС в составе биохимии",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "191241538",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Опрос (анкетирование) , направленное на выявление хронических неинфекционных заболеваний (до 75 лет)",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "191241529",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Измерение артериального давления",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": null,
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "185558104",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "316075805",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Офтальмология",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": "22.01.2020",
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "270373319",
                   "dir_info": null
                 },
                 {
                   "vis_uid": "270374323",
                   "mo": "Ямал Министерство Здравоохранения Республики Татарстан \"Республиканская Клиническая Офтальмологическая Больница\" ",
                   "mo_name": "РКОБ Государственное автономное учреждение здравоохранения \"Республиканская клиническая офтальмологическая больница Министерства здравоохранения Республики Татарстан\"",
                   "service": "Посещение терапевта первичный",
                   "emp_fio": "Кравцова О1И1",
                   "vis_date": "22.01.2020",
                   "cost": "0",
                   "status": "1",
                   "status_desc": "Оказана",
                   "recommend": null,
                   "source": null,
                   "source_desc": null,
                   "direction_uid": "270373765",
                   "dir_info": null
                 }
               ],
               "anthropometry": [
                 {
                   "meas_date": "25.11.1988",
                   "constitution": null,
                   "specification": [
                     {
                       "anthrop": "Рост (стоя)",
                       "a_value": "171",
                       "meas_name": "сантиметр"
                     }
                   ]
                 }
               ],
               "bulletins": [
                 {
                   "bull_uid": "9310169",
                   "types": "0",
                   "description": "2",
                   "datecreate": "28.10.2011",
                   "dateend": "03.11.2011",
                   "code": " 99958"
                 },
                 {
                   "bull_uid": "9310171",
                   "types": "0",
                   "description": "2",
                   "datecreate": "01.12.2011",
                   "dateend": null,
                   "code": " 99959"
                 },
                 {
                   "bull_uid": "9310179",
                   "types": "0",
                   "description": "2",
                   "datecreate": "28.10.2011",
                   "dateend": "03.11.2011",
                   "code": " 99963"
                 }
               ],
               "vaccinations": [
                 {
                   "vac_uid": "22577974",
                   "type": "Ревакцинация",
                   "title": "1R Дифтерия, столбняк: Схема 2",
                   "datecreate": "22.03.2014",
                   "mo_uid": "426570",
                   "mo_name": "6202 - Городская поликлиника",
                   "mo_adr": "231004327",
                   "caption": "1"
                 }
               ]
             }
           }
           '::jsonb
)

     --,   sites as (
select t.*,
       kafka.f_ext_entity_values8find(n_system, n_entity, t."LPU_ID")                                as mo_ext_id,
       kafka.f_ext_entity_values8find(n_system, n_entity, t."DIV_ID")                                as div_ext_id,
       kafka.f_ext_entity_values8rebuild(n_system, n_entity, t."SITE_ID", coalesce(t.action, 'add')) as ext_id
from params, jsonb_populate_recordset(null::kafka.ext_system_sites_type,
                                      json_body -> 'response' -> 'sites') as t
where t."SITE_CODE" is not null
    ),
     ext as (
         select t.*,
                mo.id  as mo,
                div.id as div
         from sites as t
                  join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                  left join er.er_mo div ON (t.div_ext_id = div.ext_id)
         where t.div_ext_id is null
            or div.id is not null
     ),
     cte as (
         select t.*,
                s.site_id as site_uuid,
                s.id      as id
         from ext as t
                  left join er.er_sites as s on s.ext_id = t.ext_id
     ),
     ins_sites(id, ext_id) as (
         select kafka.f_ext_sites8add(
                        t.ext_id,
                        uuid_generate_v1(),
                        mo,
                        div,
                        t."SITE_CODE",
                        t."SITE_NAME",
                        coalesce(t."DATE_BEGIN"::date, current_date),
                        t."DATE_END"::date,
                        t."FullInfo"::jsonb
                    ),
                t.ext_id
         from cte as t
                  left join er.er_mo mo ON (t.mo_ext_id = mo.ext_id)
                  left join er.er_mo div ON (t.div_ext_id = div.ext_id)
         where t.id is null
     ),
     upd_sites(none, id, ext_id) as (
         select kafka.f_ext_sites8upd(
                        t.id,
                        t.ext_id,
                        t.site_uuid,
                        t.mo,
                        t.div,
                        t."SITE_CODE",
                        t."SITE_NAME",
                        t."DATE_BEGIN"::date,
                        t."DATE_END"::date,
                        t."FullInfo"::jsonb
                    ) as none,
                t.id,
                t.ext_id
         from cte as t
         where t.id is not null
     ),
     all_sites(id, ext_id) as (
         select id, ext_id
         from ins_sites
         union
         select id, ext_id
         from upd_sites
     ),
     ins_person_sites as (
         select kafka.f_ext_person_sites8add(
                        ss.id,
                        n_person_id,
                        true,
                        p."PURPOSE",
                        p."TYPE",
                        null::jsonb)
         from params, all_sites as ss
                  join cte as p on ss.ext_id = p.ext_id
                  left join er.er_person_sites as ps on ps.sites_id = ss.id
         where ps.id is null
     ),
     upd_person_sites as (
         select kafka.f_ext_person_sites8upd(
                        ps.id,
                        ss.id,
                        n_person_id,
                        true,
                        p."PURPOSE",
                        p."TYPE",
                        null::jsonb)
         from params, er.er_person_sites as ps
                  join all_sites as ss on ps.sites_id = ss.id
                  join cte as p on ss.ext_id = p.ext_id
     ),
     cnt as (
         select count(1) as n
         from ins_person_sites
         union all
         select count(1) as n
         from upd_person_sites
     )
select sum(n)
from cnt;