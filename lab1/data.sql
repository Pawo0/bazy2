-- generacja danych


-- trip
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Wycieczka do Paryza', 'Francja', to_date('2023-09-12', 'YYYY-MM-DD'), 3);
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Piekny Krakow', 'Polska', to_date('2025-05-03','YYYY-MM-DD'), 2);
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Znow do Francji', 'Francja', to_date('2025-05-01','YYYY-MM-DD'), 2);
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Hel', 'Polska', to_date('2025-05-01','YYYY-MM-DD'), 2);

insert into trip(trip_name, country, trip_date, max_no_places)
values ('Zajecia', 'Wydzial', to_date('2027-12-11','YYYY-MM-DD'), 7);
insert into trip(trip_name, country, trip_date, max_no_places)
values ('Sladami Adolfa', 'Niemcy', to_date('1941-03-21','YYYY-MM-DD'), 7);
-- person
insert into person(firstname, lastname)
values ('Jan', 'Nowak');
insert into person(firstname, lastname)
values ('Jan', 'Kowalski');
insert into person(firstname, lastname)
values ('Jan', 'Nowakowski');
insert into person(firstname, lastname)
values ('Novak', 'Nowak');


insert into person(firstname, lastname)
values ('Maria', 'Curie');
insert into person(firstname, lastname)
values ('Adam', 'Malysz');
insert into person(firstname, lastname)
values ('Krzysztof', 'Piatek');
insert into person(firstname, lastname)
values ('Aleksandra', 'Matraszek');
insert into person(firstname, lastname)
values ('Zosia', 'Zych');
insert into person(firstname, lastname)
values ('Robert', 'Kubica');
-- reservation
-- trip1
insert into reservation(trip_id, person_id, status)
values (1, 1, 'P');
insert into reservation(trip_id, person_id, status)
values (1, 2, 'N');
-- trip 2
insert into reservation(trip_id, person_id, status)
values (2, 1, 'P');
insert into reservation(trip_id, person_id, status)
values (2, 4, 'C');
-- trip 3
insert into reservation(trip_id, person_id, status)
values (2, 4, 'P');

-- trip 4
insert into reservation(trip_id, person_id, status)
values (3, 7, 'P');
-- trip 5
insert into reservation(trip_id, person_id, status)
values (4, 6, 'N');
insert into reservation(trip_id, person_id, status)
values (4, 8, 'P');
insert into reservation(trip_id, person_id, status)
values (4, 10, 'P');
-- trip 6
insert into reservation(trip_id, person_id, status)
values (5, 1, 'P');
insert into reservation(trip_id, person_id, status)
values (5, 2, 'P');
-- trip 7
insert into reservation(trip_id, person_id, status)
values (6, 1, 'N');
insert into reservation(trip_id, person_id, status)
values (6, 2, 'P');





