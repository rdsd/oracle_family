select * from family; --comments hello

select lpad(' ', level * 2, ' ') || first_name as first_name
from family
start with mother_id is null
connect by nocycle prior id in (mother_id, father_id);

begin debug_pkg.p_debug_memo('test'); end;
select * from debug_memo; 
begin delete from debug_memo; commit; end;

begin family_pkg.p_remove_duplicate; end;

alter table family
add joined_date date default sysdate;

alter table family
add updated_date date default sysdate;

alter table family
add father_id integer;

create table child_parent
(
    child_parent_id integer,
    child_id integer,
    parent_id,
    constraint child_parent_pk primary key (child_parent_id),
    constraint child_parent_child_fk foreign key (child_id) references family(id),
    constraint child_parent_parent_fk foreign key (parent_id) references family(id)
);

create sequence child_parent_id_seq
    start with 1
    increment by 1
    maxvalue 999999999999999;

create or replace trigger tib_family
    before insert on family
    for each row
    begin
        :new.id := family_id_seq.nextval;
    exception when others then
        raise_application_error('-2001','exception during insert into family on trigger')    ;
    end;
/

create or replace trigger tib_child_parent
    before insert on child_parent
    for each row
    begin
        :new.child_parent_id := child_parent_id_seq.nextval;
    exception when others then
        raise_application_error('-2001','exception during insert into family on trigger')    ;
    end;
/