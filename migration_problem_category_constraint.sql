-- Migration: Add check constraint for problem_category column
-- This ensures problem_category can only be one of the 4 specified values

-- First, normalize existing values to match dropdown options
UPDATE public.land_areas 
SET problem_category = CASE
  WHEN LOWER(problem_category) = 'document infirmities' THEN 'Document Infirmities'
  WHEN LOWER(problem_category) = 'land owner issues' THEN 'Land Owner Issues'
  WHEN problem_category LIKE '%peace%order%' OR problem_category = 'With peace and order problem; unstable peace & order situation' THEN 'Peace and Order Problem'
  WHEN problem_category = 'VLT Problems' THEN 'VLT Problems'
  ELSE NULL
END
WHERE problem_category IS NOT NULL;

-- Add check constraint to problem_category (matching dropdown values)
ALTER TABLE public.land_areas 
  DROP CONSTRAINT IF EXISTS land_areas_problem_category_check;

ALTER TABLE public.land_areas 
  ADD CONSTRAINT land_areas_problem_category_check 
  CHECK (
    problem_category IS NULL OR 
    problem_category IN (
      'Document Infirmities',
      'Land Owner Issues',
      'Peace and Order Problem',
      'VLT Problems'
    )
  );

-- Create index for better query performance when filtering by problem_category
CREATE INDEX IF NOT EXISTS land_areas_problem_category_idx 
  ON public.land_areas USING btree (problem_category) 
  TABLESPACE pg_default;

