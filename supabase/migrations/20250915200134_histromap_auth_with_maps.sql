-- Location: supabase/migrations/20250915200134_histromap_auth_with_maps.sql
-- Schema Analysis: Fresh project - creating complete schema from scratch
-- Integration Type: Authentication + Historical Maps module
-- Dependencies: None (fresh start)

-- 1. Types and Core Tables
CREATE TYPE public.user_role AS ENUM ('admin', 'historian', 'explorer');
CREATE TYPE public.map_era AS ENUM ('ancient', 'medieval', 'renaissance', 'industrial', 'modern', 'contemporary');
CREATE TYPE public.map_status AS ENUM ('active', 'archived', 'under_review');
CREATE TYPE public.annotation_type AS ENUM ('location', 'route', 'region', 'event', 'building');

-- Critical intermediary table for authentication
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'explorer'::public.user_role,
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Historical maps table
CREATE TABLE public.historical_maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    era public.map_era NOT NULL,
    year_start INTEGER,
    year_end INTEGER,
    location_name TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    map_image_url TEXT,
    thumbnail_url TEXT,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    status public.map_status DEFAULT 'active'::public.map_status,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Collections for organizing maps
CREATE TABLE public.collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    is_public BOOLEAN DEFAULT false,
    cover_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for maps in collections
CREATE TABLE public.collection_maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID REFERENCES public.collections(id) ON DELETE CASCADE,
    map_id UUID REFERENCES public.historical_maps(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, map_id)
);

-- Map annotations for interactive features
CREATE TABLE public.map_annotations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    map_id UUID REFERENCES public.historical_maps(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type public.annotation_type NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    color TEXT DEFAULT '#3B82F6',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- User activity tracking for real-time features
CREATE TABLE public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    resource_type TEXT NOT NULL,
    resource_id UUID NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_historical_maps_era ON public.historical_maps(era);
CREATE INDEX idx_historical_maps_location ON public.historical_maps(latitude, longitude);
CREATE INDEX idx_historical_maps_creator ON public.historical_maps(creator_id);
CREATE INDEX idx_historical_maps_status ON public.historical_maps(status);
CREATE INDEX idx_collections_owner ON public.collections(owner_id);
CREATE INDEX idx_collection_maps_collection ON public.collection_maps(collection_id);
CREATE INDEX idx_collection_maps_map ON public.collection_maps(map_id);
CREATE INDEX idx_map_annotations_map ON public.map_annotations(map_id);
CREATE INDEX idx_map_annotations_user ON public.map_annotations(user_id);
CREATE INDEX idx_user_activities_user ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_created ON public.user_activities(created_at);

-- 3. Update timestamp function
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Triggers for updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_historical_maps_updated_at
    BEFORE UPDATE ON public.historical_maps
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_collections_updated_at
    BEFORE UPDATE ON public.collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historical_maps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_maps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.map_annotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies - Following Pattern System

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for historical maps
CREATE POLICY "public_can_read_historical_maps"
ON public.historical_maps
FOR SELECT
TO public
USING (status = 'active'::public.map_status);

CREATE POLICY "users_manage_own_historical_maps"
ON public.historical_maps
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

-- Pattern 6A: Admin access for maps using auth metadata
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

CREATE POLICY "admin_full_access_historical_maps"
ON public.historical_maps
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Pattern 2: Simple user ownership for collections
CREATE POLICY "users_manage_own_collections"
ON public.collections
FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

-- Public read for public collections
CREATE POLICY "public_can_read_public_collections"
ON public.collections
FOR SELECT
TO public
USING (is_public = true);

-- Pattern 7: Complex relationship for collection_maps
CREATE OR REPLACE FUNCTION public.can_access_collection_maps(collection_map_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.collections c
    JOIN public.collection_maps cm ON c.id = cm.collection_id
    WHERE cm.id = collection_map_uuid
    AND (c.owner_id = auth.uid() OR c.is_public = true)
)
$$;

CREATE POLICY "users_access_collection_maps"
ON public.collection_maps
FOR SELECT
TO authenticated
USING (public.can_access_collection_maps(id));

CREATE POLICY "owners_manage_collection_maps"
ON public.collection_maps
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.collections c
        WHERE c.id = collection_id AND c.owner_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.collections c
        WHERE c.id = collection_id AND c.owner_id = auth.uid()
    )
);

-- Pattern 2: Simple user ownership for annotations
CREATE POLICY "users_manage_own_map_annotations"
ON public.map_annotations
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Public read for annotations on active maps
CREATE POLICY "public_can_read_map_annotations"
ON public.map_annotations
FOR SELECT
TO public
USING (
    EXISTS (
        SELECT 1 FROM public.historical_maps hm
        WHERE hm.id = map_id AND hm.status = 'active'::public.map_status
    )
);

-- Pattern 2: Simple user ownership for activities
CREATE POLICY "users_manage_own_user_activities"
ON public.user_activities
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Functions for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'explorer')::public.user_role
    );
    RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 8. Real-time activity logging function
CREATE OR REPLACE FUNCTION public.log_user_activity(
    p_activity_type TEXT,
    p_resource_type TEXT,
    p_resource_id UUID,
    p_metadata JSONB DEFAULT '{}'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    activity_id UUID;
BEGIN
    INSERT INTO public.user_activities (user_id, activity_type, resource_type, resource_id, metadata)
    VALUES (auth.uid(), p_activity_type, p_resource_type, p_resource_id, p_metadata)
    RETURNING id INTO activity_id;
    
    RETURN activity_id;
END;
$$;

-- 9. Complete Mock Data with Authentication
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    historian_uuid UUID := gen_random_uuid();
    explorer_uuid UUID := gen_random_uuid();
    map1_id UUID := gen_random_uuid();
    map2_id UUID := gen_random_uuid();
    map3_id UUID := gen_random_uuid();
    collection1_id UUID := gen_random_uuid();
    collection2_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records with all required fields
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
         'admin@histromap.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (historian_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'historian@histromap.com', crypt('secure123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Sarah Chen", "role": "historian"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (explorer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'explorer@histromap.com', crypt('explore123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Map Explorer", "role": "explorer"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create historical maps
    INSERT INTO public.historical_maps (id, title, description, era, year_start, year_end, location_name, latitude, longitude, map_image_url, thumbnail_url, creator_id, view_count)
    VALUES
        (map1_id, 'Ancient Rome - Forum Romanum', 'Detailed map of the Roman Forum during the height of the Roman Empire, showing temples, basilicas, and public spaces.', 'ancient'::public.map_era, 100, 200, 'Rome, Italy', 41.8925, 12.4853, 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800', 'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=400', historian_uuid, 1247),
        (map2_id, 'Medieval London Bridge', 'Historic depiction of London Bridge in the 14th century, showing the famous houses and shops built upon it.', 'medieval'::public.map_era, 1300, 1400, 'London, England', 51.5074, -0.0862, 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800', 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400', historian_uuid, 892),
        (map3_id, 'Industrial Manchester Mills', 'Map showing the textile mills and industrial infrastructure of Manchester during the Industrial Revolution.', 'industrial'::public.map_era, 1850, 1900, 'Manchester, England', 53.4808, -2.2426, 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800', 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400', admin_uuid, 654);

    -- Create collections
    INSERT INTO public.collections (id, name, description, owner_id, is_public, cover_image_url)
    VALUES
        (collection1_id, 'Ancient Civilizations', 'Maps showcasing the great ancient civilizations and their architectural marvels.', historian_uuid, true, 'https://images.unsplash.com/photo-1539650116574-75c0c6d0258f?w=600'),
        (collection2_id, 'Industrial Revolution Sites', 'Historical maps documenting the transformation of cities during the Industrial Revolution.', admin_uuid, true, 'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=600');

    -- Add maps to collections
    INSERT INTO public.collection_maps (collection_id, map_id)
    VALUES
        (collection1_id, map1_id),
        (collection2_id, map3_id);

    -- Create sample annotations
    INSERT INTO public.map_annotations (map_id, user_id, type, title, content, latitude, longitude, color)
    VALUES
        (map1_id, historian_uuid, 'building'::public.annotation_type, 'Temple of Jupiter', 'The largest temple in the Roman Forum, dedicated to Jupiter Optimus Maximus.', 41.8930, 12.4840, '#FF6B6B'),
        (map1_id, explorer_uuid, 'location'::public.annotation_type, 'Basilica Julia', 'Important judicial building where legal proceedings took place.', 41.8920, 12.4850, '#4ECDC4'),
        (map2_id, historian_uuid, 'route'::public.annotation_type, 'Main Thoroughfare', 'Primary route across the Thames connecting the City to Southwark.', 51.5074, -0.0862, '#45B7D1');

    -- Log some sample activities
    INSERT INTO public.user_activities (user_id, activity_type, resource_type, resource_id, metadata)
    VALUES
        (historian_uuid, 'map_view', 'historical_map', map1_id, '{"duration_seconds": 120, "zoom_level": 15}'::jsonb),
        (explorer_uuid, 'collection_view', 'collection', collection1_id, '{"maps_viewed": 3}'::jsonb),
        (admin_uuid, 'annotation_create', 'map_annotation', map1_id, '{"annotation_type": "building"}'::jsonb);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 10. Enable Realtime for all tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE public.historical_maps;
ALTER PUBLICATION supabase_realtime ADD TABLE public.collections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.collection_maps;
ALTER PUBLICATION supabase_realtime ADD TABLE public.map_annotations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_activities;