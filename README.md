# DBS Group Project: Movie Theater Booking System

## Overview
This project implements a comprehensive Movie Theater Booking System using SQL. The system is designed to manage users, preferences, theaters, screens, seats, movies, pricing, shows, bookings, payments, cancellations, refunds, and reporting. It includes table definitions, triggers for business logic, and sample data insertions for demonstration and testing.

## Features
- **User Management:** Store user details and preferences.
- **Theater & Screen Management:** Define theaters, screens, and seat arrangements.
- **Movie & Show Scheduling:** Manage movies, showtimes, and pricing.
- **Booking & Payment:** Book tickets, process payments, and handle cancellations and refunds.
- **Triggers:** Automate status updates for bookings and shows upon cancellations or changes.
- **Reporting:** Includes sample SQL queries for generating business reports (e.g., earnings, user activity, parental guidance movies).

## Database Schema
- **Users, Preferences, UserPreferences**: Manage users and their movie preferences.
- **Theater, Screen, Seat**: Define theater locations, screens, and seat classes.
- **Movie, Pricings, Shows, ShowChanges**: Manage movies, pricing, show schedules, and changes.
- **Payment, Bookings, Refund, Cancellations**: Handle ticket bookings, payments, refunds, and cancellations.

## Triggers
- **trg_AfterInsertShowChange:** Updates show status to 'Rescheduled' when a show change is recorded.
- **trg_AfterInsertBookingCancellation:** Updates booking status to 'Cancelled' when a cancellation is recorded.
- **trg_AfterInsertShowCancellation:** Updates show status to 'Cancelled' if a show is cancelled by the system or admin.

## Sample Data
The script includes sample data for all tables, including users, preferences, theaters, screens, seats, movies, pricing, shows, bookings, payments, cancellations, and refunds.

## Example Reports
The script provides example SQL queries for:
- Listing movies requiring parental guidance.
- Users who booked more than 10 tickets.
- User details with respect to card payments.
- Total earnings per movie (descending order).
- Theater details by screen ID.
- User details by ticket ID.

## Getting Started

### Clone the Repository
To get a local copy of this project, run:

```sh
git clone https://github.com/Apil120/DBS-GA.git
```

## Usage
1. **Run the SQL script** (`GA_SQL_CODE.sql`) in a MySQL-compatible database.
2. The script will create the schema, tables, triggers, and insert sample data.
3. Use the provided SQL queries at the end of the script to generate reports.

## Requirements
- MySQL or compatible RDBMS (supports triggers and ENUM types).

## Author
- Apil Adhikari and Group

---
For any questions or improvements, please open an issue or contact us.