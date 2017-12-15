pragma solidity ^0.4.18;

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
  address public refererAddress;
  uint public bonus;
  uint public refererBonus;

  function PersonalBonusRecord(uint _bonus, address _referer, uint _refererBonus) public {
    refererAddress = _referer;
    refererBonus = _refererBonus;
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
    Claim,          // Claim funds by owner
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
  bool public isPersonalBonuses;        // Should check personal beneficiary bonus?
  bool public isAllowClaimBeforeFinalization;
                                        // Should allow to claim funds before finalization?

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
  uint public soldTokens;

  mapping (address => uint) public weiDeposit;
  mapping (address => mapping(address => uint)) public altDeposit;

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
  
  event EthBuy(
    address indexed purchaser, 
    address indexed beneficiary, 
    uint value, 
    uint amount);
  event HashBuy(
    address indexed beneficiary, 
    uint value, 
    uint amount, 
    uint timestamp, 
    bytes32 indexed bitcoinHash);
  event AltBuy(
    address indexed beneficiary, 
    address indexed allowedToken, 
    uint allowedTokenValue, 
    uint ethValue, 
    uint shipAmount);
    
  event ShipTokens(address indexed owner, uint amount);

  event Sanetize();
  event Finalize();

  event Whitelisted(address indexed beneficiary, uint min, uint max);
  event PersonalBonus(address indexed beneficiary, address indexed referer, uint bonus, uint refererBonus);
  event FundsClaimed(address indexed owner, uint amount);


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
    bool _isPersonalBonuses,
    // Should allow to claim funds before finalization?
    bool _isAllowClaimBeforeFinalization)
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
    isPersonalBonuses = _isPersonalBonuses;
    isAllowClaimBeforeFinalization = _isAllowClaimBeforeFinalization;
  }

  function setPrice(uint _price)
    inState(State.Setup) onlyOwner public
  {
    require(_price > 0);
    // SetPrice(msg.sender, price, _price);
    price = _price;
  }

  function setSoftHardCaps(uint _softCap, uint _hardCap)
    inState(State.Setup) onlyOwner public
  {
    // SetSoftCap(msg.sender, softCap, _softCap);
    // SetHardCap(msg.sender, hardCap, _hardCap);
    hardCap = _hardCap;
    softCap = _softCap;
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
  }

  function setToken(address _tokenAddress) 
    inState(State.Setup) onlyOwner public
  {
    // SetToken(msg.sender, token, _tokenAddress);
    token = MintableTokenInterface(_tokenAddress);
    tokenDecimals = token.decimals();
  }

  function setWallet(address _wallet) 
    inState(State.Setup) onlyOwner public 
  {
    require(_wallet != address(0));
    // SetWallet(msg.sender, wallet, _wallet);
    wallet = _wallet;
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {
    require(_registry != address(0));
    // SetRegistry(msg.sender, userRegistry, _registry);
    userRegistry = UserRegistryInterface(_registry);
  }

  function setExtraDistribution(address _holder, uint _extraPart) 
    inState(State.Setup) onlyOwner public
  {
    require(_holder != address(0));
    // SetExtraTokensHolder(msg.sender, extraTokensHolder, _holder);
    // SetExtraTokensPart(msg.sender, extraDistributionPart, _extraPart);
    extraTokensHolder = _holder;
    extraDistributionPart = _extraPart;
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
  }

  function finalizeIt() inState(State.Active) onlyOwner public {
    require(ended());

    if (success()) {
      state = State.Claim;
    } else {
      state = State.Refund;
    }
  }

  function historyIt() inState(State.Claim) onlyOwner public {
    require(address(this).balance == 0);
    state = State.History;
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
  ) public constant returns(
    uint calculatedTotal, 
    uint calculatedBeneficiary, 
    uint calculatedExtra, 
    uint calculatedreferer, 
    address refererAddress) 
  {
    _totalSupply;
    uint bonus = 0;
    
    if (isAmountBonus) {
      bonus = bonus.add(calculateAmountBonus(_weiAmount));
    }

    if (isEarlyBonus) {
      bonus = bonus.add(calculateTimeBonus(_time.sub(startTime)));
    }

    if (isPersonalBonuses && personalBonuses[_beneficiary].bonus() > 0) {
      bonus = bonus.add(personalBonuses[_beneficiary].bonus());
    }

    calculatedBeneficiary = _weiAmount.mul(10 ** tokenDecimals).div(price);
    if (bonus > 0) {
      calculatedBeneficiary = calculatedBeneficiary.add(calculatedBeneficiary.mul(bonus).div(10000));
    }

    if (isExtraDistribution) {
      calculatedExtra = calculatedBeneficiary.mul(extraDistributionPart).div(10000);
    }

    if (isPersonalBonuses && 
        personalBonuses[_beneficiary].refererAddress() != address(0) && 
        personalBonuses[_beneficiary].refererBonus() > 0) 
    {
      calculatedreferer = calculatedBeneficiary.mul(personalBonuses[_beneficiary].refererBonus()).div(10000);
      refererAddress = personalBonuses[_beneficiary].refererAddress();
    }

    calculatedTotal = calculatedBeneficiary.add(calculatedExtra).add(calculatedreferer);
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

  function calculateTimeBonus(uint _at) public constant returns(uint) {
    uint bonus = 0;
    for (uint index = timeSlices.length; index > 0; index--) {
      if(timeSlices[index - 1] < _at) {
        break;
      }
      bonus = timeBonuses[timeSlices[index - 1]];
    }

    return bonus;
  }

  function validPurchase(
    address _beneficiary, 
    uint _weiAmount, 
    uint _tokenAmount,
    uint _extraAmount,
    uint _totalAmount,
    uint _time) 
  public constant returns(bool) 
  {
    _tokenAmount;
    _extraAmount;
    _weiAmount;

    if (_time < startTime || _time > endTime) {
      return false;
    }

    if (isKnownOnly && !userRegistry.knownAddress(_beneficiary)) {
      return false;
    }

    uint finalBeneficiaryInvest = beneficiaryInvest[_beneficiary].add(_weiAmount);
    uint finalTotalSupply = soldTokens.add(_totalAmount);

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
    require(address(allowedTokens[_token]) != address(0x0));
    tokensValues[_token] = _value;
  }

  // ██████╗ ███████╗ █████╗ ██████╗ 
  // ██╔══██╗██╔════╝██╔══██╗██╔══██╗
  // ██████╔╝█████╗  ███████║██║  ██║
  // ██╔══██╗██╔══╝  ██╔══██║██║  ██║
  // ██║  ██║███████╗██║  ██║██████╔╝
  // ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
  function success() public constant returns(bool) {
    if (isCappedInEther) {
      return weiRaised >= softCap;
    } else {
      return token.totalSupply() >= softCap;
    }
  }

  function capped() public constant returns(bool) {
    if (isCappedInEther) {
      return weiRaised >= hardCap;
    } else {
      return token.totalSupply() >= hardCap;
    }
  }

  function ended() public constant returns(bool) {
    return capped() || block.timestamp >= endTime;
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
    uint shipAmount = sellTokens(_beneficiary, msg.value, block.timestamp);
    require(shipAmount > 0);
    // forwardEther();
  }

  function buyWithHash(address _beneficiary, uint _value, uint _timestamp, bytes32 _hash) 
    inState(State.Active) onlyOwner public 
  {
    uint shipAmount = sellTokens(_beneficiary, _value, _timestamp);
    require(shipAmount > 0);
    HashBuy(_beneficiary, _value, shipAmount, _timestamp, _hash);
  }
  
  function receiveApproval(address _from, 
                           uint256 _value, 
                           address _token, 
                           bytes _extraData) public 
  {
    require(isTokenExchange);

    Debug(msg.sender, appendUintToString("Should be equal: ", toUint(_extraData)));
    Debug(msg.sender, appendUintToString("and: ", tokensValues[_token]));
    require(toUint(_extraData) == tokensValues[_token]);
    require(tokensValues[_token] > 0);
    require(forwardTokens(_from, _token, _value));

    uint weiValue = _value.mul(tokensValues[_token]).div(10 ** allowedTokens[_token].decimals());
    require(weiValue > 0);

    uint shipAmount = sellTokens(_from, weiValue, block.timestamp);
    require(shipAmount > 0);

    AltBuy(_from, _token, _value, weiValue, shipAmount);
  }

  function claimFunds() onlyOwner public returns(bool) {
    require(state == State.Claim || (isAllowClaimBeforeFinalization && success()));
    wallet.transfer(address(this).balance);
    return true;
  }

  function claimTokenFunds(address _token) onlyOwner public returns(bool) {
    require(state == State.Claim || (isAllowClaimBeforeFinalization && success()));
    uint balance = allowedTokens[_token].balanceOf(address(this));
    require(balance > 0);
    require(allowedTokens[_token].transfer(wallet, balance));
    return true;
  }

  function claimRefundEther(address _beneficiary) inState(State.Refund) public returns(bool) {
    require(weiDeposit[_beneficiary] > 0);
    _beneficiary.transfer(weiDeposit[_beneficiary]);
    return true;
  }

  function claimRefundTokens(address _beneficiary, address _token) inState(State.Refund) public returns(bool) {
    require(altDeposit[_token][_beneficiary] > 0);
    require(allowedTokens[_token].transfer(_beneficiary, altDeposit[_token][_beneficiary]));
    return true;
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

    Whitelisted(_beneficiary, _min, _max);
  }
  
  function setPersonalBonus(
    address _beneficiary, 
    uint _bonus, 
    address _refererAddress, 
    uint _refererBonus) onlyOwner public {
    personalBonuses[_beneficiary] = new PersonalBonusRecord(
      _bonus,
      _refererAddress,
      _refererBonus
    );

    PersonalBonus(_beneficiary, _refererAddress, _bonus, _refererBonus);
  }

  // ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗     ███████╗
  // ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║     ██╔════╝
  // ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║     ███████╗
  // ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║     ╚════██║
  // ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗███████║
  // ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚══════╝
  // low level token purchase function
  function sellTokens(address _beneficiary, uint _weiAmount, uint timestamp) 
    inState(State.Active) internal returns(uint)
  {
    uint beneficiaryTokens;
    uint extraTokens;
    uint totalTokens;
    uint refererTokens;
    address refererAddress;
    (totalTokens, beneficiaryTokens, extraTokens, refererTokens, refererAddress) = calculateEthAmount(
      _beneficiary, 
      _weiAmount, 
      timestamp, 
      token.totalSupply());

    require(validPurchase(_beneficiary,   // Check if current purchase is valid
                          _weiAmount, 
                          beneficiaryTokens,
                          extraTokens,
                          totalTokens,
                          timestamp));

    weiRaised = weiRaised.add(_weiAmount); // update state (wei amount)
    beneficiaryInvest[_beneficiary] = beneficiaryInvest[_beneficiary].add(_weiAmount);
    shipTokens(_beneficiary, beneficiaryTokens);     // ship tokens to beneficiary
    // soldTokens = soldTokens.add(beneficiaryTokens);
    EthBuy(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  _weiAmount, 
                  beneficiaryTokens);
    ShipTokens(_beneficiary, beneficiaryTokens);

    if (isExtraDistribution) {            // calculate and
      shipTokens(extraTokensHolder,       // ship extra tokens (team, foundation and etc)
                 extraTokens);

      // soldTokens = soldTokens.add(extraTokens);
      ShipTokens(extraTokensHolder, extraTokens);
    }

    if (isPersonalBonuses) {
      PersonalBonusRecord record = personalBonuses[_beneficiary];
      if (record.refererAddress() != address(0) && record.refererBonus() > 0) {
        shipTokens(record.refererAddress(), refererTokens);
        // soldTokens = soldTokens.add(_amount);
      ShipTokens(record.refererAddress(), refererTokens);
      }
    }

    soldTokens = soldTokens.add(totalTokens);
    return beneficiaryTokens;
  }

  function shipTokens(address _beneficiary, uint _amount) 
    inState(State.Active) internal 
  {
    if (isTransferShipment) {
      token.transferFrom(address(this), _beneficiary, _amount);
    } else {
      token.mint(_beneficiary, _amount);
    }
  }

  function forwardEther() internal returns (bool) {
    weiDeposit[msg.sender] = msg.value;
    return true;
  }

  function forwardTokens(address _beneficiary, address _tokenAddress, uint _amount) internal returns (bool) {
    TokenInterface allowedToken = allowedTokens[_tokenAddress];
    allowedToken.transferFrom(_beneficiary, address(this), _amount);
    altDeposit[_tokenAddress][_beneficiary] = _amount;
    return true;
  }

  // ██╗   ██╗████████╗██╗██╗     ███████╗
  // ██║   ██║╚══██╔══╝██║██║     ██╔════╝
  // ██║   ██║   ██║   ██║██║     ███████╗
  // ██║   ██║   ██║   ██║██║     ╚════██║
  // ╚██████╔╝   ██║   ██║███████╗███████║
  //  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝
  function toUint(bytes left) public pure returns (uint) {
      uint out;
      for (uint i = 0; i < 32; i++) {
          out |= uint(left[i]) << (31 * 8 - i * 8);
      }
      
      return out;
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

  function addressToString(address x) public pure returns (string) {
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

  function char(byte b) public pure returns (byte c) {
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