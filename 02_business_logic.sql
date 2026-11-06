-- ФУНКЦИОНАЛЬНЫЕ ТРЕБОВАНИЯ

-- R1.1 Хранить профиль студента (личные данные, интересы и другое)

create function get_student_profile(p_id integer)
returns table(id_student integer, first_name varchar,last_name varchar, email varchar, phone varchar,date_of_birth date,
    rating numeric, faculty varchar, student_id_card varchar, verification_status text,is_banned boolean,late_cancel_count smallint
) as
$$
select id_student, first_name, last_name, email, phone, date_of_birth, rating, faculty, student_id_card, 
	verification_status::text, is_banned, late_cancel_count
from "Student"
where id_student = p_id;
$$
language sql;

-- Тест
-- Получение профиля существующего студента 
select * from get_student_profile(12);


-- R1.2 Создавать групповые чаты для обсуждения и хранить их историю

-- 1
create or replace function create_chat (trip_id integer) returns text
as
$$
insert into schema1."Chat" (messages, created_at, trip_id)
values ('[]', now(), trip_id);
select 'Success';
$$
language sql;

-- Тесты
-- Создание пустого чата
select create_chat(12)

-- Некорректное создание чата
select create_chat(1)

-- 2
create or replace function update_chat (cha_id integer, message jsonb) returns text
as
$$
begin
if not exists (select 1 from schema1."Chat" where chat_id = cha_id) then
return 'Chat with this id does not exist';
end if;

update schema1."Chat"
set messages = messages || message
where chat_id = cha_id;
return 'Success';
end
$$
language plpgsql;

-- Тесты
-- Добавление нового отправленного в чат сообщения
select update_chat (15, jsonb_build_object('id', 2, 'name', 'Марина', 'time', now(), 'message', 'йоу'))

-- Добавление сообщения в несуществующий чат
select update_chat (19, jsonb_build_object('id', 2, 'name', 'Марина', 'time', now(), 'message', 'йоу'))


-- R1.3 Уведомлять о новых сообщениях, изменениях в поездке

-- 1
create or replace function new_notif_sis (content text, user_id_receiver integer, user_id_sender integer) returns text
as
$$
insert into schema1."Notification" (type, created_at, content, user_id_receiver, user_id_sender)
values ('Системное', now(), content, user_id_receiver, user_id_sender);
select 'Success';
$$
language sql

-- Тесты
-- Отправка нового системного уведомления
select new_notif_sis('Пользователь Мария отправил заявку на вашу поездку', 3, 1)

-- Отправка системного уведомления несуществующему пользователю
select new_notif_sis('Пользователь Мария отправил заявку на вашу поездку', 10, 1)

-- 2
create or replace function new_notif_adm (content text, user_id_receiver integer) returns text
as
$$
insert into schema1."Notification" (type, created_at, content, user_id_receiver)
values ('Администраторское', now(), content, user_id_receiver);
select 'Success';
$$
language sql

-- Тесты
-- Отправка нового администраторского уведомления
select new_notif_adm('Администратор изменил статус модерации ваших документов на "Подтверждён"', 4)

-- Отправка администраторского уведомления несуществующему пользователю
select new_notif_adm('Администратор изменил статус модерации ваших документов на "Подтверждён"', 10)

-- 3
create or replace function new_notif_us (content text, user_id_receiver integer, user_id_sender integer) returns text
as
$$
insert into schema1."Notification" (type, created_at, content, user_id_receiver, user_id_sender)
values ('Пользовательское', now(), content, user_id_receiver, user_id_sender);
select 'Success';
$$
language sql

-- Тесты
-- Отправка нового пользовательского уведомления
select new_notif_us('Пользователь Мария написал в чат', 4, 1)

-- Отправка пользовательского уведомления несуществующему пользователю
select new_notif_us('Пользователь Мария написал в чат', 10, 1)

-- 4
create or replace function get_notif (user_id integer, filt_day date, filt_user integer) returns table (
created_at timestamp with time zone, content text, user_id_sender integer, user_id_receiver integer
)
as
$$
select created_at, content, user_id_sender, user_id_receiver from schema1."Notification"
where user_id_receiver = user_id and (filt_day is null or date(created_at) = filt_day) and
(filt_user is null or user_id_sender = filt_user)
$$
language sql;

-- Тесты
-- Вывод всех уведомлений пользователя
select * from get_notif(1, null, null)

-- Вывод уведомлений пользователя за определенную дату
select * from get_notif(1, '2026-05-10', null)

-- Вывод уведомлений пользователя от конкретного отправителя
select * from get_notif(4, null, 1)

-- Вывод уведомлений за дату, когда уведомлений нет
select * from get_notif(4, '2027-01-10', null)


-- R2.1 Создать проверку добавления пользователя к поездке

create or replace function schema1.check_student_can_join(p_student_id integer)
returns text as $$
declare
s schema1."Student"%rowtype;
begin
select * into s from schema1."Student" where id_student = p_student_id;
if not found then
return 'student not found';
end if;
if s.is_banned then return 'banned'; end if;
if s.verification_status not in ('Подтверждён', 'Студент подтвержден') then return 'not verified'; end if;
if s.late_cancel_count >= 3 then return 'blocked: late cancel limit'; end if;
return 'ok';
end;
$$ language plpgsql;

-- Тесты
-- Может ли студент быть добавлен
select schema1.check_student_can_join(1);

-- Проверка несуществующего студента
select schema1.check_student_can_join(999);


-- R2.2 Добавить модерацию новых пользователей с присвоением статусов (на проверке, подтверждён, отказано) 
-- и возможностью повторной загрузки

create or replace function set_verif_status (user_id integer, verif_status schema1.verification_type) returns text
as
$$
begin
if not exists (select 1 from schema1."Student" where id_student = user_id) then
return 'Student with this id does not exist';
end if;

update schema1."Student"
set verification_status = verif_status
where id_student = user_id;
return 'Succes';
end
$$
language plpgsql;

-- Тесты
-- Отказ в верификации 
select set_verif_status (2, 'Отказано')

-- Статус подтвержден
select set_verif_status (3, 'Подтверждён')

-- Подтверждение несуществующего студента 
select set_verif_status (999, 'Подтверждён')


-- R2.3 Внедрить систему оценки попутчиков после каждой поездки

-- 1
create or replace function schema1.find_replacement(s_faculty varchar, min_rating numeric)
returns table (first_name varchar, last_name varchar, rating numeric, contact varchar)
as
$$
select first_name, last_name, rating, phone
from schema1."Student"
where faculty = s_faculty 
and rating >= min_rating 
and verification_status = 'Студент подтвержден' 
and is_banned = false
$$
language sql

-- Тесты
-- Поиск замены для студента, фильтр по факультету и высокому рейтингу
select * from schema1.find_replacement('БИ', 4)

-- Поиск замены для студента, фильтр по факультету и завышенному рейтингу, которого в базе нет
select * from schema1.find_replacement('БИ', 6)

-- 2
create or replace view schema1.stud_rating as
select 
id_student,
first_name,
last_name,
count(id_trip) as total_created,
count(id_trip) filter (where status = 'Завершена') as successful_trips,
rating,
late_cancel_count,
case 
when rating >= 4.5 and late_cancel_count = 0 then 'Очень хороший'
when late_cancel_count >= 3 then 'Все плохо'
else 'Стандартный'
end as status_category
from schema1."Student"
join schema1."Trip" on id_student = creator_id
group by id_student, first_name, last_name, rating, late_cancel_count

-- Тесты
-- Фильтр по рейтингу >4 
SELECT * FROM schema1.stud_rating WHERE rating > 4;

-- Проверка статуса забаненных 
SELECT * FROM schema1.stud_rating WHERE account_status = 'Заблокирован';


-- R3.2 Хранить дату поездки

create or replace function schema1.search_trips(c_from varchar, c_to varchar, date_from timestamp with time zone, date_to timestamp with time zone)
returns table (id integer, trip_dep varchar, trip_to varchar, departure timestamp with time zone, free_seats integer, price numeric)
as
$$
select 
id_trip, 
departure_city,
destination_city,
departure_datetime, 
(available_seats - (select count(*)::int from schema1."Application"
where trip_id = id_trip and status != 'Отказ')),
cost_per_person
from schema1."Trip"
join schema1."Student" on creator_id = id_student
join schema1."Balance" on id_trip = trip_id
where departure_city = c_from 
and destination_city = c_to 
and departure_datetime >= date_from
and departure_datetime <= date_to
and verification_status = 'Студент подтвержден'
and status = 'Создана'
$$
language sql

-- Тест
-- Поиск в интервале дат, есть поездка в заданный период 
select * from schema1.search_trips('Москва', 'Казань', '2026-06-01 00:00', '2026-07-01 00:00')

-- Поиск в интервале дат, нет поездок в этот период в этот город 
select * from schema1.search_trips('Москва', 'Казань', '2026-08-01 00:00', '2026-09-01 00:00')


-- R3.3 Скрывать объявления, у которых дата поездки меньше нынешней

alter type schema1.trip_status add 'Неактуальна';

create function change_failed_trips() returns text
as
$$
update schema1."Trip" set status = 'Неактуальна' where departure_datetime < CURRENT_TIMESTAMP 
and status = 'Создана'
returning 'Поездка ' || id_trip || ' помечена как неактуальная';
$$
language sql;

-- Тест
-- Меняем статус не состоявшихся поездок с датой меньше текущей
select change_failed_trips();


-- R3.4 Добавить обновление статуса поездки при заполнении всех мест

-- 1
create or replace view schema1.trips_occupancy as
select 
id_trip,
departure_city,
destination_city,
departure_datetime,
available_seats,
count(id_request) filter (where a.status not in ('Завяка подана', 'Отказ')) as occupied_seats,
round((count(id_request) filter (where a.status not in ('Завяка подана', 'Отказ'))::numeric / nullif(available_seats, 0))* 100,2) as occupancy_percentage,
c.status as trip_status,
total_cost
from schema1."Trip" c
join schema1."Application" a on id_trip = a.trip_id
join schema1."Balance" b on id_trip = b.trip_id
where c.status != 'Отменена'
group by id_trip, departure_city, destination_city, departure_datetime, available_seats, c.status, total_cost

-- 2
create or replace function schema1.check_free_place(trip integer, student_id integer)
returns boolean
as
$$
select 
(available_seats > (select count(*) from schema1."Application" where trip_id = trip and status not in ('Завяка подана', 'Отказ'))) 
and status not in ('Завершена', 'Отменена')
from schema1."Trip"
where id_trip = trip
$$
language sql

--Тесты
-- Проверка возможности добавить студента в поездку, в поездке нет мест 
select schema1.check_free_place(10,10) as can_join

-- Проверка возможности добавить студента в поездку, в поездке есть места,
-- поездка не завершена
select schema1.check_free_place(20,10) as can_join

-- Проверка возможности добавить студента в поездку, несуществующая поездка
select schema1.check_free_place(100,10) as can_join


-- R4.1 Обновлять информацию о продвижении каждого попутчика в подготовке к поездке

create function update_pass_progress(application_id int, new_status text) returns text
as
$$
update schema1."Application" 
set status = new_status::schema1.application_status
where id_request = application_id returning 'Статус обновлен на: ' || new_status;
$$
language sql;

-- Тест
insert into schema1."Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Владивосток', '2026-06-15 14:00:00', 'Пешая', 12, 'Создана', CURRENT_TIMESTAMP, 1)

insert into schema1."Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Тула', '2026-02-15 14:00:00', 'Пешая', 3, 'Создана', CURRENT_TIMESTAMP, 1)

insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id)
values ('Завяка подана', CURRENT_TIMESTAMP, 500.00, false, 'Назначен', 14, 4)

-- Обновление статуса поездки: ‘заявка подана’ -> ‘состоит в поездке’
select update_pass_progress(8, 'Состоит в поездке');


-- R4.2 Сделать вывод сведений о попутчиках, которые могли бы заменить студента, отказавшегося от поездки
-- Функция find_replacement, реализованная ранее


-- R4.3 Приоритетно вывести информацию об этой поездке другим пользователям с указанием срочности

create or replace function schema1.get_soon_trips(days integer)
returns table (id integer, departure_city varchar, destination_city varchar, departure timestamp with time zone, seats_left integer)
as
$$
select 
id_trip, 
departure_city,
destination_city, 
departure_datetime,
(available_seats-(select count(*)::int from schema1."Application"
where trip_id = id_trip and status != 'Отказ'))
from schema1."Trip"
where status = 'Создана'
and departure_datetime > now()
and departure_datetime <=(now()+(days||' days')::interval)
and (available_seats > (select count(*)::int from schema1."Application"
where trip_id = id_trip and status != 'Отказ'))
$$
language sql

-- Тесты
-- Вывод поездок через заданное число дней где есть отказавшиеся,
-- случай когда все места заполнены
select * from schema1.get_soon_trips(100)

-- Вывод поездок через заданное число дней где есть отказавшиеся,
-- случай когда есть отказавшийся
update schema1."Application" 
set status = 'Отказ' 
where passenger_id = 9 and trip_id = 10
select * from schema1.get_soon_trips(100)

-- Вывод поездок через заданное число дней, но все поездки позже
select * from schema1.get_soon_trips(1)


-- R4.4 Добавить маркировку на аккаунт отказавшегося студента о том, что он в последний момент отменил поездку 

create or replace function ban_students_with_late_cancels()
returns table(id_student integer, first_name text, last_name text, is_banned boolean, late_cancel_count smallint) as
$$
update "Student"
set is_banned = true,
    late_cancel_count = late_cancels.cnt
from (
    select a.passenger_id, count(*) as cnt
    from "Application" a
    join "Trip" t on a.trip_id = t.id_trip
    where a.status = 'Отказ'
    and a.created_at > t.departure_datetime - interval '1 day'
    group by a.passenger_id
    having count(*) > 3
) late_cancels
where id_student = late_cancels.passenger_id
and is_banned = false
returning id_student, first_name, last_name, is_banned, late_cancel_count;
$$
language sql;

-- Тест
-- Блокировка студента за 4+ поздних отказа 
select * from ban_students_with_late_cancels();


-- R4.5 Убирать маркировку, если уважительность причины подтверждена у модератора 

create or replace function remove_ban (user_id integer) returns text
as
$$
begin
if not exists (select 1 from schema1."Student" where id_student = user_id) then
return 'Student with this id does not exist';
end if;

update schema1."Student"
set is_banned = false
where id_student = user_id;
return 'Succes';
end
$$
language plpgsql;

-- Тесты
-- Убираем маркировку студента, который подтвердил уважительность причины
update schema1."Student"
set is_banned = true
where id_student = 1;

select remove_ban (1)

-- Убираем маркировку у несуществующего студента
select remove_ban (10)

-- R5.1 Хранить информацию о совместных затратах на поездку со стороны каждого попутчика
-- 1
create or replace function schema1.get_payment(trip integer)
returns table (first_name varchar, last_name varchar, phone varchar, cost numeric, status_paid text)
as
$$
select 
first_name,
last_name, 
phone, 
individual_cost,
(case 
when payment_status in ('Оплачен', 'Принят') then 'Оплачено' 
else 'Не оплачено' 
end)::text
from schema1."Application"
join schema1."Student" on passenger_id = id_student
where trip_id = trip and status != 'Отказ'
$$
language sql

-- Тесты
-- Вывод финансового отчета по существующей поездке
select * from schema1.get_payment(10)

-- Вывод финансового отчета по несуществующей поездке
select * from schema1.get_payment(100)

-- 2
create or replace view schema1.money_left as
select 
departure_city, 
destination_city,
sum(case when payment_status in ('Оплачен', 'Принят') then individual_cost else 0 end) as collected_money,
sum(case when payment_status = 'Назначен' and a.status != 'Отказ' then individual_cost else 0 end) as debts
from schema1."Trip"
join schema1."Application" a on id_trip = trip_id
group by departure_city, destination_city


-- R5.2 Вывести рассчитанную сумму, которую должен каждый попутчик
-- Функция get_payment, реализованная ранее


-- R5.3 Завершать поездку только после подтверждения оплаты со стороны всех попутчиков
-- Функция get_payment, реализованная ранее




-- ТЕСТИРОВАНИЕ ФУНКЦ. ТРЕБОВАНИЙ И БИЗНЕС-ПРАВИЛ (ДОП.)

alter type schema1.verification_type add value'Подтверждён'
alter type schema1.verification_type add value'На проверке'
alter type schema1.verification_type add value'Отказано'
--вставляем данные
	
--Студенты
insert into schema1."Student" (id_student, email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values
(4,  'ttt@hse.ru', '!mfkmwep4', '+79160000002', 'Антонина', 'Лазаренко', '2006-01-01', 4, 'БИ', '450006', 0, false),
(5, 'debtor@hse.ru', 'b8wyeiey824h)', '+79160000003', 'Мария', 'Шагако', '2006-02-02', 3, 'БИ', '789123', 0, false),
(6, 'eguyegfu@hse.ru', 'fgueyg7=', '+79160000004', 'Мария', 'Чернышова', '2006-03-03', 5, 'БИ', '089010', 0, false)

--Поездка
insert into schema1."Trip" (id_trip, departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values(3, 'Москва', 'Минск', '2026-06-30 11:00:00+03', 'Пешая', 2, 'Создана', now(), 1)

--Заявка
insert into schema1."Application" (id_request, status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values (201, 'Собирает вещи', now(), 1500, true, 'Принят', 3, 4)
insert into schema1."Application" (id_request, status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values (202, 'Собирает вещи', now(), 1500, true, 'Назначен', 3, 5)
insert into schema1."Application" (id_request, status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values (203, 'Завяка подана', now(), 1500, false, 'Назначен', 3, 6)
--Баланс
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
values(3, 3000, 1500, false)
--R5.1 Хранить информацию о совместных затратах на поездку со стороны каждого попутчика
--вывод всех затрат студента (сколько всего заплатил)
select sum(individual_cost) as "Сумма затрат"from schema1."Application" where passenger_id = 4 and payment_status in ('Оплачен', 'Принят')
--R5.2 Вывести рассчитанную сумму, которую должен каждый попутчик
--вывод для конкретного студента его индивидуальной стоимости
select individual_cost, payment_status from schema1."Application" where passenger_id = 5
--вывод суммы к оплате от каждого для поездки
select id_trip, departure_city, destination_city, cost_per_person from schema1."Trip" join schema1."Balance" on id_trip = trip_id
--R5.4 Завершать поездку только после подтверждения оплаты со стороны всех попутчиков
--вывод для поездки сколько не оплатили
select trip_id, count(id_request) 
from schema1."Application" 
where payment_status != 'Оплачен' and payment_status != 'Принят' and status !='Завяка подана' and status !='Отказ'
group by trip_id
--если есть кто не оплатил нельзя закрывать баланс 
select a.trip_id from schema1."Balance" a
join schema1."Application" b on a.trip_id = b.trip_id 
where a.is_settled = true and b.payment_status != 'Оплачен' and b.payment_status != 'Принят'
--R3.4 Добавить автоматическое обновление статуса поездки при заполнении всех мест
--вывод количесва занятых и свободных мест
select id_trip, available_seats, (select count(*) from schema1."Application" where trip_id=id_trip and status !='Завяка подана' and status !='Отказ') as unavailable_seats
from schema1."Trip"
--правило 10: После начала поездки добавление новых участников запрещено
--вывод заявок на поездку которые после ее начала
select id_request, trip_id, a.created_at, departure_datetime
from schema1."Application" a
join schema1."Trip" on trip_id = id_trip
where a.created_at > departure_datetime

select * from schema1."Student"
--тесты для студента
--вставляем данные
insert into schema1."Student" (id_student, email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned, verification_status) 
values
(7, 'qwer@hse.ru', 'y475h)', '+79161111111', 'Данила', 'Левин', '2005-01-01', 5, 'БИ', '11111111', 0, false, 'Подтверждён'),
(8, 'bhjadj@hse.ru', 'NCDJKJF7:', '+79162222222', 'Татьяна', 'Таекина', '2005-03-05', 0, 'БИ', '22222564', 0, false, 'На проверке'),
(9, 'endwjk@hse.ru', 'bcehjwb6!', '+79163333333', 'Артем', 'Азимов', '2004-09-04', 5, 'БИ', '74859035', 4, false, 'Подтверждён'),
(10, 'ytho@hse.ru', 'hejb43<', '+79164444444', 'Признак', 'Камамбера', '2003-06-07', 1, 'БИ', '34628790', 1, false, 'Подтверждён')
--правило 1: Пользователь с неподтвержденной личностью может просматривать объявления, но не может создавать поездки или подавать заявки
--вывод студентов с неподтвержденным аккаунтом которые создали поездки
select id_student, first_name, verification_status, id_trip
from schema1."Student"
join schema1."Trip" on id_student = creator_id
where verification_status != 'Подтверждён'
--правило 5: При накоплении более 3 поздних отмен без обоснованной причины пользователь получает ограничение на бронирование новых поездок
--вывод студентов, у которых более 3 поздних отмен
select id_student, first_name, late_cancel_count, is_banned
from schema1."Student"
where late_cancel_count >3
--R2.3 Внедрить систему рейтингов после каждой поездки
--вывод студентов с плохим рейтингом чтобы админ мог обратить на них внимание
select id_student, first_name, rating
from schema1."Student"
where rating < 3 and rating > 0
--правило 4: В случае отмены поездки запись не удаляется из базы данных, а меняет статус на «отменено»
--проверка, что если студент забанен, его поездки отменены
select id_student, first_name, id_trip, status
from schema1."Student"
join schema1."Trip" on id_student = creator_id
where is_banned = true and status != 'Отменена'
--R2.2 Добавить модерацию загруженных документов с присвоением статусов (на проверке, подтверждён, отказано) и возможностью повторной загрузки
--вывод студентов со статусом на проверке, чтобы админ быстрее их верифицировал
select id_student, first_name, verification_status
from schema1."Student"
where verification_status = 'На проверке'
--R4.4 Добавить маркировку с описанием причины на аккаунт отказавшегося студента о том, что он в последний момент отменил поездку
--вывод студентов, которые имеют хотя бы одну позднюю отмену
select id_student, first_name, late_cancel_count, verification_status
from schema1."Student"
where late_cancel_count > 0


--ТЕСТИРОВАНИЕ TRIP
SELECT id_student, full_name FROM public.Student ORDER BY id_student;

-- Positive

-- Тест 1
INSERT INTO schema1.Trip (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, creator_id)
VALUES ('Москва', 'Санкт-Петербург', '2026-05-01 10:00:00','На поезде', 3, 'Создана', 1);

-- Тест 2
INSERT INTO schema1.Trip (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, creator_id) 
VALUES 
('Казань', 'Москва', '2026-05-02 12:00:00', 'На машине', 3, 'Создана', 1),
('Сочи', 'Краснодар', '2026-05-03 14:00:00', 'На самолете', 1, 'В пути', 2),
('Владимир', 'Суздаль', '2026-05-04 09:00:00', 'Пешая', 10, 'Создана', 4),
('Тверь', 'Клин', '2026-05-05 11:00:00', 'Другое', 5, 'Завершена', 2),
('Пермь', 'Киров', '2026-05-06 08:00:00', 'На машине', 2, 'В пути', 5),
('Самара', 'Уфа', '2026-05-07 10:00:00', 'На поезде', 4, 'Завершена', 3),
('Омск', 'Новосибирск', '2026-05-08 16:00:00', 'На самолете', 0, 'Отменена', 6);


-- Тест 3
UPDATE schema1.Trip 
SET status = 'В пути' 
WHERE status = 'Создана' 
  AND departure_city = 'Москва';

-- Тест 4
UPDATE schema1.Trip 
SET available_seats = available_seats - 1 
WHERE id_trip = 1 AND available_seats > 0;

-- Тест 5
UPDATE schema1.Trip 
SET status = 'Завершена' WHERE departure_city = 'Казань' AND status = 'В пути';

SELECT t.id_trip, t.departure_city, t.destination_city, t.trip_type, t.available_seats, t.status, s.full_name AS creator
FROM schema1.Trip t
JOIN public.Student s ON t.creator_id = s.id_student
ORDER BY t.id_trip;

--Negative

-- неверный тип поездки
INSERT INTO schema1.Trip (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, creator_id) 
VALUES ('Тула', 'Орел', '2026-05-09 09:00:00', 'на велосипеде', 1, 'Создана', 1);



--неверный статус
INSERT INTO schema1.Trip (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, creator_id) 
VALUES ('Ярославль', 'Кострома', '2026-05-10 10:00:00', 'На машине', 2, 'Приостановлена', 1);

--несуществующий студент
INSERT INTO schema1.Trip (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, creator_id) 
VALUES ('Псков', 'Новгород', '2026-05-12 12:00:00', 'На поезде', 3, 'Создана', 999);


SELECT departure_city, destination_city, departure_datetime, available_seats FROM schema1.Trip 
WHERE available_seats > 0;


--ТЕСТИРОВАНИЕ ADMIN
--Positive

-- Тест 1: Валидный email стандартного формата "@_._"
INSERT INTO Admin (email, password) 
VALUES ('admin@hse.ru', 'LevDan1!');
Select * from Admin


-- Тест 2: Валидный email с поддоменом
INSERT INTO Admin (email, password) 
VALUES ('admin.admin@edu.hse.ru', 'LevinDan1!');
Select * from Admin

-- Тест 3: Валидный email с цифрами в имени
INSERT INTO Admin (email, password) 
VALUES ('admin2403@hse.ru', 'LevinDan1!');
Select * from Admin

-- Тест 4: Пароль ровно 8 символов
INSERT INTO Admin (email, password) 
VALUES ('admin2@hse.ru', 'LevDan1!');
Select * from Admin

-- Тест 5: Пароль длиннее 8 символов со всеми категориями символов
INSERT INTO Admin (email, password) 
VALUES ('admin3@hse.ru', 'Levin$Danil@1!');
Select * from Admin

-- Тест 6: Пароль с несколькими спецсимволами и цифрами
INSERT INTO Admin (email, password) 
VALUES ('admin4@hse.ru', 'Lev#in$Dan%il0@1!');
Select * from Admin



--Negative

-- Тест 1: Невалидный email (нет символа @)
INSERT INTO Admin (email, password) 
VALUES ('admin.hse.ru', 'LevDan1!');


-- Тест 2: Невалидный email (нет домена после @)
INSERT INTO Admin (email, password) 
VALUES ('admin@hse', 'LevDan1!');


-- Тест 3: Невалидный email (нет имени до @)
INSERT INTO Admin (email, password) 
VALUES ('@hse.ru', 'LevDan1!');


-- Тест 4: Невалидный email
INSERT INTO Admin (email, password) 
VALUES ('admin@hse.', 'LevDan1!');


-- Тест 5: Дубликат email (нарушение уникальности)
INSERT INTO Admin (email, password) 
VALUES ('admin@hse.ru', 'LevDan1!');


-- Тест 6: Пароль короче 8 символов
INSERT INTO Admin (email, password) 
VALUES ('admin2403@hse.ru', 'Levin');


-- Тест 7: Пароль без заглавных букв
INSERT INTO Admin (email, password) 
VALUES ('admin2@hse.ru', 'danila');


-- Тест 8: Пароль без строчных букв
INSERT INTO Admin (email, password) 
VALUES ('admin4@hse.ru', 'LEVINDANILA1*');


-- Тест 9: Пароль без цифр
INSERT INTO Admin (email, password) 
VALUES ('newadmin@hse.ru', 'LEVINDANILa*!');


-- Тест 10: Пароль без спецсимволов
INSERT INTO Admin (email, password) 
VALUES ('newadmin2@hse.ru', 'LEVINDANILa');


-- Тест 11: Пароль NULL (нарушение NOT NULL)
INSERT INTO Admin (email, password) 
VALUES ('newadmin@hse.ru', NULL);


-- Тест 12: Email NULL (нарушение NOT NULL)
INSERT INTO Admin (email, password) 
VALUES (NULL, 'LEVINDANILa*!');

--

insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, is_banned, late_cancel_count)
values ('masha@hse.ru', '123456', '+79662744009', 'Мария', 'Шагако', '2007-01-12', 8.0, 'БИ', '12345678', false, 0)

insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, is_banned, late_cancel_count)
values ('egorka@hse.ru', '123457', '+78005553535', 'Егор', 'Крид', '2007-01-10', 3.0, 'УБ', '12345699', false, 0)


insert into schema1."Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Владивосток', '2026-06-15 14:00:00', 'Пешая', 12, 'Создана', CURRENT_TIMESTAMP, 1)

insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id)
values ('Завяка подана', CURRENT_TIMESTAMP, 500.00, false, 'Назначен', 2, 2)
delete from schema1."Application" where trip_id = 2 and passenger_id = 1;

--ТЕСТИРОВАНИЕ ЧАТ
--тест R1.2. Создавать групповые чаты для обсуждения и хранить их историю
select * from schema1."Chat" where trip_id = 2;

insert into schema1."Chat" (messages, created_at, trip_id)
values ('[{"id": 1, "name": "Мария", "message": "хелоу", "time": "2026-04-25 12:30:00+03"}]', CURRENT_TIMESTAMP, 2)

--R1.2 Проверим что чат создан
select exists (select 1 from schema1."Chat" where trip_id = 2) as chat_exists;

--Проверим, что сообщение сохранено в истории
select jsonb_array_length(messages) as message_count, messages::text as saved_messages from schema1."Chat" 
where trip_id = 2;



--R1.3 - после подтверждения участник может писать в чат
update schema1."Application"
set status = 'Состоит в поездке' where trip_id = 2 AND passenger_id = 2

insert into schema1."Chat" (messages, created_at, trip_id)
values ('[{"id": 2, "name": "Егор", "message": "возьми телефон детка", "time": "2026-04-26 23:30:00+03"}]', CURRENT_TIMESTAMP, 2)

select jsonb_array_length(messages) as message_count, messages::text as saved_messages from schema1."Chat" 
where trip_id = 2;



--ТЕСТИРОВАНИЕ УВЕДОМЛЕНИЯ
--R1.4 Уведомлять о новых сообщениях, изменениях в поездке
insert into schema1."Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('Пользовательское', CURRENT_TIMESTAMP, 'Егор написал: "Когда выезжаем?"', 2, 1)

-- Проверим, что уведомление есть у получателя
select * from schema1."Notification" where user_id_receiver = 1
-- Проверим, что уведомления нет у отправителя
select * from schema1."Notification" where user_id_receiver = 2     


