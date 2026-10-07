# Esquema de Banco de Dados & Cache (MariaDB 10.4+ / MySQL 8 InnoDB & CacheService)

> **Documentação Oficial:** A bridge nativa do OPEN//77 (`MySQL.*` e `Open77.database.*`) opera no servidor dedicado via `MySqlConnector` e suporta oficialmente **MySQL e MariaDB**. O esquema utiliza o motor `InnoDB` para garantir integridade referencial, transações ACID com locks pessimistas (`SELECT ... FOR UPDATE`) e colunas `JSON`.

---

## 1. Estratégia Híbrida de Armazenamento

```text
[ Cliente (CEF WebUI / Lua Client) ] 
          │ (Eventos sanitizados)
          ▼
[ Servidor (Controllers Lua 5.4) ]
   ├── Alta Frequência (Vitals/Sessão) ──► [ CacheService (Tabelas Lua in-memory) ]
   │                                              │ (Worker a cada 5m / Disconnect / Stop)
   │                                              ▼
   └── Transações ACID (Dinheiro/Bens) ──► [ MariaDB / MySQL (InnoDB + JSON) ]
```

---

## 2. Catálogo Oficial das Tabelas (MariaDB 10.4+ / MySQL 8 - InnoDB)

### 1. `ls_schema_migrations` (Controle de Migrações Versionadas)
```sql
CREATE TABLE IF NOT EXISTS `ls_schema_migrations` (
    `module`     VARCHAR(32) NOT NULL,
    `version`    INT         NOT NULL,
    `checksum`   CHAR(64)    NOT NULL,
    `applied_at` TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`module`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 2. `ls_players` (Fase 1 - Identidade & Perfil do Cidadão)
```sql
CREATE TABLE IF NOT EXISTS `ls_players` (
    `license`      CHAR(32)    NOT NULL,
    `user_id`      VARCHAR(36) NULL,
    `display_name` VARCHAR(64) NOT NULL,
    `data`         JSON        NULL,
    `created_at`   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_seen_at` TIMESTAMP   NULL,
    PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3. `ls_vitals` (Fase 2 - Telemetria Fisiológica)
```sql
CREATE TABLE IF NOT EXISTS `ls_vitals` (
    `license`    CHAR(32)  NOT NULL,
    `data`       JSON      NOT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`),
    CONSTRAINT `fk_ls_vitals_license` FOREIGN KEY (`license`) REFERENCES `ls_players`(`license`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4. `ls_cyberware` (Fase 3 - Implantes & Estabilidade Neural)
```sql
CREATE TABLE IF NOT EXISTS `ls_cyberware` (
    `license`    CHAR(32)  NOT NULL,
    `data`       JSON      NOT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`),
    CONSTRAINT `fk_ls_cyberware_license` FOREIGN KEY (`license`) REFERENCES `ls_players`(`license`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 5. `ls_ui_settings` (Fase 2 & 3 - Persistência Espacial da HUD Kiroshi)
```sql
CREATE TABLE IF NOT EXISTS `ls_ui_settings` (
    `license`    CHAR(32)  NOT NULL,
    `data`       JSON      NOT NULL,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`),
    CONSTRAINT `fk_ls_ui_settings_license` FOREIGN KEY (`license`) REFERENCES `ls_players`(`license`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 6. `ls_accounts` (Fase 4 - Saldo Financeiro Cash & Bank)
```sql
CREATE TABLE IF NOT EXISTS `ls_accounts` (
    `license`    CHAR(32)  NOT NULL,
    `cash`       BIGINT    NOT NULL DEFAULT 500,
    `bank`       BIGINT    NOT NULL DEFAULT 2500,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`),
    CONSTRAINT `fk_ls_accounts_license` FOREIGN KEY (`license`) REFERENCES `ls_players`(`license`) ON DELETE CASCADE,
    CONSTRAINT `chk_cash_positive` CHECK (`cash` >= 0),
    CONSTRAINT `chk_bank_positive` CHECK (`bank` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 7. `ls_transactions` (Fase 4 - Livro Razão e Auditoria Financeira ACID)
```sql
CREATE TABLE IF NOT EXISTS `ls_transactions` (
    `id`            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `license`       CHAR(32)     NOT NULL,
    `action`        VARCHAR(32)  NOT NULL,
    `target`        VARCHAR(64)  NULL,
    `amount`        BIGINT       NOT NULL,
    `balance_after` BIGINT       NOT NULL,
    `reason`        VARCHAR(128) NOT NULL,
    `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ls_transactions_license` (`license`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 8. `ls_player_apartments` (Fase 5 - Contratos Residenciais & Trancas)
```sql
CREATE TABLE IF NOT EXISTS `ls_player_apartments` (
    `license`       CHAR(32)     NOT NULL,
    `apt_id`        VARCHAR(32)  NOT NULL,
    `status`        VARCHAR(16)  NOT NULL DEFAULT 'rented',
    `rent_due_unix` BIGINT       NOT NULL DEFAULT 0,
    `is_locked`     TINYINT(1)   NOT NULL DEFAULT 1,
    `pin_code`      VARCHAR(8)   NULL,
    `keys_data`     JSON         NULL,
    `updated_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`, `apt_id`),
    INDEX `idx_ls_player_apartments_apt` (`apt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 9. `ls_apartment_furniture` (Fase 5 - Mobílias com Posição 3D & Rotação)
```sql
CREATE TABLE IF NOT EXISTS `ls_apartment_furniture` (
    `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `apt_id`        VARCHAR(32)  NOT NULL,
    `owner_license` CHAR(32)     NOT NULL,
    `template_id`   VARCHAR(64)  NOT NULL,
    `pos_x`         FLOAT        NOT NULL,
    `pos_y`         FLOAT        NOT NULL,
    `pos_z`         FLOAT        NOT NULL,
    `rot_yaw`       FLOAT        NOT NULL,
    `meta_data`     JSON         NULL,
    `created_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ls_furniture_apt` (`apt_id`),
    INDEX `idx_ls_furniture_owner` (`owner_license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 10. `ls_player_spawns` (Gateway Pré-Fase 5 - Registro de Spawns & Última Posição)
```sql
CREATE TABLE IF NOT EXISTS `ls_player_spawns` (
    `license`       CHAR(32)     NOT NULL,
    `last_spawn_id` VARCHAR(32)  NOT NULL DEFAULT 'h10_default',
    `pos_x`         FLOAT        NOT NULL,
    `pos_y`         FLOAT        NOT NULL,
    `pos_z`         FLOAT        NOT NULL,
    `heading`       FLOAT        NOT NULL DEFAULT 0.0,
    `updated_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 11. `ls_inventories` (Fase 5.5 - Mochilas & Armazenamento Autoritativo)
```sql
CREATE TABLE IF NOT EXISTS `ls_inventories` (
    `inventory_id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `owner_type`   VARCHAR(32)     NOT NULL DEFAULT 'character',
    `owner_id`     VARCHAR(64)     NOT NULL,
    `max_weight`   INT             NOT NULL DEFAULT 35000,
    `max_slots`    INT             NOT NULL DEFAULT 40,
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uq_ls_inv_owner` (`owner_type`, `owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 12. `ls_inventory_items` (Fase 5.5 - Itens em Slots com Metadata JSON)
```sql
CREATE TABLE IF NOT EXISTS `ls_inventory_items` (
    `id`           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `inventory_id` BIGINT UNSIGNED NOT NULL,
    `item_id`      VARCHAR(64)     NOT NULL,
    `slot`         INT             NOT NULL,
    `count`        INT             NOT NULL DEFAULT 1,
    `metadata`     LONGTEXT        NOT NULL DEFAULT '{}',
    `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_ls_inv_slot` (`inventory_id`, `slot`),
    CONSTRAINT `fk_ls_inv_items_parent` FOREIGN KEY (`inventory_id`) REFERENCES `ls_inventories`(`inventory_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 3. Estrutura de Cache em Memória (`CacheService` Lua)

O `CacheService` opera dentro de `ls_data` gerenciando tabelas Lua em memória por jogador com carimbos gerados por `GetUnixTime()` (já que `os.time()` não existe no servidor):

```lua
-- Estrutura de registro volátil na VM do servidor
CacheService.sessions[license] = {
    source = src,
    joined_at = GetUnixTime(),
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
    last_flush = GetUnixTime()
}
```

- **Dirty Flagging:** Quando atributos de biometria ou dados voláteis são modificados, `is_dirty` é marcado como `true`.
- **Batch Flush Worker:** A cada 5 minutos (300 segundos), o worker itera apenas sobre registros com `is_dirty == true`, disparando a atualização em lote no MariaDB via `MySQL.update.await`.
- **Garantia de Desconexão e Parada:** Na desconexão do jogador (`playerDropped`) ou no encerramento do recurso (`onResourceStop`), o flush imediato é garantido.
- **Transações Financeiras e Contratos:** NUNCA passam pelo cache intermediário; utilizam transações ACID imediatas com `MySQL.transaction.await` e `SELECT ... FOR UPDATE`.
