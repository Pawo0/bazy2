-- procedura do aktualizacji liczby dostepnych miejsc w podrozy
create or replace procedure calculate_available_places_for_trip(
    inp_trip_id int
) as
begin
    update trip t
    set no_available_places = (select nvl(max(t.max_no_places) - sum(r.no_tickets), 0)
                               from reservation r
                               where r.trip_id = t.trip_id
                                 and r.status <> 'C')
    where t.trip_id = inp_trip_id;
end;



create or replace procedure p_add_reservation_6(
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
        --     uzywa triggera validate_reservation
--     jesli nie ma miejsc to wywala blad

    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;

    begin
        calculate_available_places_for_trip(inp_trip_id);
    end;
end;


--     procedura do zmiany statusu rezerwacji

create or replace procedure p_modify_reservation_status_6(
    inp_reservation_id int,
    inp_status char
) as
    got_trip_id int;
begin
    begin
        update RESERVATION
        set status = inp_status
        where reservation_id = inp_reservation_id;
--     uzywa triggera validate_reservation_status

    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;

    select TRIP_ID
    into got_trip_id
    from RESERVATION
    where reservation_id = inp_reservation_id;

    begin
        calculate_available_places_for_trip(got_trip_id);
    end;
end;


--     procedura do zmiany ilosci biletow w rezerwacji
create or replace procedure p_modify_reservation_tickets_6(
    inp_reservation_id int,
    inp_no_tickets int
) as
    got_trip_id int;
begin
    begin
        update RESERVATION
        set no_tickets = inp_no_tickets
        where reservation_id = inp_reservation_id;
--     uzywa triggera validate_reservation_no_tickets
    exception
        when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            return;
    end;
    select TRIP_ID
    into got_trip_id
    from RESERVATION
    where reservation_id = inp_reservation_id;

    begin
        calculate_available_places_for_trip(got_trip_id);
    end;
end;