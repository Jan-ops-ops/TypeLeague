import { createClient } from '@supabase/supabase-js'

// Wir holen die Daten aus der .env Datei
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Erstellt die Verbindung
export const supabase = createClient(supabaseUrl, supabaseAnonKey) 