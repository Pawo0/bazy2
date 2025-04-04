-- function f_trip_participants

create or replace type trip_participants_info as OBJECT
(
    trip_id   int,
    person_id int,
    firstname varchar(50),
    lastname  varchar(50)

);
create or replace type trip_participants_info_table as table of trip_participants_info;


create or replace function f_trip_participants(
    searched_trip_id int
) return trip_participants_info_table
as
    result trip_participants_info_table := trip_participants_info_table();
begin
    select trip_participants_info(
                   r.trip_id,
                   r.person_id,
                   r.firstname,
                   r.lastname
           ) bulk collect
    into result
    from vw_reservation r
    where r.trip_id = searched_trip_id;

    return result;
end;


select *
from f_trip_participants(1);


-- function f_trip_participants

create or replace type person_reservation_info as OBJECT
(
    person_id int,
    firstname varchar(50),
    lastname  varchar(50),
    trip_id   int,
    trip_name varchar(100),
    country   varchar(50),
    trip_date date,
    status    char(1)
);
create or replace type person_reservation_info_table as table of person_reservation_info;

create or replace function f_person_reservation(
    searched_person_id int
) return person_reservation_info_table
as
    result person_reservation_info_table := person_reservation_info_table();
begin
    select person_reservation_info(
                   r.person_id,
                   r.firstname,
                   r.lastname,
                   r.trip_id,
                   r.trip_name,
                   r.country,
                   r.trip_date,
                   r.status
           ) bulk collect
    into result
    from vw_reservation r
    where r.person_id = searched_person_id;

    return result;
end;

select *
from f_person_reservation(6);


-- function available_trip_to
CREATE OR REPLACE TYPE available_trip_info AS OBJECT
(
    trip_id             INT,
    country             VARCHAR(50),
    trip_date           DATE,
    trip_name           VARCHAR(100),
    max_no_places       INT,
    no_available_places INT
);

CREATE OR REPLACE TYPE available_trip_info_table AS TABLE OF available_trip_info;


CREATE OR REPLACE FUNCTION f_available_trip_to(
    country_name VARCHAR2,
    date_from DATE,
    date_to DATE
) RETURN available_trip_info_table PIPELINED AS
BEGIN
    FOR rec IN (
        SELECT available_trip_info(
                   t.trip_id,
                   t.country,
                   t.trip_date,
                   t.trip_name,
                   t.max_no_places,
                   t.no_available_places
               ) AS trip_obj
        FROM vw_available_trip t
        WHERE t.country = country_name
          AND t.trip_date BETWEEN date_from AND date_to
    ) LOOP
        PIPE ROW (rec.trip_obj);
    END LOOP;

    RETURN;
END;
/

SELECT * FROM TABLE(f_available_trip_to('Francja', DATE '2024-04-01', DATE '2025-12-31'));

select *
from VW_AVAILABLE_TRIP;

SELECT * FROM USER_ERRORS WHERE NAME = 'F_AVAILABLE_TRIP_TO';