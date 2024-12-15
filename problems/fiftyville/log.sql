-- Keep a log of any SQL queries you execute as you solve the mystery.

--Check crime reports
SELECT *
  FROM crime_scene_reports
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND street = "Humphrey Street";

-- Theft of the CS50 duck took place at 10:15am at
-- the Humphrey Street bakery. Interviews were conducted
-- today with three witnesses who were present at the
-- time – each of their interview transcripts mentions the bakery.

--Check interview transcripts for the day of the theft
SELECT name, transcript
  FROM interviews
 WHERE year = 2021
   AND month = 7
   AND day = 28;

-- Ruth:
-- Sometime within ten minutes of the theft, I saw the thief get into
-- a car in the bakery parking lot and drive away. If you have security
-- footage from the bakery parking lot, you might want to look for
-- cars that left the parking lot in that time frame.

-- Eugene:
-- I don't know the thief's name, but it was someone I recognized.
-- Earlier this morning, before I arrived at Emma's bakery, I was walking
-- by the ATM on Leggett Street and saw the thief there withdrawing some money.

-- Raymond:
-- As the thief was leaving the bakery, they called someone who talked to them for
-- less than a minute. In the call, I heard the thief say that they were planning to
-- take the earliest flight out of Fiftyville tomorrow. The thief then asked the person
-- on the other end of the phone to purchase the flight ticket.

-- Check security logs for 10 minutes before and after 10:15
SELECT hour, minute, activity, license_plate
  FROM bakery_security_logs
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND hour = 10;

-- Check atm withdrawl, accounts and amounts
SELECT account_number, amount
  FROM atm_transactions
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND atm_location = "Leggett Street"
   AND transaction_type = "withdraw"
 ORDER BY amount;

-- Check names and amounts
SELECT name, amount
  FROM people
       JOIN atm_transactions
         ON bank_accounts.account_number = atm_transactions.account_number
       JOIN bank_accounts
         ON people.id = bank_accounts.person_id
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND atm_location = "Leggett Street"
   AND transaction_type = "withdraw"
 ORDER BY amount;

--     #1
-- +---------+
-- | Suspect |
-- +---------+
-- | Bruce   |
-- | Diana   |
-- | Brooke  |
-- | Kenny   |
-- | Iman    |
-- | Luca    |
-- | Taylor  |
-- | Benista |
-- +---------+

-- Print suspect list
SELECT name
  FROM people
       JOIN atm_transactions
         ON bank_accounts.account_number = atm_transactions.account_number
       JOIN bank_accounts
         ON people.id = bank_accounts.person_id
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND atm_location = "Leggett Street"
   AND transaction_type = "withdraw"
 ORDER BY amount;

-- Find Fiftyville airport
SELECT abbreviation, full_name, city
  FROM airports
 WHERE city = "Fiftyville";

-- Check flights out of Fiftyville on July 29th
SELECT flights.id, full_name, city, flights.hour, flights.minute
  FROM airports
       JOIN flights
       ON airports.id = flights.destination_airport_id
 WHERE flights.origin_airport_id =
       (SELECT id
          FROM airports
         WHERE city = "Fiftyville")
   AND flights.year = 2021
   AND flights.month = 7
   AND flights.day = 29
 ORDER BY flights.hour;

-- +----+-------------------------------------+---------------+------+--------+
-- | id |              full_name              |     city      | hour | minute |
-- +----+-------------------------------------+---------------+------+--------+
-- | 36 | LaGuardia Airport                   | New York City | 8    | 20     |
-- +----+-------------------------------------+---------------+------+--------+

-- Check flight id 36 passenger list
SELECT flights.id, name, passengers.passport_number, passengers.seat
  FROM people
       JOIN passengers
         ON people.passport_number = passengers.passport_number
       JOIN flights
         ON passengers.flight_id = flights.id
 WHERE flights.id = 36 AND name IN
       (SELECT name
          FROM people
               JOIN atm_transactions
                 ON bank_accounts.account_number = atm_transactions.account_number
               JOIN bank_accounts
                 ON people.id = bank_accounts.person_id
         WHERE year = 2021
           AND month = 7
           AND day = 28
           AND atm_location = "Leggett Street"
           AND transaction_type = "withdraw"
         ORDER BY amount)
 ORDER BY name;

-- +----+--------+-----------------+------+
-- | id |  name  | passport_number | seat |
-- +----+--------+-----------------+------+
-- | 36 | Bruce  | 5773159633      | 4A   |
-- | 36 | Kenny  | 9878712108      | 7A   |
-- | 36 | Luca   | 8496433585      | 7B   |
-- | 36 | Taylor | 1988161715      | 6D   |
-- +----+--------+-----------------+------+

--     #2
-- +---------+
-- | Suspect |
-- +---------+
-- | Bruce   |
-- | Kenny   |
-- | Luca    |
-- | Taylor  |
-- +---------+

-- Check phone calls
SELECT *
  FROM phone_calls
 WHERE year = 2021
   AND month = 7
   AND day = 28
   AND duration <= 60
 ORDER BY duration ASC;

-- +-----+----------------+----------------+------+-------+-----+----------+
-- | id  |     caller     |    receiver    | year | month | day | duration |
-- +-----+----------------+----------------+------+-------+-----+----------+
-- | 224 | (499) 555-9472 | (892) 555-8872 | 2021 | 7     | 28  | 36       |
-- | 261 | (031) 555-6622 | (910) 555-3251 | 2021 | 7     | 28  | 38       |
-- | 254 | (286) 555-6063 | (676) 555-6554 | 2021 | 7     | 28  | 43       |
-- | 233 | (367) 555-5533 | (375) 555-8161 | 2021 | 7     | 28  | 45       |
-- | 255 | (770) 555-1861 | (725) 555-3243 | 2021 | 7     | 28  | 49       |
-- | 251 | (499) 555-9472 | (717) 555-1342 | 2021 | 7     | 28  | 50       |
-- | 221 | (130) 555-0289 | (996) 555-8899 | 2021 | 7     | 28  | 51       |
-- | 281 | (338) 555-6650 | (704) 555-2131 | 2021 | 7     | 28  | 54       |
-- | 279 | (826) 555-1652 | (066) 555-9701 | 2021 | 7     | 28  | 55       |
-- | 234 | (609) 555-5876 | (389) 555-5198 | 2021 | 7     | 28  | 60       |
-- +-----+----------------+----------------+------+-------+-----+----------+

-- Check names of short phone calls
SELECT name AS "caller", phone_number, phone_calls.duration
  FROM people
       JOIN phone_calls
       ON people.phone_number = phone_calls.caller
 WHERE phone_calls.year = 2021
   AND phone_calls.month = 7
   AND phone_calls.day = 28
   AND phone_calls.duration <= 60
   AND name IN
       ("Bruce", "Kenny", "Luca", "Taylor")
 ORDER BY phone_calls.duration ASC;

-- +--------+----------------+----------+
-- | caller |  phone_number  | duration |
-- +--------+----------------+----------+
-- | Taylor | (286) 555-6063 | 43       |
-- | Bruce  | (367) 555-5533 | 45       |
-- | Kenny  | (826) 555-1652 | 55       |
-- +--------+----------------+----------+

--     #3
-- +---------+
-- | Suspect |
-- +---------+
-- | Bruce   |
-- | Kenny   |
-- | Taylor  |
-- +---------+

-- Check security logs for 10 minutes before and after 10:15 to find plates
SELECT name, bakery_security_logs.hour, bakery_security_logs.minute, bakery_security_logs.activity, bakery_security_logs.license_plate
  FROM people
       JOIN bakery_security_logs
         ON people.license_plate = bakery_security_logs.license_plate
 WHERE bakery_security_logs.year = 2021
   AND bakery_security_logs.month = 7
   AND bakery_security_logs.day = 28
   AND bakery_security_logs.hour = 10
   AND bakery_security_logs.minute >= 15
   AND bakery_security_logs.minute <= 25
   AND name IN
       ("Bruce", "Kenny", "Taylor");

-- +-------+------+--------+----------+---------------+
-- | name  | hour | minute | activity | license_plate |
-- +-------+------+--------+----------+---------------+
-- | Bruce | 10   | 18     | exit     | 94KL13X       |
-- +-------+------+--------+----------+---------------+

--     #4
-- +---------+
-- | Suspect |
-- +---------+
-- | Bruce   |
-- +---------+

-- Find accomplice call
SELECT name, phone_number, phone_calls.duration
  FROM people
       JOIN phone_calls
         ON people.phone_number = phone_calls.receiver
 WHERE phone_calls.year = 2021
   AND phone_calls.month = 7
   AND phone_calls.day = 28
   AND phone_calls.duration <= 60
 ORDER BY phone_calls.duration ASC;

-- +------------+----------+
-- |    name    | duration |
-- +------------+----------+
-- | Larry      | 36       |
-- | Jacqueline | 38       |
-- | James      | 43       |
-- | Robin      | 45       |
-- | Philip     | 49       |
-- | Melissa    | 50       |
-- | Jack       | 51       |
-- | Anna       | 54       |
-- | Doris      | 55       |
-- | Luca       | 60       |
-- +------------+----------+

--         Thief call
-- +------------+----------+
-- |    name    | duration |
-- +------------+----------+
-- | Bruce      | 45       |
-- +------------+----------+

--      Accomplice call
-- +------------+----------+
-- |    name    | duration |
-- +------------+----------+
-- | Robin      | 45       |
-- +------------+----------+

--------------------------------------------------------------------------------------------------------------------------

-- Thief: Bruce
-- Reason: Bruce is present in all lists, which corroborates with all witness interviews.
            -- He was on flight id 36.
            -- He made a phone call within 10 minutes of the crime occuring.
            -- His license plate was monitored leaving the crime scene.
            -- He was seen that morning taking out money from an ATM by someone who had seen him before.

-- Accomplice: Robin
--     Reason: The accomplice is Robin because they are the only person that had a 1 minute or less phone
--             call from Bruce within 10 minutes of the crime happening.