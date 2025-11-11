# 🔐 Configurar Cambio de Contraseñas desde el Dashboard

Este documento explica cómo habilitar el cambio directo de contraseñas desde el dashboard de administración.

## ⚠️ IMPORTANTE: Consideraciones de Seguridad

Hay **DOS MÉTODOS** para cambiar contraseñas:

### Método 1: Link de Recuperación por Email (RECOMENDADO - MÁS SEGURO)
✅ **VENTAJAS:**
- No requiere configuración adicional
- Más seguro (no expone credenciales sensibles)
- El usuario recibe un email para cambiar su contraseña
- Funciona de forma predeterminada

❌ **DESVENTAJAS:**
- El usuario debe tener acceso a su email
- Requiere configuración de email en Supabase
- No es instantáneo (depende del email)

### Método 2: Cambio Directo (REQUIERE CONFIGURACIÓN - MENOS SEGURO)
✅ **VENTAJAS:**
- Cambio instantáneo de contraseña
- El admin ve y establece la nueva contraseña
- No requiere que el usuario tenga email activo

❌ **DESVENTAJAS:**
- Requiere exponer el Service Role Key en el frontend
- **RIESGO DE SEGURIDAD**: Si alguien accede al código fuente, obtiene acceso COMPLETO a la base de datos
- Solo recomendado para aplicaciones NO públicas (intranets, localhost, red privada)

## 🔧 Configuración del Método 2 (Cambio Directo)

### Paso 1: Obtener el Service Role Key

1. Abre [Supabase Dashboard](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Settings** (⚙️) en el menú lateral
4. Haz clic en **API**
5. En la sección **Project API keys**, encuentra:
   - `service_role` key (secret)
6. Haz clic en el ícono 👁️ para revelar la clave
7. **Copia la clave completa**

### Paso 2: Configurar el Archivo .env

1. En el proyecto web, crea o edita el archivo `.env`:

```bash
cd /home/user/Veterinaria_Flutter/web
cp .env.example .env
nano .env
```

2. Agrega las siguientes variables:

```env
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu_anon_key_aqui

# Service Role Key (SOLO para cambio directo de contraseñas)
VITE_SUPABASE_SERVICE_ROLE_KEY=tu_service_role_key_aqui
```

3. Guarda el archivo

### Paso 3: Reiniciar el Servidor de Desarrollo

```bash
npm run dev
```

### Paso 4: Verificar que Funciona

1. Abre el dashboard en `http://localhost:5173`
2. Ve a **Personal**
3. Haz clic en el botón **Contraseña** de cualquier usuario
4. Ingresa una nueva contraseña
5. Haz clic en **Cambiar Contraseña**

Si funciona, verás: `✅ Contraseña actualizada exitosamente!`

## 🛡️ Medidas de Seguridad Adicionales

Si decides usar el Método 2 (cambio directo), **DEBES** tomar estas precauciones:

### 1. NO Exponer la Aplicación Públicamente

La aplicación debe estar:
- ✅ En red local (intranet)
- ✅ En localhost (solo desarrollo)
- ✅ Detrás de VPN
- ✅ Con autenticación adicional (firewall, IP whitelist)
- ❌ Accesible desde internet público

### 2. NO Subir el .env a Git

Verifica que `.env` esté en `.gitignore`:

```bash
# Verificar .gitignore
cat .gitignore | grep .env

# Si no está, agregarlo
echo ".env" >> .gitignore
```

### 3. Rotar la Service Role Key Periódicamente

Cada 3-6 meses:
1. Ve a Supabase Dashboard > Settings > API
2. Haz clic en "Generate new key"
3. Actualiza el archivo `.env`
4. Reinicia la aplicación

### 4. Monitorear Accesos

En Supabase Dashboard:
1. Ve a **Logs**
2. Revisa los accesos sospechosos
3. Configura alertas para actividades inusuales

## 📋 Flujo de Trabajo Recomendado

### Para Desarrollo Local (Método 2 - OK)
```
✅ Usar Service Role Key
✅ Cambio directo de contraseñas
✅ Rápido y conveniente
```

### Para Producción Pública (Método 1 - OBLIGATORIO)
```
✅ NO usar Service Role Key
✅ Usar link de recuperación por email
✅ Configurar email templates en Supabase
✅ Más seguro
```

## 🔄 Cambiar del Método 2 al Método 1

Si ya configuraste el Método 2 y quieres volver al Método 1:

1. Edita el archivo `.env`:
```bash
nano .env
```

2. Comenta o elimina la línea:
```env
# VITE_SUPABASE_SERVICE_ROLE_KEY=...
```

3. Reinicia el servidor:
```bash
npm run dev
```

4. Ahora al intentar cambiar contraseñas, se ofrecerá automáticamente el método de email.

## 🆘 Troubleshooting

### Error: "Cliente Admin no está configurado"
**Solución:** Verifica que:
1. El archivo `.env` existe
2. `VITE_SUPABASE_SERVICE_ROLE_KEY` está configurado
3. Reiniciaste el servidor después de agregar la variable

### Error: "Invalid API key"
**Solución:**
1. Verifica que copiaste la clave completa (sin espacios)
2. Asegúrate de copiar la `service_role` key, no la `anon` key
3. La clave es muy larga (varios caracteres)

### Error: "Failed to send reset password email"
**Solución:**
1. Ve a Supabase Dashboard > Authentication > Email Templates
2. Verifica que la plantilla "Reset Password" esté habilitada
3. Configura tu proveedor de email (SMTP)

### El link de recuperación no funciona
**Solución:**
1. Verifica que el `redirectTo` URL sea correcto
2. Agrega el URL en Supabase Dashboard > Authentication > URL Configuration > Redirect URLs
3. Ejemplo: `http://localhost:5173/reset-password`

## 📚 Referencias

- [Supabase Auth Admin API](https://supabase.com/docs/reference/javascript/auth-admin-updateuserbyid)
- [Supabase Service Role Key](https://supabase.com/docs/guides/api#the-service_role-key)
- [Best Practices de Seguridad](https://supabase.com/docs/guides/api/api-keys)

## ✅ Resumen

**Para uso local/privado:** Configurar Service Role Key (Método 2)
**Para producción pública:** Usar email recovery (Método 1)

**¿Dudas?** El sistema elegirá automáticamente el método disponible y te guiará.
