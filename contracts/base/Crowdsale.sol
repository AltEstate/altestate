pragma solidity ^0.4.15;

// import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './UserRegistryInterface.sol';
import './MultiOwners.sol';

contract MintableTokenInterface {
  function mint(address beneficiary, uint amount) public returns(bool);
  uint public decimals;
}

/**
 * Complex crowdsale with huge posibilities
 * Core features:
 * - Whitelisting
 * - Min\max invest amounts
 * - Buy with allowed tokens
 * - Oraclize based pairs (ETH to TOKEN)
 * - Pulling tokens (temporal balance inside sale)
 * - Revert\refund
 * - Amount bonuses
 * - Early birds bonuses
 * - Extra distribution (team, foundation and also)
 * - Finalization logics
**/
contract Crowdsale is MultiOwners {
  using SafeMath for uint256;

  enum State {
    Setup,          // Non active yet (require to be setuped)
    Active,         // Crowdsale in a live
    Finalization,   // Finalization state (forward funds, transfer tokens (if not yet), refunding if it requires)
    History         // Close and store only historical fact of existence
  }

  // Current crowdsale state
  State public state;

  // Should be whitelisted to buy tokens
  bool public isWhitelisted;
  // Should be known user to buy tokens
  bool public isKnownOnly;
  // Enable amount bonuses in crowdsale?
  bool public isAmountBonus;
  // Enable early bird bonus in crowdsale?
  bool public isEarlyBonus;
  // Allow to refund money?
  bool public isRefundable;
  // Allow to buy tokens for another tokens?
  bool public isTokenExcange;

  // List of allowed beneficiaries
  mapping (address => bool) whitelist;  
  // Known users registry (required to known rules)
  UserRegistryInterface public userRegistry;

  // Amount bonuses
  // Key is min amount of buy
  // 10000 - totaly free
  //  5000 - 50% sale
  //     0 - 100% (no bonus)
  //
  // discont = 10000 - bonus
  // priceWithBonus = price * discount / 10000
  // 
  // price = 100
  // bonus = 2500
  // discount = 7500
  // priceWithBonus = 100 * 7500 / 10000 = 750000 / 10000 = 75
  mapping (uint => uint) amountBonuses;
  uint[] public amountSlices;

  // Time bonuses
  // Same as amount but key is seconds after start
  mapping (uint => uint) timeBonuses;
  uint[] public timeSlices;

  // Temporal balances to pull tokens after token sale
  // requires to ship required balance to smart contract
  mapping (address => uint) pullingBalances;
  mapping (address => bool) pullingAllowance;

  // The token being sold
  MintableTokenInterface public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public price;

  // amount of raised money in wei
  uint256 public weiRaised;

  bool public isSane;
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event BitcoinSale(address indexed beneficiary, uint value, uint amount, bytes32 indexed bitcoinHash);

  function Crowdsale(
    uint256 _startTime, 
    uint256 _endTime, 
    uint256 _price, 
    address _token, 
    address _wallet,
    address _registry) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_price > 0);
    require(_wallet != address(0));
    require(_token != 0);
    require(_registry != 0);

    userRegistry = UserRegistryInterface(_registry);
    token = MintableTokenInterface(_token);
    startTime = _startTime;
    endTime = _endTime;
    price = _price;
    wallet = _wallet;

    isSane = true;
  }

  // function setTime(uint _life) onlyOwner public {
  //   require(startTime == 0);
  //   require(endTime == 0);
  //   startTime = now;
  //   endTime = startTime + _life;
  // }
  
  // function setPrice(uint _price) onlyOwner public {
  //   require(price == 0);
  //   price = _price;
  // }
  
  // function setWallet(address _wallet) onlyOwner public {
  //   require(wallet == 0);
  //   wallet = _wallet;
  // }
  
  // function setRegistry(address _registry) onlyOwner public {
  //   require(address(userRegistry) == 0);
  //   userRegistry = UserRegistryInterface(_registry);
  // }
  
  // function setToken(address _token) onlyOwner public {
  //   require(address(token) == 0);
  //   token = MintableTokenInterface(_token);
  // }
  
  // function saneIt() onlyOwner public {
  //   require(!isSane);
  //   require(startTime <= now);
  //   require(endTime > now);
  //   require(price > 0);
  //   require(wallet != address(0));
  //   require(token != address(0));
  //   require(userRegistry != address(0));
  //   isSane = true;
  // }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address _beneficiary) public payable {
    require(isSane);
    require(_beneficiary != address(0));
    require(validPurchase());
    require(userRegistry.knownAddress(_beneficiary));

    uint256 weiAmount = msg.value;

    uint decimals = token.decimals();

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(10 ** decimals).div(price);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function buyWithBitcoin(address _beneficiary, uint _amount, bytes32 _hash) onlyOwner public {
    require(isSane);
    require(userRegistry.knownAddress(_beneficiary));
    uint decimals = token.decimals();
    uint value = _amount.mul(price).div(10 ** decimals);
    weiRaised = weiRaised.add(value);
    token.mint(_beneficiary, _amount);
    BitcoinSale(_beneficiary, value, _amount, _hash);
    TokenPurchase(_beneficiary, _beneficiary, value, _amount);

  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  // function () public view returns (bool) {
    // return now > endTime;
  // }
}