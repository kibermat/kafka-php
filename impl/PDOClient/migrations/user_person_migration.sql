
set search_path to public;

CREATE TABLE IF NOT EXISTS user_person (
      "user"               bigint  NOT NULL ,
      person               bigint  NOT NULL ,
      "system"             integer  NOT NULL ,
      CONSTRAINT idx_user_person_unique UNIQUE ( "user", person, "system" )
);
COMMENT ON TABLE user_person IS 'связь пользователя и пациета';
COMMENT ON COLUMN user_person."user" IS 'Пользователь';
COMMENT ON COLUMN user_person.person IS 'Пациент';
COMMENT ON COLUMN user_person."system" IS 'Связь с внешней системой';


DO
$$
    begin
        set search_path to public;

        ALTER TABLE user_person ADD CONSTRAINT fk_user_persons_users FOREIGN KEY ( "user" ) REFERENCES users( id );
        ALTER TABLE user_person ADD CONSTRAINT fk_user_persons_er_persons_id FOREIGN KEY ( person ) REFERENCES er.er_persons( id );
        ALTER TABLE user_person ADD CONSTRAINT fk_user_person_system FOREIGN KEY ( "system" ) REFERENCES ext_systems( id );
    exception
        when others then raise notice 'pass %', sqlerrm;
    END
$$;


drop function if exists f_user_person8add(pn_user bigint, pn_person bigint, pn_system integer, OUT "user" bigint, OUT "person" bigint);
create function f_user_person8add(pn_user bigint, pn_person bigint, pn_system integer,
                                  OUT "user" bigint, OUT "person" bigint)
as
'
    insert into user_person ("user", person, "system")
    select t."user",
           t.person,
           t."system"
    from (values (pn_user, pn_person, pn_system)) as t ("user", person, "system")
             left join user_person as up using ("user", person, "system")
    where t."user" is not null and up."user" is null
    returning "user", "person"
'
    LANGUAGE SQL;
alter function f_user_person8add(bigint, bigint, integer, OUT bigint, OUT bigint) owner to dev;


drop function if exists f_user_person8upd(pn_user bigint, pn_person bigint, pn_system integer);
create function f_user_person8upd(pn_user bigint, pn_person bigint, pn_system integer) RETURNS void
as
'
    update user_person
    set ("user", person, "system") =
            (pn_user, pn_person, pn_system)
'
    LANGUAGE SQL;
alter function f_user_person8upd(bigint, bigint, integer) owner to dev;


drop function if exists f_user_person8del(pn_user bigint);
create function f_user_person8del(pn_user bigint) RETURNS void
as '
    delete from user_person
    where "user" = pn_user
'
    LANGUAGE SQL;
alter function f_user_person8del(bigint) owner to dev;
