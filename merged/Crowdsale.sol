pragma solidity ^0.4.15;

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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
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

// 




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
    // require(_startTime >= now);
    require(_endTime >= _startTime && _endTime > now);
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
    
    
    bool known = userRegistry.knownAddress(_beneficiary);
    require(known);

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