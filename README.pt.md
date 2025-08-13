# HTTP DSL 🚀 Seu Canivete Suíço para Segurança e Integração de APIs

> *Porque proteger e integrar APIs não deveria exigir um doutorado em DevOps*

Olá! 👋 

Já passou horas escrevendo scripts para validar os headers de segurança da sua API? Lutou com workflows de integração complexos entre múltiplos serviços? Ou precisou auditar rapidamente uma API em busca de vulnerabilidades mas se perdeu em ferramentas complicadas?

**Nós também passamos por isso.** Por isso construímos o HTTP DSL - uma linguagem poderosa e legível por humanos para validação de segurança de APIs, integração de serviços e fluxos de trabalho automatizados.

## 💭 Por Que Construímos Isso

Imagine isso: Você precisa validar que sua API está devidamente protegida contra vulnerabilidades comuns. Ou está orquestrando um workflow complexo entre múltiplos microsserviços. Com ferramentas tradicionais, você precisaria de múltiplos scripts, frameworks e horas de configuração. Com HTTP DSL?

```
# Validação de segurança em segundos
GET "https://api.seuservico.com/admin"
assert status 401  # Garantir que o acesso não autorizado está bloqueado

GET "https://api.seuservico.com/login"
assert header "X-Frame-Options" exists  # Proteção contra clickjacking
assert header "X-Content-Type-Options" "nosniff"  # Proteção contra MIME sniffing
assert header "Strict-Transport-Security" exists  # Aplicação de HTTPS
```

**É só isso.** Validação de segurança instantânea. Sem configuração complexa. Sem necessidade de ser especialista em segurança.

## 🎁 O Que Torna Isso Especial?

Não criamos apenas outro cliente HTTP. Construímos uma ferramenta que **pensa como você**:

```
# Lembra daquele fluxo de autenticação chato que você sempre tem que testar?
POST "https://api.exemplo.com/login" json {
    "email": "usuario@exemplo.com",
    "password": "segredo123"
}
extract jsonpath "$.token" as $token

# Agora use em todo lugar, automaticamente
GET "https://api.exemplo.com/perfil" 
    header "Authorization" "Bearer $token"
    
# E realmente valide as coisas importantes
assert status 200
assert response contains "Bem-vindo de volta"
```

### 🛡️ Construído para Profissionais de Segurança e Integração

- **Validação de Segurança**: Verificações integradas para as vulnerabilidades OWASP Top 10
- **Orquestração de Serviços**: Encadeia múltiplas APIs com lógica condicional
- **Automação de Conformidade**: Valida requisitos GDPR, HIPAA, SOC2
- **Monitoramento de Desempenho**: Porque APIs lentas são riscos de segurança
- **Trilhas de Auditoria**: Registro completo de solicitações/respostas para conformidade

## 🤝 Isso é Parte de Algo Maior

HTTP DSL é alimentado por [**go-dsl**](https://github.com/arturoeanton/go-dsl), nosso framework para criar linguagens específicas de domínio em Go. Se você já quis construir sua própria mini-linguagem para suas necessidades específicas, confira! Estamos construindo todo um ecossistema de ferramentas que tornam a vida dos desenvolvedores mais fácil.

## 🚦 Status Atual: v1.0.0 - Pronto para Produção!

Temos orgulho de dizer que alcançamos v1.0.0! 🎉 Isso significa:
- ✅ 95% de cobertura de testes (testamos nossos testes!)
- ✅ Testado em batalha em projetos reais
- ✅ API estável que não quebrará seus scripts
- ✅ Seu feedback ajudou a moldar cada recurso

Mas não terminamos. Estamos apenas começando.

## 🚀 Início Rápido (30 Segundos para Seu Primeiro Teste!)

```bash
# Clonar e construir
git clone https://github.com/arturoeanton/httpdsl
cd httpdsl
go build -o httpdsl ./cmd/httpdsl/main.go

# Execute seu primeiro teste!
./httpdsl scripts/demos/01_basic.http
```

É só isso! Sem arquivos de configuração. Sem dependências para instalar. Simplesmente funciona. ✨

## 🎯 Casos de Uso do Mundo Real

### 🛡️ Suíte de Validação de Segurança
```
# auditoria_seguranca.http - Execute antes de cada implantação
GET "https://api.producao.com/api/v1/usuarios"
assert status 401  # Acesso não autenticado deve ser bloqueado

# Verificar vulnerabilidades de injeção SQL
GET "https://api.producao.com/buscar?q='; DROP TABLE usuarios--"
assert status 400  # Deve rejeitar entrada maliciosa
assert response not contains "SQL"  # Não vazar detalhes de erro

# Validar limite de taxa
repeat 20 times do
    GET "https://api.producao.com/api/endpoint"
endloop
assert status 429  # Limite de taxa deve ser ativado

# Verificar cabeçalhos de segurança
GET "https://api.producao.com/"
assert header "Content-Security-Policy" exists
assert header "X-XSS-Protection" "1; mode=block"
assert response time less 1000 ms  # Verificação de desempenho
```

### 🔄 Orquestração de Integração de Microsserviços
```
# integracao_servicos.http
# Workflow complexo entre múltiplos serviços

# Passo 1: Autenticar com o Serviço de Auth
POST "https://auth.empresa.com/token" json {
    "grant_type": "client_credentials",
    "scope": "inventario:ler pedidos:escrever"
}
extract jsonpath "$.access_token" as $token_auth

# Passo 2: Verificar serviço de inventário
GET "https://inventario.empresa.com/produtos/SKU-123/disponibilidade"
    header "Authorization" "Bearer $token_auth"
extract jsonpath "$.quantidade_disponivel" as $estoque

if $estoque > 0 then
    # Passo 3: Criar pedido no Serviço de Pedidos
    POST "https://pedidos.empresa.com/pedidos" json {
        "produto_id": "SKU-123",
        "quantidade": 1,
        "prioridade": "alta"
    }
    extract jsonpath "$.pedido_id" as $id_pedido
    
    # Passo 4: Acionar workflow de cumprimento
    POST "https://cumprimento.empresa.com/processar/$id_pedido"
    assert status 202  # Aceito para processamento
else
    # Acionar workflow de reabastecimento
    POST "https://inventario.empresa.com/solicitacoes-reabastecimento" json {
        "produto_id": "SKU-123",
        "urgencia": "alta"
    }
endif
```

### 🔍 Automação de Conformidade e Auditoria
```
# verificacao_conformidade.http - Validação GDPR/HIPAA

# Testar conformidade de privacidade de dados
POST "https://api.empresa.com/usuarios/solicitacao-exclusao" json {
    "usuario_id": "usuario-teste-123",
    "motivo": "GDPR Artigo 17"
}
assert status 200
assert response contains "exclusao_agendada"

# Verificar que os dados realmente são excluídos
wait 5000 ms
GET "https://api.empresa.com/usuarios/usuario-teste-123"
assert status 404  # Usuário deve ter desaparecido

# Verificação de registro de auditoria
GET "https://auditoria.empresa.com/logs?acao=exclusao_usuario&id=usuario-teste-123"
assert status 200
assert response contains "excluido_por"
assert response contains "timestamp_exclusao"
assert response contains "base_legal"
```

## 🛠️ Recursos Que Realmente Importam

### O Que Construímos (Com Amor 💙)

**O Básico** (porque deveria ser fácil):
- Todos os métodos HTTP - `GET`, `POST`, `PUT`, `DELETE`, o que você precisar
- Headers que se encadeiam naturalmente - chega de objetos de header!
- JSON que lida com símbolos @ e caracteres especiais (finalmente!)

**As Coisas Inteligentes** (porque você é inteligente):
- Variáveis com `$` - como bash, mas mais amigável
- Matemática real - `set $total $preco * $quantidade * 1.08`
- If/else que faz sentido - até mesmo aninhados
- Loops - `while`, `foreach`, `repeat` com `break`/`continue`

**Os Economizadores de Tempo** (porque tempo é precioso):
- Extraia qualquer coisa - JSONPath, regex, headers
- Valide tudo - status, tempo de resposta, conteúdo
- Arrays com indexação - `$usuarios[0]`, `$itens[$indice]`
- Argumentos CLI - passe configurações sem editar scripts

**O "Graças a Deus Alguém Construiu Isso"**:
- Sem setup, sem arquivos de config
- Scripts são portáteis - compartilhe com sua equipe
- Legível por humanos - até não-programadores entendem
- Erros que realmente dizem o que deu errado

## Instalação

```bash
# Clonar o repositório
git clone https://github.com/arturoeanton/httpdsl
cd httpdsl

# Construir a ferramenta CLI
go build -o httpdsl ./cmd/httpdsl/main.go

# Ou instalar globalmente
go install github.com/arturoeanton/httpdsl/cmd/httpdsl@latest
```

## 🎨 Integrar no Seu Projeto Go

Quer adicionar superpoderes do HTTP DSL à sua própria aplicação Go? É ridiculamente fácil:

### Instalar o Módulo
```bash
go get github.com/arturoeanton/httpdsl
```

### Use no Seu Código
```go
package main

import (
    "fmt"
    "log"
    "httpdsl/core"
)

func main() {
    // Criar uma nova instância do HTTP DSL
    dsl := core.NewHTTPDSLv3()
    
    // Seu script DSL como string (pode vir de um arquivo, BD, ou API)
    script := `
        # Testar a saúde da nossa API
        GET "https://api.exemplo.com/health"
        assert status 200
        
        # Login e obter token
        POST "https://api.exemplo.com/login" json {
            "username": "usuarioteste",
            "password": "senhateste"
        }
        extract jsonpath "$.token" as $token
        
        # Usar o token para requisições autenticadas
        GET "https://api.exemplo.com/usuarios/eu"
            header "Authorization" "Bearer $token"
        
        if status == 200 then
            print "✅ Todos os sistemas operacionais!"
        else
            print "❌ Algo deu errado"
        endif
    `
    
    // Executar o script
    result, err := dsl.ParseWithBlockSupport(script)
    if err != nil {
        log.Fatal("Script falhou:", err)
    }
    
    // Acessar variáveis após a execução
    token := dsl.GetVariable("token")
    fmt.Printf("Token obtido: %v\n", token)
}
```

### Exemplos de Integração do Mundo Real

**1. Verificações de Saúde Automatizadas**
```go
func verificacaoSaude(apiURL string) error {
    dsl := core.NewHTTPDSLv3()
    script := fmt.Sprintf(`
        GET "%s/health"
        assert status 200
        assert time less 1000 ms
    `, apiURL)
    
    _, err := dsl.ParseWithBlockSupport(script)
    return err
}
```

**2. Executor de Testes Dinâmico**
```go
func executarSuiteDeTestes(arquivoTeste string, env map[string]string) {
    dsl := core.NewHTTPDSLv3()
    
    // Definir variáveis de ambiente
    for chave, valor := range env {
        dsl.SetVariable(chave, valor)
    }
    
    // Carregar e executar script de teste
    script, _ := os.ReadFile(arquivoTeste)
    result, err := dsl.ParseWithBlockSupport(string(script))
    
    if err != nil {
        log.Printf("Teste falhou: %v", err)
    }
}
```

**3. Integração com Pipeline CI/CD**
```go
func validadorImplantacao(urlImplantacao string) bool {
    dsl := core.NewHTTPDSLv3()
    
    scriptValidacao := `
        set $tentativas 0
        set $saudavel false
        
        while $tentativas < 5 and $saudavel == false do
            GET "%s"
            if status == 200 then
                set $saudavel true
            else
                wait 2000 ms
                set $tentativas $tentativas + 1
            endif
        endloop
        
        if $saudavel == false then
            print "Validação da implantação falhou após 5 tentativas"
        endif
    `
    
    script := fmt.Sprintf(scriptValidacao, urlImplantacao)
    _, err := dsl.ParseWithBlockSupport(script)
    
    return dsl.GetVariable("saudavel") == true
}
```

### Acessar Componentes do DSL

```go
// Obter todas as variáveis após a execução
vars := dsl.GetVariables()

// Definir variáveis iniciais antes da execução
dsl.SetVariable("baseURL", "https://api.producao.com")
dsl.SetVariable("apiKey", os.Getenv("API_KEY"))

// Acessar o motor HTTP para configurações personalizadas
engine := dsl.GetHTTPEngine()
engine.SetTimeout(30 * time.Second)
```

### Por Que Integrar o HTTP DSL?

- **Chega de Manutenção de Código de Testes**: Testes se tornam dados, não código
- **Não-Desenvolvedores Podem Escrever Testes**: Gerentes de produto, QA, qualquer um!
- **Geração Dinâmica de Testes**: Gere testes baseados em especificações OpenAPI
- **Bibliotecas de Testes Reutilizáveis**: Compartilhe arquivos `.http` entre projetos
- **Testes com Recarga a Quente**: Mude testes sem recompilar

## Uso

### Exemplo de Produção (Tudo Funcionando!)

```
# Todo este script FUNCIONA em v1.0.0!
set $base_url "https://jsonplaceholder.typicode.com"
set $api_version "v3"

# Múltiplos headers - FUNCIONA!
GET "$base_url/posts/1" 
    header "Accept" "application/json"
    header "X-API-Version" "$api_version"
    header "X-Request-ID" "test-123"
    header "Cache-Control" "no-cache"

assert status 200
extract jsonpath "$.userId" as $user_id

# JSON com símbolos @ - FUNCIONA!
POST "$base_url/posts" json {
    "title": "Notificações por email",
    "body": "Enviar para usuario@exemplo.com com @menções e #tags",
    "userId": 1
}

assert status 201
extract jsonpath "$.id" as $post_id

# Expressões aritméticas - FUNCIONANDO!
set $pontuacao_base 100
set $bonus 25
set $total $pontuacao_base + $bonus
set $final $total * 1.1
print "Pontuação final: $final"

# Condicionais - FUNCIONANDO!
if $post_id > 0 then set $status "SUCESSO" else set $status "FALHA"
print "Status de criação: $status"

# Loops com break/continue - FUNCIONANDO!
set $contador 0
while $contador < 10 do
    if $contador == 5 then
        break
    endif
    set $contador $contador + 1
endloop

# Operações com arrays - NOVO em v1.0.0!
set $frutas "[\"maçã\", \"banana\", \"laranja\"]"
set $primeira $frutas[0]  # Indexação de arrays com colchetes
set $tamanho length $frutas  # Função length
foreach $item in $frutas do
    print "Fruta: $item"
endloop

# Argumentos CLI - NOVO em v1.0.0!
if $ARGC > 0 then
    print "Primeiro argumento: $ARG1"
endif

print "Todos os testes completados com sucesso!"
```

### Usando o Executor

```bash
# Executar um arquivo de script
./httpdsl scripts/demos/demo_complete.http

# Passar argumentos de linha de comando para o script
./httpdsl script.http arg1 arg2 arg3

# Com saída detalhada
./httpdsl -v scripts/demos/06_loops.http

# Parar no primeiro erro
./httpdsl -stop scripts/demos/04_conditionals.http

# Execução a seco (validar sem executar)
./httpdsl --dry-run scripts/demos/05_blocks.http

# Validar apenas a sintaxe
./httpdsl --validate scripts/demos/02_headers_json.http
```

## 💝 Precisamos de Você! (Sim, Você!)

Este projeto existe porque desenvolvedores como você disseram "tem que haver um jeito melhor". E estavam certos.

### Como Você Pode Ajudar a Tornar os Testes Melhores para Todos

**🐛 Encontrou um Bug?** 
Não sofra em silêncio! [Abra uma issue](https://github.com/arturoeanton/httpdsl/issues) e vamos consertar juntos. Nenhum bug é pequeno demais.

**💡 Tem uma Ideia?**
Aquele recurso que você gostaria que existisse? Vamos construí-lo! Abra uma discussão e compartilhe seus pensamentos.

**📝 Melhorar a Documentação?**
Se algo confundiu você, confundirá outros. Ajude-nos a tornar mais claro!

**⭐ Apenas nos Dê uma Estrela!**
Sério, ajuda mais do que você imagina. Nos diz que estamos no caminho certo.

### Contribuindo com Código

```bash
# Fork, clone e crie sua branch de recurso
git checkout -b meu-recurso-incrivel

# Faça suas mudanças e teste-as
go test ./...

# Push e crie um PR!
```

Prometemos:
- 🚀 Revisar PRs rapidamente (geralmente em 48h)
- 💬 Fornecer feedback construtivo e gentil
- 🎉 Celebrar sua contribuição publicamente
- 📝 Dar crédito a você em nossos releases

### 🌟 Nossos Incríveis Contribuidores

Cada pessoa que contribui torna isso melhor. Seja código, documentação, relatórios de bugs, ou apenas espalhar a palavra - **você importa**.

## 🤲 Junte-se à Nossa Comunidade

**Não estamos construindo uma ferramenta. Estamos construindo uma comunidade de desenvolvedores que acreditam que testes deveriam ser simples.**

- 🐦 Compartilhe seus scripts e dicas com #httpdsl
- 💬 [Junte-se às nossas discussões](https://github.com/arturoeanton/httpdsl/discussions)
- 📧 Entre em contato diretamente - nós realmente respondemos!

## 🎭 O Panorama Geral

HTTP DSL é orgulhosamente alimentado por [**go-dsl**](https://github.com/arturoeanton/go-dsl) - nosso framework para construir linguagens específicas de domínio. Juntos, estamos fazendo ferramentas de desenvolvimento que respeitam seu tempo e inteligência.

## 📜 Licença

MIT - Porque grandes ferramentas deveriam ser grátis para todos.

## 🙏 Pensamentos Finais

Construímos isso porque precisávamos. Mantemos porque você também precisa. Cada issue que você abre, cada PR que você envia, cada estrela que você dá - tudo nos lembra por que fazemos isso.

**Obrigado por fazer parte desta jornada.**

Vamos tornar os testes agradáveis novamente! 🚀

---

<p align="center">
Feito com ❤️ por desenvolvedores que estavam cansados de testes complexos
<br>
<b>HTTP DSL v1.0.0</b> - Seu companheiro de testes
<br>
<i>"Ferramentas simples para problemas complexos"</i>
</p>

<p align="center">
  <a href="https://github.com/arturoeanton/httpdsl">⭐ Nos dê uma estrela</a> •
  <a href="https://github.com/arturoeanton/httpdsl/issues">🐛 Reportar Bug</a> •
  <a href="https://github.com/arturoeanton/httpdsl/discussions">💬 Discussões</a> •
  <a href="https://github.com/arturoeanton/go-dsl">🔧 go-dsl</a>
</p>