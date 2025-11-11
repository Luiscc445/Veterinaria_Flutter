# Funciones SQL para Creación Automática de Usuarios

Este documento explica cómo configurar las funciones SQL necesarias para que el sistema pueda crear y gestionar usuarios automáticamente sin intervención manual en Supabase.

## 📋 Funciones Disponibles

### 1. `cambiar_password_admin` - Cambio de Contraseñas por Admin

**Ubicación:** `database/functions/cambiar_password_admin.sql`

**Propósito:** Permite que los administradores cambien las contraseñas de cualquier usuario del sistema desde el dashboard web.

**Parámetros:**
- `p_user_email` (TEXT): Email del usuario al que se le cambiará la contraseña
- `p_nueva_password` (TEXT): Nueva contraseña (mínimo 6 caracteres)

**Uso desde el código:**
```typescript
const { data, error } = await supabase.rpc('cambiar_password_admin', {
  p_user_email: 'usuario@ejemplo.com',
  p_nueva_password: 'nuevaPassword123',
})
```

## 🚀 Instalación de las Funciones

### Opción 1: Desde Supabase Dashboard (Recomendado)

1. Abre tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Ve a **SQL Editor** en el menú lateral
3. Crea una nueva query
4. Copia y pega el contenido del archivo `cambiar_password_admin.sql`
5. Ejecuta la query (Run)
6. Verifica que aparezca el mensaje "Success. No rows returned"

### Opción 2: Desde CLI de Supabase

```bash
# Asegúrate de estar en el directorio del proyecto
cd /home/user/Veterinaria_Flutter

# Ejecutar el archivo SQL
supabase db push --file database/functions/cambiar_password_admin.sql
```

## ✅ Verificación

Después de instalar las funciones, verifica que estén disponibles:

```sql
-- Ejecuta esto en el SQL Editor de Supabase
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('cambiar_password_admin');
```

Deberías ver:
```
routine_name              | routine_type
--------------------------|-------------
cambiar_password_admin    | FUNCTION
```

## 🔒 Seguridad

Estas funciones usan `SECURITY DEFINER` lo que significa que se ejecutan con los permisos del creador (superusuario). Por esto:

1. ✅ **Validación de Admin:** Todas las funciones verifican que el usuario que las ejecuta sea administrador
2. ✅ **Permisos Limitados:** Solo usuarios autenticados pueden ejecutarlas (via `GRANT EXECUTE TO authenticated`)
3. ✅ **Auditoría:** Todos los errores se registran en los logs

## 📝 Notas Importantes

### Creación de Usuarios

El sistema ahora usa `supabase.auth.signUp()` directamente desde el código para crear usuarios en Authentication. Esto es más seguro y no requiere funciones SQL adicionales.

**Flujo de creación:**
1. Frontend llama a `supabase.auth.signUp()`
2. Supabase crea el usuario en `auth.users`
3. Frontend obtiene el `auth_user_id`
4. Frontend crea el registro en `users` con el `auth_user_id`
5. Si es necesario, crea registros en `tutores` o `profesionales`

### Cambio de Contraseñas

Para cambiar contraseñas, el sistema usa la función `cambiar_password_admin` que:
1. Verifica que quien la ejecuta sea admin
2. Busca el `auth_user_id` del usuario
3. Actualiza `encrypted_password` en `auth.users`
4. Usa `crypt()` con bcrypt para hashear la contraseña

## 🐛 Troubleshooting

### Error: "function does not exist"
**Solución:** La función no se ha instalado correctamente. Ejecuta el script SQL de nuevo.

### Error: "Solo administradores pueden..."
**Solución:** El usuario que intenta ejecutar la función no tiene rol 'admin' en la tabla `users`.

### Error: "Usuario no encontrado"
**Solución:** El email proporcionado no existe en la tabla `users`.

### Error: "permission denied for table auth.users"
**Solución:** La función necesita `SECURITY DEFINER` y debe ser creada por un superusuario. Ejecuta el script desde el SQL Editor de Supabase Dashboard.

## 📞 Soporte

Si tienes problemas instalando las funciones:
1. Verifica que tengas permisos de administrador en Supabase
2. Revisa los logs en Supabase Dashboard > Logs
3. Asegúrate de que la extensión `pgcrypto` esté habilitada: `CREATE EXTENSION IF NOT EXISTS pgcrypto;`
