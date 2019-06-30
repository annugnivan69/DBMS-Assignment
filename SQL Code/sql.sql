CREATE TABLE movie(
	M_ID varchar(12) PRIMARY KEY,
	Name varchar(25) NOT NULL,
	Length number(4) NOT NULL,
	Rating varchar(25) NOT NULL,
	Synopsis varchar(300) DEFAULT 'No synopsis found.',
	Genre varchar(300) DEFAULT 'No info found.'
);

INSERT INTO movie(M_ID, Name, Length, Rating) VALUES ('M01', 'Avatar', 300, '13');
INSERT INTO movie(M_ID, Name, Length, Rating, Synopsis, Genre) VALUES ('M02', 'Avengers: Infinity War', 280, '13', '-', '-');
INSERT INTO movie(M_ID, Name, Length, Rating, Synopsis, Genre) VALUES ('M03', 'Avengers: Endgame', 246, '13', '-', '-');


CREATE TABLE hall(
	H_ID varchar(12) PRIMARY KEY
);

INSERT INTO hall(H_ID) VALUES ('H01');
INSERT INTO hall(H_ID) VALUES ('H02');
INSERT INTO hall(H_ID) VALUES ('H03');

CREATE TABLE showing_time(
	ST_ID varchar(12) PRIMARY KEY,
	ST_DATE date NOT NULL,
	ST_TIME varchar(5) NOT NULL,
	M_ID varchar(12) NOT NULL,		
	H_ID varchar(12) NOT NULL,
		CONSTRAINT st_fk_movie FOREIGN KEY (M_ID) REFERENCES movie(M_ID),
		CONSTRAINT st_fk_hall FOREIGN KEY (H_ID) REFERENCES hall(H_ID)
);

INSERT INTO showing_time(ST_ID, ST_DATE, ST_TIME, M_ID, H_ID) VALUES ('ST01', TO_DATE('01/01/19', 'DD/MM/YY'), '0830', 'M01', 'H01');
INSERT INTO showing_time(ST_ID, ST_DATE, ST_TIME, M_ID, H_ID) VALUES ('ST02', TO_DATE('03/01/19', 'DD/MM/YY'), '1030', 'M02', 'H03');
INSERT INTO showing_time(ST_ID, ST_DATE, ST_TIME, M_ID, H_ID) VALUES ('ST03', TO_DATE('27/01/19', 'DD/MM/YY'), '1400', 'M03', 'H01');

CREATE TABLE seats(
	S_Row varchar(1) NOT NULL,
	S_No varchar(2) NOT NULL,	
	H_ID varchar(12) NOT NULL,
		CONSTRAINT s_fk_hall FOREIGN KEY (H_ID) REFERENCES hall(H_ID),
	ST_ID varchar(12) NOT NULL,
		CONSTRAINT s_fk_showing_time FOREIGN KEY (ST_ID) REFERENCES showing_time(ST_ID),
	Price decimal(5,2) NOT NULL,
	Availability varchar(1) DEFAULT 'Y',
		constraint chk_avail CHECK(availability in ('Y', 'N')),
		CONSTRAINT s_pk PRIMARY KEY (S_Row, S_No, H_ID, ST_ID)
);

INSERT INTO seats(S_Row, S_No, H_ID, ST_ID, Price, Availability) VALUES ('A', '1', 'H01', 'ST01', '5.00', 'Y');
INSERT INTO seats(S_Row, S_No, H_ID, ST_ID, Price, Availability) VALUES ('H', '22', 'H03', 'ST02', '10.00', 'Y');
INSERT INTO seats(S_Row, S_No, H_ID, ST_ID, Price, Availability) VALUES ('J', '6', 'H01', 'ST03', '10.00', 'Y');

CREATE TABLE employee(
	E_ID varchar(12) PRIMARY KEY,
	E_Name varchar(30) NOT NULL,
	Position varchar(30) NOT NULL
);

					--SELECT seats.S_Row, seats.S_No, seats.H_ID, seats.ST_ID, s.Availability
					--FROM seats 
					--JOIN ticket


INSERT INTO employee(E_ID, E_Name, Position) VALUES ('E01', 'John', 'Manager');
INSERT INTO employee(E_ID, E_Name, Position) VALUES ('E02', 'Mary', 'Cashier');

CREATE TABLE ticket(
	T_ID varchar(12) PRIMARY KEY,
	ST_ID varchar(12) NOT NULL,
	H_ID varchar(12) NOT NULL,
	S_Row varchar(1) NOT NULL,
	S_No varchar(2) NOT NULL,
	CONSTRAINT t_fk_seats FOREIGN KEY (S_Row, S_No, ST_ID, H_ID) REFERENCES seats(S_Row, S_No, ST_ID, H_ID)
);
	
--trigger to look or unavailable seat
CREATE OR REPLACE TRIGGER Ticket_Seat_Avail
BEFORE INSERT ON ticket
for each row
DECLARE
	v_s_row varchar(1);
	v_s_seat varchar(2);
	v_seat_avail seats.Availability%Type;
BEGIN
	v_s_row := :new.S_Row;
	v_s_seat := :new.S_No;

	select Availability into v_seat_avail
	from seats
	WHERE S_Row = v_s_row and S_No = v_s_seat;

	if v_seat_avail = 'N' then
		raise_application_error(-20069, 'Seat is taken');
	end if;
END;
/

--trigger to mark taken seats as taken
CREATE OR REPLACE TRIGGER Seat_Sold
AFTER INSERT ON ticket
FOR EACH ROW 
declare
	v_s_row varchar(1);
	v_s_seat varchar(2);
BEGIN
	v_s_row := :new.S_Row;
	v_s_seat := :new.S_No;

	update seats
	set Availability = 'N'
	WHERE S_Row = v_s_row and S_No = v_s_seat;
END;
/

CREATE ROLE manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON ticket TO manager;
GRANT SELECT ON showing_time TO manager;
CREATE USER john IDENTIFIED BY pwd;
GRANT manager TO john;

CREATE ROLE cashier;
GRANT INSERT ON ticket TO cashier;
GRANT SELECT ON showing_time TO cashier;
CREATE USER mary IDENTIFIED BY pwd;
GRANT cashier TO mary;
