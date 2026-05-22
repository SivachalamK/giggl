-- Giggl Database Schema
-- Run in Supabase SQL Editor

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUM types
CREATE TYPE user_role AS ENUM ('customer', 'seller', 'admin');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'inProgress', 'completed', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'advancePaid', 'fullyPaid', 'failed', 'refunded');
CREATE TYPE seller_status AS ENUM ('pending', 'approved', 'rejected', 'suspended');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');

-- Users (extends auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  phone TEXT,
  full_name TEXT,
  avatar_url TEXT,
  role user_role DEFAULT 'customer',
  fcm_token TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT,
  slug TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.categories (name, slug) VALUES
  ('Photography', 'photography'),
  ('Videography', 'videography'),
  ('Catering', 'catering'),
  ('DJ', 'dj'),
  ('Travels', 'travels'),
  ('Makeup Artist', 'makeup-artist'),
  ('Mehendi', 'mehendi'),
  ('Astrologer', 'astrologer'),
  ('Iyer/Priest', 'iyer-priest'),
  ('Decoration', 'decoration'),
  ('Balloon Decoration', 'balloon-decoration'),
  ('Wedding Planner', 'wedding-planner'),
  ('Stage Setup', 'stage-setup'),
  ('Sound System', 'sound-system'),
  ('Return Gifts', 'return-gifts');

-- Sellers
CREATE TABLE public.sellers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  business_name TEXT NOT NULL,
  description TEXT,
  aadhaar_number TEXT,
  phone_verified BOOLEAN DEFAULT FALSE,
  email_verified BOOLEAN DEFAULT FALSE,
  status seller_status DEFAULT 'pending',
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  location_lat DECIMAL(10,8),
  location_lng DECIMAL(11,8),
  address TEXT,
  portfolio_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seller Verification
CREATE TABLE public.seller_verification (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id) ON DELETE CASCADE,
  aadhaar_number TEXT,
  aadhaar_document_url TEXT,
  status verification_status DEFAULT 'pending',
  reviewed_by UUID REFERENCES public.users(id),
  reviewed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Services
CREATE TABLE public.services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id),
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(12,2) NOT NULL,
  image_url TEXT,
  portfolio_urls TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bookings
CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id),
  service_id UUID NOT NULL REFERENCES public.services(id),
  event_date TIMESTAMPTZ NOT NULL,
  event_location TEXT,
  notes TEXT,
  total_amount DECIMAL(12,2) NOT NULL,
  advance_amount DECIMAL(12,2) NOT NULL,
  paid_amount DECIMAL(12,2) DEFAULT 0,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'pending',
  chat_room_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id),
  user_id UUID NOT NULL REFERENCES public.users(id),
  amount DECIMAL(12,2) NOT NULL,
  currency TEXT DEFAULT 'INR',
  type TEXT DEFAULT 'advance',
  razorpay_payment_id TEXT,
  razorpay_order_id TEXT,
  status TEXT DEFAULT 'pending',
  refund_amount DECIMAL(12,2),
  refunded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews
CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id) UNIQUE,
  customer_id UUID NOT NULL REFERENCES public.users(id),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id),
  service_id UUID NOT NULL REFERENCES public.services(id),
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chats
CREATE TABLE public.chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES public.bookings(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id),
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat Messages
CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id),
  content TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat Typing Indicator
CREATE TABLE public.chat_typing (
  room_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id),
  is_typing BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (room_id, user_id)
);

-- Wishlists
CREATE TABLE public.wishlists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, service_id)
);

-- Seller Availability
CREATE TABLE public.seller_availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  seller_id UUID NOT NULL REFERENCES public.sellers(user_id) ON DELETE CASCADE,
  date DATE NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  UNIQUE(seller_id, date)
);

-- Banners (Admin)
CREATE TABLE public.banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  image_url TEXT NOT NULL,
  link_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Complaints
CREATE TABLE public.complaints (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  booking_id UUID REFERENCES public.bookings(id),
  subject TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_sellers_status ON public.sellers(status);
CREATE INDEX idx_services_seller ON public.services(seller_id);
CREATE INDEX idx_services_category ON public.services(category_id);
CREATE INDEX idx_services_active ON public.services(is_active);
CREATE INDEX idx_bookings_customer ON public.bookings(customer_id);
CREATE INDEX idx_bookings_seller ON public.bookings(seller_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_payments_booking ON public.payments(booking_id);
CREATE INDEX idx_payments_user ON public.payments(user_id);
CREATE INDEX idx_notifications_user ON public.notifications(user_id);
CREATE INDEX idx_chat_messages_room ON public.chat_messages(room_id);
CREATE INDEX idx_wishlists_user ON public.wishlists(user_id);

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, phone, full_name, avatar_url, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Updated_at trigger
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER sellers_updated_at BEFORE UPDATE ON public.sellers
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER services_updated_at BEFORE UPDATE ON public.services
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER bookings_updated_at BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_verification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Public can view seller profiles" ON public.users
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.sellers WHERE user_id = users.id AND status = 'approved')
  );

-- Services policies
CREATE POLICY "Anyone can view active services" ON public.services
  FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Sellers manage own services" ON public.services
  FOR ALL USING (auth.uid() = seller_id);

-- Bookings policies
CREATE POLICY "Customers view own bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Sellers view their bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = seller_id);
CREATE POLICY "Customers create bookings" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Parties update bookings" ON public.bookings
  FOR UPDATE USING (auth.uid() = customer_id OR auth.uid() = seller_id);

-- Payments policies
CREATE POLICY "Users view own payments" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users create own payments" ON public.payments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Chat policies
CREATE POLICY "Chat participants access rooms" ON public.chats
  FOR SELECT USING (auth.uid() = customer_id OR auth.uid() = seller_id);
CREATE POLICY "Chat participants send messages" ON public.chat_messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.chats
      WHERE id = room_id AND (customer_id = auth.uid() OR seller_id = auth.uid())
    )
  );
CREATE POLICY "Chat participants read messages" ON public.chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.chats
      WHERE id = room_id AND (customer_id = auth.uid() OR seller_id = auth.uid())
    )
  );

-- Wishlist policies
CREATE POLICY "Users manage own wishlist" ON public.wishlists
  FOR ALL USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users view own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Sellers policies
CREATE POLICY "Anyone view approved sellers" ON public.sellers
  FOR SELECT USING (status = 'approved' OR auth.uid() = user_id);
CREATE POLICY "Users register as seller" ON public.sellers
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Sellers update own profile" ON public.sellers
  FOR UPDATE USING (auth.uid() = user_id);

-- Admin policies (role check)
CREATE POLICY "Admins full access sellers" ON public.sellers
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_typing;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
