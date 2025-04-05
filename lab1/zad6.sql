alter table trip
    add
        no_available_places int;


create or replace procedure calculate_available_places
as
begin
    update trip t
    set no_available_places = max_no_places
    where trip_id is not null;


    update trip t
    set no_available_places = (select nvl(max(t.max_no_places) - sum(r.no_tickets), 0)
                               from reservation r
                               where r.trip_id = t.trip_id
                                 and r.status <> 'C')
    where t.trip_id in (select trip_id
                        from reservation r
                        where r.status <> 'C');
end;

begin
    calculate_available_places;
end;
