-- Migration: Remove current_status and current_status_desc columns from land_areas table

-- Drop the index that references current_status
DROP INDEX IF EXISTS public.land_areas_status_idx;

-- Drop the columns
ALTER TABLE public.land_areas 
  DROP COLUMN IF EXISTS current_status,
  DROP COLUMN IF EXISTS current_status_desc;

-- Modified CREATE TABLE statement (for reference or new installations)
CREATE TABLE IF NOT EXISTS public.land_areas (
  id uuid not null default extensions.uuid_generate_v4 (),
  user_id integer null,
  path jsonb not null,
  created_at timestamp with time zone null default now(),
  lhid text null,
  title_number text null,
  lo_name text null,
  moa text null,
  barangay_name text null,
  total_area text null,
  survey_number text null,
  lot_number text null,
  problem_category text null,
  sub_category text null,
  remarks text null,
  land_status text null default 'workable'::text,
  exif_data jsonb null,
  land_image_url text null,
  constraint land_areas_pkey primary key (id),
  constraint land_areas_user_id_fkey foreign KEY (user_id) references users (user_id) on delete CASCADE,
  constraint land_areas_land_status_check check (
    (
      land_status = any (array['workable'::text, 'problematic'::text])
    )
  )
) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS land_areas_land_status_idx ON public.land_areas USING btree (land_status) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS land_areas_created_at_idx ON public.land_areas USING btree (created_at desc) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS land_areas_barangay_idx ON public.land_areas USING btree (barangay_name) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS land_areas_exif_data_idx ON public.land_areas USING gin (exif_data) TABLESPACE pg_default;

