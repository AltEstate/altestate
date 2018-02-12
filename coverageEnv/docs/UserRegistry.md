## Чтение данных

### Вызов: `hasIdentity`

hasIdentity isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "hasIdentity",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `systemAddresses`

systemAddresses isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
to         : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "systemAddresses",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `publisher`

publisher isn't documentated yet..

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "publisher",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isOwner`

isOwner isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "isOwner",
  "at": "0x....",
  "args": []
}
```
### Вызов: `knownAddress`

knownAddress isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "knownAddress",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `checkOwner`

checkOwner isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
maybeowner : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "checkOwner",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
## Запись данных

### Метод: `addAddress`

addAddress isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "addAddress",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `grant`

grant isn't documentated yet..

**Аргументы:**

```
owner      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "grant",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `revoke`

revoke isn't documentated yet..

**Аргументы:**

```
owner      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "revoke",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `addSystem`

addSystem isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
address    : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "addSystem",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `addIdentity`

addIdentity isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "addIdentity",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `AddAddress`

AddAddress isn't documentated yet..

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "AddAddress",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `AddIdentity`

AddIdentity isn't documentated yet..

**Аргументы:**

```
who        : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "AddIdentity",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `AccessGrant`

AccessGrant isn't documentated yet..

**Аргументы:**

```
owner      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "AccessGrant",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `AccessRevoke`

AccessRevoke isn't documentated yet..

**Аргументы:**

```
owner      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "UserRegistry",
  "method": "AccessRevoke",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
## Журналы событий

### Событие: `AddAddress`

AddAddress isn't documentated yet..

**Поля:**

```
who        : address [indexed]
```
### Событие: `AddIdentity`

AddIdentity isn't documentated yet..

**Поля:**

```
who        : address [indexed]
```
### Событие: `AccessGrant`

AccessGrant isn't documentated yet..

**Поля:**

```
owner      : address [indexed]
```
### Событие: `AccessRevoke`

AccessRevoke isn't documentated yet..

**Поля:**

```
owner      : address [indexed]
```
