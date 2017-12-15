## Чтение данных

### Вызов: `success`

success isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "success",
  "at": "0x....",
  "args": []
}
```
### Вызов: `ended`

ended isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "ended",
  "at": "0x....",
  "args": []
}
```
### Вызов: `timeSlices`

timeSlices isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "timeSlices",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `isRefundable`

isRefundable isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isRefundable",
  "at": "0x....",
  "args": []
}
```
### Вызов: `endTime`

endTime isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "endTime",
  "at": "0x....",
  "args": []
}
```
### Вызов: `calculateEthAmount`

calculateEthAmount isn't documentated yet..

**Возвращает:**

```
calculated : uint256
calculated : uint256
calculated : uint256
calculated : uint256
refererAdd : address
```
**Аргументы:**

```
beneficiar : address
weiAmount  : uint256
time       : uint256
totalSuppl : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "calculateEthAmount",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000,
    1000000000000
]
}
```
### Вызов: `tokenDecimals`

tokenDecimals isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "tokenDecimals",
  "at": "0x....",
  "args": []
}
```
### Вызов: `whitelisted`

whitelisted isn't documentated yet..

**Возвращает:** `address`

**Аргументы:**

```
           : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "whitelisted",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `weiRaised`

weiRaised isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "weiRaised",
  "at": "0x....",
  "args": []
}
```
### Вызов: `altDeposit`

altDeposit isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : address
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "altDeposit",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `wallet`

wallet isn't documentated yet..

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "wallet",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isAllowToIssue`

isAllowToIssue isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isAllowToIssue",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isCappedInEther`

isCappedInEther isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isCappedInEther",
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
  "contract": "Crowdsale",
  "method": "userRegistry",
  "at": "0x....",
  "args": []
}
```
### Вызов: `amountSlices`

amountSlices isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "amountSlices",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `addressToString`

addressToString isn't documentated yet..

**Возвращает:** `string`

**Аргументы:**

```
x          : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "addressToString",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `capped`

capped isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "capped",
  "at": "0x....",
  "args": []
}
```
### Вызов: `soldTokens`

soldTokens isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "soldTokens",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isWhitelisted`

isWhitelisted isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isWhitelisted",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isTokenExchange`

isTokenExchange isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isTokenExchange",
  "at": "0x....",
  "args": []
}
```
### Вызов: `char`

char isn't documentated yet..

**Возвращает:** `bytes1`

**Аргументы:**

```
b          : bytes1
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "char",
  "at": "0x....",
  "args": [
    null
]
}
```
### Вызов: `timeSlicesCount`

timeSlicesCount isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "timeSlicesCount",
  "at": "0x....",
  "args": []
}
```
### Вызов: `calculateTimeBonus`

calculateTimeBonus isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
at         : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "calculateTimeBonus",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `startTime`

startTime isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "startTime",
  "at": "0x....",
  "args": []
}
```
### Вызов: `personalBonuses`

personalBonuses isn't documentated yet..

**Возвращает:** `address`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "personalBonuses",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `isPersonalBonuses`

isPersonalBonuses isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isPersonalBonuses",
  "at": "0x....",
  "args": []
}
```
### Вызов: `beneficiaryInvest`

beneficiaryInvest isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "beneficiaryInvest",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `toUint`

toUint isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
left       : bytes
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "toUint",
  "at": "0x....",
  "args": [
    "0xfffffffff000000aaaaaaaa"
]
}
```
### Вызов: `calculateAmountBonus`

calculateAmountBonus isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
changeAmou : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "calculateAmountBonus",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `isAllowClaimBeforeFinalization`

isAllowClaimBeforeFinalization isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isAllowClaimBeforeFinalization",
  "at": "0x....",
  "args": []
}
```
### Вызов: `publisher`

publisher isn't documentated yet..

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
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
  "contract": "Crowdsale",
  "method": "isOwner",
  "at": "0x....",
  "args": []
}
```
### Вызов: `softCap`

softCap isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "softCap",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isAmountBonus`

isAmountBonus isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isAmountBonus",
  "at": "0x....",
  "args": []
}
```
### Вызов: `whitelist`

whitelist isn't documentated yet..

**Возвращает:** `address`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "whitelist",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `price`

price isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "price",
  "at": "0x....",
  "args": []
}
```
### Вызов: `whitelistedCount`

whitelistedCount isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "whitelistedCount",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isTransferShipment`

isTransferShipment isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isTransferShipment",
  "at": "0x....",
  "args": []
}
```
### Вызов: `state`

state isn't documentated yet..

**Возвращает:** `uint8`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "state",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isExtraDistribution`

isExtraDistribution isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isExtraDistribution",
  "at": "0x....",
  "args": []
}
```
### Вызов: `appendUintToString`

appendUintToString isn't documentated yet..

**Возвращает:** `string`

**Аргументы:**

```
inStr      : string
v          : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "appendUintToString",
  "at": "0x....",
  "args": [
    "Sample String",
    1000000000000
]
}
```
### Вызов: `amountBonuses`

amountBonuses isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "amountBonuses",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `weiDeposit`

weiDeposit isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "weiDeposit",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `extraDistributionPart`

extraDistributionPart isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "extraDistributionPart",
  "at": "0x....",
  "args": []
}
```
### Вызов: `timeBonuses`

timeBonuses isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "timeBonuses",
  "at": "0x....",
  "args": [
    1000000000000
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
  "contract": "Crowdsale",
  "method": "checkOwner",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `amountSlicesCount`

amountSlicesCount isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "amountSlicesCount",
  "at": "0x....",
  "args": []
}
```
### Вызов: `isKnownOnly`

isKnownOnly isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isKnownOnly",
  "at": "0x....",
  "args": []
}
```
### Вызов: `allowedTokens`

allowedTokens isn't documentated yet..

**Возвращает:** `address`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "allowedTokens",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `extraTokensHolder`

extraTokensHolder isn't documentated yet..

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "extraTokensHolder",
  "at": "0x....",
  "args": []
}
```
### Вызов: `uintToString`

uintToString isn't documentated yet..

**Возвращает:** `string`

**Аргументы:**

```
v          : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "uintToString",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Вызов: `isEarlyBonus`

isEarlyBonus isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "isEarlyBonus",
  "at": "0x....",
  "args": []
}
```
### Вызов: `validPurchase`

validPurchase isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
beneficiar : address
weiAmount  : uint256
tokenAmoun : uint256
extraAmoun : uint256
totalAmoun : uint256
time       : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "validPurchase",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000,
    1000000000000,
    1000000000000,
    1000000000000
]
}
```
### Вызов: `tokensValues`

tokensValues isn't documentated yet..

**Возвращает:** `uint256`

**Аргументы:**

```
           : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "tokensValues",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Вызов: `hardCap`

hardCap isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "hardCap",
  "at": "0x....",
  "args": []
}
```
### Вызов: `token`

token isn't documentated yet..

**Возвращает:** `address`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "token",
  "at": "0x....",
  "args": []
}
```
### Вызов: `VERSION`

VERSION isn't documentated yet..

**Возвращает:** `uint256`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "VERSION",
  "at": "0x....",
  "args": []
}
```
## Запись данных

### Метод: `setToken`

setToken isn't documentated yet..

**Аргументы:**

```
tokenAddre : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setToken",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `setTimeBonuses`

setTimeBonuses isn't documentated yet..

**Аргументы:**

```
timeSlices : uint256[]
prices     : uint256[]
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setTimeBonuses",
  "at": "0x....",
  "args": [
    null,
    null
]
}
```
### Метод: `buyWithHash`

buyWithHash isn't documentated yet..

**Аргументы:**

```
beneficiar : address
value      : uint256
timestamp  : uint256
hash       : bytes32
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "buyWithHash",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000,
    null
]
}
```
### Метод: `updateTokenValue`

updateTokenValue isn't documentated yet..

**Аргументы:**

```
token      : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "updateTokenValue",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `claimRefundEther`

claimRefundEther isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
beneficiar : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "claimRefundEther",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `setAmountBonuses`

setAmountBonuses isn't documentated yet..

**Аргументы:**

```
amountSlic : uint256[]
prices     : uint256[]
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setAmountBonuses",
  "at": "0x....",
  "args": [
    null,
    null
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
  "contract": "Crowdsale",
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
  "contract": "Crowdsale",
  "method": "revoke",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `finalizeIt`

finalizeIt isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "finalizeIt",
  "at": "0x....",
  "args": []
}
```
### Метод: `saneIt`

saneIt isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "saneIt",
  "at": "0x....",
  "args": []
}
```
### Метод: `historyIt`

historyIt isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "historyIt",
  "at": "0x....",
  "args": []
}
```
### Метод: `setExtraDistribution`

setExtraDistribution isn't documentated yet..

**Аргументы:**

```
holder     : address
extraPart  : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setExtraDistribution",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `receiveApproval`

receiveApproval isn't documentated yet..

**Аргументы:**

```
from       : address
value      : uint256
token      : address
extraData  : bytes
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "receiveApproval",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xfffffffff000000aaaaaaaa"
]
}
```
### Метод: `setPrice`

setPrice isn't documentated yet..

**Аргументы:**

```
price      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setPrice",
  "at": "0x....",
  "args": [
    1000000000000
]
}
```
### Метод: `claimTokenFunds`

claimTokenFunds isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
token      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "claimTokenFunds",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `setTime`

setTime isn't documentated yet..

**Аргументы:**

```
start      : uint256
end        : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setTime",
  "at": "0x....",
  "args": [
    1000000000000,
    1000000000000
]
}
```
### Метод: `claimRefundTokens`

claimRefundTokens isn't documentated yet..

**Возвращает:** `bool`

**Аргументы:**

```
beneficiar : address
token      : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "claimRefundTokens",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `setRegistry`

setRegistry isn't documentated yet..

**Аргументы:**

```
registry   : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setRegistry",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `claimFunds`

claimFunds isn't documentated yet..

**Возвращает:** `bool`

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "claimFunds",
  "at": "0x....",
  "args": []
}
```
### Метод: `addToWhitelist`

addToWhitelist isn't documentated yet..

**Аргументы:**

```
beneficiar : address
min        : uint256
max        : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "addToWhitelist",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000
]
}
```
### Метод: `setTokenExcange`

setTokenExcange isn't documentated yet..

**Аргументы:**

```
token      : address
value      : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setTokenExcange",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `setSoftHardCaps`

setSoftHardCaps isn't documentated yet..

**Аргументы:**

```
softCap    : uint256
hardCap    : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setSoftHardCaps",
  "at": "0x....",
  "args": [
    1000000000000,
    1000000000000
]
}
```
### Метод: `setFlags`

setFlags isn't documentated yet..

**Аргументы:**

```
isWhitelis : bool
isKnownOnl : bool
isAmountBo : bool
isEarlyBon : bool
isRefundab : bool
isTokenExc : bool
isAllowToI : bool
isExtraDis : bool
isMintingS : bool
isCappedIn : bool
isPersonal : bool
isAllowCla : bool
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setFlags",
  "at": "0x....",
  "args": [
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true,
    true
]
}
```
### Метод: `setWallet`

setWallet isn't documentated yet..

**Аргументы:**

```
wallet     : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setWallet",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `buyTokens`

buyTokens isn't documentated yet..

**Аргументы:**

```
beneficiar : address
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "buyTokens",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
### Метод: `setPersonalBonus`

setPersonalBonus isn't documentated yet..

**Аргументы:**

```
beneficiar : address
bonus      : uint256
refererAdd : address
refererBon : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "setPersonalBonus",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `undefined`

undefined isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "undefined",
  "at": "0x....",
  "args": []
}
```
### Метод: `TokenPurchase`

TokenPurchase isn't documentated yet..

**Аргументы:**

```
purchaser  : address
beneficiar : address
value      : uint256
amount     : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "TokenPurchase",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000
]
}
```
### Метод: `HashSale`

HashSale isn't documentated yet..

**Аргументы:**

```
beneficiar : address
value      : uint256
amount     : uint256
timestamp  : uint256
bitcoinHas : bytes32
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "HashSale",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000,
    1000000000000,
    null
]
}
```
### Метод: `TokenSell`

TokenSell isn't documentated yet..

**Аргументы:**

```
beneficiar : address
allowedTok : address
allowedTok : uint256
ethValue   : uint256
shipAmount : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "TokenSell",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000,
    1000000000000
]
}
```
### Метод: `ShipTokens`

ShipTokens isn't documentated yet..

**Аргументы:**

```
owner      : address
amount     : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "ShipTokens",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `Sanetize`

Sanetize isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "Sanetize",
  "at": "0x....",
  "args": []
}
```
### Метод: `Finalize`

Finalize isn't documentated yet..

**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "Finalize",
  "at": "0x....",
  "args": []
}
```
### Метод: `Whitelisted`

Whitelisted isn't documentated yet..

**Аргументы:**

```
beneficiar : address
min        : uint256
max        : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "Whitelisted",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000
]
}
```
### Метод: `PersonalBonus`

PersonalBonus isn't documentated yet..

**Аргументы:**

```
beneficiar : address
referer    : address
bonus      : uint256
refererBon : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "PersonalBonus",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000,
    1000000000000
]
}
```
### Метод: `FundsClaimed`

FundsClaimed isn't documentated yet..

**Аргументы:**

```
owner      : address
amount     : uint256
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "FundsClaimed",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    1000000000000
]
}
```
### Метод: `Debug`

Debug isn't documentated yet..

**Аргументы:**

```
sender     : address
message    : string
```
**Пример запроса:**

```
POST /contract
{
  "contract": "Crowdsale",
  "method": "Debug",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf",
    "Sample String"
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
  "contract": "Crowdsale",
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
  "contract": "Crowdsale",
  "method": "AccessRevoke",
  "at": "0x....",
  "args": [
    "0xc569011652c8206daf01775a01e4ba0ddb25dddf"
]
}
```
## Журналы событий

### Событие: `TokenPurchase`

TokenPurchase isn't documentated yet..

**Поля:**

```
purchaser  : address [indexed]
beneficiar : address [indexed]
value      : uint256 
amount     : uint256 
```
### Событие: `HashSale`

HashSale isn't documentated yet..

**Поля:**

```
beneficiar : address [indexed]
value      : uint256 
amount     : uint256 
timestamp  : uint256 
bitcoinHas : bytes32 [indexed]
```
### Событие: `TokenSell`

TokenSell isn't documentated yet..

**Поля:**

```
beneficiar : address [indexed]
allowedTok : address [indexed]
allowedTok : uint256 
ethValue   : uint256 
shipAmount : uint256 
```
### Событие: `ShipTokens`

ShipTokens isn't documentated yet..

**Поля:**

```
owner      : address [indexed]
amount     : uint256 
```
### Событие: `Sanetize`

Sanetize isn't documentated yet..

### Событие: `Finalize`

Finalize isn't documentated yet..

### Событие: `Whitelisted`

Whitelisted isn't documentated yet..

**Поля:**

```
beneficiar : address [indexed]
min        : uint256 
max        : uint256 
```
### Событие: `PersonalBonus`

PersonalBonus isn't documentated yet..

**Поля:**

```
beneficiar : address [indexed]
referer    : address [indexed]
bonus      : uint256 
refererBon : uint256 
```
### Событие: `FundsClaimed`

FundsClaimed isn't documentated yet..

**Поля:**

```
owner      : address [indexed]
amount     : uint256 
```
### Событие: `Debug`

Debug isn't documentated yet..

**Поля:**

```
sender     : address [indexed]
message    : string  
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
