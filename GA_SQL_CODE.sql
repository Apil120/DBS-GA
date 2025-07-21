DELIMITER // 
CREATE SCHEMA DBS_GROUP_PROJECT;
USE DBS_GROUP_PROJECT;

-- Table Creations
CREATE TABLE Users(
    user_id VARCHAR(7) PRIMARY KEY, 
    userName VARCHAR(50),
    email VARCHAR(70),
    contact_no VARCHAR(14)
);

CREATE TABLE Preferences(
    pref_id VARCHAR(8) PRIMARY KEY, 
    genre VARCHAR(25),
    pref_language VARCHAR(25),
    director VARCHAR(25),
    actor VARCHAR(25),
    length ENUM("Short","Medium","Long")
);

CREATE TABLE UserPreferences (
    userPrefid INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(7),
    pref_id VARCHAR(8),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (pref_id) REFERENCES Preferences(pref_id)
);

CREATE TABLE Theater(
    theater_id VARCHAR(9) PRIMARY KEY, 
    location VARCHAR(25),
    num_screen INT
);

CREATE TABLE Screen(
    screen_id VARCHAR(7) PRIMARY KEY,
    theater_id VARCHAR(9),
    total_seats INT,
    FOREIGN KEY (theater_id) REFERENCES Theater(theater_id)
);

CREATE TABLE Seat(
    seat_id VARCHAR(6) PRIMARY KEY,
    screen_id VARCHAR(7),
    seat_label VARCHAR(3),
    class ENUM("Gold","Silver","Economy"),
    is_booked BOOL,
    FOREIGN KEY (screen_id) REFERENCES Screen(screen_id)
);

CREATE TABLE Movie(
    movie_id VARCHAR(7) PRIMARY KEY, 
    title VARCHAR(45),
    language VARCHAR(15), 
    duration_in_mins INT,
    genre VARCHAR(15),
    rating INT CHECK (rating BETWEEN 1 AND 5), 
    company VARCHAR(125)
);

CREATE TABLE Pricings(
    price_id VARCHAR(7) PRIMARY KEY, 
    gold INT,
    silver INT,
    economy INT,
    valid_from DATETIME,
    valid_to DATETIME
);

CREATE TABLE Shows(
    show_id VARCHAR (8) PRIMARY KEY, 
    movie_id VARCHAR(7),
    screen_id VARCHAR(7),
    show_datetime DATETIME,
    price_id VARCHAR(7),
    show_status ENUM ("Scheduled","Rescheduled","Cancelled"),
    updated_at DATETIME,
    cancel_reason TEXT,
    cancel_datetime DATETIME,
    FOREIGN KEY (price_id) REFERENCES Pricings(price_id)
);

CREATE TABLE ShowChanges(
    change_id VARCHAR(7) PRIMARY KEY, 
    show_id VARCHAR (8),
    old_date DATETIME,
    new_date DATETIME,
    changed_on DATETIME,
    reason TEXT,
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

-- Trigger for ShowChanges: Automatically updates show_status in Shows table
CREATE TRIGGER trg_AfterInsertShowChange
AFTER INSERT ON ShowChanges
FOR EACH ROW
BEGIN
    UPDATE Shows
    SET
        show_status = 'Rescheduled',
        updated_at = NOW()
    WHERE
        show_id = NEW.show_id;
END //

CREATE TABLE Payment(
    payment_id VARCHAR(7) PRIMARY KEY, 
    method ENUM("Card","Cash","Online"),
    cardno VARCHAR(20) NULL
);

CREATE TABLE Bookings(
    booking_id VARCHAR(8) PRIMARY KEY, 
    show_id VARCHAR (8),
    seat_id VARCHAR(6),
    user_id VARCHAR(7) ,
    booking_datetime DATETIME,
    payment_id VARCHAR(7),
    booking_status ENUM ("Booked","Cancelled"),
    cancel_reason TEXT,
    FOREIGN KEY (show_id) REFERENCES Shows(show_id),
    FOREIGN KEY (seat_id) REFERENCES Seat(seat_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (payment_id) REFERENCES Payment(payment_id)
);

CREATE TABLE Refund(
    refund_id VARCHAR(7) PRIMARY KEY, 
    booking_id VARCHAR(8),
    amount INT,
    refund_method ENUM ("Original","Voucher"),
    refund_datetime DATETIME,
    refund_status ENUM("Pending","Processed","Failed"),
    reason TEXT,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

CREATE TABLE Cancellations(
    cancel_id VARCHAR(7) PRIMARY KEY, 
    booking_id VARCHAR(8),
    show_id VARCHAR(8),
    cancelled_by ENUM ("User","System","Admin"),
    reason TEXT,
    cancel_datetime DATETIME,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

-- Trigger for Booking Cancellations: Automatically updates booking_status in Bookings table
CREATE TRIGGER trg_AfterInsertBookingCancellation
AFTER INSERT ON Cancellations
FOR EACH ROW
BEGIN
    -- Update the booking_status in the Bookings table to 'Cancelled'
    -- when a new cancellation record is inserted.
    UPDATE Bookings
    SET
        booking_status = 'Cancelled',
        cancel_reason = NEW.reason
    WHERE
        booking_id = NEW.booking_id;
END //

-- Trigger for Show Cancellations: Automatically updates show_status in Shows table if cancelled by System/Admin
CREATE TRIGGER trg_AfterInsertShowCancellation
AFTER INSERT ON Cancellations
FOR EACH ROW
BEGIN
    IF NEW.cancelled_by IN ('System', 'Admin') AND NEW.show_id IS NOT NULL THEN
        UPDATE Shows
        SET
            show_status = 'Cancelled',
            cancel_reason = NEW.reason,
            cancel_datetime = NEW.cancel_datetime,
            updated_at = NOW()
        WHERE
            show_id = NEW.show_id;
    END IF;
END //

-- Reset delimiter
DELIMITER ;

-- Data Insertions
INSERT INTO Users (user_id, userName, email, contact_no) VALUES
('USR-001', 'Apil Adhikari', 'apil.adhikari@gmail.com', '+9779812345678'),
('USR-002', 'Bob Johnson', 'bob.j@gmail.com', '+9779823456789'),
('USR-003', 'Aarogya Kuikel', 'aarogya.kuikel@gmail.com', '+9779834567890'),
('USR-004', 'Ram Shah', 'ram.shah@gmail.com', '+9779845678901'),
('USR-005', 'Eve Adams', 'eve.a@gmail.com', '+9779856789012'),
('USR-006', 'Frank Ocean', 'frank.o@gmail.com', '+9779867890123'),
('USR-007', 'Franz Kafka', 'franz.k@gmail.com', '+9779878901234'),
('USR-008', 'Fyodor Dostoevsky', 'fyodor.d@gmail.com', '+9779889012345'),
('USR-009', 'Subit Timalsina', 'subit .t@gmail.com', '+9779890123456'),
('USR-010', 'Jack Black', 'jack.b@gmail.com', '+9779801234567');

INSERT INTO Preferences (pref_id, genre, pref_language, director, actor, length) VALUES
('PREF-001', 'Action', 'English', 'Christopher Nolan', 'Tom Hardy', 'Long'),
('PREF-002', 'Comedy', 'Nepali', 'Ram Krishna', 'Hari Bansha', 'Medium'),
('PREF-003', 'Drama', 'Hindi', 'Karan Johar', 'Shah Rukh Khan', 'Long'),
('PREF-004', 'Sci-Fi', 'English', 'Denis Villeneuve', 'Timothée Chalamet', 'Long'),
('PREF-005', 'Thriller', 'Korean', 'Bong Joon-ho', 'Song Kang-ho', 'Medium'),
('PREF-006', 'Animation', 'English', 'Pete Docter', 'Tom Hanks', 'Short'),
('PREF-007', 'Horror', 'English', 'James Wan', 'Patrick Wilson', 'Medium');

INSERT INTO UserPreferences (user_id, pref_id) VALUES
('USR-001', 'PREF-001'), ('USR-001', 'PREF-004'),
('USR-002', 'PREF-002'), ('USR-002', 'PREF-003'),
('USR-003', 'PREF-001'),
('USR-004', 'PREF-005'), ('USR-004', 'PREF-007'),
('USR-005', 'PREF-006'),
('USR-006', 'PREF-001'), ('USR-006', 'PREF-003'), ('USR-006', 'PREF-004'),
('USR-007', 'PREF-002'),
('USR-008', 'PREF-003'), ('USR-008', 'PREF-005'),
('USR-009', 'PREF-006'),
('USR-010', 'PREF-001');

INSERT INTO Theater (theater_id, location, num_screen) VALUES
('THEAT-001', 'Kathmandu', 3),
('THEAT-002', 'Pokhara', 2),
('THEAT-003', 'Lalitpur', 3);

INSERT INTO Screen (screen_id, theater_id, total_seats) VALUES
('SCR-001', 'THEAT-001', 150),
('SCR-002', 'THEAT-001', 120),
('SCR-003', 'THEAT-001', 100),
('SCR-004', 'THEAT-002', 130),
('SCR-005', 'THEAT-002', 90),
('SCR-006', 'THEAT-003', 140),
('SCR-007', 'THEAT-003', 110),
('SCR-008', 'THEAT-003', 95);


INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-001', 'SCR-001', 'A1', 'Gold', FALSE), ('ST-002', 'SCR-001', 'A2', 'Gold', FALSE), ('ST-003', 'SCR-001', 'A3', 'Gold', FALSE),
('ST-004', 'SCR-001', 'B1', 'Silver', FALSE), ('ST-005', 'SCR-001', 'B2', 'Silver', FALSE), ('ST-006', 'SCR-001', 'B3', 'Silver', FALSE),
('ST-007', 'SCR-001', 'C1', 'Economy', FALSE), ('ST-008', 'SCR-001', 'C2', 'Economy', FALSE), ('ST-009', 'SCR-001', 'C3', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-010', 'SCR-002', 'D1', 'Gold', FALSE), ('ST-011', 'SCR-002', 'D2', 'Gold', FALSE),
('ST-012', 'SCR-002', 'E1', 'Silver', FALSE), ('ST-013', 'SCR-002', 'E2', 'Silver', FALSE),
('ST-014', 'SCR-002', 'F1', 'Economy', FALSE), ('ST-015', 'SCR-002', 'F2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-016', 'SCR-003', 'G1', 'Silver', FALSE), ('ST-017', 'SCR-003', 'G2', 'Silver', FALSE),
('ST-018', 'SCR-003', 'H1', 'Economy', FALSE), ('ST-019', 'SCR-003', 'H2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-020', 'SCR-004', 'I1', 'Gold', FALSE), ('ST-021', 'SCR-004', 'I2', 'Gold', FALSE),
('ST-022', 'SCR-004', 'J1', 'Silver', FALSE), ('ST-023', 'SCR-004', 'J2', 'Silver', FALSE),
('ST-024', 'SCR-004', 'K1', 'Economy', FALSE), ('ST-025', 'SCR-004', 'K2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-026', 'SCR-005', 'L1', 'Silver', FALSE), ('ST-027', 'SCR-005', 'L2', 'Silver', FALSE),
('ST-028', 'SCR-005', 'M1', 'Economy', FALSE), ('ST-029', 'SCR-005', 'M2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-030', 'SCR-006', 'N1', 'Gold', FALSE), ('ST-031', 'SCR-006', 'N2', 'Gold', FALSE),
('ST-032', 'SCR-006', 'O1', 'Silver', FALSE), ('ST-033', 'SCR-006', 'O2', 'Silver', FALSE),
('ST-034', 'SCR-006', 'P1', 'Economy', FALSE), ('ST-035', 'SCR-006', 'P2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-036', 'SCR-007', 'Q1', 'Silver', FALSE), ('ST-037', 'SCR-007', 'Q2', 'Silver', FALSE),
('ST-038', 'SCR-007', 'R1', 'Economy', FALSE), ('ST-039', 'SCR-007', 'R2', 'Economy', FALSE);

INSERT INTO Seat (seat_id, screen_id, seat_label, class, is_booked) VALUES
('ST-040', 'SCR-008', 'S1', 'Economy', FALSE), ('ST-041', 'SCR-008', 'S2', 'Economy', FALSE);

INSERT INTO Movie (movie_id, title, language, duration_in_mins, genre, rating, company) VALUES
('MOV-001', 'Inception', 'English', 148, 'Sci-Fi', 5, 'Warner Bros. Pictures'),
('MOV-002', 'Pashupati Prasad', 'Nepali', 130, 'Comedy', 4, 'Tukee Arts'),
('MOV-003', 'Dilwale Dulhania Le Jayenge', 'Hindi', 190, 'Romance', 5, 'Yash Raj Films'),
('MOV-004', 'Dune: Part Two', 'English', 166, 'Sci-Fi', 5, 'Warner Bros. Pictures'),
('MOV-005', 'Parasite', 'Korean', 132, 'Thriller', 5, 'CJ Entertainment'),
('MOV-006', 'Toy Story', 'English', 81, 'Animation', 4, 'Pixar Animation Studios'),
('MOV-007', 'The Conjuring', 'English', 112, 'Horror', 4, 'Warner Bros. Pictures'),
('MOV-008', 'Avengers: Endgame', 'English', 181, 'Action', 5, 'Marvel Studios'),
('MOV-009', 'KGF Chapter 2', 'Hindi', 168, 'Action', 4, 'Hombale Films'),
('MOV-010', 'Interstellar', 'English', 169, 'Sci-Fi', 5, 'Paramount Pictures');

INSERT INTO Pricings (price_id, gold, silver, economy, valid_from, valid_to) VALUES
('PRC-001', 1000, 700, 400, '2024-01-01 00:00:00', '2025-12-31 23:59:59'),
('PRC-002', 1200, 800, 500, '2024-06-01 00:00:00', '2025-05-31 23:59:59'),
('PRC-003', 900, 600, 350, '2024-03-01 00:00:00', '2024-08-31 23:59:59'),
('PRC-004', 1100, 750, 450, '2024-07-01 00:00:00', '2025-06-30 23:59:59'),
('PRC-005', 950, 650, 380, '2024-02-15 00:00:00', '2025-01-14 23:59:59');

INSERT INTO Shows (show_id, movie_id, screen_id, show_datetime, price_id, show_status, updated_at, cancel_reason, cancel_datetime) VALUES
-- MOV-001 (Inception)
('SHOW-001', 'MOV-001', 'SCR-001', '2024-07-20 10:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
('SHOW-002', 'MOV-001', 'SCR-002', '2024-07-20 14:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
('SHOW-003', 'MOV-001', 'SCR-003', '2024-07-20 18:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
-- MOV-002 (Pashupati Prasad)
('SHOW-004', 'MOV-002', 'SCR-004', '2024-07-21 11:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
('SHOW-005', 'MOV-002', 'SCR-005', '2024-07-21 15:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
('SHOW-006', 'MOV-002', 'SCR-001', '2024-07-21 19:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
-- MOV-003 (DDLJ)
('SHOW-007', 'MOV-003', 'SCR-006', '2024-07-22 10:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
('SHOW-008', 'MOV-003', 'SCR-007', '2024-07-22 14:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
('SHOW-009', 'MOV-003', 'SCR-008', '2024-07-22 18:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
-- MOV-004 (Dune: Part Two)
('SHOW-010', 'MOV-004', 'SCR-001', '2024-07-23 12:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
('SHOW-011', 'MOV-004', 'SCR-002', '2024-07-23 16:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
('SHOW-012', 'MOV-004', 'SCR-003', '2024-07-23 20:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
-- MOV-005 (Parasite)
('SHOW-013', 'MOV-005', 'SCR-004', '2024-07-24 10:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL),
('SHOW-014', 'MOV-005', 'SCR-005', '2024-07-24 14:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL),
('SHOW-015', 'MOV-005', 'SCR-006', '2024-07-24 18:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL),
-- MOV-006 (Toy Story)
('SHOW-016', 'MOV-006', 'SCR-007', '2024-07-25 11:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
('SHOW-017', 'MOV-006', 'SCR-008', '2024-07-25 15:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
('SHOW-018', 'MOV-006', 'SCR-001', '2024-07-25 19:00:00', 'PRC-001', 'Scheduled', NOW(), NULL, NULL),
-- MOV-007 (The Conjuring)
('SHOW-019', 'MOV-007', 'SCR-002', '2024-07-26 12:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
('SHOW-020', 'MOV-007', 'SCR-003', '2024-07-26 16:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
('SHOW-021', 'MOV-007', 'SCR-004', '2024-07-26 20:00:00', 'PRC-002', 'Scheduled', NOW(), NULL, NULL),
-- MOV-008 (Avengers: Endgame)
('SHOW-022', 'MOV-008', 'SCR-005', '2024-07-27 10:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
('SHOW-023', 'MOV-008', 'SCR-006', '2024-07-27 14:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
('SHOW-024', 'MOV-008', 'SCR-007', '2024-07-27 18:30:00', 'PRC-003', 'Scheduled', NOW(), NULL, NULL),
-- MOV-009 (KGF Chapter 2)
('SHOW-025', 'MOV-009', 'SCR-008', '2024-07-28 11:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
('SHOW-026', 'MOV-009', 'SCR-001', '2024-07-28 15:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
('SHOW-027', 'MOV-009', 'SCR-002', '2024-07-28 19:00:00', 'PRC-004', 'Scheduled', NOW(), NULL, NULL),
-- MOV-010 (Interstellar)
('SHOW-028', 'MOV-010', 'SCR-003', '2024-07-29 12:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL),
('SHOW-029', 'MOV-010', 'SCR-004', '2024-07-29 16:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL),
('SHOW-030', 'MOV-010', 'SCR-005', '2024-07-29 20:00:00', 'PRC-005', 'Scheduled', NOW(), NULL, NULL);

-- Insert data into ShowChanges table (3 entries)
-- These inserts will trigger trg_AfterInsertShowChange
INSERT INTO ShowChanges (change_id, show_id, old_date, new_date, changed_on, reason) VALUES
('CHG-001', 'SHOW-001', '2024-07-20 10:00:00', '2024-07-20 11:00:00', NOW(), 'Technical issue in screen 1'),
('CHG-002', 'SHOW-005', '2024-07-21 15:00:00', '2024-07-21 16:00:00', NOW(), 'Director request for later showtime'),
('CHG-003', 'SHOW-010', '2024-07-23 12:00:00', '2024-07-23 13:00:00', NOW(), 'Maintenance work');

-- Insert data into Payment table (20 entries)
INSERT INTO Payment (payment_id, method, cardno) VALUES
('PAY-001', 'Card', '1234-5678-9012-3456'),
('PAY-002', 'Online', NULL),
('PAY-003', 'Cash', NULL),
('PAY-004', 'Card', '9876-5432-1098-7654'),
('PAY-005', 'Online', NULL),
('PAY-006', 'Card', '1122-3344-5566-7788'),
('PAY-007', 'Cash', NULL),
('PAY-008', 'Online', NULL),
('PAY-009', 'Card', '9988-7766-5544-3322'),
('PAY-010', 'Cash', NULL),
('PAY-011', 'Card', '2233-4455-6677-8899'),
('PAY-012', 'Online', NULL),
('PAY-013', 'Cash', NULL),
('PAY-014', 'Card', '3344-5566-7788-9900'),
('PAY-015', 'Online', NULL),
('PAY-016', 'Card', '4455-6677-8899-0011'),
('PAY-017', 'Cash', NULL),
('PAY-018', 'Online', NULL),
('PAY-019', 'Card', '5566-7788-9900-1122'),
('PAY-020', 'Cash', NULL)
('PAY-021', 'Card', '6677-8899-0011-2233'),
('PAY-022', 'Online', NULL),
('PAY-023', 'Cash', NULL),
('PAY-024', 'Card', '7788-9900-1122-3344'),
('PAY-025', 'Online', NULL),
('PAY-026', 'Card', '8899-0011-2233-4455'),
('PAY-027', 'Cash', NULL),
('PAY-028', 'Online', NULL),
('PAY-029', 'Card', '9900-1122-3344-5566'),
('PAY-030', 'Cash', NULL),
('PAY-031', 'Card', '0011-2233-4455-6677'),
('PAY-032', 'Online', NULL),
('PAY-033', 'Cash', NULL),
('PAY-034', 'Card', '1122-3344-5566-7788'),
('PAY-035', 'Online', NULL),
('PAY-036', 'Card', '2233-4455-6677-8899'),
('PAY-037', 'Online', NULL),
('PAY-038', 'Cash', NULL),
('PAY-039', 'Card', '3344-5566-7788-9900'),
('PAY-040', 'Online', NULL),
('PAY-041', 'Card', '4455-6677-8899-0011'),
('PAY-042', 'Cash', NULL),
('PAY-043', 'Online', NULL),
('PAY-044', 'Card', '5566-7788-9900-1122');

INSERT INTO Bookings (booking_id, show_id, user_id, booking_datetime, payment_id, booking_status, cancel_reason) VALUES
('BOOK-001', 'SHOW-001', 'USR-001', '2024-07-19 09:30:00', 'PAY-001', 'Booked', NULL),
('BOOK-002', 'SHOW-001', 'USR-002', '2024-07-19 09:35:00', 'PAY-002', 'Booked', NULL),
('BOOK-003', 'SHOW-001', 'USR-003', '2024-07-19 09:40:00', 'PAY-003', 'Booked', NULL),
('BOOK-004', 'SHOW-002', 'USR-004', '2024-07-19 13:00:00', 'PAY-004', 'Booked', NULL),
('BOOK-005', 'SHOW-002', 'USR-005', '2024-07-19 13:05:00', 'PAY-005', 'Booked', NULL),
('BOOK-006', 'SHOW-003', 'USR-006', '2024-07-19 17:00:00', 'PAY-006', 'Booked', NULL),
('BOOK-007', 'SHOW-004', 'USR-007', '2024-07-20 10:00:00', 'PAY-007', 'Booked', NULL),
('BOOK-008', 'SHOW-004', 'USR-008', '2024-07-20 10:05:00', 'PAY-008', 'Booked', NULL),
('BOOK-009', 'SHOW-005', 'USR-009', '2024-07-20 14:00:00', 'PAY-009', 'Booked', NULL),
('BOOK-010', 'SHOW-006', 'USR-010', '2024-07-20 18:00:00', 'PAY-010', 'Booked', NULL),
('BOOK-011', 'SHOW-007', 'USR-001', '2024-07-21 09:30:00', 'PAY-011', 'Booked', NULL),
('BOOK-012', 'SHOW-007', 'USR-002', '2024-07-21 09:35:00', 'PAY-012', 'Booked', NULL),
('BOOK-013', 'SHOW-008', 'USR-003', '2024-07-21 13:30:00', 'PAY-013', 'Booked', NULL),
('BOOK-014', 'SHOW-009', 'USR-004', '2024-07-21 17:30:00', 'PAY-014', 'Booked', NULL),
('BOOK-015', 'SHOW-010', 'USR-005', '2024-07-22 11:00:00', 'PAY-015', 'Booked', NULL),
('BOOK-016', 'SHOW-010', 'USR-006', '2024-07-22 11:05:00', 'PAY-016', 'Booked', NULL),
('BOOK-017', 'SHOW-011', 'USR-007', '2024-07-22 15:00:00', 'PAY-017', 'Booked', NULL),
('BOOK-018', 'SHOW-012', 'USR-008', '2024-07-22 19:00:00', 'PAY-018', 'Booked', NULL),
('BOOK-019', 'SHOW-013', 'USR-009', '2024-07-23 09:00:00', 'PAY-019', 'Booked', NULL),
('BOOK-020', 'SHOW-014', 'USR-010', '2024-07-23 13:00:00', 'PAY-020', 'Booked', NULL),
('BOOK-021', 'SHOW-015', 'USR-001', '2024-07-23 17:00:00', 'PAY-001', 'Booked', NULL),
('BOOK-022', 'SHOW-016', 'USR-002', '2024-07-24 10:00:00', 'PAY-002', 'Booked', NULL),
('BOOK-023', 'SHOW-016', 'USR-003', '2024-07-24 10:05:00', 'PAY-003', 'Booked', NULL),
('BOOK-024', 'SHOW-017', 'USR-004', '2024-07-24 14:00:00', 'PAY-004', 'Booked', NULL),
('BOOK-025', 'SHOW-018', 'USR-005', '2024-07-24 18:00:00', 'PAY-005', 'Booked', NULL),
('BOOK-026', 'SHOW-019', 'USR-006', '2024-07-25 11:00:00', 'PAY-006', 'Booked', NULL),
('BOOK-027', 'SHOW-019', 'USR-007', '2024-07-25 11:05:00', 'PAY-007', 'Booked', NULL),
('BOOK-028', 'SHOW-020', 'USR-008', '2024-07-25 15:00:00', 'PAY-008', 'Booked', NULL),
('BOOK-029', 'SHOW-021', 'USR-009', '2024-07-25 19:00:00', 'PAY-009', 'Booked', NULL),
('BOOK-030', 'SHOW-022', 'USR-010', '2024-07-26 09:30:00', 'PAY-010', 'Booked', NULL),
('BOOK-031', 'SHOW-023', 'USR-001', '2024-07-26 13:30:00', 'PAY-011', 'Booked', NULL),
('BOOK-032', 'SHOW-024', 'USR-002', '2024-07-26 17:30:00', 'PAY-012', 'Booked', NULL),
('BOOK-033', 'SHOW-025', 'USR-003', '2024-07-27 10:00:00', 'PAY-013', 'Booked', NULL),
('BOOK-034', 'SHOW-025', 'USR-004', '2024-07-27 10:05:00', 'PAY-014', 'Booked', NULL),
('BOOK-035', 'SHOW-026', 'USR-005', '2024-07-27 14:00:00', 'PAY-015', 'Booked', NULL),
('BOOK-036', 'SHOW-027', 'USR-006', '2024-07-27 18:00:00', 'PAY-016', 'Booked', NULL),
('BOOK-037', 'SHOW-028', 'USR-007', '2024-07-28 11:00:00', 'PAY-017', 'Booked', NULL),
('BOOK-038', 'SHOW-028', 'USR-008', '2024-07-28 11:05:00', 'PAY-018', 'Booked', NULL),
('BOOK-039', 'SHOW-029', 'USR-009', '2024-07-28 15:00:00', 'PAY-019', 'Booked', NULL),
('BOOK-040', 'SHOW-030', 'USR-010', '2024-07-28 19:00:00', 'PAY-020', 'Booked', NULL)
('BOOK-041', 'SHOW-001', 'USR-001', '2024-07-19 09:45:00', 'PAY-021', 'Booked', NULL),
('BOOK-042', 'SHOW-002', 'USR-001', '2024-07-19 13:10:00', 'PAY-022', 'Booked', NULL),
('BOOK-043', 'SHOW-003', 'USR-001', '2024-07-19 17:10:00', 'PAY-023', 'Booked', NULL),
('BOOK-044', 'SHOW-004', 'USR-001', '2024-07-20 10:10:00', 'PAY-024', 'Booked', NULL),
('BOOK-045', 'SHOW-005', 'USR-001', '2024-07-20 14:10:00', 'PAY-025', 'Booked', NULL),
('BOOK-046', 'SHOW-006', 'USR-001', '2024-07-20 18:10:00', 'PAY-026', 'Booked', NULL),
('BOOK-047', 'SHOW-008', 'USR-001', '2024-07-21 13:40:00', 'PAY-027', 'Booked', NULL),
('BOOK-048', 'SHOW-009', 'USR-001', '2024-07-21 17:40:00', 'PAY-028', 'Booked', NULL),
('BOOK-049', 'SHOW-010', 'USR-002', '2024-07-22 11:10:00', 'PAY-029', 'Booked', NULL),
('BOOK-050', 'SHOW-011', 'USR-002', '2024-07-22 15:10:00', 'PAY-030', 'Booked', NULL),
('BOOK-051', 'SHOW-012', 'USR-002', '2024-07-22 19:10:00', 'PAY-031', 'Booked', NULL),
('BOOK-052', 'SHOW-013', 'USR-002', '2024-07-23 09:10:00', 'PAY-032', 'Booked', NULL),
('BOOK-053', 'SHOW-014', 'USR-002', '2024-07-23 13:10:00', 'PAY-033', 'Booked', NULL),
('BOOK-054', 'SHOW-015', 'USR-002', '2024-07-23 17:10:00', 'PAY-034', 'Booked', NULL),
('BOOK-055', 'SHOW-017', 'USR-002', '2024-07-24 14:10:00', 'PAY-035', 'Booked', NULL),
('BOOK-056', 'SHOW-018', 'USR-002', '2024-07-24 18:10:00', 'PAY-036', 'Booked', NULL),
('BOOK-057', 'SHOW-019', 'USR-003', '2024-07-25 11:10:00', 'PAY-037', 'Booked', NULL),
('BOOK-058', 'SHOW-020', 'USR-003', '2024-07-25 15:10:00', 'PAY-038', 'Booked', NULL),
('BOOK-059', 'SHOW-021', 'USR-003', '2024-07-25 19:10:00', 'PAY-039', 'Booked', NULL),
('BOOK-060', 'SHOW-022', 'USR-003', '2024-07-26 09:40:00', 'PAY-040', 'Booked', NULL),
('BOOK-061', 'SHOW-024', 'USR-003', '2024-07-26 17:40:00', 'PAY-041', 'Booked', NULL),
('BOOK-062', 'SHOW-026', 'USR-003', '2024-07-27 14:10:00', 'PAY-042', 'Booked', NULL),
('BOOK-063', 'SHOW-027', 'USR-003', '2024-07-27 18:10:00', 'PAY-043', 'Booked', NULL),
('BOOK-064', 'SHOW-029', 'USR-003', '2024-07-28 15:10:00', 'PAY-044', 'Booked', NULL),
('BOOK-065', 'SHOW-030', 'USR-003', '2024-07-28 19:10:00', 'PAY-021', 'Booked', NULL),
('BOOK-066', 'SHOW-028', 'USR-003', '2024-07-28 11:10:00', 'PAY-022', 'Booked', NULL);

-- Insert data into Cancellations table (3 entries)
-- These inserts will trigger trg_AfterInsertBookingCancellation and trg_AfterInsertShowCancellation
INSERT INTO Cancellations (cancel_id, booking_id, show_id, cancelled_by, reason, cancel_datetime) VALUES
('CAN-001', 'BOOK-003', 'SHOW-001', 'User', 'Change of plans', NOW()),
('CAN-002', 'BOOK-005', 'SHOW-002', 'System', 'Overbooking detected', NOW()),
('CAN-003', 'BOOK-013', 'SHOW-008', 'Admin', 'Show cancelled due to low attendance', NOW());

-- Insert data into Refund table (2 entries for cancelled bookings)
INSERT INTO Refund (refund_id, booking_id, amount, refund_method, refund_datetime, refund_status, reason) VALUES
('REF-001', 'BOOK-003', 400, 'Original', NOW(), 'Processed', 'User cancelled booking'),
('REF-002', 'BOOK-005', 500, 'Voucher', NOW(), 'Pending', 'System cancelled due to overbooking');

-- SQL Report Queries
-- 1. Write an SQL query to list all the movies that require parental guidance based on their genres.
SELECT
    movie_id,
    title,
    genre,
    rating
FROM
    Movie
WHERE
    genre IN ('Horror', 'Thriller') OR rating < 3;

-- 2. Write an SQL query to list all the details of the people who booked more than 10 tickets.
SELECT
    U.user_id,
    U.userName,
    U.email,
    U.contact_no,
    COUNT(B.booking_id) AS total_tickets_booked
FROM
    Users AS U
JOIN
    Bookings AS B ON U.user_id = B.user_id
GROUP BY
    U.user_id, U.userName, U.email, U.contact_no
HAVING
    COUNT(B.booking_id) > 10;

-- 3. Write an SQL query to list out the details of the user with respect to the card number the user swiped during the payment process.
SELECT
    U.user_id,
    U.userName,
    U.email,
    U.contact_no,
    P.cardno AS payment_card_number,
    P.method AS payment_method
FROM
    Users AS U
JOIN
    Bookings AS B ON U.user_id = B.user_id
JOIN
    Payment AS P ON B.payment_id = P.payment_id
WHERE
    P.method = 'Card' AND P.cardno IS NOT NULL
GROUP BY
    U.user_id, U.userName, U.email, U.contact_no, P.cardno, P.method;

-- 4. Generate a report for the total earnings per movie and arrange them in a descending order.
-- This query calculates earnings based on booked tickets and seat class prices.
SELECT
    M.title AS movie_title,
    SUM(Pr.economy) AS total_earnings
FROM
    Movie AS M
JOIN
    Shows AS Sh ON M.movie_id = Sh.movie_id
JOIN
    Bookings AS B ON Sh.show_id = B.show_id
JOIN
    Pricings AS Pr ON Sh.price_id = Pr.price_id
WHERE
    B.booking_status = 'Booked'
GROUP BY
    M.title
ORDER BY
    total_earnings DESC;

-- 5. Write an SQL query to get the details of the Theatre based on the screen ID.
SELECT
    T.theater_id,
    T.location,
    T.num_screen,
    S.screen_id,
    S.total_seats
FROM
    Theater AS T
JOIN
    Screen AS S ON T.theater_id = S.theater_id
WHERE
    S.screen_id = 'SCR-001'; 

-- 6. Write an SQL query to list out the details of the user with respect to his/her ticket ID.
SELECT
    U.user_id,
    U.userName,
    U.email,
    U.contact_no,
    B.booking_id,
    B.booking_datetime,
    B.booking_status,
    M.title AS movie_title,
    Sh.show_datetime,
    Th.location AS theater_location,
    Sc.screen_id,

    CASE
        WHEN B.booking_status = 'Booked' THEN 'Confirmed'
        WHEN B.booking_status = 'Cancelled' THEN 'Cancelled'
        ELSE 'Unknown'
    END AS booking_status_description
FROM
    Users AS U
JOIN
    Bookings AS B ON U.user_id = B.user_id
JOIN
    Shows AS Sh ON B.show_id = Sh.show_id
JOIN
    Movie AS M ON Sh.movie_id = M.movie_id
JOIN
    Screen AS Sc ON Sh.screen_id = Sc.screen_id
JOIN
    Theater AS Th ON Sc.theater_id = Th.theater_id
WHERE
    B.booking_id = 'BOOK-040'; 