-- Notifications RLS policies
-- Note: backend uses service-role key and bypasses RLS, but these policies
-- are useful for future direct client reads/updates.

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "notifications_view_own" ON notifications
FOR SELECT USING (auth.uid() = user_id);

-- Users can mark their notifications as read
CREATE POLICY "notifications_update_own" ON notifications
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permissions for authenticated clients
GRANT SELECT, UPDATE ON notifications TO authenticated;

