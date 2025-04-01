-- modyfikacja tabeli RESERVATION i LOG
alter table RESERVATION
add no_tickets int;

alter table LOG
add no_tickets int;


-- dodanie kolumny no_tickets do tabeli RESERVATION i LOG
update RESERVATION
set no_tickets = 1
where RESERVATION_ID > 0;

update RESERVATION
set no_tickets = 2
where trip_id = 1 and person_id = 1;

-- dodanie danych do tabeli LOG i usunięcie rekordu
insert into LOG (reservation_id, log_date, status, no_tickets)
values (1, sysdate, 'N', 2);

insert into LOG (reservation_id, log_date, status, no_tickets)
values (2, sysdate, 'P', 5);

select * from LOG;

DELETE from LOG
where reservation_id = 2;