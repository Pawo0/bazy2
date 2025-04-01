create or replace view vw_reservation
            (
             reservation_id,
             country,
             trip_date,
             trip_name,
             firstname,
             lastname,
             status,
             trip_id,
             person_id,
             no_tickets)
as
select reservation_id,
       country,
       trip_date,
       trip_name,
       firstname,
       lastname,
       status,
       r.trip_id,
       r.person_id,
       no_tickets
from RESERVATION r
         inner join TRIP t on r.TRIP_ID = t.TRIP_ID
         inner join PERSON p on r.PERSON_ID = p.PERSON_ID;

create or replace view vw_trip
            (
             trip_id,
             country,
             trip_date,
             trip_name,
             max_no_places,
             no_available_places
                )
as
select t.trip_id,
       t.country,
       t.trip_date,
       t.trip_name,
       t.max_no_places,
       t.max_no_places - nvl(sum_tickets.total_tickets, 0) as no_available_places
from trip t
         left join
     (select trip_id,
             sum(no_tickets) as total_tickets
      from reservation
      where status <> 'C'
      group by trip_id) sum_tickets on t.trip_id = sum_tickets.trip_id;

create or replace view vw_available_trip
            (
             trip_id,
             country,
             trip_date,
             trip_name,
             max_no_places,
             no_available_places
                )
as
select vwt.*
from vw_trip vwt
where vwt.no_available_places > 0
  and vwt.trip_date > sysdate;

