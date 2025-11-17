-- Migration: Add check constraint for problem_category column
-- This ensures problem_category can only be one of the 4 specified values

-- First, update any existing invalid values to NULL
UPDATE public.land_areas 
SET problem_category = NULL 
WHERE problem_category IS NOT NULL 
  AND problem_category NOT IN (
    'document infirmities',
    'land owner issues',
    'With peace and order problem; unstable peace & order situation',
    'VLT Problems'
  );

-- Add check constraint to problem_category
ALTER TABLE public.land_areas 
  DROP CONSTRAINT IF EXISTS land_areas_problem_category_check;

ALTER TABLE public.land_areas 
  ADD CONSTRAINT land_areas_problem_category_check 
  CHECK (
    problem_category IS NULL OR 
    problem_category IN (
      'document infirmities',
      'land owner issues',
      'With peace and order problem; unstable peace & order situation',
      'VLT Problems'
    )
  );

-- Create index for better query performance when filtering by problem_category
CREATE INDEX IF NOT EXISTS land_areas_problem_category_idx 
  ON public.land_areas USING btree (problem_category) 
  TABLESPACE pg_default;

