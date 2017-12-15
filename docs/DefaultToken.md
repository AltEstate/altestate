## Чтение данных

### Вызов: `mintingFinished`

mintingFinished isn't documentated yet..

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

name isn't documentated yet..

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

totalSupply isn't documentated yet..

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

decimals isn't documentated yet..

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
### Вызов: `userRegistry`

userRegistry isn't documentated yet..

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

balanceOf isn't documentated yet..

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

ticker isn't documentated yet..

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

owner isn't documentated yet..

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

allowance isn't documentated yet..

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

approve isn't documentated yet..

**Возвращает:** `bool`

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

transferFrom isn't documentated yet..

**Возвращает:** `bool`

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
### Метод: `mint`

mint isn't documentated yet..

**Возвращает:** `bool`

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

decreaseApproval isn't documentated yet..

**Возвращает:** `bool`

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

finishMinting isn't documentated yet..

**Возвращает:** `bool`

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

transfer isn't documentated yet..

**Возвращает:** `bool`

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

approveAndCall isn't documentated yet..

**Возвращает:** `bool`

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

**Возвращает:** `bool`

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
### Метод: `undefined`

undefined isn't documentated yet..

**Аргументы:**

```
name       : string
ticker     : string
decimals   : uint256
registry   : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "DefaultToken",
  "method": "undefined",
  "at": "0x....",
  "args": [
    "Sample String",
    "Sample String",
    1000000000000,
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

Mint isn't documentated yet..

**Поля:**

```
to         : address [indexed]
amount     : uint256 
```
### Событие: `MintFinished`

MintFinished isn't documentated yet..

### Событие: `OwnershipTransferred`

OwnershipTransferred isn't documentated yet..

**Поля:**

```
previousOw : address [indexed]
newOwner   : address [indexed]
```
### Событие: `Approval`

Approval isn't documentated yet..

**Поля:**

```
owner      : address [indexed]
spender    : address [indexed]
value      : uint256 
```
### Событие: `Transfer`

Transfer isn't documentated yet..

**Поля:**

```
from       : address [indexed]
to         : address [indexed]
value      : uint256 
```
