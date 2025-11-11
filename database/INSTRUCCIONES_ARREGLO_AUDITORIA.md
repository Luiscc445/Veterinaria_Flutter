# 🔧 Arreglo del Error de Auditoría

## ❌ Error que Aparecía

```
Error al guardar el personal:
insert or update on table "auditoria" violates foreign key constraint "auditoria_usuario_id_fkey"

Detalles: Key (usuario_id)=(fcc2c31e-f436-4a37-bb42-8d95e2332d6e) is not present in table "users".
```

## 🔍 Causa del Problema

El sistema tiene un **trigger de auditoría** que se ejecuta automáticamente cada vez que se inserta un registro en la tabla `users`.

**El flujo problemático era:**

1. Cliente admin crea usuario en `auth.users` con `createUser()` ✅
2. Sistema inserta registro en tabla `users`
3. **TRIGGER** `trigger_audit_users` se dispara automáticamente
4. Trigger llama a función `registrar_auditoria()`
5. Función usa `auth.uid()` para obtener el ID del usuario que hace la acción
6. Pero `auth.uid()` retorna el UUID del **cliente admin** (service_role), NO del usuario que se está creando
7. Ese UUID del cliente admin NO existe en la tabla `users`
8. ❌ **ERROR**: Foreign key violation en tabla `auditoria`

## ✅ Solución Implementada

He creado una versión mejorada de la función `registrar_auditoria()` que:

1. **Busca el usuario correcto**: Intenta encontrar el `id` del usuario en la tabla `users` que corresponda al `auth_user_id` actual
2. **Si no existe**: Usa `NULL` (que está permitido en la columna `usuario_id`)
3. **Para operaciones en la tabla users**: Usa el `id` del nuevo usuario siendo creado
4. **Manejo de errores**: Si aún así falla, inserta con `NULL` para no bloquear la operación principal

## 📋 PASOS PARA ARREGLAR (Solo 2 minutos)

### Paso 1: Abrir Supabase SQL Editor

1. Ve a [Supabase Dashboard](https://app.supabase.com)
2. Selecciona tu proyecto **RamboPet**
3. En el menú lateral, haz clic en **SQL Editor**
4. Haz clic en **New query** (botón verde)

### Paso 2: Copiar el Script

Abre el archivo:
```
database/fix_auditoria_trigger.sql
```

Copia TODO el contenido (desde `CREATE OR REPLACE FUNCTION` hasta el final)

### Paso 3: Pegar y Ejecutar

1. Pega el contenido en el SQL Editor de Supabase
2. Haz clic en **Run** (o presiona Ctrl+Enter)
3. Deberías ver: **"Success. No rows returned"**

### Paso 4: Verificar

Ejecuta esta query para verificar que se actualizó:

```sql
SELECT
    proname as nombre_funcion,
    pg_get_functiondef(oid) as definicion
FROM pg_proc
WHERE proname = 'registrar_auditoria';
```

Deberías ver la nueva definición de la función con el manejo de errores.

## 🎯 Resultado Después del Arreglo

**Ahora el flujo es:**

1. Cliente admin crea usuario en `auth.users` ✅
2. Sistema inserta registro en tabla `users` ✅
3. Trigger se dispara ✅
4. Función busca el usuario correcto en la tabla `users` ✅
5. **Si el usuario no existe aún** (caso de creación desde admin), usa el `id` del nuevo usuario ✅
6. Inserta en auditoría sin errores ✅
7. ✅ **Usuario creado exitosamente**

## 🧪 Probar la Solución

Después de ejecutar el script:

1. Reinicia tu aplicación web (por si acaso):
   ```bash
   # Detén el servidor (Ctrl+C)
   npm run dev
   ```

2. Intenta crear un nuevo personal:
   - Dashboard → Personal → Agregar Personal
   - Completa todos los campos
   - Haz clic en **Crear**

3. Deberías ver:
   ```
   ✅ Usuario creado exitosamente!

   Email: ejemplo@test.com
   Contraseña: Test123!

   El usuario ya puede iniciar sesión en el sistema.
   ```

4. Verifica en la consola del navegador (F12):
   ```
   ✅ Usuario creado en auth.users con ID: ...
   ✅ Usuario insertado en tabla users: ...
   ✅ Profesional insertado correctamente
   🎉 PROCESO COMPLETO - Usuario creado exitosamente
   ```

## 📊 ¿Qué Pasa con los Registros de Auditoría?

**Operaciones normales** (admin logueado desde el dashboard):
- ✅ `usuario_id` tendrá el ID del admin que hizo la acción

**Operaciones desde service_role** (creación de usuarios):
- ✅ `usuario_id` tendrá el ID del usuario que se está creando
- O `NULL` si no se puede determinar

**Esto es correcto** porque:
- Para crear usuarios nuevos, no hay un "usuario" que haga la acción (es el sistema)
- La auditoría registra que se creó el usuario, aunque el campo `usuario_id` sea el mismo usuario o NULL

## 🆘 Si Aún Hay Problemas

Si después de ejecutar el script sigues teniendo errores:

1. **Verifica que se ejecutó correctamente**:
   ```sql
   SELECT routine_name, routine_definition
   FROM information_schema.routines
   WHERE routine_name = 'registrar_auditoria';
   ```

2. **Revisa los triggers existentes**:
   ```sql
   SELECT trigger_name, event_manipulation, event_object_table
   FROM information_schema.triggers
   WHERE trigger_name LIKE '%audit%';
   ```

3. **Comparte los detalles del error**:
   - Abre consola del navegador (F12)
   - Intenta crear usuario
   - Copia TODO el output de la consola
   - Comparte el mensaje de error completo

## 📝 Notas Técnicas

**¿Por qué no eliminamos el trigger?**
- El trigger de auditoría es importante para rastrear cambios
- La solución es arreglarlo, no eliminarlo

**¿Por qué NULL en usuario_id es aceptable?**
- Para operaciones del sistema (no iniciadas por un usuario específico)
- El resto de la información (qué se modificó, cuándo, datos) sigue registrada

**¿Afecta a otras operaciones?**
- No, solo mejora el manejo de operaciones desde service_role
- Las operaciones normales siguen funcionando igual

## ✅ Confirmación Final

Después de ejecutar el script, deberías poder:
- ✅ Crear personal (veterinarios, laboratoristas, etc.)
- ✅ Crear tutores
- ✅ El sistema crea los usuarios automáticamente
- ✅ La auditoría registra las operaciones correctamente
- ✅ Sin errores de foreign key
