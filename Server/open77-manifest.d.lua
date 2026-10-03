---@meta
-- Open77 Resource Manifest Declarations (open77.lua)
-- Fornece tipagem e supressão de diagnósticos para manifestos do motor OPEN//77.

---Define o identificador único do recurso
---@param name string
function resource(name) end

---Define a versão semântica do recurso
---@param ver string
function version(ver) end

---Define a versão mínima exigida do runtime OPEN//77
---@param ver string
function open77_version(ver) end

---Define se o recurso inicia automaticamente ao subir o servidor
---@param val boolean
function auto_start(val) end

---Define a política de recarregamento (local, reconnect, manual)
---@param policy string
function reload_policy(policy) end

---Declara uma dependência individual com versão opcional
---@param dep string
function dependency(dep) end

---Declara uma lista de dependências
---@param deps string[]
function dependencies(deps) end

---Declara um script compartilhado entre servidor e cliente
---@param path string
function shared_script(path) end

---Declara uma lista de scripts compartilhados
---@param paths string[]
function shared_scripts(paths) end

---Declara um script executado no lado do servidor
---@param path string
function server_script(path) end

---Declara uma lista de scripts do servidor
---@param paths string[]
function server_scripts(paths) end

---Declara um script executado no lado do cliente
---@param path string
function client_script(path) end

---Declara uma lista de scripts do cliente
---@param paths string[]
function client_scripts(paths) end

---Declara a lista de permissões solicitadas pelo recurso
---@param perms string[]
function permissions(perms) end

---Declara uma permissão individual solicitada pelo recurso
---@param perm string
function permission(perm) end

---Declara a página HTML de entrada da WebUI
---@param page string
function web_ui_page(page) end

---Define se a WebUI é instanciada automaticamente pelo cliente
---@param val boolean
function web_ui_auto_create(val) end

---Declara os arquivos estáticos expostos para a WebUI
---@param files string[]
function web_files(files) end

---Declara arquivos estáticos gerais transferidos para o cliente
---@param files string[]
function files(files) end

---Declara a tela de carregamento (loading screen) do recurso
---@param page string
function loadscreen(page) end

---Define se a tela de carregamento deve ser fechada manualmente
---@param val string|boolean
function loadscreen_manual_shutdown(val) end

