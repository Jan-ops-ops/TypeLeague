import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://sgkafqxjnoaefkdonsxv.supabase.co/rest/v1/'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNna2FmcXhqbm9hZWZrZG9uc3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5MDcwNzMsImV4cCI6MjA5MjQ4MzA3M30.BeNfr7N-d9JZ7EPY0seNnJ04K86a8ZeOsOuAVG5QG5s'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)