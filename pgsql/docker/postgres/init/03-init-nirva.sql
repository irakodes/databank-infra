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
    "username" varchar(50) unique not null,
    "passwordHash" text not null,
    "role" varchar(20) not null default 'USER',
    "createdAt" timestamp with time zone default now(),
    "lastLogin" timestamp with time zone
);

create table "vendor" (
    "id" integer primary key,
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
    "id" integer primary key,
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
    "id" integer primary key,
    "vendorId" integer not null,
    "bankName" varchar(50),
    "accountNumber" varchar(50) unique,
    "active" boolean default true
);

create table "customerAccount" (
    "id" integer primary key,
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

CREATE UNIQUE INDEX ON "customers" ("account");
CREATE UNIQUE INDEX ON "customers" ("msisdn");
CREATE INDEX ON "customers" ("houseHoldId");
CREATE INDEX ON "customers" ("lastName", "firstName");
CREATE UNIQUE INDEX ON "users" ("username");
CREATE INDEX ON "users" ("customerId");
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
    "customerId", account, "firstName", "lastName",
    msisdn,
    gender,
    "dateOfBirth",
    "homeAddress",
    city,
    "postalCode",
    "houseHoldId"
    )
FROM '/docker-entrypoint-initdb.d/data/customers.csv' DELIMITER ',' CSV HEADER;

COPY vendor (
    id,name,"accountNumber","shortName",type
) FROM '/docker-entrypoint-initdb.d/data/vendors.csv' DELIMITER ',' CSV HEADER;