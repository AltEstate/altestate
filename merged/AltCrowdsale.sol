pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract UserRegistryInterface {
  mapping (address => bool) public addresses;
  mapping (address => bool) public identities;

  event AddAddress(address indexed who);
  event AddIdentity(address indexed who);

  function knownAddress(address _who) public constant returns(bool);
  function hasIdentity(address _who) public constant returns(bool);
}

contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;
    address public publisher;

    function MultiOwners() public {
        owners[msg.sender] = true;
        publisher = msg.sender;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() public constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) public constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }

    function grant(address _owner) onlyOwner public {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner public {
        require(_owner != publisher);
        require(msg.sender != _owner);

        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract TokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; 
}

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
  bool public isTokenExcange;           // Allow to buy tokens for another tokens?
  bool public isAllowToIssue;           // Allow to issue tokens with tx hash (ex bitcoin)
  bool public isExtraDistribution;      // Should distribute extra tokens to special contract?
  bool public isMintingShipment;        // Will ship token via minting?
  bool public isCappedInEther;          // Should be capped in Ether 
  bool public isPullingTokens;          // Should beneficiaries pull their tokens?

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
  mapping (address => uint) public temporalBalances;
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
  event ShipTokens(address indexed owner, uint indexed amount);

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
    bool _isTokenExcange,
    // Allow to issue tokens with tx hash (ex bitcoin)
    bool _isAllowToIssue,
    // Should mint extra tokens for future distribution?
    bool _isExtraDistribution,
    // Will ship token via minting? 
    bool _isMintingShipment,
    // Should be capped in ether
    bool _isCappedInEther,
    // Should beneficiaries pull their tokens? 
    bool _isPullingTokens)
    inState(State.Setup) onlyOwner public 
  {
    isWhitelisted = _isWhitelisted;
    isKnownOnly = _isKnownOnly;
    isAmountBonus = _isAmountBonus;
    isEarlyBonus = _isEarlyBonus;
    isRefundable = _isRefundable;
    isTokenExcange = _isTokenExcange;
    isAllowToIssue = _isAllowToIssue;
    isExtraDistribution = _isExtraDistribution;
    isMintingShipment = _isMintingShipment;
    isCappedInEther = _isCappedInEther;
    isPullingTokens = isRefundable || _isPullingTokens;
  }

  function setPrice(uint _price)
    inState(State.Setup) onlyOwner public
  {
    price = _price;
  }

  function setSoftHardCaps(uint _softCap, uint _hardCap)
    inState(State.Setup) onlyOwner public
  {
    hardCap = _hardCap;
    softCap = _softCap;
  }

  function setTime(uint _start, uint _end)
    inState(State.Setup) onlyOwner public 
  {
    require(_start < _end);
    require(_end > block.timestamp);
    startTime = _start;
    endTime = _end;
  }

  function setToken(address _tokenAddress) 
    inState(State.Setup) onlyOwner public
  {
    require(_tokenAddress != address(0));
    token = MintableTokenInterface(_tokenAddress);
    tokenDecimals = token.decimals();
  }

  function setWallet(address _wallet) 
    inState(State.Setup) onlyOwner public 
  {
    require(wallet == address(0));
    wallet = _wallet;
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {
    require(address(userRegistry) == 0);
    userRegistry = UserRegistryInterface(_registry);
  }

  function setExtraDistribution(address _holder, uint _extraPart) 
    inState(State.Setup) onlyOwner public
  {
    require(_holder != address(0));
    extraTokensHolder = _holder;
    extraDistributionPart = _extraPart;
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
  
  function setTokenExcange(address _token, uint _value)
    inState(State.Setup) onlyOwner public
  {
    allowedTokens[_token] = TokenInterface(_token);
    updateTokenValue(_token, _value); 
  }

  function saneIt() 
    inState(State.Setup) onlyOwner public 
  {
    require(startTime <= now);
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

    if (isMintingShipment) {
      require(token.owner() == address(this));
    } else {
      require(token.balanceOf(address(this)) >= hardCap);
    }

    state = State.Active;
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
  ) public returns(uint, uint, uint) 
  {
    _totalSupply;

    uint beneficiaryTokens;
    uint priceWithBonus;
    uint bonus = 0;
    uint extraTokens;

    if (_time < startTime || _time > endTime) {
      return (0, 0, 0);
    } else {
      if (isAmountBonus) {
        bonus = bonus.add(calculateAmountBonus(_weiAmount));
        Debug(msg.sender, appendUintToString("Calculated amount dependent bonus: ", bonus));
      }

      if (isEarlyBonus) {
        Debug(msg.sender, appendUintToString("Calculate time bonus at: ", _time.sub(startTime)));
        bonus = bonus.add(calculateTimeBonus(_time - startTime));
        Debug(msg.sender, appendUintToString("Calculated time dependent bonus: ", bonus));
      }
    }

    // tokenBonus = price.mul(bonus).div(10000);
    beneficiaryTokens = _weiAmount.mul(10 ** tokenDecimals).div(price);
    beneficiaryTokens = beneficiaryTokens.add(beneficiaryTokens.mul(bonus).div(10000));

    if (isExtraDistribution) {
      extraTokens = beneficiaryTokens.mul(extraDistributionPart).div(10000);
    }

    return (beneficiaryTokens.add(extraTokens), beneficiaryTokens, extraTokens);
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
    for (uint index = 0; index < timeSlices.length; index++) {
      bonus = timeBonuses[timeSlices[index]];
      if(timeSlices[index] > _at) {
        break;
      }
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

    uint finalBeneficiaryBalance = temporalBalances[_beneficiary].add(_tokenAmount);
    uint finalTotalSupply = temporalTotalSupply.add(_totalAmount);

    if (isWhitelisted) {
      WhitelistRecord record = whitelist[_beneficiary];
      if (!record.allow() || 
          record.min() > finalBeneficiaryBalance ||
          record.max() < finalBeneficiaryBalance) {
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
    if (isTokenExcange) {
      // token.transfer(_beneficiary, altDeposit[_beneficiary]);
    }
  }

  function addToWhitelist(address _beneficiary, uint _min, uint _max) public
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
  function sellTokens(address _beneficiary, uint weiAmount) 
    inState(State.Active) internal returns(uint)
  {
    Debug(msg.sender, "Start sell tokens");
    uint beneficiaryTokens;
    uint extraTokens;
    uint totalTokens;
    (totalTokens, beneficiaryTokens, extraTokens) = calculateEthAmount(
      _beneficiary, 
      weiAmount, 
      block.timestamp, 
      token.totalSupply());
    Debug(msg.sender, "Calculate amount");
    Debug(msg.sender, appendUintToString("Total: ", totalTokens));
    Debug(msg.sender, appendUintToString("Beneficiary: ", beneficiaryTokens));

    require(validPurchase(_beneficiary,   // Check if current purchase is valid
                          weiAmount, 
                          beneficiaryTokens,
                          extraTokens,
                          totalTokens));

    weiRaised = weiRaised.add(weiAmount); // update state (wei amount)
    shipTokens(_beneficiary, beneficiaryTokens);     // ship tokens to beneficiary
    TokenPurchase(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  weiAmount, 
                  beneficiaryTokens);
    ShipTokens(_beneficiary, beneficiaryTokens);

    if (isExtraDistribution) {            // calculate and
      shipTokens(extraTokensHolder,       // ship extra tokens (team, foundation and etc)
                 extraTokens);
      ShipTokens(extraTokensHolder, extraTokens);
    }

    return beneficiaryTokens;
  }

  function shipTokens(address _beneficiary, uint _amount) 
    inState(State.Active) internal 
  {
    if (!isPullingTokens) {
      if (isMintingShipment) {
        token.mint(_beneficiary, _amount);
      } else {
        token.transferFrom(address(this), _beneficiary, _amount);
      }
    } 

    temporalBalances[_beneficiary] = temporalBalances[_beneficiary].add(_amount);
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

contract AltCrowdsalePhaseOne is Crowdsale {
  function AltCrowdsalePhaseOne(
    address _registry,
    address _token,
    address _extraTokensHolder,
    uint _extraTokensPart,
    uint[] _timeSlices,
    uint[] _timePrices
  ) public
  {
    setFlags(
      // Should be whitelisted to buy tokens
      // _isWhitelisted,
      true,
      // Should be known user to buy tokens
      // _isKnownOnly,
      true,
      // Enable amount bonuses in crowdsale? 
      // _isAmountBonus,
      false,
      // Enable early bird bonus in crowdsale?
      // _isEarlyBonus,
      true,
      // Allow to refund money?
      // _isRefundable,
      false,
      // Allow to buy tokens for another tokens?
      // _isTokenExcange,
      false,
      // Allow to issue tokens with tx hash (ex bitcoin)
      // _isAllowToIssue,
      true,
      // Should mint extra tokens for future distribution?
      // _isExtraDistribution,
      false,
      // Will ship token via minting? 
      // _isMintingShipment,
      true,
      // Should be capped in ether
      // bool _isCappedInEther,
      true,
      // Should beneficiaries pull their tokens? 
      // _isPullingTokens
      false
    );

    setToken(_token); 
 
    setTime(block.timestamp - 1 seconds, block.timestamp + 30 days);

    setRegistry(_registry);
    setWallet(msg.sender);
    setExtraDistribution(_extraTokensHolder, _extraTokensPart);

    setSoftHardCaps(
      5 ether, // soft
      10 ether  // hard
    );

    // 200 ALT per 1 ETH
    setPrice(uint(1 ether).div(100));

    setTimeBonuses(_timeSlices, _timePrices);
  }  
}