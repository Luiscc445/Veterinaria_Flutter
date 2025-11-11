# RamboPet Cleanup Checklist

This document provides step-by-step instructions to clean up the project.

## Quick Stats
- Total LOC: 9,687 (Web: 3,756 | Mobile: 5,931)
- Files to refactor: 4 pages
- Files to delete: 5+ files
- Type duplications: 100%
- Controllers unused: 12 files (orphaned)

---

## PHASE 1: Quick Cleanup (30 minutes)

### 1.1 Remove Empty Role-Based Page Directories

```bash
# These directories are empty and were never implemented
rm -rf /home/user/Veterinaria_Flutter/web/src/views/pages/admin/
rm -rf /home/user/Veterinaria_Flutter/web/src/views/pages/medico/
rm -rf /home/user/Veterinaria_Flutter/web/src/views/pages/recepcion/
```

**Verify**:
```bash
ls /home/user/Veterinaria_Flutter/web/src/views/pages/
# Should only show: CitasPage.tsx DashboardPage.tsx InventarioPage.tsx MascotasPage.tsx auth/
```

---

## PHASE 2: Type Consolidation (1-2 hours)

### 2.1 Consolidate Type Definitions

**Problem**: Types are defined in TWO places:
- `/web/src/types/index.ts` (used by views)
- `/web/src/models/*.ts` (used by controllers)

**Solution**: Keep models/ as single source of truth

#### Step 1: Update All Import Statements

**Files that import from types/index.ts**:
```bash
grep -r "from.*['\"].*types['\"]" /home/user/Veterinaria_Flutter/web/src/views/
```

**Find and replace in each view file**:
```bash
# In DashboardPage.tsx
# Change: import { Mascota, Cita } from '../types'
# To:     import { Mascota, Cita } from '../models'

# In MascotasPage.tsx
# Change: import { Mascota } from '../types'
# To:     import { Mascota } from '../models'

# In CitasPage.tsx
# Change: import { Cita } from '../types'
# To:     import { Cita } from '../models'

# In InventarioPage.tsx
# Change: import { Farmaco, LoteFarmaco } from '../types'
# To:     import { Farmaco, LoteFarmaco } from '../models'
```

#### Step 2: Delete Duplicate Type File

```bash
rm /home/user/Veterinaria_Flutter/web/src/types/index.ts
```

#### Step 3: Verify Compilation

```bash
cd /home/user/Veterinaria_Flutter/web
npm run build  # Should have no type errors
```

---

## PHASE 3: Controller Integration (4-6 hours)

### 3.1 Refactor DashboardPage.tsx

**File**: `/home/user/Veterinaria_Flutter/web/src/views/pages/DashboardPage.tsx`

**Current Code** (Lines 1-35):
```typescript
import { useEffect, useState } from 'react'
import { supabase } from '../services/supabase'

const loadStats = async () => {
  const [mascotas, citas, citasHoy, pendientes] = await Promise.all([
    supabase.from('mascotas').select('id', { count: 'exact' }).is('deleted_at', null),
    supabase.from('citas').select('id', { count: 'exact' }).is('deleted_at', null),
    // ... more direct queries
  ])
}
```

**New Code**:
```typescript
import { useEffect, useState } from 'react'
import { MascotasController, CitasController } from '../controllers'

const loadStats = async () => {
  try {
    const [mascotasStats, citasStats] = await Promise.all([
      MascotasController.getStats(),
      CitasController.getStats(),
    ])
    
    setStats({
      totalMascotas: mascotasStats.total,
      totalCitas: citasStats.total,
      citasHoy: citasStats.hoy,
      mascotasPendientes: mascotasStats.pendientes,
    })
  } catch (error) {
    console.error('Error loading stats:', error)
  }
}
```

**Testing**:
```bash
# Should load same data with same structure
# Verify dashboard displays correctly with no permission errors
```

### 3.2 Refactor MascotasPage.tsx

**File**: `/home/user/Veterinaria_Flutter/web/src/views/pages/MascotasPage.tsx`

**Changes**:
```typescript
// Add import
import { MascotasController } from '../controllers'

// Replace loadMascotas()
const loadMascotas = async () => {
  try {
    const data = await MascotasController.getAll(filter)
    setMascotas(data)
  } catch (error) {
    console.error('Error loading mascotas:', error)
  } finally {
    setLoading(false)
  }
}

// Replace aprobarMascota()
const aprobarMascota = async (id: string) => {
  try {
    await MascotasController.aprobar(id)
    await loadMascotas()
  } catch (error) {
    console.error('Error aprobando mascota:', error)
  }
}

// Replace rechazarMascota()
const rechazarMascota = async (id: string) => {
  try {
    await MascotasController.rechazar(id)
    await loadMascotas()
  } catch (error) {
    console.error('Error rechazando mascota:', error)
  }
}
```

**Testing**:
```bash
# Test filtering (Todas, Pendientes, Aprobadas)
# Test approving a mascota
# Test rejecting a mascota
# Verify RLS permissions work correctly
```

### 3.3 Refactor CitasPage.tsx

**File**: `/home/user/Veterinaria_Flutter/web/src/views/pages/CitasPage.tsx`

**Changes**:
```typescript
// Add import
import { CitasController } from '../controllers'

// Replace loadCitas()
const loadCitas = async () => {
  try {
    const data = await CitasController.getAll()
    setCitas(data)
  } catch (error) {
    console.error('Error loading citas:', error)
  } finally {
    setLoading(false)
  }
}

// Replace confirmarCita()
const confirmarCita = async (id: string) => {
  try {
    await CitasController.confirmar(id)
    await loadCitas()
  } catch (error) {
    console.error('Error confirmando cita:', error)
  }
}
```

**Testing**:
```bash
# Test loading citas with relationships
# Test confirming a cita
# Verify all cita status colors display correctly
```

### 3.4 Refactor InventarioPage.tsx

**File**: `/home/user/Veterinaria_Flutter/web/src/views/pages/InventarioPage.tsx`

**Changes**:
```typescript
// Add imports
import { FarmacosController, LotesFarmacosController } from '../controllers'

// This page needs to load both farmacos and lotes
// Currently loads both with direct queries
// Keep structure the same but load via controllers

const loadInventario = async () => {
  try {
    // Note: Current controllers don't have getAll() for lotes
    // May need to add LotesFarmacosController.getAll() method
    // Or keep this as-is and refactor later
    
    const farmacos = await FarmacosController.getAll()
    // Need to implement: const lotes = await LotesFarmacosController.getAll()
    
    setFarmacos(farmacos)
    // setLotes(lotes)
  } catch (error) {
    console.error('Error loading inventario:', error)
  }
}
```

**Note**: May need to extend LotesFarmacosController with getAll() method

**Testing**:
```bash
# Test loading inventory data
# Test stock calculations
# Test stock status colors
```

### 3.5 Verify All Controllers Are Used

After refactoring, run:
```bash
cd /home/user/Veterinaria_Flutter/web
grep -r "Controller" src/views/pages/*.tsx | wc -l
# Should show >0 results
```

---

## PHASE 4: Mobile Cleanup (1 hour)

### 4.1 Verify Unused Services

Check if historia_clinica and episodio services are truly unused:

```bash
# Search for any reference to these services
grep -r "HistoriaClinica\|Episodio" /home/user/Veterinaria_Flutter/mobile/lib/features --include="*.dart" | grep -v "/historias/data/"

# Should return NO results if truly unused
```

### 4.2 Delete Unused Services (if not used)

If no results from above:
```bash
rm /home/user/Veterinaria_Flutter/mobile/lib/features/historias/data/historia_clinica_service.dart
rm /home/user/Veterinaria_Flutter/mobile/lib/features/historias/data/episodio_service.dart
```

### 4.3 Verify Mobile Tests Still Pass

```bash
cd /home/user/Veterinaria_Flutter/mobile
flutter test
```

---

## PHASE 5: Testing & Verification (2-3 hours)

### 5.1 Web Testing

```bash
cd /home/user/Veterinaria_Flutter/web

# 1. Check for TypeScript errors
npm run build

# 2. Start dev server
npm run dev

# 3. Test each page manually:
# - Dashboard: Verify stats load
# - Mascotas: Filter, approve, reject
# - Citas: View, confirm
# - Inventario: View stock

# 4. Check browser console for errors
```

### 5.2 Mobile Testing

```bash
cd /home/user/Veterinaria_Flutter/mobile

# 1. Analyze code
flutter analyze

# 2. Run tests (if any exist)
flutter test

# 3. Build APK
flutter build apk

# 4. Test on device/emulator:
flutter run
```

---

## PHASE 6: Documentation Updates (30 minutes)

### 6.1 Update README

Add section explaining architecture:

```markdown
## Architecture

### Web (React + TypeScript)
- **Views**: React components in `web/src/views/pages/`
- **Controllers**: Business logic in `web/src/controllers/`
- **Models**: TypeScript interfaces in `web/src/models/`
- **Services**: Supabase client in `web/src/services/`

### Mobile (Flutter)
- **Pages**: Flutter widgets in `mobile/lib/features/*/presentation/pages/`
- **Providers**: Riverpod providers in `mobile/lib/features/*/presentation/providers/`
- **Services**: Business logic in `mobile/lib/features/*/data/`
- **Models**: Dart models in `mobile/lib/shared/models/`

## Data Access Pattern

All data access goes through:
1. Web: Views → Controllers → Supabase (via RPC or direct queries)
2. Mobile: Pages → Providers → Services → Supabase (via RPC)
```

### 6.2 Add Architecture Decision Record

Create `ARCHITECTURE.md`:

```markdown
# Architecture Decisions

## 1. Controllers Pattern (Web)
- Implemented to centralize business logic
- All views should use controllers, NOT direct Supabase queries
- Controllers support both RPC and direct queries

## 2. Services Pattern (Mobile)
- Services are the data layer
- All RPC functions have corresponding service methods
- Views use Riverpod providers which consume services

## 3. Models vs Types
- Single source of truth: `/web/src/models/`
- No duplicate type definitions
- Form data types live alongside models
```

---

## Final Checklist

### Before Starting
- [ ] Create backup branch: `git checkout -b cleanup/architecture-fix`
- [ ] Review analysis in PROJECT_ANALYSIS.md
- [ ] Understand current architecture issues

### Phase 1 Complete
- [ ] Deleted admin/, medico/, recepcion/ directories
- [ ] Verified no references to deleted directories

### Phase 2 Complete
- [ ] Updated all type imports to use models
- [ ] Deleted types/index.ts
- [ ] Web project compiles without errors

### Phase 3 Complete
- [ ] DashboardPage.tsx uses MascotasController & CitasController
- [ ] MascotasPage.tsx uses MascotasController
- [ ] CitasPage.tsx uses CitasController
- [ ] InventarioPage.tsx updated (may be partial)
- [ ] All controllers are now imported in views
- [ ] No direct supabase queries in view files

### Phase 4 Complete
- [ ] Verified mobile unused services
- [ ] Deleted unused services (if applicable)
- [ ] Mobile code still compiles

### Phase 5 Complete
- [ ] Web builds without errors
- [ ] Web pages load and function correctly
- [ ] Mobile analyzes without errors
- [ ] Mobile builds successfully

### Phase 6 Complete
- [ ] README updated with architecture section
- [ ] ARCHITECTURE.md created
- [ ] PROJECT_ANALYSIS.md committed

### Final Steps
- [ ] All tests passing
- [ ] Create commit: "refactor: consolidate architecture and remove duplication"
- [ ] Create PR for review
- [ ] Merge after approval

---

## Estimated Timeline

| Phase | Effort | Duration |
|-------|--------|----------|
| 1: Quick Cleanup | 30 min | 30 min |
| 2: Type Consolidation | 1-2 hrs | 1 hr |
| 3: Controller Integration | 4-6 hrs | 5 hrs |
| 4: Mobile Cleanup | 1 hr | 1 hr |
| 5: Testing & Verification | 2-3 hrs | 3 hrs |
| 6: Documentation | 30 min | 30 min |
| **TOTAL** | **10-16 hrs** | **11 hrs** |

---

## Questions & Support

If you encounter issues:

1. **TypeScript errors after import changes?**
   - Run: `npm run build` to see exact errors
   - Check that model files export all needed types

2. **Controller methods don't work as expected?**
   - Review controller implementation
   - May need to add new methods to controllers
   - Check RLS policies for permission errors

3. **Tests failing?**
   - Verify controller behavior matches old behavior
   - May need to update test mocks

4. **Build failures?**
   - Check for circular imports
   - Verify all imports are correct paths
   - Run `npm install` / `flutter pub get` if needed

