## Контруктор

**Аргументы ожидаемые контрактом при создании**
```
name       : string
ticker     : string
decimals   : uint256
registry   : address – адрес реестра пользователей
```

## Чтение данных

### Вызов: `mintingFinished`
Возвращает `true` если чеканка завершена

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "mintingFinished",
  "at": "0x....",
  "args": []
}
```
### Вызов: `name`

Возвращает название токена

**Возвращает:** `string`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "name",
  "at": "0x....",
  "args": []
}
```
### Вызов: `totalSupply`

Возвращает количество эмитированных токенов

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "totalSupply",
  "at": "0x....",
  "args": []
}
```
### Вызов: `decimals`

Кратность токена или количество знаков после запятой в графических интерфейсах

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "decimals",
  "at": "0x....",
  "args": []
}
```
### Вызов: `unfrozen`

unfrozen isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "unfrozen",
  "at": "0x....",
  "args": []
}
```
### Вызов: `userRegistry`

Адрес смартконтракта `UserRegistry` ассоциированного с токеном (для реализации правил `KnownHolderToken`)

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "userRegistry",
  "at": "0x....",
  "args": []
}
```
### Вызов: `balanceOf`

Возвращает баланс (токенов) для переданного адреса

*NB: Для вывода в графическом интерфейсе требуется полученное значение разделить на 10 в степени `decimals`!*

**Возвращает:** `uint256`

**Аргументы:**

```
owner      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "balanceOf",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `ticker`

Возвращает тикер токена (короткое наименование для листинга на бирже)

**Возвращает:** `string`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "ticker",
  "at": "0x....",
  "args": []
}
```
### Вызов: `owner`

Адрес текущего владельца токена

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "owner",
  "at": "0x....",
  "args": []
}
```
### Вызов: `allowance`

Возвращает количество токенов переданное `owner`ом в управление `spender`у.

Выделенные в управление токены доступны для перевода через `transferFrom`.

**Возвращает:** `uint256`

**Аргументы:**

```
owner      : address
spender    : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "allowance",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
## Запись данных

### Метод: `approve`

Выделить `value` токенов в управление `spender`у.

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
spender    : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "approve",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `transferFrom`

Перевести `value` токенов с адреса `from` на адрес `to`. Для перевода требуется наличие разрешения (`approve`) у вызывающего метод адреса

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
from       : address
to         : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "transferFrom",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `unfrezee`

unfrezee isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "unfrezee",
  "at": "0x....",
  "args": []
}
```
### Метод: `takeAway`

takeAway isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
holder   : address
to       : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "takeAway",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `mint`

Чеканда `amount` токенов для адреса `to`. Требуется наличие `owner` прав у адреса вызывающего метод.

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
to         : address
amount     : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "mint",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `decreaseApproval`

Уменьшает количество выделенных в управление для `spender` токенов на значение `subtracted`.

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
spender    : address
subtracted : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "decreaseApproval",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `finishMinting`

Объявляет завершение чеканки. Требуются права владельца

**Возвращает:** `true` в случае успеха или ошибку.

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "finishMinting",
  "at": "0x....",
  "args": []
}
```
### Метод: `transfer`

Переводит `value` токенов с адреса вызывающего метод на адресс `to`.

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
to         : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "transfer",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `approveAndCall`

Передает в управление `spender` токены в количестве `value` и вызывает метод `receiveApproval` из `TokenRecipient` интерфейса.

Третий аргумент произвольные данные для дополнительной логики.

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
spender    : address
value      : uint256
data       : bytes
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "approveAndCall",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    "0xfffffffff000000aaaaaaaa"
]
}
```
### Метод: `increaseApproval`

increaseApproval isn't documentated yet..

**Возвращает:** `true` в случае успеха или ошибку.

**Аргументы:**

```
spender    : address
addedValue : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "increaseApproval",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `transferOwnership`

transferOwnership isn't documentated yet..

**Аргументы:**

```
newOwner   : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "transferOwnership",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `Mint`

Mint isn't documentated yet..

**Аргументы:**

```
to         : address
amount     : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "Mint",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `MintFinished`

MintFinished isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "MintFinished",
  "at": "0x....",
  "args": []
}
```
### Метод: `OwnershipTransferred`

OwnershipTransferred isn't documentated yet..

**Аргументы:**

```
previousOw : address
newOwner   : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "OwnershipTransferred",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `Approval`

Approval isn't documentated yet..

**Аргументы:**

```
owner      : address
spender    : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "Approval",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `Transfer`

Transfer isn't documentated yet..

**Аргументы:**

```
from       : address
to         : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "Transfer",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
## Журналы событий

### Событие: `Mint`

Создается каждый раз когда чеканются токены для адреса `to` в количетсве `amount`

**Поля:**

```
to         : address [indexed]
amount     : uint256 
```
### Событие: `MintFinished`

Создается единоразово в момент завершения чеканки

### Событие: `OwnershipTransferred`

Создается каждый раз когда владелец токена передает права другому

**Поля:**

```
previousOwner : address [indexed]
newOwner      : address [indexed]
```
### Событие: `Approval`

Создается каждый раз когда `owner` передает `value` токенов в управление `spender`

**Поля:**

```
owner      : address [indexed]
spender    : address [indexed]
value      : uint256 
```
### Событие: `Transfer`

Создается каждый раз когда `from` переводит `value` токенов на адрес `to`

**Поля:**

```
from       : address [indexed]
to         : address [indexed]
value      : uint256 
```
