-- Enable required extensions
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- ENUMS
create type user_role as enum ('admin', 'staff');
create type attendance_status as enum ('present', 'absent', 'late');
create type leave_status as enum ('pending', 'approved', 'rejected');

-- TABLE: User Profiles
create table if not exists user_profiles (
    id uuid primary key default gen_random_uuid(),
    emp_id text unique not null,
    full_name text not null,
    password_hash text not null,
    role user_role not null default 'staff',
    created_at timestamp default now()
);

-- TABLE: Work Schedules
create table if not exists work_schedules (
    id uuid primary key default gen_random_uuid(),
    emp_id text not null references user_profiles(emp_id) on delete cascade,
    start_time time not null,
    end_time time not null
);

-- TABLE: Attendance Records
create table if not exists attendance_records (
    id uuid primary key default gen_random_uuid(),
    emp_id text not null references user_profiles(emp_id) on delete cascade,
    login_time timestamp,
    logout_time timestamp,
    qr_code_data text,
    status attendance_status default 'present',
    created_at timestamp default now()
);

-- TABLE: Leave Requests
create table if not exists leave_requests (
    id uuid primary key default gen_random_uuid(),
    emp_id text not null references user_profiles(emp_id) on delete cascade,
    start_date date not null,
    end_date date not null,
    reason text,
    status leave_status default 'pending',
    created_at timestamp default now()
);

-- TABLE: Leave Balances
create table if not exists leave_balances (
    emp_id text primary key references user_profiles(emp_id) on delete cascade,
    total_leaves integer default 30,
    used_leaves integer default 0
);

-- TABLE: Notifications
create table if not exists notifications (
    id uuid primary key default gen_random_uuid(),
    emp_id text references user_profiles(emp_id) on delete cascade,
    title text not null,
    message text not null,
    created_at timestamp default now()
);

-- FUNCTION: Auto-create leave balance when new user is added
create or replace function create_leave_balance()
returns trigger as $$
begin
    insert into leave_balances(emp_id)
    values (new.emp_id);
    return new;
end;
$$ language plpgsql;

-- TRIGGER: On user insert → create leave balance
create trigger trg_create_leave_balance
after insert on user_profiles
for each row execute function create_leave_balance();
