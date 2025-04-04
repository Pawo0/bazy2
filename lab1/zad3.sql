-- procedure p_add_reservation

create or replace procedure p_add_reservation(
    inp_trip_id int,
    inp_person_id int,
    inp_no_ticket int
) as
    got_country       varchar2(50);
    available_tickets int;
begin
    select COUNTRY
    into got_country
    from TRIP
    where trip_id = inp_trip_id;


    select count(*)
    into available_tickets
    from TABLE (F_AVAILABLE_TRIP_TO(got_country, sysdate, date '3000-01-01')) t
    where t.trip_id = inp_trip_id;


    if available_tickets < inp_no_ticket then
        raise_application_error(-20001, 'Not enough tickets available, or trip in future not found');
    end if;


    insert into RESERVATION
    (trip_id,
     person_id,
     no_tickets,
     status)
    values (inp_trip_id,
            inp_person_id,
            inp_no_ticket,
            'N');

    insert into LOG
    (reservation_id,
     log_date,
     status,
     no_tickets)
    values (S_RESERVATION_SEQ.currval,
            sysdate,
            'N',
            inp_no_ticket);
end;

declare
    inp_trip_id   int := 5;
    inp_person_id int := 6;
    inp_no_ticket int := 1;
begin
    p_add_reservation(inp_trip_id, inp_person_id, inp_no_ticket);
exception
    when others then
        dbms_output.put_line('Error: ' || sqlerrm);
end;


-- procedure p_modify_reservation_status

create or replace procedure p_modify_reservation_status(
    inp_reservation_id int,
    inp_status char
) as
    got_status            char(1);
    got_available_tickets int;
    got_trip_id           int;
    got_no_tickets        int;
begin
    dbms_output.put_line('Got reservation id: ' || inp_reservation_id);
    select status
    into got_status
    from RESERVATION
    where reservation_id = inp_reservation_id;
    dbms_output.put_line('Got status: ' || got_status);

    select trip_id, no_tickets
    into got_trip_id, got_no_tickets
    from RESERVATION
    where reservation_id = inp_reservation_id;
    dbms_output.put_line('Got trip id: ' || got_trip_id);

    select nvl(max(no_available_places), 0)
    into got_available_tickets
    from VW_TRIP vwt
    where vwt.trip_id = got_trip_id;

    DBMS_OUTPUT.PUT_LINE('Got status: ' || got_status);

    if inp_status = 'P' then
        if got_available_tickets < got_no_tickets then
            raise_application_error(-20001, 'Not enough tickets available');
        end if;
    end if;

    dbms_output.put_line('Got available tickets: ' || got_available_tickets);
    if inp_status = 'C' then
        if got_status = 'P' then
            raise_application_error(-20001, 'Cannot cancel paid reservation');
        end if;
    end if;
    dbms_output.put_line('Got no tickets: ' || got_no_tickets);

    update RESERVATION
    set status = inp_status
    where reservation_id = inp_reservation_id;

    dbms_output.put_line('Updated status: ' || inp_status);
    insert into LOG
    (reservation_id,
     log_date,
     status,
     no_tickets)
    values (inp_reservation_id,
            sysdate,
            inp_status,
            got_no_tickets);

    dbms_output.put_line('Inserted log: ' || inp_reservation_id || ' ' || inp_status || ' ' || got_no_tickets);
end;

-- test

select *
from RESERVATION;

DECLARE
    inp_reservation_id int     := 2;
    inp_status         char(1) := 'C';
BEGIN
    p_modify_reservation_status(inp_reservation_id, inp_status);
    dbms_output.put_line('Reservation status updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: ' || SQLERRM);
END;
/


-- procedura p_modify_reservation

create or replace procedure p_modify_reservation(
    inp_reservation_id int,
    inp_no_tickets int
) as
    curr_no_tickets int;
begin
    if inp_no_tickets < 1 then
        raise_application_error(-20001, 'Number of tickets must be greater than 0');
    end if;

    begin
        select nvl(NO_TICKETS, 0)
        into curr_no_tickets
        from RESERVATION
        where RESERVATION_ID = inp_reservation_id;
    exception
        when NO_DATA_FOUND then
            raise_application_error(-20001, 'Reservation does not exist');
    end;

    if curr_no_tickets = inp_no_tickets then
        raise_application_error(-20001, 'No change in number of tickets');
    end if;

    update RESERVATION
    set NO_TICKETS = inp_no_tickets,
        STATUS     = 'N'
    where RESERVATION_ID = inp_reservation_id;
    dbms_output.put_line('Updated number of tickets: ' || inp_no_tickets);

    insert into LOG
    (reservation_id,
     log_date,
     status,
     no_tickets)
    values (inp_reservation_id,
            sysdate,
            'N',
            inp_no_tickets);
    dbms_output.put_line('Inserted log: ' || inp_reservation_id || ' ' || 'N' || ' ' || inp_no_tickets);

end;

-- test

select *
from RESERVATION;

select *
from VW_TRIP;

DECLARE
    inp_reservation_id int := 21;
    inp_no_tickets     int := 2;
BEGIN
    p_modify_reservation(inp_reservation_id, inp_no_tickets);
    dbms_output.put_line('Reservation modified successfully.');
end;


-- procedure p_modify_max_no_places

create or replace procedure p_modify_max_no_places(
    inp_trip_id int,
    inp_max_no_places int
) as
    curr_max_no_places       int;
    curr_min_no_tickets      int;
begin
    if inp_max_no_places < 1 then
        raise_application_error(-20001, 'Max number of places must be greater than 0');
    end if;


    begin
        select nvl(MAX_NO_PLACES, 0),
               nvl(MAX_NO_PLACES, 0) - nvl(NO_AVAILABLE_PLACES, 0) as min_no_tickets
        into curr_max_no_places, curr_min_no_tickets
        from VW_TRIP
        where TRIP_ID = inp_trip_id;
    exception
        when NO_DATA_FOUND then
            raise_application_error(-20001, 'Trip does not exist');
    end;

    if curr_max_no_places = inp_max_no_places then
        raise_application_error(-20001, 'No change in max number of places');
    end if;

    if inp_max_no_places < curr_min_no_tickets then
        raise_application_error(-20001, 'Cannot reduce max number of places below current reservations');
    end if;


    update TRIP
    set MAX_NO_PLACES = inp_max_no_places
    where TRIP_ID = inp_trip_id;
    dbms_output.put_line('Updated max number of places: ' || inp_max_no_places);
end;

-- test

select * from vw_trip;

DECLARE
    inp_trip_id       int := 4;
    inp_max_no_places int := 1;
begin
    p_modify_max_no_places(inp_trip_id, inp_max_no_places);
    dbms_output.put_line('Max number of places modified successfully.');
end;