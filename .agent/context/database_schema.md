# Esquema de Banco de Dados & Cache (MariaDB 10.11+ / MySQL 8 & CacheService Lua)

> **Plataforma:** A bridge nativa do OPEN//77 (`Open77.database` / `MySQL.*`) suporta oficialmente **MySQL e MariaDB**. O esquema utiliza motor `InnoDB` para garantir ACID completo e colunas `JSON`.

---

## 1. Estratégia Híbrida de Armazenamento

```text
[ Cliente (WebView2 / Lua Client) ] 
          │ (Eventos sanitizados)
          ▼
[ Servidor (Controllers Lua 5.4) ]
   ├── Alta Frequência (Vitals/Sessão) ──► [ CacheService (Tabelas Lua in-memory) ]
   │                                              │ (Worker a cada 5m / Disconnect / Stop)
   │                                              ▼
   └── Transações ACID (Dinheiro/Bens) ──► [ MariaDB / MySQL (InnoDB + JSON) ]
```

---

## 2. Tabelas Principais (MariaDB 10.11+ / MySQL 8 - InnoDB)

### `players`
```sql
CREATE TABLE IF NOT EXISTS `players` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `license` VARCHAR(64) NOT NULL UNIQUE,
    `name` VARCHAR(64) NOT NULL,
    `eurodollars` BIGINT NOT NULL DEFAULT 1000,
    `bank_balance` BIGINT NOT NULL DEFAULT 5000,
    `job` VARCHAR(32) NOT NULL DEFAULT 'unemployed',
    `job_grade` INT NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `chk_eurodollars_positive` CHECK (`eurodollars` >= 0),
    CONSTRAINT `chk_bank_balance_positive` CHECK (`bank_balance` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `characters_vitals`
```sql
CREATE TABLE IF NOT EXISTS `characters_vitals` (
    `license` VARCHAR(64) PRIMARY KEY,
    `nutrition` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `hydration` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `energy` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `hygiene` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `neural_stability` DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    `stress_factor` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    `implants_count` INT NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`license`) REFERENCES `players`(`license`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `inventories`
```sql
CREATE TABLE IF NOT EXISTS `inventories` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `owner` VARCHAR(64) NOT NULL,
    `type` VARCHAR(24) NOT NULL DEFAULT 'player', -- 'player', 'glovebox', 'trunk', 'stash'
    `items` JSON NOT NULL,
    `max_weight` DECIMAL(6,2) NOT NULL DEFAULT 35.00,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_inventories_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### `properties`
```sql
CREATE TABLE IF NOT EXISTS `properties` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(64) NOT NULL,
    `megabuilding_id` VARCHAR(16) NOT NULL, -- ex: 'H10', 'H8'
    `interior_coords` JSON NOT NULL, -- {"x": 0.0, "y": 0.0, "z": 0.0, "h": 0.0}
    `owner_license` VARCHAR(64) NULL,
    `bucket_id` INT NOT NULL UNIQUE,
    `daily_rent` INT NOT NULL DEFAULT 150,
    `rent_due_date` TIMESTAMP NOT NULL,
    `furniture_data` JSON NOT NULL,
    INDEX `idx_properties_owner` (`owner_license`),
    FOREIGN KEY (`owner_license`) REFERENCES `players`(`license`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 3. Estrutura de Cache em Memória (`CacheService` Lua)

O `CacheService` opera dentro de `ls_data` gerenciando tabelas Lua em memória por jogador:

```lua
-- Estrutura de registro volátil na VM
CacheService.sessions[license] = {
    source = src,
    joined_at = os.time(),
    ping = 0,
    routing_bucket = bucketId
}

CacheService.vitals[license] = {
    nutrition = 100.0,
    hydration = 100.0,
    energy = 100.0,
    hygiene = 100.0,
    neural_stability = 100.0,
    stress_factor = 0.0,
    is_dirty = false,
    last_flush = os.time()
}
```
- **Dirty Flagging:** Quando os valores de biometria são alterados, `is_dirty` é marcado como `true`.
- **Batch Flush Worker:** A cada 5 minutos (300 segundos), o worker itera apenas sobre registros com `is_dirty == true`, gerando uma query em lote assíncrona para o MariaDB.
- **Transações Financeiras:** NUNCA passam pelo cache; executam queries síncronas com `SELECT ... FOR UPDATE`.
