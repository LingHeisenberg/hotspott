# Eyazs Hotspot

Projeto novo em Node.js, Express, mysql2, React e TailwindCSS para venda de vouchers de hotspot com a mesma logica do sistema PHP antigo.

## Estrutura

```text
frontend/  App React, Tailwind, imagens, fontes e assets visuais
backend/   API Express, integrações M-Pesa/MikroTik, rotas e scripts
db/        Schema MySQL
```

Os comandos principais continuam na raiz do projeto. As variaveis de ambiente agora ficam separadas por camada:

```text
backend/.env   Banco, admin, MikroTik, M-Pesa e e-Mola
frontend/.env  Porta da API usada pelo proxy do Vite e URL publica do MikroTik
mikrotik/      Arquivos que vao para o Hotspot do MikroTik
```

## O que ja esta funcional

- Lista planos vindos do MySQL.
- Valida telefone M-Pesa: prefixos `84` e `85`.
- Valida telefone e-Mola: prefixos `86` e `87`.
- Reserva voucher disponivel com transacao MySQL e `FOR UPDATE`.
- Cria referencia interna da compra.
- Gera vouchers pre-criados no MySQL e no MikroTik a partir do painel admin ou script CLI.
- Tela de espera consulta o backend a cada 3 segundos.
- Em modo `mock`, o pagamento e aprovado automaticamente apos alguns segundos.
- Em modo `live`, o M-Pesa usa `APIMPESA` e envia `transaction_ref`, `msisdn`, `amount` e `thirdparty_ref`.
- Se a API M-Pesa confirmar sucesso no pedido inicial, o voucher muda automaticamente de `pendente` para `pago`.
- Se a API M-Pesa devolver saldo insuficiente, o voucher volta ao stock e o cliente ve a mensagem no modal de pagamento.
- e-Mola ja tem estrutura de integracao no backend, mas fica desligado por padrao com `EMOLA_ENABLED=false`.
- Quando o pagamento fica pago, mostra voucher/senha e envia o formulario para o login do MikroTik.
- Em modo real, bloqueia pagamento aberto fora do Hotspot quando nao existe IP/MAC do cliente.
- Depois do pagamento, o backend tenta autenticar o cliente no MikroTik via `/ip/hotspot/active/login`.
- Painel admin com metricas, historico e exportacao CSV.
- Callback preparado em `/api/payments/mpesa/callback` e `/api/payments/emola/callback`.

## Instalar

```bash
npm install
```

Crie os arquivos de ambiente a partir dos exemplos de cada camada:

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

Ajuste `backend/.env` para banco, senha admin, MikroTik, M-Pesa e e-Mola. Ajuste `frontend/.env` quando mudar a porta da API ou a URL publica de login do MikroTik.

## Banco de dados

Crie o banco e rode o schema:

```bash
npm run db:setup
```

O schema ja cria os pacotes e alguns vouchers de teste.

## Rodar em desenvolvimento

```bash
npm run dev
```

- Frontend: `http://localhost:5173`
- API: `http://localhost:3010`
- Admin: `http://localhost:5173/admin`

## MikroTik

Configure o `backend/.env` com o endpoint REST do MikroTik:

```env
MIKROTIK_LOGIN_URL=http://10.5.50.1/login
MIKROTIK_REST_URL=http://102.67.188.90:8070/rest/ip/hotspot/user
MIKROTIK_API_USER=usuario_mikrotik
MIKROTIK_API_PASS=sua_senha
MIKROTIK_HOTSPOT_SERVER=all
MIKROTIK_SYNC_ENABLED=true
MIKROTIK_REQUIRE_HOTSPOT_CONTEXT=true
```

No RouterOS v7, ative o serviço `www` ou `www-ssl` e use um usuario com permissao para criar Hotspot Users.

Para o acesso automatico funcionar, a compra precisa ser aberta pela pagina de login do Hotspot. Use o arquivo:

```text
mikrotik/login.html
```

Substitua `http://SEU_SERVIDOR:3010/` pelo IP ou dominio onde este projeto esta a rodar e envie esse `login.html` para os arquivos do Hotspot no MikroTik. Nao use `localhost` para clientes reais, porque no telemovel do cliente `localhost` aponta para o proprio telemovel.

Nesta maquina o portal esta configurado como:

```env
PORTAL_PUBLIC_URL=http://192.168.1.5:3010/
```

Para configurar o MikroTik automaticamente:

```bash
npm run hotspot:setup
```

Esse comando cria a regra walled-garden para `192.168.1.5:3010` e envia o `login.html` para `hotspot/login.html` e `flash/hotspot/login.html`.

## Gerar vouchers

Pelo painel:

```text
http://localhost:5173/admin
```

Ou pelo terminal:

```bash
npm run vouchers:generate -- --pacote=1 --quantity=10 --prefix=VCH
```

O sistema cria primeiro o usuario no MikroTik. So depois grava o voucher no MySQL como `disponivel`.

Antes de vender, sincronize os perfis dos pacotes no MikroTik:

```bash
npm run profiles:sync
```

Para sincronizar vouchers antigos que ja existem no MySQL, use:

```bash
npm run vouchers:sync -- --code=VCH10002
```

Sem `--code`, o comando tenta sincronizar ate 100 vouchers ainda nao sincronizados.

Para ver o stock sincronizado por pacote:

```bash
npm run vouchers:stock
```

## API real do M-Pesa

Configure o `backend/.env` assim:

```env
PAYMENT_MODE=live
APIMPESA=https://api-mpesa-production.up.railway.app/api/mpesa/c2b
MPESA_MSISDN_PREFIX=258
MPESA_TIMEOUT_MS=45000
```

O ponto principal da integracao fica em:

```text
backend/src/services/paymentService.js
```

O payload enviado para a API e:

```json
{
  "transaction_ref": "ISP...",
  "msisdn": "25884XXXXXXX",
  "amount": 5,
  "thirdparty_ref": "ISP..."
}
```

O webhook deve chamar:

```text
POST /api/payments/mpesa/callback
```

O callback ja tenta reconhecer varios formatos comuns de resposta. Ele atualiza o voucher de `pendente` para `pago` em caso de sucesso e grava o motivo quando a operadora recusar, incluindo saldo insuficiente.

## e-Mola

Por enquanto o e-Mola fica bloqueado para clientes. Ao digitar um numero `86` ou `87`, a tela mostra que pagamentos com e-Mola ainda nao estao disponiveis e orienta a usar M-Pesa.

Quando a API e-Mola estiver disponivel, configure:

```env
EMOLA_ENABLED=true
EMOLA_API_URL=https://...
EMOLA_CHANNEL_ID=...
EMOLA_PASSWORD=...
EMOLA_SERVICE_CODE=...
```
