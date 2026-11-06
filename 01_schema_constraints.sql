-- СОЗДАНИЕ БД

--
-- PostgreSQL database dump
--

\restrict 5KgcUOhtcr2Dcz0QadmQjDLVhhNpEJhdCN4sDk1dOP9yAu8XWKraMepoQAIvlyj

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-12 04:19:56

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 16389)
-- Name: schema1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA schema1;


ALTER SCHEMA schema1 OWNER TO postgres;

--
-- TOC entry 866 (class 1247 OID 16391)
-- Name: application_status; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.application_status AS ENUM (
    'Завяка подана',
    'Состоит в поездке',
    'Купил билеты',
    'Собирает вещи',
    'В пути',
    'Отказ'
);


ALTER TYPE schema1.application_status OWNER TO postgres;

--
-- TOC entry 869 (class 1247 OID 16404)
-- Name: notification_types; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.notification_types AS ENUM (
    'Системное',
    'Администраторское',
    'Пользовательское'
);


ALTER TYPE schema1.notification_types OWNER TO postgres;

--
-- TOC entry 872 (class 1247 OID 16412)
-- Name: payment_status; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.payment_status AS ENUM (
    'Назначен',
    'Оплачен',
    'Принят'
);


ALTER TYPE schema1.payment_status OWNER TO postgres;

--
-- TOC entry 875 (class 1247 OID 16420)
-- Name: trip_status; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.trip_status AS ENUM (
    'Создана',
    'В пути',
    'Завершена',
    'Отменена'
);


ALTER TYPE schema1.trip_status OWNER TO postgres;

--
-- TOC entry 878 (class 1247 OID 16430)
-- Name: trip_type; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.trip_type AS ENUM (
    'На машине',
    'На поезде',
    'На самолете',
    'Пешая',
    'Другое'
);


ALTER TYPE schema1.trip_type OWNER TO postgres;

--
-- TOC entry 881 (class 1247 OID 16442)
-- Name: verification_type; Type: TYPE; Schema: schema1; Owner: postgres
--

CREATE TYPE schema1.verification_type AS ENUM (
    'Студент подтвержден',
    'Студент не подтвержден'
);


ALTER TYPE schema1.verification_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16447)
-- Name: Application; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Application" (
    id_request integer NOT NULL,
    status schema1.application_status,
    created_at timestamp with time zone,
    individual_cost numeric(10,2),
    ready_to_pay boolean,
    payment_status schema1.payment_status,
    trip_id integer,
    passenger_id integer
);


ALTER TABLE schema1."Application" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16451)
-- Name: Application_id_request_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Application_id_request_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Application_id_request_seq" OWNER TO postgres;

--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 221
-- Name: Application_id_request_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Application_id_request_seq" OWNED BY schema1."Application".id_request;


--
-- TOC entry 222 (class 1259 OID 16452)
-- Name: Balance; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Balance" (
    id_balance integer NOT NULL,
    total_cost numeric(10,2),
    cost_per_person numeric(10,2),
    is_settled boolean,
    trip_id integer
);


ALTER TABLE schema1."Balance" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16456)
-- Name: Balance_id_balance_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Balance_id_balance_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Balance_id_balance_seq" OWNER TO postgres;

--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 223
-- Name: Balance_id_balance_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Balance_id_balance_seq" OWNED BY schema1."Balance".id_balance;


--
-- TOC entry 224 (class 1259 OID 16457)
-- Name: Chat; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Chat" (
    chat_id integer NOT NULL,
    messages jsonb,
    created_at timestamp with time zone NOT NULL,
    trip_id integer NOT NULL,
    CONSTRAINT chat_trio_id_check CHECK ((trip_id >= 0))
);


ALTER TABLE schema1."Chat" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16463)
-- Name: Chat_chat_id_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Chat_chat_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Chat_chat_id_seq" OWNER TO postgres;

--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 225
-- Name: Chat_chat_id_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Chat_chat_id_seq" OWNED BY schema1."Chat".chat_id;


--
-- TOC entry 226 (class 1259 OID 16464)
-- Name: Notification; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Notification" (
    id_notification integer NOT NULL,
    type schema1.notification_types NOT NULL,
    created_at timestamp with time zone NOT NULL,
    content text NOT NULL,
    user_id_sender integer,
    user_id_receiver integer NOT NULL,
    CONSTRAINT notif_receiver_check CHECK ((user_id_receiver >= 0)),
    CONSTRAINT notif_sender_check CHECK ((user_id_sender >= 0))
);


ALTER TABLE schema1."Notification" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16470)
-- Name: Notification_id_notification_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Notification_id_notification_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Notification_id_notification_seq" OWNER TO postgres;

--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 227
-- Name: Notification_id_notification_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Notification_id_notification_seq" OWNED BY schema1."Notification".id_notification;


--
-- TOC entry 228 (class 1259 OID 16471)
-- Name: Student; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Student" (
    id_student integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    phone character varying(20) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    date_of_birth date NOT NULL,
    rating numeric(3,2),
    faculty character varying(100) NOT NULL,
    student_id_card character varying(50) NOT NULL,
    verification_status schema1.verification_type,
    is_banned boolean,
    late_cancel_count smallint
);


ALTER TABLE schema1."Student" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16477)
-- Name: Student_id_student_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Student_id_student_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Student_id_student_seq" OWNER TO postgres;

--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 229
-- Name: Student_id_student_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Student_id_student_seq" OWNED BY schema1."Student".id_student;


--
-- TOC entry 230 (class 1259 OID 16478)
-- Name: Trip; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1."Trip" (
    id_trip integer NOT NULL,
    departure_city character varying(25) NOT NULL,
    destination_city character varying(25) NOT NULL,
    departure_datetime timestamp(6) with time zone NOT NULL,
    trip_type schema1.trip_type NOT NULL,
    available_seats smallint,
    status schema1.trip_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    creator_id integer NOT NULL,
    CONSTRAINT av_seats_check CHECK ((available_seats >= 0)),
    CONSTRAINT dep_creator_check CHECK ((creator_id >= 0)),
    CONSTRAINT dep_datetime_check CHECK ((departure_datetime > CURRENT_TIMESTAMP))
);


ALTER TABLE schema1."Trip" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16482)
-- Name: Trip_id_trip_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1."Trip_id_trip_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1."Trip_id_trip_seq" OWNER TO postgres;

--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 231
-- Name: Trip_id_trip_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1."Trip_id_trip_seq" OWNED BY schema1."Trip".id_trip;


--
-- TOC entry 232 (class 1259 OID 16483)
-- Name: admin; Type: TABLE; Schema: schema1; Owner: postgres
--

CREATE TABLE schema1.admin (
    id_admin integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    CONSTRAINT admin_email_format CHECK (((email)::text ~ '^[A-Za-z0-9]+@[A-Za-z]+\.[A-Za-z]+$'::text)),
    CONSTRAINT admin_password_format CHECK (((length((password)::text) >= 8) AND ((password)::text ~ '[A-Z]'::text) AND ((password)::text ~ '[a-z]'::text) AND ((password)::text ~ '[0-9]'::text) AND ((password)::text ~ '[!@#$%^&*()_+\-=\[\]{};:''"\\|,.<>\/?]'::text)))
);


ALTER TABLE schema1.admin OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16489)
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: schema1; Owner: postgres
--

CREATE SEQUENCE schema1.admin_id_admin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE schema1.admin_id_admin_seq OWNER TO postgres;

--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 233
-- Name: admin_id_admin_seq; Type: SEQUENCE OWNED BY; Schema: schema1; Owner: postgres
--

ALTER SEQUENCE schema1.admin_id_admin_seq OWNED BY schema1.admin.id_admin;


--
-- TOC entry 4858 (class 2604 OID 16490)
-- Name: Application id_request; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Application" ALTER COLUMN id_request SET DEFAULT nextval('schema1."Application_id_request_seq"'::regclass);


--
-- TOC entry 4859 (class 2604 OID 16491)
-- Name: Balance id_balance; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Balance" ALTER COLUMN id_balance SET DEFAULT nextval('schema1."Balance_id_balance_seq"'::regclass);


--
-- TOC entry 4860 (class 2604 OID 16492)
-- Name: Chat chat_id; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Chat" ALTER COLUMN chat_id SET DEFAULT nextval('schema1."Chat_chat_id_seq"'::regclass);


--
-- TOC entry 4861 (class 2604 OID 16493)
-- Name: Notification id_notification; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Notification" ALTER COLUMN id_notification SET DEFAULT nextval('schema1."Notification_id_notification_seq"'::regclass);


--
-- TOC entry 4862 (class 2604 OID 16494)
-- Name: Student id_student; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Student" ALTER COLUMN id_student SET DEFAULT nextval('schema1."Student_id_student_seq"'::regclass);


--
-- TOC entry 4863 (class 2604 OID 16495)
-- Name: Trip id_trip; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Trip" ALTER COLUMN id_trip SET DEFAULT nextval('schema1."Trip_id_trip_seq"'::regclass);


--
-- TOC entry 4864 (class 2604 OID 16496)
-- Name: admin id_admin; Type: DEFAULT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1.admin ALTER COLUMN id_admin SET DEFAULT nextval('schema1.admin_id_admin_seq'::regclass);


--
-- TOC entry 5050 (class 0 OID 16447)
-- Dependencies: 220
-- Data for Name: Application; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Application" (id_request, status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) FROM stdin;
\.


--
-- TOC entry 5052 (class 0 OID 16452)
-- Dependencies: 222
-- Data for Name: Balance; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Balance" (id_balance, total_cost, cost_per_person, is_settled, trip_id) FROM stdin;
\.


--
-- TOC entry 5054 (class 0 OID 16457)
-- Dependencies: 224
-- Data for Name: Chat; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Chat" (chat_id, messages, created_at, trip_id) FROM stdin;
\.


--
-- TOC entry 5056 (class 0 OID 16464)
-- Dependencies: 226
-- Data for Name: Notification; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Notification" (id_notification, type, created_at, content, user_id_sender, user_id_receiver) FROM stdin;
1	Пользовательское	2026-04-12 00:32:47.981747+03	Написал в чат: всем привет!	2	1
\.


--
-- TOC entry 5058 (class 0 OID 16471)
-- Dependencies: 228
-- Data for Name: Student; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Student" (id_student, email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, verification_status, is_banned, late_cancel_count) FROM stdin;
1	aaaaa@hse.ru	!23twtwegu23qFF	+79160000000	Мария	Кретова	2000-05-15	4.50	БИ	12345678	\N	f	0
2	bb@hse.ru	!23twtwrgu23qFF	+79160770000	Марина	Кретова	2001-05-15	4.60	БИ	16345678	\N	f	0
\.


--
-- TOC entry 5060 (class 0 OID 16478)
-- Dependencies: 230
-- Data for Name: Trip; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1."Trip" (id_trip, departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id) FROM stdin;
2	Москва	Париж	2026-05-11 11:30:00+03	Пешая	4	Создана	2026-04-11 23:42:59.257388+03	1
\.


--
-- TOC entry 5062 (class 0 OID 16483)
-- Dependencies: 232
-- Data for Name: admin; Type: TABLE DATA; Schema: schema1; Owner: postgres
--

COPY schema1.admin (id_admin, email, password) FROM stdin;
\.


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 221
-- Name: Application_id_request_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Application_id_request_seq"', 1, false);


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 223
-- Name: Balance_id_balance_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Balance_id_balance_seq"', 1, false);


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 225
-- Name: Chat_chat_id_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Chat_chat_id_seq"', 6, true);


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 227
-- Name: Notification_id_notification_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Notification_id_notification_seq"', 5, true);


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 229
-- Name: Student_id_student_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Student_id_student_seq"', 2, true);


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 231
-- Name: Trip_id_trip_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1."Trip_id_trip_seq"', 8, true);


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 233
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: schema1; Owner: postgres
--

SELECT pg_catalog.setval('schema1.admin_id_admin_seq', 5, true);


--
-- TOC entry 4874 (class 2606 OID 16498)
-- Name: Application Application_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Application"
    ADD CONSTRAINT "Application_pkey" PRIMARY KEY (id_request);


--
-- TOC entry 4876 (class 2606 OID 16500)
-- Name: Balance Balance_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Balance"
    ADD CONSTRAINT "Balance_pkey" PRIMARY KEY (id_balance);


--
-- TOC entry 4878 (class 2606 OID 16502)
-- Name: Chat Chat_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Chat"
    ADD CONSTRAINT "Chat_pkey" PRIMARY KEY (chat_id);


--
-- TOC entry 4882 (class 2606 OID 16504)
-- Name: Notification Notification_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Notification"
    ADD CONSTRAINT "Notification_pkey" PRIMARY KEY (id_notification);


--
-- TOC entry 4884 (class 2606 OID 16506)
-- Name: Student Student_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Student"
    ADD CONSTRAINT "Student_pkey" PRIMARY KEY (id_student);


--
-- TOC entry 4892 (class 2606 OID 16508)
-- Name: Trip Trip_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Trip"
    ADD CONSTRAINT "Trip_pkey" PRIMARY KEY (id_trip);


--
-- TOC entry 4894 (class 2606 OID 16692)
-- Name: admin admin_email_unique; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1.admin
    ADD CONSTRAINT admin_email_unique UNIQUE (email);


--
-- TOC entry 4896 (class 2606 OID 16510)
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- TOC entry 4880 (class 2606 OID 16707)
-- Name: Chat chat_trip_id_unique; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Chat"
    ADD CONSTRAINT chat_trip_id_unique UNIQUE (trip_id);


--
-- TOC entry 4886 (class 2606 OID 16721)
-- Name: Student student_card_unique; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Student"
    ADD CONSTRAINT student_card_unique UNIQUE (student_id_card);


--
-- TOC entry 4888 (class 2606 OID 16717)
-- Name: Student student_email_unique; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Student"
    ADD CONSTRAINT student_email_unique UNIQUE (email);


--
-- TOC entry 4890 (class 2606 OID 16719)
-- Name: Student student_phone_unique; Type: CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Student"
    ADD CONSTRAINT student_phone_unique UNIQUE (phone);


--
-- TOC entry 4897 (class 2606 OID 16516)
-- Name: Application passenger_id; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Application"
    ADD CONSTRAINT passenger_id FOREIGN KEY (passenger_id) REFERENCES schema1."Student"(id_student) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 4898 (class 2606 OID 16521)
-- Name: Application trip_id; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Application"
    ADD CONSTRAINT trip_id FOREIGN KEY (trip_id) REFERENCES schema1."Trip"(id_trip) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 4899 (class 2606 OID 16526)
-- Name: Balance trip_id; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Balance"
    ADD CONSTRAINT trip_id FOREIGN KEY (trip_id) REFERENCES schema1."Trip"(id_trip) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 4900 (class 2606 OID 16531)
-- Name: Chat trip_id; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Chat"
    ADD CONSTRAINT trip_id FOREIGN KEY (trip_id) REFERENCES schema1."Trip"(id_trip) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 4901 (class 2606 OID 16536)
-- Name: Notification user_id_receiver; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Notification"
    ADD CONSTRAINT user_id_receiver FOREIGN KEY (user_id_receiver) REFERENCES schema1."Student"(id_student) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- TOC entry 4902 (class 2606 OID 16541)
-- Name: Notification user_id_sender; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Notification"
    ADD CONSTRAINT user_id_sender FOREIGN KEY (user_id_sender) REFERENCES schema1."Student"(id_student) ON UPDATE RESTRICT ON DELETE SET NULL;


--
-- -- Name: Trip creator_id; Type: FK CONSTRAINT; Schema: schema1; Owner: postgres
--

ALTER TABLE ONLY schema1."Trip"
    ADD CONSTRAINT creator_id FOREIGN KEY (creator_id) REFERENCES schema1."Student"(id_student) ON UPDATE RESTRICT ON DELETE CASCADE;

-- Completed on 2026-04-12 04:19:56

--
-- PostgreSQL database dump complete
--

\unrestrict 5KgcUOhtcr2Dcz0QadmQjDLVhhNpEJhdCN4sDk1dOP9yAu8XWKraMepoQAIvlyj


-- ОГРАНИЧЕНИЯ И ИХ ТЕСТИРОВАНИЕ

--Студент
--создание ограничений
SET search_path TO public, schema1;
alter table schema1."Student" 
alter column email set not null,
alter column password set not null,
alter column phone set not null,
alter column first_name set not null,
alter column last_name set not null,
alter column date_of_birth set not null,
alter column faculty set not null,
alter column student_id_card set not null

alter table schema1."Student" 
add constraint student_email_unique unique (email),
add constraint student_phone_unique unique (phone),
add constraint student_card_unique unique (student_id_card)

alter table schema1."Student" 
add constraint student_email_check check (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$')
    
add constraint student_phone_check check (phone ~ '^(\+7|8)[0-9]{10}$')
    
add constraint student_password_check check (length(password) >= 8 and password ~ '[A-Z]' and password ~ '[a-z]' and password ~ '[0-9]' and password ~ '[!@#$%^&*()_+\-=\[\]{};'':"\\|,.<>\/?]')

alter table schema1."Student" 
add constraint student_birth_date_check check (date_of_birth >= current_date - interval '140 years' and date_of_birth <= current_date - interval '16 years')

alter table schema1."Student" 
add constraint student_rating_check check (rating >= 0 and rating <= 5)

alter table schema1."Student" 
add constraint student_late_cancel_check check (late_cancel_count >= 0)

select * from schema1."Student" 

--правильное добавление
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaa@hse.ru','!23twtwegu23qFF','+79160000000','Мария','Кретова','2000-05-15',4.5,'БИ','12345678',0,false)
--неправильное добавление, неверный формат почты
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaahse.ru','!23twtegu23qFF','+79160000001','Мария','Шагако','2000-05-19',5,'БИ','12345878',4,false)
--неправильное добавление, неверный формат телефона
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaa@hse.ru','!23twte23qFF','+9160000001','Мария','Чернышова','2000-05-16',3,'БИ','12345878',1,false)
--неправильное добавление, неверный формат пароля
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaaaa@hse.ru','!23','+79160000001','Антонина','Лазаренко','2000-05-13',5,'БИ','12345878',1,false)
--неправильное добавление, возраст слишком маленький
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaaaa@hse.ru','23twtweg!u23qFF','+79160000001','Данила','Левин','2020-05-13',5,'БИ','12345878',1,false)
--неправильное добавление, рейтинг не входит в диапозон
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaaaa@hse.ru','23twtweg!u23qFF','+79160000001','Юрий','Саночкин','2000-05-13',-3,'БИ','12345878',1,false)
--неправильное добавление, отмен отрицательное число
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaaaa@hse.ru','23twtweg!u23qFF','+79160000001','Татьяна','Таекина','2000-05-13',3,'БИ','12345878',-1,false)
--неправильное добавление, такая почта уже есть
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaa@hse.ru','23twtweg!u23qFF','+79160000001','Татьяна','Таекина','2000-05-13',3,'БИ','12345878',1,false)
--неправильное добавление, нет обязательного поля
insert into schema1."Student" (email, password, phone, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaaaa@hse.ru','23twtweg!u23qFF','+79160000001','Саночкин','2000-05-13',3,'БИ','12345878',1,false)

--неправильная замена, такой телефон уже есть
update schema1."Student" set phone='+79160000000' where student_id_card='12345878'
--неправильная замена, фамилия не может быть null
update schema1."Student" set last_name=null where student_id_card='12345878'
--неправильная замена, возраст больше 140
update schema1."Student" set date_of_birth='1800-05-13' where student_id_card='12345878'
--неправильная замена, нет такого статуса
update schema1."Student" set verification_status='студент подтвержден' where student_id_card='12345878'
--правильная замена
update schema1."Student" set verification_status='Студент подтвержден' where student_id_card='12345878'

--удаление забаненных студентов
update schema1."Student" set is_banned = true where student_id_card='12345878'
delete from schema1."Student" where is_banned = true
select count(*) from schema1."Student" where is_banned = true



--Заявка
--создание ограничений
alter table schema1."Application" 
alter column status set not null,
alter column created_at set not null,
alter column individual_cost set not null,
alter column ready_to_pay set not null,
alter column payment_status set not null,
alter column trip_id set not null,
alter column passenger_id set not null

alter table schema1."Application" 
add constraint application_cost_check check (individual_cost >= 0)

alter table schema1."Application" 
add constraint application_ready_payment_check check (not (ready_to_pay = false and payment_status in ('Оплачен', 'Принят')))

alter table schema1."Application" 
add constraint application_cancel_check check (not (status = 'Отказ' and ready_to_pay = true))

alter table schema1."Application" 
add constraint application_payment_check check (not (status = 'Отказ' and payment_status in ('Оплачен', 'Принят')))

select * from schema1."Application"

--правильное добавление
insert into schema1."Trip" (id_trip, departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values (1,'Москва','Санкт-Петербург','2026-04-11 12:00:00+03','На машине',2,'Создана',now(),32)
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaa@hse.ru','23twtg!u23qFF','+79160000001','Юрий','Саночкин','2000-05-13',3,'БИ','12345878',1,false)
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('Собирает вещи', now(), 1000, true, 'Принят', 1,42)
--неправильное добавление, отрицательная цена
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('Собирает вещи', now(), -1000, true, 'Принят', 1,42)
--неправильное добавление, статус не может быть оплачен, если студент не готов оплатить
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('Собирает вещи', now(), 1000, false, 'Оплачен', 1,42)
--неправильное добавление, студент не может быть готов оплатить если статус отказ
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('Отказ', now(), 1000, true, 'Назначен', 1,42)
--неправильное добавление, студент не мог оплатить если статус отказ
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('Отказ', now(), 1000, false, 'Оплачен', 1,42)
--неправильное добавление, нет такого статуса
insert into schema1."Application" (status, created_at, individual_cost, ready_to_pay, payment_status, trip_id, passenger_id) 
values ('собирает вещи', now(), 1000, true, 'Принят', 1,42)

--правильная замена
update schema1."Application" set individual_cost = 1500 where passenger_id = 42
--неправильная замена, цена не может быть отрицательной
update schema1."Application" set individual_cost = -1500 where passenger_id = 42
--неправильное обновление, статус не может быть отказ, если студент готов оплатить
update schema1."Application" set status = 'Отказ' where passenger_id = 42
--неправильное обновление, created_at не может быть null
update schema1."Application" set created_at = null where passenger_id = 42

--удаление всех заявок на поездку
delete from schema1."Application" where trip_id = 1
--удаление всех заявок со статусом отказ
delete from schema1."Application" where status = 'Отказ'
--проверка что если удалить поездку то удалятся и ее заявки
delete from schema1."Trip" where id_trip = 1
select * from schema1."Application" 



--Баланс
--создание ограничений
alter table schema1."Balance" 
alter column trip_id set not null,
alter column total_cost set not null,
alter column cost_per_person set not null,
alter column is_settled set not null

alter table schema1."Balance" 
add constraint unique_trip_balance unique (trip_id)

alter table schema1."Balance" 
add constraint balance_total_cost_check check (total_cost >= 0)

alter table schema1."Balance" 
add constraint balance_cost_per_person_check check (cost_per_person >= 0)

alter table schema1."Balance" 
add constraint balance_cost_total_check check (cost_per_person <= total_cost)

select * from schema1."Balance"
--правильное добавление
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
select 1, 5000, 5000/available_seats, false from schema1."Trip" where id_trip = 1
--неправильное добавление нет поля trip_id
insert into schema1."Balance" (total_cost, cost_per_person, is_settled) 
values (5000, 1000, false)
--неправильное добавление, баланс для этой поездки уже есть
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
values (1, 3000, 500, true)
--неправильное добавление, отрицательная общая цена
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
values (1, -100, 50, false)
--неправильное добавление, отрицательная цена на человека
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
values (1, 1000, -10, false)
--неправильное добавление, цена на человека больше общей цены
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
values (1, 1000, 2000, false)

--правильное обновление
update schema1."Balance" set total_cost = 6000 where trip_id = 1
--неправильное обновление, цена на человека больше общей цены
update schema1."Balance" set cost_per_person = 10000 where trip_id = 1
--неправильное обновление, is_settled не может быть null
update schema1."Balance" set is_settled = null where trip_id = 1
--неправильное обновление, нельзя изменить trip_id на уже существующий
insert into schema1."Trip" (id_trip, departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values (2,'Санкт-Петербург','Казань','2026-04-11 11:30:00+03','На машине',3,'Создана',now(),32)
insert into schema1."Balance" (trip_id, total_cost, cost_per_person, is_settled) 
select 2, 5000, 5000/available_seats, false from schema1."Trip" where id_trip = 2
update schema1."Balance" set trip_id = 1 where trip_id = 2

--удаление всех оплаченных балансов
delete from schema1."Balance" where is_settled = true
--проверка что если удалить поездку то удалится и ее баланс
delete from schema1."Trip" where id_trip = 2
select * from schema1."Balance" 

SET search_path TO public, schema1;

SET search_path TO public, schema1;
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('aaaaa@hse.ru','!23twtwegu23qFF','+79160000000','Мария','Кретова','2000-05-15',4.5,'БИ','12345678',0,false)
insert into schema1."Student" (email, password, phone, first_name, last_name, date_of_birth, rating, faculty, student_id_card, late_cancel_count, is_banned) 
values('bb@hse.ru','!23twtwrgu23qFF','+79160770000','Марина','Кретова','2001-05-15',4.6,'БИ','16345678',0,false)
select * from "Student"


-- Поездка
-- создание ограничений
alter table "Trip"
alter column departure_city set not null,
alter column destination_city set not null,
alter column departure_datetime set not null,
add constraint dep_datetime_check
check (departure_datetime > CURRENT_TIMESTAMP),
alter column trip_type set not null,
add constraint av_seats_check check (available_seats >= 0),
alter column status set not null,
alter column created_at set not null,
add constraint dep_creator_check
check (creator_id >= 0),
alter column creator_id set not null;

--правильное добавление
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2026-05-11 11:30:00+03', 'Пешая', 3, 'Создана', CURRENT_TIMESTAMP, 1)
select * from "Trip"
--неправильное добавление: пропущено одно из обязательных полей
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2026-05-11 11:30:00+03', 'Пешая', 3, NULL, CURRENT_TIMESTAMP, 1)
--неправильное добавление: добавление завершенной поездки
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2025-05-11 11:30:00+03', 'Пешая', 3, 'Создана', CURRENT_TIMESTAMP, 1)
--неправильное добавление: отрицательное кол-во мест
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2026-05-11 11:30:00+03', 'Пешая', -3, 'Создана', CURRENT_TIMESTAMP, 1)
--неправильное добавление: не существующий тип поездки
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2026-05-11 11:30:00+03', 'asd', 3, 'Создана', CURRENT_TIMESTAMP, 1)
--неправильное добавление: не существующий статус поездки
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Москва', 'Париж', '2026-05-11 11:30:00+03', 'Пешая', 3, 'asd', CURRENT_TIMESTAMP, 1)

--правильное изменение
update "Trip" set available_seats=4 where id_trip=2;
select * from "Trip";
--неправильное изменение: отрицательное кол-во мест
update "Trip" set available_seats=-4 where id_trip=2;
--неправильное изменение: не существующий статус поездки
update "Trip" set status='qwe' where id_trip=2;

--удаление отмененной поездки
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Казань', 'Новосибирск', '2026-05-11 12:30:00+03', 'На самолете', 1, 'Создана', CURRENT_TIMESTAMP, 2);
select * from "Trip";
update "Trip" set status='Отменена' where id_trip=7;
delete from "Trip" where status='Отменена';
select * from "Trip" where status='Отменена';
--удаление завершенной поездки
insert into "Trip" (departure_city, destination_city, departure_datetime, trip_type, available_seats, status, created_at, creator_id)
values ('Казань', 'Новосибирск', '2026-05-11 12:30:00+03', 'На самолете', 1, 'Создана', CURRENT_TIMESTAMP, 2);
select * from "Trip";
update "Trip" set status='Завершена' where id_trip=8;
delete from "Trip" where status='Завершена';
select * from "Trip" where status='Завершена';


-- Уведомление
-- создание ограничений
alter table "Notification"
alter column type set not null,
alter column created_at set not null,
alter column content set not null,
add constraint notif_sender_check
check (user_id_sender >= 0),
add constraint notif_receiver_check
check (user_id_receiver >= 0),
alter column user_id_receiver set not null;

--правильное добавление
insert into "Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('Пользовательское', CURRENT_TIMESTAMP, 'Написал в чат: всем привет!', 1, 2);
insert into "Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('Системное', CURRENT_TIMESTAMP, 'Изменено имя пользователя', NULL, 2);
select * from "Notification";
--неправильное добавление: несуществующий тип уведомления
insert into "Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('asd', CURRENT_TIMESTAMP, 'Написал в чат: всем привет!', 1, 2);
--неправильное добавление: пропущено обязательное поле
insert into "Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('Пользовательское', NULL, 'Написал в чат: всем привет!', 1, 2);
--неправильное добавление: отрицательный id
insert into "Notification" (type, created_at, content, user_id_sender, user_id_receiver)
values ('Пользовательское', CURRENT_TIMESTAMP, 'Написал в чат: всем привет!', -1, 2);

--правильное изменение
update "Notification" set user_id_sender=2 where id_notification=1;
update "Notification" set user_id_receiver=1 where id_notification=1;
select * from "Notification";
--неправильное изменение: отрицательный id
update "Notification" set user_id_sender=-2 where id_notification=1;

--удаление уведомления
delete from "Notification" where id_notification=4;
select * from "Notification";


-- Админ
-- создание ограничений
alter table "admin"
alter column email set not null,
add constraint admin_email_unique unique (email),
add constraint admin_email_format 
check (email ~ '^[A-Za-z0-9]+@[A-Za-z]+\.[A-Za-z]+$'),
alter column password set not null,
add constraint admin_password_format
check(length(password) >= 8 and password ~ '[A-Z]' and password ~'[a-z]'
and password ~'[0-9]' and password ~'[!@#$%^&*()_+\-=\[\]{};:''"\\|,.<>\/?]');

--правильное добавление
insert into "admin" (email, password) values ('asd@mail.ru', 'fdFDG_1dsd');
select * from "admin";
--неправильное добавление: неправильный формат почты
insert into "admin" (email, password) values ('asdmail.ru', 'fdFDG_1dsd');
--неправильное добавление: пропущено обязательное поле
insert into "admin" (email, password) values ('asd@mail.ru', NULL);
--неправильное добавление: неправильный формат пароля
insert into "admin" (email, password) values ('asd@mail.ru', 'fdFDG1dsd');
--неправильное добавление: уже есть пользователь с такой почтой
insert into "admin" (email, password) values ('asd@mail.ru', 'dsddad_123DS');


--правильное изменение
update "admin" set email='asf@mail.ru' where id_admin=1;
update "admin" set password='fdfsfhjsFHDJFHS_43' where id_admin=1;
select * from "admin";
--неправильное изменение: неправильный формат почты
update "admin" set email='ads@mail?ru' where id_admin=1;
--неправильное изменение: неправильный формат пароля
update "admin" set password='hjfdhjf_43' where id_admin=1;


--удаление админа
delete from "admin" where id_admin=1;
select * from "admin";


-- Чат
-- создание ограничений
alter table "Chat"
alter column created_at set not null,
alter column trip_id set not null,
add constraint chat_trip_id_unique unique (trip_id),
add constraint chat_trio_id_check
check (trip_id>= 0),
alter column trip_id set not null;

--правильное добавление
insert into "Chat" (messages, created_at, trip_id)
values ('[{"id": 1, "name": "Мария", "message": "Привет)))", "time": "2026-04-12 12:30:00+03"}]', CURRENT_TIMESTAMP, 2);
select * from "Chat";
--неправильное добавление: добавление чата к несуществующей поездке
insert into "Chat" (messages, created_at, trip_id)
values (NULL, CURRENT_TIMESTAMP, 1);
--неправильное добавление: отрицательное id поездки
insert into "Chat" (messages, created_at, trip_id)
values ('[{"id": 1, "name": "Мария", "message": "Привет)))", "time": "2026-04-12 12:30:00+03"}]', CURRENT_TIMESTAMP, -2);
--неправильное добавление: пропущено обязательное значение
insert into "Chat" (messages, created_at, trip_id)
values ('[{"id": 1, "name": "Мария", "message": "Привет)))", "time": "2026-04-12 12:30:00+03"}]', CURRENT_TIMESTAMP, NULL);
--неправильное добавление: добавление второго чата для одной поездки
insert into "Chat" (messages, created_at, trip_id)
values ('[{"id": 2, "name": "Марина", "message": "приветик", "time": "2026-04-12 12:30:00+03"}]', CURRENT_TIMESTAMP, 2);

--правильное изменение
update "Chat" set messages='[{"id": 1, "name": "Мария", "message": "Привет!!", "time": "2026-04-12 12:30:00+03"}]' where chat_id=1;
select * from "Chat"
--неправильное изменение: нет такой поездки
update "Chat" set trip_id=1 where chat_id=1;

--удаление чата
delete from "Chat" where chat_id=1;
select * from "Chat";

