pragma solidity ^0.4.15;

// import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './UserRegistryInterface.sol';
import './MultiOwners.sol';

contract TokenInterface {
  function balanceOf(address who) public constant returns(uint);
  function transfer(address beneficiary, uint amount) public returns(bool);
  function mint(address beneficiary, uint amount) public returns(bool);
  uint public decimals;
  uint public totalSupply;
}

contract WhitelistRecord {
  bool public allow;
  uint public minAmount;
  uint public maxAmount;

  function WhitelistRecord(uint _minAmount, uint _maxAmount) public {
    allow = true;
    minAmount = _minAmount;
    maxAmount = _maxAmount;
  }
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

  //  ██████╗ ██████╗ ███╗   ██╗███████╗████████╗███████╗
  // ██╔════╝██╔═══██╗████╗  ██║██╔════╝╚══██╔══╝██╔════╝
  // ██║     ██║   ██║██╔██╗ ██║███████╗   ██║   ███████╗
  // ██║     ██║   ██║██║╚██╗██║╚════██║   ██║   ╚════██║
  // ╚██████╗╚██████╔╝██║ ╚████║███████║   ██║   ███████║
  //  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝
  uint public constant VERSION = 0x1;
  enum State {
    Setup,          // Non active yet (require to be setuped)
    Active,         // Crowdsale in a live
    Finalization,   // Finalization state (forward funds, transfer tokens (if not yet), refunding if it requires)
    History         // Close and store only historical fact of existence
  }


  //  ██████╗ ██████╗ ███╗   ██╗███████╗██╗███╗   ██╗ ██████╗ 
  // ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║████╗  ██║██╔════╝ 
  // ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██╔██╗ ██║██║  ███╗
  // ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║╚██╗██║██║   ██║
  // ╚██████╗╚██████╔╝██║ ╚████║██║     ██║██║ ╚████║╚██████╔╝
  //  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                           
  bool public isWhitelisted;            // Should be whitelisted to buy tokens
  bool public isKnownOnly;              // Should be known user to buy tokens
  bool public isAmountBonus;            // Enable amount bonuses in crowdsale?
  bool public isEarlyBonus;             // Enable early bird bonus in crowdsale?
  bool public isRefundable;             // Allow to refund money?
  bool public isTokenExcange;           // Allow to buy tokens for another tokens?
  bool public isAllowToIssue;           // Allow to issue tokens with tx hash (ex bitcoin)
  bool public isExtraDistribution;      // Should distribute extra tokens to special contract?

  // List of allowed beneficiaries
  mapping (address => WhitelistRecord) public whitelist;
  address[] public whitelisted;
  uint public whitelistedCount;

  // Known users registry (required to known rules)
  UserRegistryInterface public userRegistry;

  mapping (uint => uint) amountBonuses; // Amount bonuses
  uint[] public amountSlices;           // Key is min amount of buy
  uint public amountSlicesCount;        // 10000 - totaly free
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

  
  mapping (uint => uint) timeBonuses;   // Time bonuses
  uint[] public timeSlices;             // Same as amount but key is seconds after start
  uint public timeSlicesCount;

  TokenInterface public token;  // The token being sold
  uint public decimals;                 // Token decimals

  uint256 public startTime;             // start and end timestamps where 
  uint256 public endTime;               // investments are allowed (both inclusive)

  address public wallet;                // address where funds are collected
  uint256 public price;                 // how many token (1 * 10 ** decimals) a buyer gets per wei

  address public extraTokensHolder;     // address to mint/transfer extra tokens (0 – 0%, 1000 - 100.0%)
  uint public extraDistributionPart;    // % of extra distribution
                                        //
                                        // extraDistrubutionPart = 30
                                        // beneficiaryAmount = 70000
                                        // onePercent = beneficiaryAmount / (1000 - extraDistributionPart) = 1000
                                        // extraAmount = onePercent * extraDistrubutionPart = 1000 * 30 = 30000

  // ███████╗████████╗ █████╗ ████████╗███████╗
  // ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
  // ███████╗   ██║   ███████║   ██║   █████╗  
  // ╚════██║   ██║   ██╔══██║   ██║   ██╔══╝  
  // ███████║   ██║   ██║  ██║   ██║   ███████╗
  // ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝
  // amount of raised money in wei
  uint256 public weiRaised;
  // Current crowdsale state
  State public state;
  // Temporal balances to pull tokens after token sale
  // requires to ship required balance to smart contract
  mapping (address => uint) pullingBalances;
  mapping (address => bool) pullingAllowance;



  // ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
  // ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
  // █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
  // ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
  // ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
  // ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
                                                      
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
    // Should be whitelisted to buy tokens
    bool _isWhitelisted,
    // Should be known user to buy tokens
    bool _isKnownOnly,
    // Enable amount bonuses in crowdsale?
    bool _isAmountBonus,
    // Enable early bird bonus in crowdsale?
    bool _isEarlyBonus,
    // Allow to refund money?
    bool _isRefundable,
    // Allow to buy tokens for another tokens?
    bool _isTokenExcange,
    // Allow to issue tokens with tx hash (ex bitcoin)
    bool _allowToIssue,
    // Should mint extra tokens for future distribution?
    bool _isExtraDistribution,

    // primary values:
    uint _price,
    uint _start, uint _end,
    address _token
  ) {
    state = State.Setup;
    isWhitelisted = _isWhitelisted;
    isKnownOnly = _isKnownOnly;
    isAmountBonus = _isAmountBonus;
    isEarlyBonus = _isEarlyBonus;
    isRefundable = _isRefundable;
    isTokenExcange = _isTokenExcange;
    allowToIssue = _allowToIssue;
    isExtraDistribution = _isExtraDistribution;

    require(endTime > now);
    startTime = _start;
    endTime = _end;

    token = TokenInterface(_token);
    decimals = token.decimals();

    price = _price;
  }

  modifier inState(State _target) {
    require(state == _target);
    _;
  }

  // ███████╗███████╗████████╗██╗   ██╗██████╗     ███╗   ███╗███████╗████████╗██╗  ██╗ ██████╗ ██████╗ ███████╗
  // ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ████╗ ████║██╔════╝╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔════╝
  // ███████╗█████╗     ██║   ██║   ██║██████╔╝    ██╔████╔██║█████╗     ██║   ███████║██║   ██║██║  ██║███████╗
  // ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝     ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║   ██║██║  ██║╚════██║
  // ███████║███████╗   ██║   ╚██████╔╝██║         ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║╚██████╔╝██████╔╝███████║
  // ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝         ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
  
  function setWallet(address _wallet) 
    inState(State.Setup) onlyOwner public 
  {
    require(wallet == 0);
    wallet = _wallet;
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {
    require(address(userRegistry) == 0);
    userRegistry = UserRegistryInterface(_registry);
  }

  function setWhitelistThem(address[] _beneficiaries, uint[] _min, uint[] _max)
    inState(State.Setup) onlyOwner public
  {
    require(_beneficiaries.length > 0);
    require(_beneficiaries.length == _min.length);
    require(_max.length == _min.length);

    for (uint index = 0; index < _beneficiaries.length; index++) {
      whitelist[_beneficiaries[index]] = new WhitelistRecord(
        _min[index],
        _max[index]
      );

      whitelisted.push(_beneficiaries[index]);
      whitelistedCount++;
    }
  }

  function setAmountBonuses(uint[] _amountSlices, uint[] _prices) 
    inState(State.Setup) onlyOwner public 
  {
    // Only once in life time
    require(amountSlicesCount == 0);
    require(_amountSlices.length > 1);
    require(_prices.length == _amountSlices.length);
    uint lastSlice = 0;
    for (uint index = 0; index < _amountSlices.length; index++) {
      require(_amountSlices[index] >= lastSlice);
      lastSlice = _amountSlices[index];
      amountSlices.push(lastSlice);
      amountBonuses[lastSlice] = _prices[index];
    }
    amountSlicesCount = amountSlices.length;
  }

  function setTimeBonuses(uint[] _timeSlices, uint[] _prices) 
    inState(State.Setup) onlyOwner public 
  {
    // Only once in life time
    require(timeSlicesCount == 0);
    require(_timeSlices.length > 1);
    require(_prices.length == _timeSlices.length);
    uint lastSlice = 0;
    for (uint index = 0; index < _timeSlices.length; index++) {
      require(_timeSlices[index] >= lastSlice);
      lastSlice = _timeSlices[index];
      timeSlices.push(lastSlice);
      timeBonuses[lastSlice] = _prices[index];
    }
    timeSlicesCount = timeSlices.length;
  }
  
  function saneIt() 
    inState(State.Setup) onlyOwner public 
  {
    require(startTime <= now);
    require(endTime > now);

    require(price > 0);

    require(wallet != address(0));
    require(token != address(0));

    if (isWhitelisted) {
      require(whitelistedCount > 0);
    }

    if (isKnownOnly) {
      require(userRegistry != address(0));
    }

    if (isAmountBonus) {
      require(amountSlicesCount > 0);
    }

    if (isEarlyBonus) {
      require(timeSlicesCount > 0);
    }

    state = State.Active;
  }

  // ███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗███████╗
  // ██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔════╝
  // █████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   █████╗  
  // ██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██╔══╝  
  // ███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ███████╗
  // ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝
  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address _beneficiary) 
    inState(State.Active) public payable 
  {
    uint weiAmount = msg.value;
    uint beneficiaryTokens;
    uint extraTokens;

    (beneficiaryTokens, extraTokens) = calculateAmount(weiAmount, token.totalSupply()); 
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount            // calculate token amount to be created
      .mul(10 ** tokenDecimals)
      .div(price);

    uint 

    require(validPurchase(_beneficiary, 
                          weiAmount, 
                          tokens));       // Check if current purchase is valid

    weiRaised = weiRaised.add(weiAmount); // update state (wei amount)
    shipTokens(_beneficiary, tokens);     // ship tokens to beneficiary
    TokenPurchase(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  weiAmount, 
                  tokens);

    if (isExtraMinting) {                 // calculate and
      shipExtraTokens(tokens);            // ship extra tokens (team, foundation and etc)
      ExtraTokens(msg.sender,             // Fire extra distribution event
                  extraTokensHolder, 
                  tokens);
    }

    forwardFunds();                       // Forward funds
  }

  function buyWithBitcoin(address _beneficiary, uint _amount, bytes32 _hash) 
    inState(State.Active) onlyOwner public 
  {
    uint value = _amount.mul(price).div(10 ** tokenDecimals);
    weiRaised = weiRaised.add(value);
    token.mint(_beneficiary, _amount);
    BitcoinSale(_beneficiary, value, _amount, _hash);
    TokenPurchase(_beneficiary, _beneficiary, value, _amount);
  }

  function shipTokens(address _beneficiary, uint _amount) 
    inState(Active) internal 
  {
    if (isMintingShipment) {
      token.mint(_beneficiary, _amount);
    } else {
      token.transferFrom(address(this), _beneficiary, _amount);
    }
  }

  function shipExtraTokens(uint _amount) 
    inState(Active) internal
  {
    uint extraAmount = _amount.mul(10 ** tokenDecimals).div();
    shipTokens(extraTokensHolder, amount);
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