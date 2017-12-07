pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import './UserRegistryInterface.sol';
import './MultiOwners.sol';
import './TokenRecipient.sol';

contract TokenInterface is ERC20 {
  string public name;
  string public symbol;
  uint public decimals;
}

contract MintableTokenInterface is TokenInterface {
  address public owner;
  function mint(address beneficiary, uint amount) public returns(bool);
}

contract PersonalBonusRecord {
  address public referalAddress;
  uint public bonus;
  uint public referalBonus;

  function PersonalBonusRecord(uint _bonus, address _referal, uint _referalBonus) public {
    referalAddress = _referal;
    referalBonus = _referalBonus;
    bonus = _bonus;
  }
}

contract WhitelistRecord {
  bool public allow;
  uint public min;
  uint public max;

  function WhitelistRecord(uint _minAmount, uint _maxAmount) public {
    allow = true;
    min = _minAmount;
    max = _maxAmount;
  }
}

/**
 * Complex crowdsale with huge posibilities
 * Core features:
 * - Whitelisting
 *  - Min\max invest amounts
 * - Only known users
 * - Buy with allowed tokens
 *  - Oraclize based pairs (ETH to TOKEN)
 * - Pulling tokens (temporal balance inside sale)
 * - Revert\refund
 * - Personal bonuses
 * - Amount bonuses
 * - Total supply bonuses
 * - Early birds bonuses
 * - Extra distribution (team, foundation and also)
 * - Soft and hard caps
 * - Finalization logics
**/
contract Crowdsale is MultiOwners, TokenRecipient {
  using SafeMath for uint;

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
    Success,        // Finalization state (forward funds, transfer tokens (if not yet), refunding via owner if it requires (KYC))
    Refund,         // Unsucceseful crowdsale (refund ether)
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
  bool public isTokenExchange;          // Allow to buy tokens for another tokens?
  bool public isAllowToIssue;           // Allow to issue tokens with tx hash (ex bitcoin)
  bool public isExtraDistribution;      // Should distribute extra tokens to special contract?
  bool public isTransferShipment;       // Will ship token via minting?
  bool public isCappedInEther;          // Should be capped in Ether 
  bool public isPullingTokens;          // Should beneficiaries pull their tokens?
  bool public isPersonalBonuses;        // Should check personal beneficiary bonus?

  // List of allowed beneficiaries
  mapping (address => WhitelistRecord) public whitelist;
  address[] public whitelisted;
  uint public whitelistedCount;

  // Known users registry (required to known rules)
  UserRegistryInterface public userRegistry;

  mapping (uint => uint) public amountBonuses; // Amount bonuses
  uint[] public amountSlices;           // Key is min amount of buy
  uint public amountSlicesCount;        // 10000 - totaly free
                                        //  5000 - 50% sale
                                        //     0 - 100% (no bonus)
  mapping (uint => uint) public timeBonuses; // Time bonuses
  uint[] public timeSlices;             // Same as amount but key is seconds after start
  uint public timeSlicesCount;

  mapping (address => PersonalBonusRecord) public personalBonuses; 
                                        // personal bonuses
  MintableTokenInterface public token;  // The token being sold
  uint public tokenDecimals;            // Token decimals

  mapping (address => TokenInterface) public allowedTokens;
                                        // allowed tokens list
  mapping (address => uint) public tokensValues;
                                        // TOKEN to ETH conversion rate (oraclized)
  uint public startTime;                // start and end timestamps where 
  uint public endTime;                  // investments are allowed (both inclusive)
  address public wallet;                // address where funds are collected
  uint public price;                    // how many token (1 * 10 ** decimals) a buyer gets per wei
  uint public hardCap;
  uint public softCap;

  address public extraTokensHolder;     // address to mint/transfer extra tokens (0 – 0%, 1000 - 100.0%)
  uint public extraDistributionPart;    // % of extra distribution

  // ███████╗████████╗ █████╗ ████████╗███████╗
  // ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
  // ███████╗   ██║   ███████║   ██║   █████╗  
  // ╚════██║   ██║   ██╔══██║   ██║   ██╔══╝  
  // ███████║   ██║   ██║  ██║   ██║   ███████╗
  // ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝
  // amount of raised money in wei
  uint public weiRaised;
  // Current crowdsale state
  State public state;
  // Temporal balances to pull tokens after token sale
  // requires to ship required balance to smart contract
  mapping (address => uint) public beneficiaryInvest;
  uint public temporalTotalSupply;

  mapping (address => uint) public weiDeposit;
  mapping (address => mapping(address => uint)) public altDeposit;

  mapping (address => bool) public claimRefundAllowance;

  modifier inState(State _target) {
    require(state == _target);
    _;
  }

  // ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
  // ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
  // █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
  // ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
  // ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
  // ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝
  
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);
  event HashSale(address indexed beneficiary, uint value, uint amount, uint timestamp, bytes32 indexed bitcoinHash);
  event TokenSell(address indexed beneficiary, address indexed allowedToken, uint allowedTokenValue, uint ethValue, uint shipAmount);
  event ShipTokens(address indexed owner, uint amount);

  // event SetToken(address indexed owner, address previousToken, address indexed nextToken);
  // event SetStartTime(address indexed owner, uint previousStartTime, uint nextStartTime);
  // event SetEndTime(address indexed owner, uint previousEndTime, uint nextEndTime);
  // event SetExtraTokensHolder(address indexed owner, address previousExtraTokensHolder, address nextExtraTokensHolder);
  // event SetExtraTokensPart(address indexed owner, uint previousExtraTokensPart, uint nextExtraTokensPart);
  // event SetHardCap(address indexed owner, uint previousHardCap, uint nextHardCap);
  // event SetSoftCap(address indexed owner, uint previousSoftCap, uint nextSoftCap);
  // event SetPrice(address indexed owner, uint previousPrice, uint nextPrice);
  // event SetWallet(address indexed owner, address previousWallet, address nextWallet);
  // event SetRegistry(address indexed owner, address previousRegistry, address nextRegistry);
  // event AddAmountSlice(address indexed owner, uint slice, uint bonus);
  // event AddTimeSlice(address indexed owner, uint slice, uint bonus);


  // ███████╗███████╗████████╗██╗   ██╗██████╗     ███╗   ███╗███████╗████████╗██╗  ██╗ ██████╗ ██████╗ ███████╗
  // ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ████╗ ████║██╔════╝╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔════╝
  // ███████╗█████╗     ██║   ██║   ██║██████╔╝    ██╔████╔██║█████╗     ██║   ███████║██║   ██║██║  ██║███████╗
  // ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝     ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║██║   ██║██║  ██║╚════██║
  // ███████║███████╗   ██║   ╚██████╔╝██║         ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║╚██████╔╝██████╔╝███████║
  // ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝         ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝

  function setFlags(
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
    bool _isTokenExchange,
    // Allow to issue tokens with tx hash (ex bitcoin)
    bool _isAllowToIssue,
    // Should mint extra tokens for future distribution?
    bool _isExtraDistribution,
    // Will ship token via minting? 
    bool _isMintingShipment,
    // Should be capped in ether
    bool _isCappedInEther,
    // Should beneficiaries pull their tokens? 
    bool _isPullingTokens,
    // Should check personal bonus?
    bool _isPersonalBonuses)
    inState(State.Setup) onlyOwner public 
  {
    isWhitelisted = _isWhitelisted;
    isKnownOnly = _isKnownOnly;
    isAmountBonus = _isAmountBonus;
    isEarlyBonus = _isEarlyBonus;
    isRefundable = _isRefundable;
    isTokenExchange = _isTokenExchange;
    isAllowToIssue = _isAllowToIssue;
    isExtraDistribution = _isExtraDistribution;
    isTransferShipment = _isMintingShipment;
    isCappedInEther = _isCappedInEther;
    isPullingTokens = isRefundable || _isPullingTokens;
    isPersonalBonuses = _isPersonalBonuses;
  }

  function setPrice(uint _price)
    inState(State.Setup) onlyOwner public
  {
    require(_price > 0);
    // SetPrice(msg.sender, price, _price);
    price = _price;
    Debug(msg.sender, appendUintToString("New Price: ", _price));
  }

  function setSoftHardCaps(uint _softCap, uint _hardCap)
    inState(State.Setup) onlyOwner public
  {
    // SetSoftCap(msg.sender, softCap, _softCap);
    // SetHardCap(msg.sender, hardCap, _hardCap);
    hardCap = _hardCap;
    softCap = _softCap;
    Debug(msg.sender, appendUintToString("Soft Cap: ", _softCap));
    Debug(msg.sender, appendUintToString("Hard Cap: ", _hardCap));
  }

  function setTime(uint _start, uint _end)
    inState(State.Setup) onlyOwner public 
  {
    require(_start < _end);
    require(_end > block.timestamp);

    // SetStartTime(msg.sender, startTime, _start);
    // SetEndTime(msg.sender, endTime, _end);
    startTime = _start;
    endTime = _end;
    Debug(msg.sender, appendUintToString("Start Time: ", _start));
    Debug(msg.sender, appendUintToString("End Time: ", _end));
  }

  function setToken(address _tokenAddress) 
    inState(State.Setup) onlyOwner public
  {
    // SetToken(msg.sender, token, _tokenAddress);
    token = MintableTokenInterface(_tokenAddress);
    tokenDecimals = token.decimals();
    Debug(msg.sender, "New Token");
    Debug(msg.sender, addressToString(_tokenAddress));
  }

  function setWallet(address _wallet) 
    inState(State.Setup) onlyOwner public 
  {
    require(_wallet != address(0));
    // SetWallet(msg.sender, wallet, _wallet);
    wallet = _wallet;
    Debug(msg.sender, "New Wallet");
    Debug(msg.sender, addressToString(_wallet));
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {
    require(_registry != address(0));
    // SetRegistry(msg.sender, userRegistry, _registry);
    userRegistry = UserRegistryInterface(_registry);
    Debug(msg.sender, "New Registry");
    Debug(msg.sender, addressToString(_registry));
  }

  function setExtraDistribution(address _holder, uint _extraPart) 
    inState(State.Setup) onlyOwner public
  {
    require(_holder != address(0));
    // SetExtraTokensHolder(msg.sender, extraTokensHolder, _holder);
    // SetExtraTokensPart(msg.sender, extraDistributionPart, _extraPart);
    extraTokensHolder = _holder;
    extraDistributionPart = _extraPart;
    Debug(msg.sender, "New Extra Tokens Holder");
    Debug(msg.sender, addressToString(_holder));
    Debug(msg.sender, appendUintToString("New Extra Tokens Part: ", _extraPart));
  }

  function setAmountBonuses(uint[] _amountSlices, uint[] _prices) 
    inState(State.Setup) onlyOwner public 
  {
    require(_amountSlices.length > 1);
    require(_prices.length == _amountSlices.length);
    uint lastSlice = 0;
    for (uint index = 0; index < _amountSlices.length; index++) {
      require(_amountSlices[index] >= lastSlice);
      lastSlice = _amountSlices[index];
      amountSlices.push(lastSlice);
      amountBonuses[lastSlice] = _prices[index];

      // AddAmountSlice(msg.sender, _amountSlices[index], _prices[index]);
      Debug(msg.sender, appendUintToString("Add amount bonus: ", _prices[index]));
      Debug(msg.sender, appendUintToString("At slice: ", _amountSlices[index]));
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
      require(_timeSlices[index] > lastSlice);
      lastSlice = _timeSlices[index];
      timeSlices.push(lastSlice);
      timeBonuses[lastSlice] = _prices[index];
      // AddTimeSlice(msg.sender, _timeSlices[index], _prices[index]);
      Debug(msg.sender, appendUintToString("Add time bonus: ", _prices[index]));
      Debug(msg.sender, appendUintToString("At slice: ", _timeSlices[index]));
    }
    timeSlicesCount = timeSlices.length;
  }
  
  function setTokenExcange(address _token, uint _value)
    inState(State.Setup) onlyOwner public
  {
    allowedTokens[_token] = TokenInterface(_token);
    updateTokenValue(_token, _value); 
  }

  function saneIt() 
    inState(State.Setup) onlyOwner public 
  {
    require(startTime < endTime);
    require(endTime > now);

    require(price > 0);

    require(wallet != address(0));
    require(token != address(0));

    if (isKnownOnly) {
      require(userRegistry != address(0));
    }

    if (isAmountBonus) {
      require(amountSlicesCount > 0);
    }

    if (isEarlyBonus) {
      require(timeSlicesCount > 0);
    }

    if (isExtraDistribution) {
      require(extraTokensHolder != address(0));
    }

    if (isTransferShipment) {
      require(token.balanceOf(address(this)) >= hardCap);
    } else {
      require(token.owner() == address(this));
    }

    state = State.Active;

    Debug(msg.sender, "Sane it");
  }

  // ███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗███████╗
  // ██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔════╝
  // █████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   █████╗  
  // ██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██╔══╝  
  // ███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ███████╗
  // ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝

  function calculateEthAmount(
    address _beneficiary,
    uint _weiAmount,
    uint _time,
    uint _totalSupply
  // TODO: Debug
  ) public constant returns(
  // ) public returns(
    uint calculatedTotal, 
    uint calculatedBeneficiary, 
    uint calculatedExtra, 
    uint calculatedReferal, 
    address referalAddress) 
  {
    _totalSupply;
    uint bonus = 0;

    if (_time < startTime || _time > endTime) {
      return (0, 0, 0, 0, address(0));
    } else {
      if (isAmountBonus) {
        bonus = bonus.add(calculateAmountBonus(_weiAmount));
      }

      if (isEarlyBonus) {
        bonus = bonus.add(calculateTimeBonus(_time - startTime));
      }

      if (isPersonalBonuses && personalBonuses[_beneficiary].bonus() > 0) {
        bonus = bonus.add(personalBonuses[_beneficiary].bonus());
      }
    }

    calculatedBeneficiary = _weiAmount.mul(10 ** tokenDecimals).div(price);
    if (bonus > 0) {
      calculatedBeneficiary = calculatedBeneficiary.add(calculatedBeneficiary.mul(bonus).div(10000));
    }

    if (isExtraDistribution) {
      calculatedExtra = calculatedBeneficiary.mul(extraDistributionPart).div(10000);
    }

    if (isPersonalBonuses && 
        personalBonuses[_beneficiary].referalAddress() != address(0) && 
        personalBonuses[_beneficiary].referalBonus() > 0) 
    {
      calculatedReferal = calculatedBeneficiary.mul(personalBonuses[_beneficiary].referalBonus()).div(10000);
      referalAddress = personalBonuses[_beneficiary].referalAddress();
    }

    calculatedTotal = calculatedBeneficiary.add(calculatedExtra).add(calculatedReferal);
  }

  function calculateAmountBonus(uint _changeAmount) public constant returns(uint) {
    uint bonus = 0;
    for (uint index = 0; index < amountSlices.length; index++) {
      if(amountSlices[index] > _changeAmount) {
        break;
      }

      bonus = amountBonuses[amountSlices[index]];
    }
    return bonus;
  }

  // TODO: Debug
  function calculateTimeBonus(uint _at) public constant returns(uint) {
  // function calculateTimeBonus(uint _at) public returns(uint) {
    uint bonus = 0;
    // Debug(msg.sender, appendUintToString("Calculate bonus at: ", _at));
    for (uint index = 0; index < timeSlices.length; index++) {
      // Debug(msg.sender, appendUintToString("Time Slice: ", timeSlices[index]));
      if(timeSlices[index] < _at) {
        break;
      }
      bonus = timeBonuses[timeSlices[index]];
      // Debug(msg.sender, appendUintToString("Fit to bonus: ", bonus));
    }

    return bonus;
  }

  function validPurchase(
    address _beneficiary, 
    uint _weiAmount, 
    uint _tokenAmount,
    uint _extraAmount,
    uint _totalAmount) 
  public constant returns(bool) 
  {
    _extraAmount;
    _weiAmount;

    if (isKnownOnly && !userRegistry.knownAddress(_beneficiary)) {
      return false;
    }

    uint finalBeneficiaryInvest = beneficiaryInvest[_beneficiary].add(_weiAmount);
    uint finalTotalSupply = temporalTotalSupply.add(_totalAmount);

    if (isWhitelisted) {
      WhitelistRecord record = whitelist[_beneficiary];
      if (!record.allow() || 
          record.min() > finalBeneficiaryInvest ||
          record.max() < finalBeneficiaryInvest) {
        return false;
      }
    }

    if (isCappedInEther) {
      if (weiRaised.add(_weiAmount) > hardCap) {
        return false;
      }
    } else {
      if (finalTotalSupply > hardCap) {
        return false;
      }
    }

    return true;
  }

                                                                                        
  function updateTokenValue(address _token, uint _value) onlyOwner public {
    tokensValues[_token] = _value;
  }

  //  ██████╗ ██╗   ██╗████████╗███████╗██╗██████╗ ███████╗
  // ██╔═══██╗██║   ██║╚══██╔══╝██╔════╝██║██╔══██╗██╔════╝
  // ██║   ██║██║   ██║   ██║   ███████╗██║██║  ██║█████╗  
  // ██║   ██║██║   ██║   ██║   ╚════██║██║██║  ██║██╔══╝  
  // ╚██████╔╝╚██████╔╝   ██║   ███████║██║██████╔╝███████╗
  //  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝╚═════╝ ╚══════╝
  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address _beneficiary) inState(State.Active) public payable {
    Debug(msg.sender, "Start buy tokens");

    uint shipAmount = sellTokens(_beneficiary, msg.value);
    require(shipAmount > 0);
    forwardEther();
  }

  function buyWithHash(address _beneficiary, uint _value, uint _timestamp, bytes32 _hash) 
    inState(State.Active) onlyOwner public 
  {
    uint shipAmount = sellTokens(_beneficiary, _value);
    require(shipAmount > 0);
    HashSale(_beneficiary, _value, shipAmount, _timestamp, _hash);
  }

  function receiveApproval(address _from, 
                           uint256 _value, 
                           address _token, 
                           bytes _extraData) public {
    _extraData;
    require(address(allowedTokens[_token]) != address(0));
    uint weiValue = _value.mul(tokensValues[_token]).div(10 ** allowedTokens[_token].decimals());
    uint shipAmount = sellTokens(_from, weiValue);
    require(shipAmount > 0);
    TokenSell(_from, _token, _value, weiValue, shipAmount);
  }

  function refund(address _beneficiary) onlyOwner public {
    require(isRefundable);
    claimRefundAllowance[_beneficiary] = true;
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund(address _beneficiary) public returns(bool) {
    require(isRefundable);
    require(claimRefundAllowance[_beneficiary] || state == State.Refund);

    // refund all deposited wei
    _beneficiary.transfer(weiDeposit[_beneficiary]);

    // refund all deposited alt tokens
    if (isTokenExchange) {
      // token.transfer(_beneficiary, altDeposit[_beneficiary]);
    }
  }

  function addToWhitelist(address _beneficiary, uint _min, uint _max) onlyOwner public
  {
    require(_beneficiary != address(0));
    require(_min <= _max);

    if (_max == 0) {
      _max = 10 ** 40; // should be huge enough? :0
    }

    whitelist[_beneficiary] = new WhitelistRecord(_min, _max);
    whitelisted.push(_beneficiary);
    whitelistedCount++;
  }
  
  function setPersonalBonus(
    address _beneficiary, 
    uint _bonus, 
    address _referalAddress, 
    uint _referalBonus) onlyOwner public {
    personalBonuses[_beneficiary] = new PersonalBonusRecord(
      _bonus,
      _referalAddress,
      _referalBonus
    ); 
  }

  // ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗     ███████╗
  // ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║     ██╔════╝
  // ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║     ███████╗
  // ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║     ╚════██║
  // ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗███████║
  // ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝
  // low level token purchase function
  function sellTokens(address _beneficiary, uint _weiAmount) 
    inState(State.Active) internal returns(uint)
  {
    Debug(msg.sender, "Start sell tokens");
    uint beneficiaryTokens;
    uint extraTokens;
    uint totalTokens;
    uint referalTokens;
    address referalAddress;
    (totalTokens, beneficiaryTokens, extraTokens, referalTokens, referalAddress) = calculateEthAmount(
      _beneficiary, 
      _weiAmount, 
      block.timestamp, 
      token.totalSupply());
      
    Debug(msg.sender, "Calculate amount");
    Debug(msg.sender, appendUintToString("Total: ", totalTokens));
    Debug(msg.sender, appendUintToString("Beneficiary: ", beneficiaryTokens));

    require(validPurchase(_beneficiary,   // Check if current purchase is valid
                          _weiAmount, 
                          beneficiaryTokens,
                          extraTokens,
                          totalTokens));

    weiRaised = weiRaised.add(_weiAmount); // update state (wei amount)
    beneficiaryInvest[_beneficiary] = beneficiaryInvest[_beneficiary].add(_weiAmount);
    shipTokens(_beneficiary, beneficiaryTokens);     // ship tokens to beneficiary
    TokenPurchase(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  _weiAmount, 
                  beneficiaryTokens);
    ShipTokens(_beneficiary, beneficiaryTokens);

    if (isExtraDistribution) {            // calculate and
      shipTokens(extraTokensHolder,       // ship extra tokens (team, foundation and etc)
                 extraTokens);
      ShipTokens(extraTokensHolder, extraTokens);
    }

    if (isPersonalBonuses) {
      PersonalBonusRecord record = personalBonuses[_beneficiary];
      if (record.referalAddress() != address(0) && record.referalBonus() > 0) {
        shipTokens(record.referalAddress(), referalTokens);
      }
    }

    return beneficiaryTokens;
  }

  function shipTokens(address _beneficiary, uint _amount) 
    inState(State.Active) internal 
  {
    if (!isPullingTokens) {
      if (isTransferShipment) {
        token.transferFrom(address(this), _beneficiary, _amount);
      } else {
        token.mint(_beneficiary, _amount);
      }
    }

    temporalTotalSupply = temporalTotalSupply.add(_amount);
  }

  function forwardEther() internal {
    if (isRefundable) {
      weiDeposit[msg.sender] = msg.value;
    } else {
      wallet.transfer(msg.value);
    }
  }

  function forwardTokens(address _beneficiary, address _tokenAddress, uint _amount) internal {
    TokenInterface allowedToken = allowedTokens[_tokenAddress];

    if (isRefundable) {
      allowedToken.transferFrom(_beneficiary, address(this), _amount);
      altDeposit[_tokenAddress][_beneficiary] = _amount;
    } else {
      allowedToken.transferFrom(_beneficiary, wallet, _amount);
    }
  }


  // ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
  // ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
  // ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
  // ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
  // ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
  // ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 
  event Debug(address indexed sender, string message);
  
  function uintToString(uint v) public pure returns (string str) {
    uint maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
      uint remainder = v % 10;
      v = v / 10;
      reversed[i++] = byte(48 + remainder);
    }
    bytes memory s = new bytes(i);
    for (uint j = 0; j < i; j++) {
      s[j] = reversed[i - 1 - j];
    }
    str = string(s);
  }

  function addressToString(address x) returns (string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
      byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
      byte hi = byte(uint8(b) / 16);
      byte lo = byte(uint8(b) - 16 * uint8(hi));
      s[2*i] = char(hi);
      s[2*i+1] = char(lo);            
    }
    return string(s);
  }

  function char(byte b) returns (byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
  }

  function appendUintToString(string inStr, uint v) public pure returns (string str) {
    uint maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
      uint remainder = v % 10;
      v = v / 10;
      reversed[i++] = byte(48 + remainder);
    }
    bytes memory inStrb = bytes(inStr);
    bytes memory s = new bytes(inStrb.length + i);
    uint j;
    for (j = 0; j < inStrb.length; j++) {
      s[j] = inStrb[j];
    }
    for (j = 0; j < i; j++) {
      s[j + inStrb.length] = reversed[i - 1 - j];
    }
    str = string(s);
  }
}