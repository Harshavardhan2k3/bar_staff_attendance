-- Location: supabase/migrations/20241205083332_bar_staff_attendance_system.sql
-- Schema Analysis: No existing schema - creating complete attendance system
-- Integration Type: Complete new schema
-- Dependencies: None (new project)

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'staff');
CREATE TYPE public.attendance_status AS ENUM ('present', 'late', 'early', 'absent');
CREATE TYPE public.leave_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE public.leave_type AS ENUM ('sick', 'vacation', 'personal', 'emergency');

-- 2. Core Tables

-- User profiles table (intermediary for auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    employee_id TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'staff'::public.user_role,
    position TEXT,
    department TEXT,
    phone_number TEXT,
    hire_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Work schedules table
CREATE TABLE public.work_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0 = Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Attendance records table
CREATE TABLE public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    clock_in_time TIMESTAMPTZ,
    clock_out_time TIMESTAMPTZ,
    scheduled_start TIME,
    scheduled_end TIME,
    total_hours DECIMAL(4,2) DEFAULT 0,
    status public.attendance_status DEFAULT 'present'::public.attendance_status,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

-- Leave requests table
CREATE TABLE public.leave_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    leave_type public.leave_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    reason TEXT NOT NULL,
    status public.leave_status DEFAULT 'pending'::public.leave_status,
    approved_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Leave balances table
CREATE TABLE public.leave_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    sick_leave_total INTEGER DEFAULT 12,
    sick_leave_used INTEGER DEFAULT 0,
    vacation_leave_total INTEGER DEFAULT 15,
    vacation_leave_used INTEGER DEFAULT 0,
    personal_leave_total INTEGER DEFAULT 5,
    personal_leave_used INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, year)
);

-- Notifications table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_employee_id ON public.user_profiles(employee_id);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_work_schedules_user_id ON public.work_schedules(user_id);
CREATE INDEX idx_attendance_records_user_id ON public.attendance_records(user_id);
CREATE INDEX idx_attendance_records_date ON public.attendance_records(date);
CREATE INDEX idx_attendance_records_user_date ON public.attendance_records(user_id, date);
CREATE INDEX idx_leave_requests_user_id ON public.leave_requests(user_id);
CREATE INDEX idx_leave_requests_status ON public.leave_requests(status);
CREATE INDEX idx_leave_balances_user_id ON public.leave_balances(user_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(is_read);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role, employee_id)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'staff'::public.user_role),
        COALESCE(NEW.raw_user_meta_data->>'employee_id', 'EMP' || EXTRACT(EPOCH FROM NOW())::TEXT)
    );
    
    -- Create initial leave balance for current year
    INSERT INTO public.leave_balances (user_id, year)
    VALUES (NEW.id, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
    
    RETURN NEW;
END;
$$;

-- Function to calculate attendance status
CREATE OR REPLACE FUNCTION public.calculate_attendance_status(
    clock_in_time TIMESTAMPTZ,
    clock_out_time TIMESTAMPTZ,
    scheduled_start TIME,
    scheduled_end TIME
)
RETURNS public.attendance_status
LANGUAGE plpgsql
AS $$
DECLARE
    late_threshold INTERVAL := '15 minutes';
    early_threshold INTERVAL := '30 minutes';
    actual_start TIME;
    actual_end TIME;
BEGIN
    -- If no clock in time, mark as absent
    IF clock_in_time IS NULL THEN
        RETURN 'absent'::public.attendance_status;
    END IF;
    
    actual_start := clock_in_time::TIME;
    
    -- Check if late (more than 15 minutes after scheduled start)
    IF actual_start > (scheduled_start + late_threshold) THEN
        RETURN 'late'::public.attendance_status;
    END IF;
    
    -- Check if early departure (left more than 30 minutes before scheduled end)
    IF clock_out_time IS NOT NULL THEN
        actual_end := clock_out_time::TIME;
        IF actual_end < (scheduled_end - early_threshold) THEN
            RETURN 'early'::public.attendance_status;
        END IF;
    END IF;
    
    RETURN 'present'::public.attendance_status;
END;
$$;

-- Function to update leave balance
CREATE OR REPLACE FUNCTION public.update_leave_balance(
    p_user_id UUID,
    p_leave_type public.leave_type,
    p_days INTEGER,
    p_operation TEXT -- 'add' or 'subtract'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_leave_type = 'sick' THEN
        IF p_operation = 'add' THEN
            UPDATE public.leave_balances 
            SET sick_leave_used = sick_leave_used + p_days
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        ELSE
            UPDATE public.leave_balances 
            SET sick_leave_used = GREATEST(0, sick_leave_used - p_days)
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        END IF;
    ELSIF p_leave_type = 'vacation' THEN
        IF p_operation = 'add' THEN
            UPDATE public.leave_balances 
            SET vacation_leave_used = vacation_leave_used + p_days
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        ELSE
            UPDATE public.leave_balances 
            SET vacation_leave_used = GREATEST(0, vacation_leave_used - p_days)
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        END IF;
    ELSIF p_leave_type = 'personal' THEN
        IF p_operation = 'add' THEN
            UPDATE public.leave_balances 
            SET personal_leave_used = personal_leave_used + p_days
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        ELSE
            UPDATE public.leave_balances 
            SET personal_leave_used = GREATEST(0, personal_leave_used - p_days)
            WHERE user_id = p_user_id AND year = EXTRACT(YEAR FROM CURRENT_DATE);
        END IF;
    END IF;
END;
$$;

-- Function for role-based access using auth metadata
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

-- Function for manager role check
CREATE OR REPLACE FUNCTION public.is_manager_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' IN ('admin', 'manager')
         OR au.raw_app_meta_data->>'role' IN ('admin', 'manager'))
)
$$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Admin can manage all user profiles
CREATE POLICY "admin_manage_all_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for work schedules
CREATE POLICY "users_manage_own_work_schedules"
ON public.work_schedules
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Managers can view all schedules
CREATE POLICY "managers_view_all_work_schedules"
ON public.work_schedules
FOR SELECT
TO authenticated
USING (public.is_manager_from_auth());

-- Pattern 2: Simple user ownership for attendance records
CREATE POLICY "users_manage_own_attendance_records"
ON public.attendance_records
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Managers can view all attendance records
CREATE POLICY "managers_view_all_attendance_records"
ON public.attendance_records
FOR SELECT
TO authenticated
USING (public.is_manager_from_auth());

-- Pattern 2: Simple user ownership for leave requests
CREATE POLICY "users_manage_own_leave_requests"
ON public.leave_requests
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Managers can view and approve leave requests
CREATE POLICY "managers_manage_leave_requests"
ON public.leave_requests
FOR ALL
TO authenticated
USING (public.is_manager_from_auth())
WITH CHECK (public.is_manager_from_auth());

-- Pattern 2: Simple user ownership for leave balances
CREATE POLICY "users_view_own_leave_balances"
ON public.leave_balances
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Only admins can modify leave balances
CREATE POLICY "admin_manage_leave_balances"
ON public.leave_balances
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for notifications
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.updated_at_trigger();

CREATE TRIGGER update_attendance_records_updated_at
    BEFORE UPDATE ON public.attendance_records
    FOR EACH ROW EXECUTE FUNCTION public.updated_at_trigger();

CREATE TRIGGER update_leave_requests_updated_at
    BEFORE UPDATE ON public.leave_requests
    FOR EACH ROW EXECUTE FUNCTION public.updated_at_trigger();

CREATE TRIGGER update_leave_balances_updated_at
    BEFORE UPDATE ON public.leave_balances
    FOR EACH ROW EXECUTE FUNCTION public.updated_at_trigger();

-- Function for updated_at trigger
CREATE OR REPLACE FUNCTION public.updated_at_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 8. Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    staff1_uuid UUID := gen_random_uuid();
    staff2_uuid UUID := gen_random_uuid();
    staff3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@barstaff.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "System Admin", "role": "admin", "employee_id": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@barstaff.com', crypt('manager456', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Bar Manager", "role": "manager", "employee_id": "manager"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (staff1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john@barstaff.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Doe", "role": "staff", "employee_id": "staff001"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (staff2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'sarah@barstaff.com', crypt('bar2024', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Wilson", "role": "staff", "employee_id": "bartender"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (staff3_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'mike@barstaff.com', crypt('server123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Mike Johnson", "role": "staff", "employee_id": "server001"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update user profiles with additional details (trigger creates basic profiles)
    UPDATE public.user_profiles SET position = 'System Administrator', department = 'IT' WHERE id = admin_uuid;
    UPDATE public.user_profiles SET position = 'Bar Manager', department = 'Operations' WHERE id = manager_uuid;
    UPDATE public.user_profiles SET position = 'Bartender', department = 'Service', hire_date = '2024-01-15' WHERE id = staff1_uuid;
    UPDATE public.user_profiles SET position = 'Bartender', department = 'Service', hire_date = '2024-02-01' WHERE id = staff2_uuid;
    UPDATE public.user_profiles SET position = 'Server', department = 'Service', hire_date = '2024-03-10' WHERE id = staff3_uuid;

    -- Create work schedules
    INSERT INTO public.work_schedules (user_id, day_of_week, start_time, end_time) VALUES
        -- John Doe - Monday to Friday, 9 AM to 6 PM
        (staff1_uuid, 1, '09:00:00', '18:00:00'),
        (staff1_uuid, 2, '09:00:00', '18:00:00'),
        (staff1_uuid, 3, '09:00:00', '18:00:00'),
        (staff1_uuid, 4, '09:00:00', '18:00:00'),
        (staff1_uuid, 5, '09:00:00', '18:00:00'),
        -- Sarah Wilson - Tuesday to Saturday, 5 PM to 1 AM
        (staff2_uuid, 2, '17:00:00', '01:00:00'),
        (staff2_uuid, 3, '17:00:00', '01:00:00'),
        (staff2_uuid, 4, '17:00:00', '01:00:00'),
        (staff2_uuid, 5, '17:00:00', '01:00:00'),
        (staff2_uuid, 6, '17:00:00', '01:00:00');

    -- Create sample attendance records
    INSERT INTO public.attendance_records (
        user_id, date, clock_in_time, clock_out_time, scheduled_start, scheduled_end, 
        total_hours, status
    ) VALUES
        -- Recent records for John Doe
        (staff1_uuid, '2024-12-04', '2024-12-04 09:00:00+00', '2024-12-04 18:00:00+00', '09:00:00', '18:00:00', 8.0, 'present'),
        (staff1_uuid, '2024-12-03', '2024-12-03 09:15:00+00', '2024-12-03 18:15:00+00', '09:00:00', '18:00:00', 8.0, 'late'),
        (staff1_uuid, '2024-12-02', '2024-12-02 08:45:00+00', '2024-12-02 17:45:00+00', '09:00:00', '18:00:00', 8.0, 'early'),
        (staff1_uuid, '2024-12-01', NULL, NULL, '09:00:00', '18:00:00', 0.0, 'absent'),
        (staff1_uuid, '2024-11-30', '2024-11-30 09:00:00+00', '2024-11-30 18:00:00+00', '09:00:00', '18:00:00', 8.0, 'present'),
        -- Records for Sarah Wilson
        (staff2_uuid, '2024-12-04', '2024-12-04 17:00:00+00', '2024-12-05 01:00:00+00', '17:00:00', '01:00:00', 8.0, 'present'),
        (staff2_uuid, '2024-12-03', '2024-12-03 17:10:00+00', '2024-12-04 01:00:00+00', '17:00:00', '01:00:00', 7.8, 'late');

    -- Create sample leave requests
    INSERT INTO public.leave_requests (
        user_id, leave_type, start_date, end_date, total_days, reason, status
    ) VALUES
        (staff1_uuid, 'vacation', '2024-12-20', '2024-12-24', 3, 'Christmas vacation with family', 'approved'),
        (staff2_uuid, 'sick', '2024-12-10', '2024-12-10', 1, 'Feeling unwell, need rest', 'pending');

    -- Update leave balances to reflect used days
    UPDATE public.leave_balances SET vacation_leave_used = 3 WHERE user_id = staff1_uuid;

    -- Create sample notifications
    INSERT INTO public.notifications (user_id, title, message, type) VALUES
        (staff1_uuid, 'Leave Request Approved', 'Your vacation leave for Dec 20-24 has been approved.', 'success'),
        (staff1_uuid, 'Schedule Update', 'Your work schedule has been updated for next week.', 'info'),
        (staff1_uuid, 'Reminder', 'Please remember to clock out when leaving work.', 'warning'),
        (staff2_uuid, 'Leave Request Submitted', 'Your sick leave request is pending approval.', 'info'),
        (staff2_uuid, 'Welcome', 'Welcome to Bar Staff Attendance System!', 'info');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;