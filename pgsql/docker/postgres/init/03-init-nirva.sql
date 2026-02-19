CREATE DATABASE nirva;

\c nirva;

create table customers (
    customerId bigint primary key,
    account varchar(50) unique not null,
    firstName varchar(100) not null,
    lastName varchar(100) not null,
    msisdn varchar(20) unique not null,
    gender varchar(10),
    dateOfBirth date,
    homeAddress text,
    city varchar(100),
    postalCode varchar(20),
    houseHoldId varchar(50),
    createdAt timestamp with time zone default now()
);

create index idx_customers_msisdn on customers(msisdn);
create index idx_customers_customerId on customers(customerId);
create index idx_customers_houseHoldId on customers(houseHoldId);

COPY customers (
    customerId, account, firstName, lastName,
    msisdn,
    gender,
    dateOfBirth,
    homeAddress,
    city,
    postalCode,
    houseHoldId
    )
FROM '/docker-entrypoint-initdb.d/data/customers.csv' DELIMITER ',' CSV HEADER;