import { createClient } from '@supabase/supabase-js'

// Wir holen die Daten aus der .env Datei
export const supabaseUrl: string = import.meta.env.VITE_SUPABASE_URL
export const supabaseAnonKey: string = import.meta.env.VITE_SUPABASE_ANON_KEY

// Erstellt die Verbindung
export const supabase = createClient(supabaseUrl, supabaseAnonKey) 