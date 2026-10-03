# Especificação Técnica: Build Mode Livre & Prevenção de Colisões com PolyZone (`ls_housing`)

> **Versão:** 1.0.0  
> **Módulo:** `ls_housing` (Fase 5)  
> **Dependência Central:** `polyzone >=1.0.0` (`@polyzone`)  
> **Status:** Arquitetura Aprovada // Pronto para Implementação

---

## 1. Visão Geral & Decisão Arquitetural

Em substituição ao antigo modelo de posicionamento restrito por grade ("grid-snapping"), que gerava uma experiência mecânica e artificial, o sistema de decoração do `ls_housing` adota **movimentação 3D contínua e livre** com controle de yaw $360^\circ$.

Para garantir que a liberdade não resulte em "noclip", transposição de paredes ou mobílias se cruzando de forma irrealista, o sistema utiliza uma camada dupla de validação matemática baseada na biblioteca de alta performance **PolyZone**:
1. **Contenção Perimetral do Apartamento (Boundary Enclosure):** Todo o volume interno do apartamento é modelado como um `PolyZone` ou `ComboZone` tridimensional.
2. **Prevenção de Colisão Inter-Objetos (Oriented Bounding Box - OBB):** Cada peça de mobília projeta uma caixa orientada no espaço tridimensional. Vértices do objeto sendo posicionado são avaliados em tempo real contra as caixas dos objetos já existentes.

---

## 2. Modelagem Matemática do Objeto (OBB 2D/3D)

Cada objeto de mobília possui três dimensões fundamentais em seu catálogo:
- **Largura ($W$):** Extensão no eixo local $X$.
- **Comprimento ($L$):** Extensão no eixo local $Y$.
- **Altura ($H$):** Extensão no eixo local $Z$.

Dada a posição central do cursor $(X_c, Y_c, Z_c)$ e o ângulo de rotação yaw $\theta$ (em radianos):
Os quatro vértices do retângulo de projeção no piso são dados por:

$$c_1 = \left( X_c + \frac{W}{2}\cos\theta - \frac{L}{2}\sin\theta,\; Y_c + \frac{W}{2}\sin\theta + \frac{L}{2}\cos\theta \right)$$
$$c_2 = \left( X_c - \frac{W}{2}\cos\theta - \frac{L}{2}\sin\theta,\; Y_c - \frac{W}{2}\sin\theta + \frac{L}{2}\cos\theta \right)$$
$$c_3 = \left( X_c - \frac{W}{2}\cos\theta + \frac{L}{2}\sin\theta,\; Y_c - \frac{W}{2}\sin\theta - \frac{L}{2}\cos\theta \right)$$
$$c_4 = \left( X_c + \frac{W}{2}\cos\theta + \frac{L}{2}\sin\theta,\; Y_c + \frac{W}{2}\sin\theta - \frac{L}{2}\cos\theta \right)$$

---

## 3. Algoritmo de Validação com PolyZone

```lua
local PZ = assert(require('@polyzone'))

---Valida se um móvel pode ser colocado na posição e rotação especificadas
---@param aptZone table PolyZone ou ComboZone do apartamento
---@param placedFurniture table Lista de móveis já instalados
---@param newProp table { x, y, z, heading, width, length, height, allowStack }
---@return boolean isValid, string|nil reason
function ValidateFurniturePlacement(aptZone, placedFurniture, newProp)
    local xc, yc, zc = newProp.x, newProp.y, newProp.z
    local w2 = newProp.width / 2.0
    local l2 = newProp.length / 2.0
    local rad = math.rad(newProp.heading)
    local cosR, sinR = math.cos(rad), math.sin(rad)

    -- 1. Calcular os 4 cantos do OBB
    local corners = {
        vector3(xc + w2 * cosR - l2 * sinR, yc + w2 * sinR + l2 * cosR, zc),
        vector3(xc - w2 * cosR - l2 * sinR, yc - w2 * sinR + l2 * cosR, zc),
        vector3(xc - w2 * cosR + l2 * sinR, yc - w2 * sinR - l2 * cosR, zc),
        vector3(xc + w2 * cosR + l2 * sinR, yc + w2 * sinR - l2 * cosR, zc)
    }

    -- 2. Testar contenção perimetral no apartamento
    for i = 1, 4 do
        if not aptZone:isPointInside(corners[i]) then
            return false, "collision_wall_perimeter"
        end
    end

    -- 3. Testar limites de piso e teto (eixo Z)
    if zc < aptZone.minZ or (zc + newProp.height) > aptZone.maxZ then
        return false, "collision_vertical_bounds"
    end

    -- 4. Testar colisão com móveis já existentes (Inter-Furniture Collision)
    for _, existing in ipairs(placedFurniture) do
        -- Se o novo móvel é empilhável (ex: caneca sobre mesa) e está acima do topo do móvel existente
        local isSurfaceStack = newProp.allowStack and zc >= (existing.z + existing.height - 0.05)
        if not isSurfaceStack then
            local existingBox = existing.zone -- BoxZone orientada da mobília existente
            if existingBox then
                -- Checa se qualquer vértice do novo móvel invade a BoxZone do existente
                for i = 1, 4 do
                    if existingBox:isPointInside(corners[i]) then
                        return false, "collision_furniture_overlap"
                    end
                end
                -- Checa centro também
                if existingBox:isPointInside(vector3(xc, yc, zc)) then
                    return false, "collision_furniture_overlap"
                end
            end
        end
    end

    return true, nil
end
```

---

## 4. Feedback Visual Diegético (Shader Holográfico Kiroshi)

Durante o manuseio no modo de decoração:
1. **Posição Válida:**
   - Cor do wireframe / ghost: **Verde/Ciano Neon** (`#00ff9d` / `#22d8e2`), Alpha 0.65.
   - Retículo do cursor: Círculo fino pulsante com indicação `[E] FIXAR OBJETO`.
2. **Posição Inválida (Colisão com parede ou móvel):**
   - Cor do wireframe / ghost: **Vermelho Neon Kiroshi** (`#ff003c`), Alpha 0.85 com efeito estático sutil.
   - Retículo do cursor: Ícone de aviso `[ ! ] COLISÃO DETECTADA`. Ação de clique bloqueada.

---

## 5. Controles do Usuário (Navegação & Ergonomia)

| Comando | Ação |
| :--- | :--- |
| **Mouse Aim** | Raycast contínuo livre no piso e superfícies |
| **Scroll / Q / E** | Rotação Yaw suave contínua ($0^\circ - 360^\circ$) |
| **Shift + Scroll** | Elevação vertical fina do eixo $Z$ (para prateleiras e mesas) |
| **Ctrl (Hold)** | Ativa travamento angular a cada $15^\circ$ para alinhamento rápido |
| **Clique Esquerdo / [E]** | Valida e fixa o móvel no apartamento |
| **[X]** | Cancela manipulação e guarda no inventário de mobília |
| **[Del] / [R]** | Recolher móvel existente de volta ao inventário |
