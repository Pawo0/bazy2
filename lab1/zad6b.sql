-- wylaczenie wczesniejszych triggerow

alter trigger validate_reservation disable;
alter trigger validate_reservation_no_tickets disable;
alter trigger validate_reservation_status disable;

create or replace procedure p_add_reservation_6b(
    inp_trip_id int,
    inp_person_id int,
    inp_no_ticket int
) as
begin
    begin
        insert into RESERVATION (trip_id,
                                 person_id,
                                 no_tickets,
                                 status)
        values (inp_trip_id,
                inp_person_id,
                inp_no_ticket,
                'N');

    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;

end;

create or replace trigger validate_reservation_6b
    before insert
    on RESERVATION
    for each row
declare
    available_tickets int;
begin
    if :new.trip_id is null then
        raise_application_error(-20001, 'Trip ID cannot be null');
    end if;

    if :new.person_id is null then
        raise_application_error(-20002, 'Person ID cannot be null');
    end if;

    if :new.no_tickets <= 0 then
        raise_application_error(-20003, 'Number of tickets must be greater than zero');
    end if;

    if :new.status not in ('N', 'P') then
        raise_application_error(-20004, 'Status must be either N or P');
    end if;

    select nvl(no_available_places, 0)
    into available_tickets
    from vw_available_trip
    where trip_id = :new.trip_id;

    if available_tickets < :new.no_tickets then
        raise_application_error(-20005, 'Not enough available tickets');
    end if;

    begin
        calculate_available_places_for_trip(:new.trip_id);
    end;

    dbms_output.put_line('Available tickets: ' || available_tickets);
    dbms_output.put_line('New reservation: ' || :new.trip_id || ', ' || :new.person_id || ', ' || :new.no_tickets);
end;


--     procedura do zmiany statusu rezerwacji

create or replace procedure p_modify_reservation_status_6(
    inp_reservation_id int,
    inp_status char
) as
begin
    begin
        update RESERVATION
        set status = inp_status
        where reservation_id = inp_reservation_id;
--     uzywa triggera validate_reservation

    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;

end;


create or replace trigger validate_reservation_status_6b
    before update of status
    on RESERVATION
    for each row
declare
    available_tickets int;
    got_trip_id       int;
    got_no_tickets    int;
begin
    if :new.status not in ('N', 'P', 'C') then
        raise_application_error(-20006, 'Status must be either N, P or C');
    end if;
    if :new.status = 'C' then
        if :old.status = 'P' then
            raise_application_error(-20007, 'Cannot cancel paid reservation');
        end if;
    end if;
    if :new.status = 'P' then
        select trip_id, no_tickets
        into got_trip_id, got_no_tickets
        from RESERVATION
        where reservation_id = :old.reservation_id;

        select nvl(no_available_places, 0)
        into available_tickets
        from vw_available_trip
        where trip_id = got_trip_id;

        if available_tickets < got_no_tickets then
            raise_application_error(-20008, 'Not enough available tickets');
        end if;
    end if;

    begin
        calculate_available_places_for_trip(got_trip_id);
    end;

    dbms_output.put_line('Updated reservation: ' || :old.reservation_id || ', ' || :new.status);
end;


--     procedura do zmiany ilosci biletow w rezerwacji
create or replace procedure p_modify_reservation_tickets_6(
    inp_reservation_id int,
    inp_no_tickets int
) as
begin
    begin
        update RESERVATION
        set no_tickets = inp_no_tickets
        where reservation_id = inp_reservation_id;
    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;
end;

    create or replace trigger validate_reservation_no_tickets_6b
    before update of no_tickets
    on RESERVATION
    for each row
declare
    available_tickets int;
begin
    if :new.no_tickets <= 0 then
        raise_application_error(-20009, 'Number of tickets must be greater than zero');
    end if;

    select nvl(no_available_places, 0)
    into available_tickets
    from vw_available_trip
    where trip_id = :old.trip_id;

    if available_tickets < :new.no_tickets then
        raise_application_error(-20010, 'Not enough available tickets');
    end if;

    begin
        calculate_available_places_for_trip(:old.trip_id);
    end;

    dbms_output.put_line('Available tickets: ' || available_tickets);
end;