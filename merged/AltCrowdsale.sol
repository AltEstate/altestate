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


    function MultiOwners() {
        owners[msg.sender] = true;
        publisher = msg.sender;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(_owner != publisher);
        require(msg.sender != _owner);

        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract MintableInterface {
  function mint(address _beneficiary, uint tokens);
  uint256 public decimals;
}

contract AltCrowdsale is MultiOwners {
  using SafeMath for uint256;

  UserRegistryInterface public userRegistry;
  // The token being sold
  MintableInterface public token;

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
  event BitcoinSale(address indexed beneficiary, uint value, uint amount, bytes32 indexed hashLeft, bytes32 indexed hashRight);

  // function Crowdsale(
  //   uint256 _startTime, 
  //   uint256 _endTime, 
  //   uint256 _price, 
  //   address _token, 
  //   address _wallet,
  //   address _registry) public {
  //   require(_startTime >= now);
  //   require(_endTime >= _startTime);
  //   require(_price > 0);
  //   require(_wallet != address(0));
  //   require(_token != 0);
  //   require(_registry != 0);

  //   userRegistry = UserRegistryInterface(_registry);
  //   token = MintableInterface(_token);
  //   startTime = _startTime;
  //   endTime = _endTime;
  //   price = _price;
  //   wallet = _wallet;
  // }

  function setTime(uint _life) onlyOwner public {
    require(startTime == 0);
    require(endTime == 0);
    startTime = now;
    endTime = startTime + _life;
  }
  
  function setPrice(uint _price) onlyOwner public {
    require(price == 0);
    price = _price;
  }
  
  function setWallet(address _wallet) onlyOwner public {
    require(wallet == 0);
    wallet = _wallet;
  }
  
  function setRegistry(address _registry) onlyOwner public {
    require(address(userRegistry) == 0);
    userRegistry = UserRegistryInterface(_registry);
  }
  
  function setToken(address _token) onlyOwner public {
    require(address(token) == 0);
    token = MintableInterface(_token);
  }
  
  function saneIt() onlyOwner public {
    require(!isSane);
    require(startTime <= now);
    require(endTime > now);
    require(price > 0);
    require(wallet != address(0));
    require(token != address(0));
    require(userRegistry != address(0));
    isSane = true;
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(isSane);
    require(beneficiary != address(0));
    require(validPurchase());
    require(userRegistry.knownAddress(beneficiary));

    uint256 weiAmount = msg.value;

    uint decimals = 10; //token.decimals();

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(10 ** 10).div(price).mul(10 ** 10);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function issueTokens(address beneficiary, uint amount, bytes32 hashLeft, bytes32 hashRight) onlyOwner public returns (bool) {
    require(isSane);
    uint decimals = 10; //token.decimals();
    uint value = amount.mul(price).div(10 ** 10);
    weiRaised = weiRaised.add(value);
    token.mint(beneficiary, amount);
    BitcoinSale(beneficiary, value, amount, hashLeft, hashRight);
    TokenPurchase(beneficiary, beneficiary, value, amount);
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