pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import './UserRegistryInterface.sol';
import './MultiOwners.sol';
import './TokenRecipient.sol';

contract TokenInterface is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;
}

contract MintableTokenInterface is TokenInterface {
  function mint(address beneficiary, uint amount) public returns(bool);
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
  bool public isPullingTokens;          // Should beneficiaries pull their tokens?

  // List of allowed beneficiaries
  mapping (address => WhitelistRecord) public whitelist;
  address[] public whitelisted;
  uint public whitelistedCount;

  // Known users registry (required to known rules)
  UserRegistryInterface public userRegistry;

  mapping (uint => uint) public amountBonuses; 
                                        // Amount bonuses
  uint[] public amountSlices;           // Key is min amount of buy
  uint public amountSlicesCount;        // 10000 - totaly free
                                        //  5000 - 50% sale
                                        //     0 - 100% (no bonus)

  
  mapping (uint => uint) public timeBonuses;   
                                        // Time bonuses
  uint[] public timeSlices;             // Same as amount but key is seconds after start
  uint public timeSlicesCount;

  MintableTokenInterface public token;  // The token being sold
  uint public tokenDecimals;            // Token decimals

  mapping (address => TokenInterface) allowedTokens;
                                        // allowed tokens list
  mapping (address => uint) tokensValues;
                                        // TOKEN to ETH conversion rate (oraclized)

  uint public startTime;                // start and end timestamps where 
  uint public endTime;                  // investments are allowed (both inclusive)

  address public wallet;                // address where funds are collected
  uint public price;                    // how many token (1 * 10 ** decimals) a buyer gets per wei
  uint public hardCap;

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
  mapping (address => uint) temporalBalances;

  mapping (address => uint) weiDeposit;
  mapping (address => uint) tokenDeposit;



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
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);
  event BitcoinSale(address indexed beneficiary, uint value, uint amount, bytes32 indexed bitcoinHash);
  event TokenSell(address indexed beneficiary, address indexed allowedToken, uint allowedTokenValue, uint ethValue, uint shipAmount);
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
    bool _isAllowToIssue,
    // Should mint extra tokens for future distribution?
    bool _isExtraDistribution,
    // Will ship token via minting? 
    bool _isMintingShipment,
    // Should beneficiaries pull their tokens? 
    bool _isPullingTokens,

    // primary values:
    uint _price,
    uint _start, uint _end,
    uint _hardCap,
    address _token
  ) {
    state = State.Setup;
    isWhitelisted = _isWhitelisted;
    isKnownOnly = _isKnownOnly;
    isAmountBonus = _isAmountBonus;
    isEarlyBonus = _isEarlyBonus;
    isRefundable = _isRefundable;
    isTokenExcange = _isTokenExcange;
    isAllowToIssue = _isAllowToIssue;
    isExtraDistribution = _isExtraDistribution;
    isMintingShipment = _isMintingShipment;
    isPullingTokens = isRefundable || _isPullingTokens;

    require(endTime > now);
    startTime = _start;
    endTime = _end;
    hardCap = _hardCap;

    token = MintableTokenInterface(_token);
    tokenDecimals = token.decimals();
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
    require(wallet == address(0));
    wallet = _wallet;
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {
    require(address(userRegistry) == 0);
    userRegistry = UserRegistryInterface(_registry);
  }

  function setExtraTokensHolder(address _holder) 
    inState(State.Setup) onlyOwner public
  {
    require(_holder != address(0));
    extraTokensHolder = _holder;
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
    uint weiAmount,
    uint time,
    uint totalSupply
  ) public constant returns(uint, uint) 
  {
    uint beneficiaryTokens;
    uint priceWithBonus;
    uint bonus;
    uint extraTokens;

    if (time < startTime || time > endTime) {
      return (0, 0);
    } else {
      if (isAmountBonus) {
        bonus = bonus.add(calculateAmountBonus(weiAmount));
      }

      if (isEarlyBonus) {
        bonus = bonus.add(calculateTimeBonus(now - startTime));
      }
    }

    priceWithBonus = price.mul(10000 - bonus).div(10000);
    beneficiaryTokens = weiAmount.mul(10 ** tokenDecimals).div(priceWithBonus);

    if (isExtraDistribution) {
      extraTokens = beneficiaryTokens.mul(1000 - extraDistributionPart).mul(extraDistributionPart);
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
      if(timeBonuses[index] > _changeAmount) {
        break;
      }
      bonus = timeBonuses[timeSlices[index]];
    }

    return bonus;
  }

  function validPurchase(
    address _beneficiary, 
    uint _weiAmount, 
    uint _tokenAmount,
    uint _extraAmount,
    uint _totalAmount) 
  public constant returns(bool) {
    if (isKnownOnly && !userRegistry.knownAddress(_beneficiary)) {
      return false;
    }

    uint finalBeneficiaryBalance = temporalBalances[_beneficiary].add(_tokenAmount);
    uint finalTotalSupply = temporalTotalSupply.add(_totalAmount);

    if (isWhitelisted) {
      WhitelistRecord record = whitelist[_beneficiary];
      if (!record.allow || 
          record.min > finalBeneficiaryBalance ||
          record.max < finalBeneficiaryBalance) {
        return false;
      }
    }

    if (isCapped && hardCap > finalTotalSupply) {
        return false;
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
    require(sellTokens(_beneficiary, msg.value));
    forwardEther();
  }

  function buyWithBitcoin(address _beneficiary, uint _amount, bytes32 _hash) 
    inState(State.Active) onlyOwner public 
  {
    uint value = _amount.mul(price).div(10 ** tokenDecimals);
    require(sellTokens(_beneficiary, value));
    BitcoinSale(_beneficiary, value, _amount, _hash);
  }

  function receiveApproval(address _from, 
                           uint256 _value, 
                           address _token, 
                           bytes _extraData) public {
    require(address(allowedTokens[_token]) != address(0));
    uint weiValue = _value.mul(tokensValues[_token]).div(10 ** allowedTokens[_token].decimals);
    uint shipAmount = sellTokens(_from, weiAmount);
    require(shipAmount > 0);
    TokenSell(_beneficiary, _token, _value, weiValue, shipAmount);
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
      token.transfer(_beneficiary, altDeposit[_beneficiary]);
    }
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
    uint beneficiaryTokens;
    uint extraTokens;
    uint totalTokens;
    (totalTokens, beneficiaryTokens, extraTokens) = calculateEthAmount(weiAmount, token.totalSupply());

    require(validPurchase(_beneficiary,   // Check if current purchase is valid
                          weiAmount, 
                          beneficiaryTokens,
                          extraTokens,
                          totalTokens));

    weiRaised = weiRaised.add(weiAmount); // update state (wei amount)
    shipTokens(_beneficiary, tokens);     // ship tokens to beneficiary
    TokenPurchase(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  weiAmount, 
                  beneficiaryTokens);
    ShipTokens(_beneficiary, beneficiaryTokens);

    if (isExtraDistribution) {            // calculate and
      shipTokens(extraTokensHolder,       // ship extra tokens (team, foundation and etc)
                 tokens);

      ExtraTokens(msg.sender,             // Fire extra distribution event
                  extraTokensHolder, 
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

  function forwardTokens(address _beneficiary, uint _amount) internal {
    if (isRefundable) {
      token.transferFrom(_beneficiary, address(this), _amount);
      altDeposit[_beneficiary] = _amount;
    } else {
      token.transferFrom(_beneficiary, wallet, _amount);
    }
  }
}