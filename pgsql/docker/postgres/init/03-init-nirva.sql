CREATE DATABASE nirva;

\c nirva;

create table customers (
    customerId bigint primary key,
    firstName varchar(100) not null,
    lastName varchar(100) not null,
    msisdn varchar(20) unique not null,
    gender varchar(10),
    dateOfBirth date,
    homeAddress text,
    city varchar(100),
    postalCode varchar(20),
    houseHoldId varchar(50)
);

COPY customers (customerId, firstName, lastName,
    msisdn,
    gender,
    dateOfBirth,
    homeAddress,
    city,
    postalCode,
    houseHoldId)
FROM '/docker-entrypoint-initdb.d/data/customers.csv' DELIMITER ',' CSV HEADER;