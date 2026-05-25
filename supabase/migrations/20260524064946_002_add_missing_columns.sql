/*
  # Add missing columns and updates

  1. Add event_type column to bookings if missing
  2. Verify all RLS policies are properly configured
  3. No destructive changes - only additions
*/

-- Add event_type column to bookings if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bookings' AND column_name = 'event_type'
  ) THEN
    ALTER TABLE public.bookings ADD COLUMN event_type TEXT DEFAULT 'event';
  END IF;
END $$;