CREATE DATABASE nirva;
\c nirva;
create table "customers" (
    "customerId" bigint primary key,
    "account" varchar(50) unique not null,
    "firstName" varchar(100) not null,
    "lastName" varchar(100) not null,
    "msisdn" varchar(20) unique not null,
    "gender" varchar(10),
    "dateOfBirth" date,
    "homeAddress" text,
    "city" varchar(100),
    "postalCode" varchar(20),
    "houseHoldId" varchar(50),
    "createdAt" timestamp with time zone default now()
);
create table "users" (
    "userId" bigint primary key,
    "customerId" bigint references customers("customerId"),
    "firstName" varchar(100),
    "lastName" varchar(100),
    "username" varchar(50) unique not null 
    CHECK (username ~* '^[a-zA-Z0-9._-]+$')
    CHECK (username = lower(username))
    CHECK (length(username) >= 3)
    CHECK (length(username) <= 50)
    CHECK (username NOT IN ('admin', 'root', 'superuser'))
    CHECK (username NOT LIKE '%@%')
    CHECK (username NOT LIKE '% %'),
    "passwordHash" text not null,
    "role" varchar(20) not null default 'USER',
    "createdAt" timestamp with time zone default now(),
    "lastLogin" timestamp with time zone
);
create table "sessions" (
    "sessionId" integer primary key generated always as identity,
    "userId" bigint references users("userId"),
    "loginTime" timestamp with time zone default now(),
    "ipAddress" varchar(45),
    "createdAt" timestamp with time zone default now(),
    "expiresAt" timestamp with time zone
);
create table "vendor" (
    "id" integer primary key generated always as identity,
    "name" varchar(50) not null,
    "shortName" varchar(20) not null,
    "type" varchar(50) not null,
    "accountNumber" varchar(20) not null unique,
    "api_key_hash" text,
    "api_secret_encrypted" text,
    "ip_address" varchar(45),
    "createdAt" timestamp with time zone default now()
);
create table "assets" (
    "id" integer primary key generated always as identity,
    "name" varchar(100),
    "customerId" bigint references customers("customerId"),
    "vendorId" integer references vendor(id),
    "type" varchar(50),
    "value" numeric(15, 2),
    "institutionName" varchar(100),
    "accountNumber" varchar(50),
    "active" boolean default true
);
create table "vendorAccount" (
    "id" integer primary key generated always as identity,
    "vendorId" integer not null,
    "bankName" varchar(50),
    "accountNumber" varchar(50) unique,
    "active" boolean default true
);
create table "customerAccount" (
    "id" integer primary key generated always as identity,
    "customerId" bigint not null,
    "bankName" varchar(50),
    "accountNumber" varchar(50) unique,
    "active" boolean default true
);
create table "transactions" (
    "id" bigint primary key,
    "credit" boolean,
    "customerId" bigint references customers("customerId"),
    "vendorId" integer references vendor(id),
    "accountDebit" varchar(50),
    "accountCredit" varchar(50),
    "amount" numeric(15, 2),
    "type" varchar(50),
    "remarks" text,
    "dated" timestamp with time zone default now()
);
CREATE SEQUENCE IF NOT EXISTS users_userid_seq;
alter table "users"
alter column "userId"
set default nextval('users_userid_seq');

--create sequence if not exists customers_customerid_seq;
--alter table "customers"
--alter column "customerId"
--set default nextval('customers_customerid_seq');

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE UNIQUE INDEX ON "customers" ("account");
CREATE UNIQUE INDEX ON "customers" ("msisdn");
CREATE INDEX ON "customers" ("houseHoldId");
CREATE INDEX ON "customers" ("lastName", "firstName");
CREATE UNIQUE INDEX ON "users" ("username");
CREATE INDEX ON "users" ("customerId");
CREATE INDEX ON "sessions" ("userId");
create index on "sessions" ("ipAddress");
CREATE UNIQUE INDEX ON "vendor" ("accountNumber");
CREATE INDEX ON "vendor" ("name");
CREATE INDEX ON "assets" ("customerId");
CREATE INDEX ON "assets" ("vendorId");
CREATE INDEX ON "assets" ("accountNumber");
CREATE INDEX ON "vendorAccount" ("vendorId");
CREATE UNIQUE INDEX ON "vendorAccount" ("accountNumber");
CREATE INDEX ON "customerAccount" ("customerId");
CREATE INDEX ON "customerAccount" ("accountNumber");
CREATE INDEX ON "transactions" ("customerId");
CREATE INDEX ON "transactions" ("vendorId");
CREATE INDEX ON "transactions" ("dated");
CREATE INDEX ON "transactions" ("customerId", "dated");
COPY customers (
    "customerId",
    account,
    "firstName",
    "lastName",
    msisdn,
    gender,
    "dateOfBirth",
    "homeAddress",
    city,
    "postalCode",
    "houseHoldId"
)
FROM '/docker-entrypoint-initdb.d/data/customers.csv' DELIMITER ',' CSV HEADER;
COPY vendor (id, name, "accountNumber", "shortName", type)
FROM '/docker-entrypoint-initdb.d/data/vendors.csv' DELIMITER ',' CSV HEADER;