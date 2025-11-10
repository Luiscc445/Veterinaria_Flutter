/**
 * Configuración de Supabase Client
 */

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Faltan variables de entorno de Supabase: SUPABASE_URL y/o SUPABASE_ANON_KEY');
}

/**
 * Cliente de Supabase con clave anónima (para operaciones normales con RLS)
 */
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: false,
    detectSessionInUrl: false
  }
});

/**
 * Cliente de Supabase con clave de servicio (para operaciones administrativas sin RLS)
 * ⚠️ USAR CON PRECAUCIÓN - Bypasea Row Level Security
 */
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

/**
 * Obtener cliente de Supabase con token de usuario
 * @param {string} accessToken - Token JWT del usuario
 * @returns {Object} Cliente de Supabase autenticado
 */
export const getSupabaseClientWithAuth = (accessToken) => {
  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`
      }
    },
    auth: {
      autoRefreshToken: true,
      persistSession: false,
      detectSessionInUrl: false
    }
  });
};

export default supabase;
