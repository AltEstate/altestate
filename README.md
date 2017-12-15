Alt.Estate Smart-contracts
===

Официальные смарт-контракты проекта Alt.Estate

## Структура

* *Base*
  * `DefaultToken` – базовый, абстрактный токен. Реализует стандарт ERC20 и функционал "чеканки" токенов – Minting
    * `ApproveAndCall` – интерфейс перевода токенов через `approve` на адресс другого смарт-контракта
      * `TokenRecipient` – интерфейс контракта ожидающего перевод токенов через `ApproveAndCall`
    * `KnownHolderToken` – правило ограничивающее перевод для непроверенных, но известных держателей
    * `NamedToken` – описание токена: `name`, `ticker`, `decimals`
  * `Crowdsale` – конструктор смарт-контрактов краудсейла
  * `UserRegistryInterface` – интерфейс реестра пользователей платформы
* `AltCrowdsale` – контракты краудсейла AltToken'а.
  * `AltCrowdsalePhaseOne` – первый раунд краудсейла – PreICO
  * `AltCrowdsalePhaseTwo` – второй раунд краудсейла – ICO
* `AltToken`
* `SqmCrowdsale`
* `SqmToken`
* `UserRegistry`