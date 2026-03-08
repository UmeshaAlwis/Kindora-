import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://ucxqakixdpqqmbbpeptm.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeHFha2l4ZHBxcW1iYnBlcHRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1MzY1NDcsImV4cCI6MjA4NjExMjU0N30.lqbexF_zdeKXtcwpG-Ou0rw1IaBhYsMIgWa2yHfxDBY'
export const supabase = createClient(supabaseUrl, supabaseKey)