Alt.Estate Smart-contracts Manual
===

Документация к программному обеспечению для децентрализованного учета данных и реализации функционала платформы **Alt.Estate**

## Обзор

### Репозитории
* [Смарт-контракты](https://github.com/alerdenisov/altestate)
* [Прокси сервер](https://github.com/alerdenisov/altestate-proxy) для взаимодействия с блокчейном

### Типы взаимодействия
* **Централизованное** — отправка транзакции через централизованную прокси для обеспечения конфиденциальности ключа администратора
* **Вызовы** — запросы на получение информации из состояния блокчейна не требующие подписи отправителя
* **Децентрализованные** — отправка транзакции через веб–браузер пользователя для обеспечения конфиденциальности его приватного ключа

### Глосарий
* **ABI** — спецификации точек взаимодействия смарт-контракта
* **Truffle Contract** — сериализованная в JSON информация о смарт-контракте. Содержит в себе ABI, адрес контракта в сети и дополнительную информацию.
* **Tx** — транзакция в блокчейн. Содержит поля `from`, `to`, `nonce`, `data`, `value` и набор полей для проверки криптографической подписи.
* **Call** — вызов RPC ноды для получения информации из блокчейна
* **UserRegistry** — смарт–контракт учета известных платформе Alt.Estate пользователей сети Ethereum
* **User** — известный платформе пользователь сети Ethereum
    * **Identity** — статус прохождения пользователем процедуры KYC
* **Whitelist** – список `WhiteListRecord` ассоциированный с адресами пользователей сети Ethereum
* **Crowdsale** — смарт–контракт наследуемый от общего родителя: `Crowdsale`
* **Процент** — целочисленное значение от 0 до 10000. _Где 1234 — это 12.34%_

### Особенности EVM

При взаимодействии со смарт-контрактами в сети Ethereum необходимо учитывать, что:
* В Ethereum Virtual Machine нету значений с плавующей запятой. Все дробные значения это $f(x, d) = x * 10^d$, где $d$ изначально определенная дробность значения $x$. Например, 5.5% при дробности 2 — это 550.
* Все транзакции (tx) совершаются последовательно. Если необходимо выполнить сценарий из двух или более транзакций необходимо дождаться попадания в блок предыдущей перед отправкой последующей.

## Установка
Разворачивания среды для разработки состоит из двух частей:
1) Децентрализованный код сети Ethereum
2) Настройка прокси-сервера

### Децентрализованный код сети Ethereum
Для упрощения процесса разработки предлагается использовать тестовое окружение не требующие «майнинга» и времени для ожидания выполнения транзакций.

Тестовое окружение является частью [смарт-контрактов](https://github.com/alerdenisov/altestate) и поставляется с предватительными настройками.

```bash
# clone repository
git clone https://github.com/alerdenisov/altestate.git

# enter to dev directory
cd altestate

# install and build dependencies
npm install
```

Успех установки зависимостей можно проверить запуском тестового узла:

```
make testrpc
```

Результат выполнения не должен содержать ошибок и должен заканчиваться на `Listening on localhost:8545`

**Не выключая** узел можно перейти к процессу сборки смарт-контрактов и их загрузки в тестовый блокчейн:

```bash
# In new terminal
cd altestate

# NETWORK is env variable declate selected network
# in future we will use mainnet and rinkeby
NETWORK=testrpc make migrate
```

Процесс миграции может занять некоторое время, но результатом должно быть:

```bash
Running migration: 1_initial_migration.js
  Replacing Migrations...
  ... 0x8da56a48045be31369be07e4d1105efa5e8b8af729dc8fb2502e68668cc859e9
  Migrations: 0xe78a0f7e598cc8b0bb87894b0f60dd2a88d6a8ab
Saving successful migration to network...
  ... 0x584a384cffc39a4c7514d6ebecc9dad1a38a65ed66d3673cece13dfb2cc9dac5
Saving artifacts...
Running migration: 2_user_registry.js
  Replacing UserRegistry...
  ... 0x5b064f2c3ec610038b02fc42d8eb72448011625c8d736e88689dfebd3080de91
  UserRegistry: 0xcfeb869f69431e42cdb54a4f4f105c19c080a601
Saving successful migration to network...
  ... 0xf0ea38a9783319a1754b1bc4b7a351fae936e5d6b83ab7d2c658b72fc35a5f04
Saving artifacts...
Running migration: 3_token.js
  Replacing AltToken...
  ... 0x47129d94cdc7f4eeac2788ab10691ac2a8aaf73acf59dbb2ed67767f15335ae1
  AltToken: 0xc89ce4735882c9f0f0fe26686c53074e09b0d550
Saving successful migration to network...
  ... 0x0c0eefe82c4466a9956213f1cfce64f78811337e553c1a835887aac8fc525455
Saving artifacts...
Running migration: 4_ico.js
  Replacing AltCrowdsalePhaseOne...
  ... 0xa3e2f439c05c39f629ec428ebd3c47112761b6f4d3646c2fc812a4bdd39517c8
  AltCrowdsalePhaseOne: 0x9561c133dd8580860b6b7e504bc5aa500f0f06a7
  Replacing AltCrowdsalePhaseTwo...
  ... 0xd9fa6b693489fab9ddd2c2c26cdb995ab088dd84f09aba6b801f8ef0e1714396
  AltCrowdsalePhaseTwo: 0xe982e462b094850f12af94d21d470e21be9d0e9c
Saving successful migration to network...
  ... 0x5d246379e3d6b41112ff96188d227a7e52c058c4d4121db3b13bb475d20fe713
Saving artifacts...
```

Наличие записей `Saving artifacts...` говорит об успешной генерации Truffle Contract файлов.

### Настройка прокси-сервера
Удобнее всего разместить директорию с прокси сервером по-соседству с директорией смарт-контрактов:

```
cd ~
git clone https://github.com/alerdenisov/altestate-proxy.git
cd altestate-proxy

make run
```

Для более детально настройки можно использовать переменные окружения:
```
CONTRACTS:=    "../altestate/build/contracts"
NODE:=         "http://localhost:8545"
FROM:=         "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"
PRIVATE_KEY:= "4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d"
GAS_PRICE:=   "1000000"
GAS_LIMIT:=   "5000000"
```
Например, если репозиторий со смарт-контрактами находится на пути отличном от `../altestate`, тогда необходимо указать путь до truffle contract файлов:
```
make run CONTRACTS=~/some/path/to/altestate/build/contracts
```

Сервер запускается на 3000 порту и ожидает POST запросы. Если узел запушен и контракты смигрировны можно проверить работоспособность простым вызовом:
```
curl --request POST \
     --url http://localhost:3000/contract \
     --header 'content-type: application/json' \
     --data '{"contract": "AltToken","method": "name"}'
```

В ответ прокси должена вернуть:
```
{"result":"Alt Estate","statusCode":200}
```

Все взаимодействие с прокси делится на два типа: вызовы методов web3 и взаимодействие со смарт-контрактами. 

Полный список методов web3 можно посмотреть [**тут**](https://web3js.readthedocs.io/en/1.0/web3-eth-contract.html)

Вызовы опускают приставку eth, например метод web3.eth.getTransaction выглядит так:
```bash
curl --request POST \
     --url 'http://localhost:3000/getTransaction' \
     --header 'content-type: application/json' \
     --data '{ "args": ["<txHash>"] }'
```

## Взаимодействие со смарт-контрактами

Все взаимодействи со смарт-контрактами идет через общий endpoint: `/contract`, а тело запроса ждет поля: `contract` и `method`. Опционально можно передать `address` если таковой не указан явно в truffle contract файле.
### UserRegistry
Все токены и crowdsale'ы взаимодействуют с общим реестром пользователей.

Ключевой функционал реестра:
#### **`addAddress(address _who)`**
Принимает в качестве аргумента адресс пользователя сети Ethereum для внесения в список известных пользователей.

**Пример запроса**
```json
POST /contract
{
    "contract": "UserRegistry",
    "method": "addAddress",
    "args": ["0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"]
}
```

**Возвращает**
Tx Hash для дальнейшего отслеживания: 
```
POST /getTransaction
{ args: [<tx hash>] }
```

Или ошибку если пользователь уже известен

#### **`addIdentity(address _who)`**
Принимает в качестве аргумента адресс пользователя и указывает, что данный пользователь прошел процедуру KYC. 

Если пользователь еще неизвестен — создает нового.
**Пример запроса**
```json
POST /contract
{
    "contract": "UserRegistry",
    "method": "addIdentity",
    "args": ["0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"]
}
```

**Возвращает**
Tx Hash для дальнейшего отслеживания

#### **`knownAddress(address _who) constant returns(bool)`**
Внешний вызов для получения статуса указанного в аргументах адреса.

**Пример запроса**
```json
POST /contract
{
    "contract": "UserRegistry",
    "method": "knownAddress",
    "args": ["0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"]
}
```

**Возвращает**
`true` – если пользователь известен или `false` в противном

#### **`hasIdentity(address _who) constant returns(bool)`**
Внешний вызов для получения статуса прохождения KYC указанным пользователем.

**Пример запроса**
```json
POST /contract
{
    "contract": "UserRegistry",
    "method": "hasIdentity",
    "args": ["0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1"]
}
```

**Возвращает**
`true` – если пользователь прошел KYC или `false` в противном