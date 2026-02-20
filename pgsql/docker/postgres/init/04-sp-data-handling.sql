\c nirva;

create function sp_create_user(
    p_customerid bigint, p_firstname character varying, p_lastname character varying, p_password text,
    p_role character varying DEFAULT 'USER'::character varying
)
    returns TABLE
            (
                success   boolean,
                message   text,
                newuserid bigint
            )
    language plpgsql
as
$$

declare
    v_userId   bigint;
    v_username varchar(50);
begin
    -- Generate ID with next sequence
    select coalesce(max("userId"), 0) + 1 into v_userId from "users";

-- Validate input parameters
    if p_firstname is null
        or p_lastname is null
        or p_password is null then
        return query
            select false,
                   'First name, last name and password are required',
                   v_userId;
        return;
    end if;

-- Generate username based on first and last name
    v_username := lower(p_firstname || '.' || p_lastname);
    v_username := regexp_replace(v_username, '[^a-z0-9._-]', '', 'g'); -- Remove invalid characters
    v_username := regexp_replace(v_username, '\.{2,}', '.', 'g'); -- Replace multiple dots with a single dot
    v_username := regexp_replace(v_username, '^\.|\.$', '', 'g'); -- Remove leading and trailing dots
    v_username := left(v_username, 50);
    -- Ensure username does not exceed 50 characters

-- Ensure the customer exists if a customerId is provided
    if p_customerId is not null
        and not exists (select 1
                        from customers
                        where "customerId" = p_customerId) then
        return query
            select false,
                   'Customer does not exist',
                   v_userId;
        return;
    end if;

-- Validation to prevent duplicate usernames
    if exists (select 1
               from "users"
               where "username" = lower(v_username)) then
        return query
            select false,
                   'Username already exists',
                   v_userId;
        return;
    end if;

    insert into "users" ("userId",
                         "firstName",
                         "lastName",
                         "customerId",
                         "username",
                         "passwordHash",
                         "role")
    values (v_userId,
            p_firstname,
            p_lastname,
            p_customerId,
            lower(v_username),
            crypt(p_password, gen_salt('bf')),
            upper(p_role)); -- returning "userId";
    return query select true,
                        'User created successfully',
                        -- currval(pg_get_serial_sequence('"users"', '"userId"'));
                        v_userId;
                        -- lastval();

exception
    when others then return query
        select false,
               sqlerrm,
               v_userId;
end;
$$;

-- alter function sp_create_user(bigint, varchar, text, varchar) owner to postgres;

create function sp_user_login(
    p_username varchar, p_password text
)
    returns table
            (
                success   boolean,
                message   text,
                userId    bigint,
                lastLogin timestamp with time zone,
                role      varchar
            )
    language plpgsql
as
$$
begin
    if p_username is null or p_password is null then
        return query select false,
                            'Username and password are required',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
        return;
    end if;

    if not exists (select 1
                   from "users"
                   where "username" = lower(p_username)) then
        return query select false,
                            'Invalid username or password',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
        return;
    end if;

    if exists (select 1
               from "users"
               where "username" = lower(p_username)
                 and "passwordHash" = crypt(p_password, "passwordHash")) then
        update "users"
        set "lastLogin" = now()
        where "username" = lower(p_username);

        return query
            select true, 'Login successful', "userId", "lastLogin", "role"
            from "users"
            where "username" = lower(p_username);
    else
        return query select false,
                            'Invalid username or password',
                            null::bigint,
                            null::timestamp with time zone,
                            null::varchar;
    end if;

exception
    when others then
        return
            query select false,
                         sqlerrm,
                         null::bigint,
                         null::timestamp with time zone,
                         null::varchar;
end;
$$;

create function sp_user_login_v1_1202_0(
    p_username varchar, p_password text
)
returns TABLE(
    success boolean,
    message text,
    userId bigint,
    lastLogin timestamp with time zone,
    role varchar
    )
language plpgsql
as
$$
begin
    return query
    select
        true,
        'Login successful',
        "userId",
        "lastLogin",
        "role"
    from "users"
    where "username" = lower(p_username)
    and "passwordHash" = crypt(p_password, "passwordHash");

    if not found then return query
    select
        false,
        'Invalid username or password',
        null::bigint,
        null::timestamp with time zone,
        null::varchar;
    else
        update "users"
        set "lastLogin" = now()
        where "username" = lower(p_username);
    end if;
end;
$$;