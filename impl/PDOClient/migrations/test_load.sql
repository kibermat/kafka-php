

select kafka.f_kafka_load_lpu('get-lpu-info');

select kafka.f_kafka_load_profile('get-profile-info');

select kafka.f_kafka_load_derections('get-direction-info');

select kafka.f_kafka_load_resources('get-resource');

select kafka.f_kafka_load_resource_person('get-resource-person');

select kafka.f_kafka_load_person('get-about-me');


---
-- update er.er_profiles set ext_id = 20 where ext_id is null
---


with map as (
    select t.*,
           kafka.f_ext_entity_values8find(1, 3, t.lpu)             as mo_ext_id,
           kafka.f_ext_entity_values8find(1, 3, t.div)             as div_ext_id,
           kafka.f_ext_entity_values8find(1, 3, t.profile_id)      as profile_ext_id,
           kafka.f_ext_entity_values8rebuild(1, 3, t.id, "action") as ext_id
    from jsonb_populate_recordset(null::kafka.ext_system_directions_type,
                                  '{
                                    "_url": "http://192.168.228.41/med2des/webservice/rpc/er/get_direction_info?agent_id=6739415",
                                    "status": "ok",
                                    "response": {
                                      "status": "ok",
                                      "agent_id": "6739415",
                                      "mis_code": "MIS_BARS",
                                      "ResultSet": {
                                        "RowSet": [
                                          {
                                            "id": "33230247",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "9",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230253",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "10",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230269",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "12",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230286",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "13",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230316",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "15",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33228415",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "7",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "30.09.2014"
                                          },
                                          {
                                            "id": "33230241",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "8",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230261",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "11",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230293",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "14",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230335",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "16",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33230342",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "17",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33253659",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "0",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "18",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "01.10.2014"
                                          },
                                          {
                                            "id": "33256228",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "1",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "19",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "08.10.2014"
                                          },
                                          {
                                            "id": "33256232",
                                            "lpu": "22712558",
                                            "kind": "Внешнее",
                                            "type": "Поликлиника",
                                            "allow": "1",
                                            "action": "add",
                                            "date_end": null,
                                            "dir_numb": "20",
                                            "lpu_name": "ОГБУЗ Калининград(Не менять код ЛПУ, тестирование реестров Ростова)",
                                            "date_begin": "08.10.2014"
                                          }
                                        ]
                                      }
                                    },
                                    "unitcode": "er"
                                  }'::jsonb
                                      -> 'response' -> 'ResultSet' -> 'RowSet') as t
)
select t.*,
       dir_type.id as dir_type
from map as t
         left join lateral (select id
                            from er.er_direction_type
                            where lower(label) = lower(t."type")) as dir_type on true
         left join er.er_mo mo on (t.mo_ext_id = mo.ext_id)
         left join er.er_mo div on (t.div_ext_id = div.ext_id)
         left join er.er_profiles pr on (t.profile_ext_id = pr.ext_id)
where (t.lpu is null or mo.id is not null)
  and (t.div is null or div.id is not null)
  and (t.profile_id is null or pr.id is not null)
;
