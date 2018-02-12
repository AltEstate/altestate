pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import './UserRegistryInterface.sol';
import './MultiOwners.sol';
import './TokenRecipient.sol';

contract TokenInterface is ERC20 {event __CoverageTokenInterface(string fileName, uint256 lineNumber);
event __FunctionCoverageTokenInterface(string fileName, uint256 fnId);
event __StatementCoverageTokenInterface(string fileName, uint256 statementId);
event __BranchCoverageTokenInterface(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageTokenInterface(string fileName, uint256 branchId);
event __AssertPostCoverageTokenInterface(string fileName, uint256 branchId);

  string public name;
  string public symbol;
  uint public decimals;
}

contract MintableTokenInterface is TokenInterface {event __CoverageTokenInterface(string fileName, uint256 lineNumber);
event __FunctionCoverageTokenInterface(string fileName, uint256 fnId);
event __StatementCoverageTokenInterface(string fileName, uint256 statementId);
event __BranchCoverageTokenInterface(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageTokenInterface(string fileName, uint256 branchId);
event __AssertPostCoverageTokenInterface(string fileName, uint256 branchId);

  address public owner;
  function mint(address beneficiary, uint amount) public returns(bool);
  function transferOwnership(address nextOwner) public;
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
contract Crowdsale is MultiOwners, TokenRecipient {event __CoverageTokenInterface(string fileName, uint256 lineNumber);
event __FunctionCoverageTokenInterface(string fileName, uint256 fnId);
event __StatementCoverageTokenInterface(string fileName, uint256 statementId);
event __BranchCoverageTokenInterface(string fileName, uint256 branchId, uint256 locationIdx);
event __AssertPreCoverageTokenInterface(string fileName, uint256 branchId);
event __AssertPostCoverageTokenInterface(string fileName, uint256 branchId);

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


  struct PersonalBonusRecord {
    uint bonus;
    address refererAddress;
    uint refererBonus;
  }

  struct WhitelistRecord {
    bool allow;
    uint min;
    uint max;
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
  bool public isTokenExchange;          // Allow to buy tokens for another tokens?
  bool public isAllowToIssue;           // Allow to issue tokens with tx hash (ex bitcoin)
  bool public isDisableEther;           // Disable purchase with the Ether
  bool public isExtraDistribution;      // Should distribute extra tokens to special contract?
  bool public isTransferShipment;       // Will ship token via minting?
  bool public isCappedInEther;          // Should be capped in Ether 
  bool public isPersonalBonuses;        // Should check personal beneficiary bonus?
  bool public isAllowClaimBeforeFinalization;
                                        // Should allow to claim funds before finalization?
  bool public isMinimumValue;           // Validate minimum amount to purchase
  bool public isMinimumInEther;         // Is minimum amount setuped in Ether or Tokens?

  uint public minimumPurchaseValue;     // How less buyer could to purchase

  // List of allowed beneficiaries
  mapping (address => WhitelistRecord) public whitelist;
  address[] public whitelisted;
  uint public whitelistedCount;

  // Known users registry (required to known rules)
  UserRegistryInterface public userRegistry;

  mapping (uint => uint) public amountBonuses; // Amount bonuses
  uint[] public amountSlices;                  // Key is min amount of buy
  uint public amountSlicesCount;               // 10000 - 100.00% bonus over base pricetotaly free
                                               //  5000 - 50.00% bonus
                                               //     0 - no bonus at all
  mapping (uint => uint) public timeBonuses;   // Time bonuses
  uint[] public timeSlices;                    // Same as amount but key is seconds after start
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

  modifier inState(State _target) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',1);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',150);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',1);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',1);
require(state == _target);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',1);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',151);
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
    // Allow to buy tokens for another tokens?
    bool _isTokenExchange,
    // Allow to issue tokens with tx hash (ex bitcoin)
    bool _isAllowToIssue,
    // Should reject purchases with Ether?
    bool _isDisableEther,
    // Should mint extra tokens for future distribution?
    bool _isExtraDistribution,
    // Will ship token via minting? 
    bool _isTransferShipment,
    // Should be capped in ether
    bool _isCappedInEther,
    // Should beneficiaries pull their tokens? 
    bool _isPersonalBonuses,
    // Should allow to claim funds before finalization?
    bool _isAllowClaimBeforeFinalization)
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',2);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',223);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',2);
isWhitelisted = _isWhitelisted;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',224);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',3);
isKnownOnly = _isKnownOnly;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',225);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',4);
isAmountBonus = _isAmountBonus;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',226);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',5);
isEarlyBonus = _isEarlyBonus;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',227);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',6);
isTokenExchange = _isTokenExchange;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',228);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',7);
isAllowToIssue = _isAllowToIssue;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',229);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',8);
isDisableEther = _isDisableEther;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',230);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',9);
isExtraDistribution = _isExtraDistribution;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',231);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',10);
isTransferShipment = _isTransferShipment;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',232);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',11);
isCappedInEther = _isCappedInEther;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',233);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',12);
isPersonalBonuses = _isPersonalBonuses;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',234);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',13);
isAllowClaimBeforeFinalization = _isAllowClaimBeforeFinalization;
  }

  // ! Could be changed in process of sale (since 02.2018)
  function setMinimum(uint _amount, bool _inToken) 
    onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',3);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',241);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',14);
if (_amount == 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',2,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',242);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',15);
isMinimumValue = false;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',243);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',16);
minimumPurchaseValue = 0;
    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',2,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',245);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',17);
isMinimumValue = true;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',246);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',18);
isMinimumInEther = !_inToken;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',247);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',19);
minimumPurchaseValue = _amount;
    }
  }

  function setPrice(uint _price)
    inState(State.Setup) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',4);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',254);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',3);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',20);
require(_price > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',3);

    // SetPrice(msg.sender, price, _price);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',256);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',21);
price = _price;
  }

  function setSoftHardCaps(uint _softCap, uint _hardCap)
    inState(State.Setup) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',5);

    // SetSoftCap(msg.sender, softCap, _softCap);
    // SetHardCap(msg.sender, hardCap, _hardCap);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',264);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',22);
hardCap = _hardCap;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',265);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',23);
softCap = _softCap;
  }

  function setTime(uint _start, uint _end)
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',6);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',271);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',4);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',24);
require(_start < _end);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',4);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',272);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',5);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',25);
require(_end > block.timestamp);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',5);


    // SetStartTime(msg.sender, startTime, _start);
    // SetEndTime(msg.sender, endTime, _end);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',276);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',26);
startTime = _start;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',277);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',27);
endTime = _end;
  }

  function setToken(address _tokenAddress) 
    inState(State.Setup) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',7);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',283);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',28);
token = MintableTokenInterface(_tokenAddress);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',284);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',29);
tokenDecimals = token.decimals();
  }

  function setWallet(address _wallet) 
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',8);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',290);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',6);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',30);
require(_wallet != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',6);

    // SetWallet(msg.sender, wallet, _wallet);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',292);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',31);
wallet = _wallet;
  }
  
  function setRegistry(address _registry) 
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',9);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',298);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',7);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',32);
require(_registry != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',7);

    // SetRegistry(msg.sender, userRegistry, _registry);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',300);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',33);
userRegistry = UserRegistryInterface(_registry);
  }

  function setExtraDistribution(address _holder, uint _extraPart) 
    inState(State.Setup) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',10);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',306);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',8);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',34);
require(_holder != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',8);

    // SetExtraTokensHolder(msg.sender, extraTokensHolder, _holder);
    // SetExtraTokensPart(msg.sender, extraDistributionPart, _extraPart);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',309);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',35);
extraTokensHolder = _holder;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',310);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',36);
extraDistributionPart = _extraPart;
  }

  function setAmountBonuses(uint[] _amountSlices, uint[] _bonuses) 
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',11);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',316);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',9);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',37);
require(_amountSlices.length > 1);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',9);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',317);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',10);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',38);
require(_bonuses.length == _amountSlices.length);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',10);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',318);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',39);
uint lastSlice = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',319);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',40);
for (uint index = 0; index < _amountSlices.length; index++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',320);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',11);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',41);
require(_amountSlices[index] > lastSlice);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',11);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',321);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',42);
lastSlice = _amountSlices[index];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',322);
      amountSlices.push(lastSlice);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',323);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',43);
amountBonuses[lastSlice] = _bonuses[index];

      // AddAmountSlice(msg.sender, _amountSlices[index], _bonuses[index]);
    }

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',328);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',44);
amountSlicesCount = amountSlices.length;
  }

  function setTimeBonuses(uint[] _timeSlices, uint[] _bonuses) 
    // ! Not need to check state since changes at 02.2018
    // inState(State.Setup)
    onlyOwner 
    public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',12);

    // Only once in life time
    // ! Time bonuses is changable after 02.2018
    // require(timeSlicesCount == 0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',340);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',12);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',45);
require(_timeSlices.length > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',12);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',341);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',13);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',46);
require(_bonuses.length == _timeSlices.length);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',13);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',342);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',47);
uint lastSlice = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',343);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',48);
uint lastBonus = 10000;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',344);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',49);
if (timeSlicesCount > 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',14,0);
      // ! Since time bonuses is changable we should take latest first
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',346);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',50);
lastSlice = timeSlices[timeSlicesCount - 1];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',347);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',51);
lastBonus = timeBonuses[lastSlice];
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',14,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',350);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',52);
for (uint index = 0; index < _timeSlices.length; index++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',351);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',15);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',53);
require(_timeSlices[index] > lastSlice);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',15);


      // ! Add check for next bonus is equal or less than previous
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',354);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',16);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',54);
require(_bonuses[index] <= lastBonus);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',16);


      // ? Should we check bonus in a future

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',358);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',55);
lastSlice = _timeSlices[index];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',359);
      timeSlices.push(lastSlice);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',360);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',56);
timeBonuses[lastSlice] = _bonuses[index];
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',362);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',57);
timeSlicesCount = timeSlices.length;
  }
  
  function setTokenExcange(address _token, uint _value)
    inState(State.Setup) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',13);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',368);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',58);
allowedTokens[_token] = TokenInterface(_token);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',369);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',59);
updateTokenValue(_token, _value); 
  }

  function saneIt() 
    inState(State.Setup) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',14);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',375);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',17);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',60);
require(startTime < endTime);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',17);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',376);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',18);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',61);
require(endTime > now);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',18);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',378);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',19);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',62);
require(price > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',19);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',380);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',20);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',63);
require(wallet != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',20);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',381);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',21);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',64);
require(token != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',21);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',383);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',65);
if (isKnownOnly) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',22,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',384);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',23);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',66);
require(userRegistry != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',23);

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',22,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',387);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',67);
if (isAmountBonus) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',24,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',388);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',25);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',68);
require(amountSlicesCount > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',25);

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',24,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',391);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',69);
if (isEarlyBonus) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',26,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',392);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',27);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',70);
require(timeSlicesCount > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',27);

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',26,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',395);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',71);
if (isExtraDistribution) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',28,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',396);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',29);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',72);
require(extraTokensHolder != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',29);

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',28,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',399);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',73);
if (isTransferShipment) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',30,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',400);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',31);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',74);
require(token.balanceOf(address(this)) >= hardCap);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',31);

    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',30,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',402);
      __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',32);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',75);
require(token.owner() == address(this));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',32);

    }

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',405);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',76);
state = State.Active;
  }

  function finalizeIt(address _futureOwner) inState(State.Active) onlyOwner public {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',15);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',409);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',33);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',77);
require(ended());__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',33);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',411);
    token.transferOwnership(_futureOwner);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',413);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',78);
if (success()) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',34,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',414);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',79);
state = State.Claim;
    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',34,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',416);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',80);
state = State.Refund;
    }
  }

  function historyIt() inState(State.Claim) onlyOwner public {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',16);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',421);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',35);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',81);
require(address(this).balance == 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',35);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',422);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',82);
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
  ) public returns(
    uint calculatedTotal, 
    uint calculatedBeneficiary, 
    uint calculatedExtra, 
    uint calculatedreferer, 
    address refererAddress) 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',17);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',444);
    _totalSupply;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',445);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',83);
uint bonus = 0;
    
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',447);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',84);
if (isAmountBonus) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',36,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',448);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',85);
bonus = bonus.add(calculateAmountBonus(_weiAmount));
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',36,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',451);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',86);
if (isEarlyBonus) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',37,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',452);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',87);
bonus = bonus.add(calculateTimeBonus(_time.sub(startTime)));
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',37,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',455);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',88);
if (isPersonalBonuses && personalBonuses[_beneficiary].bonus > 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',38,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',456);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',89);
bonus = bonus.add(personalBonuses[_beneficiary].bonus);
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',38,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',459);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',90);
calculatedBeneficiary = _weiAmount.mul(10 ** tokenDecimals).div(price);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',460);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',91);
if (bonus > 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',39,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',461);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',92);
calculatedBeneficiary = calculatedBeneficiary.add(calculatedBeneficiary.mul(bonus).div(10000));
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',39,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',464);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',93);
if (isExtraDistribution) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',40,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',465);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',94);
calculatedExtra = calculatedBeneficiary.mul(extraDistributionPart).div(10000);
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',40,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',468);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',95);
if (isPersonalBonuses && 
        personalBonuses[_beneficiary].refererAddress != address(0) && 
        personalBonuses[_beneficiary].refererBonus > 0) 
    {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',41,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',472);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',96);
calculatedreferer = calculatedBeneficiary.mul(personalBonuses[_beneficiary].refererBonus).div(10000);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',473);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',97);
refererAddress = personalBonuses[_beneficiary].refererAddress;
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',41,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',476);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',98);
calculatedTotal = calculatedBeneficiary.add(calculatedExtra).add(calculatedreferer);
  }

  function calculateAmountBonus(uint _changeAmount) public returns(uint) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',18);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',480);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',99);
uint bonus = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',481);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',100);
for (uint index = 0; index < amountSlices.length; index++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',482);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',101);
if(amountSlices[index] > _changeAmount) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',42,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',483);
        break;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',42,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',486);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',102);
bonus = amountBonuses[amountSlices[index]];
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',488);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',103);
return bonus;
  }

  function calculateTimeBonus(uint _at) public returns(uint) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',19);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',492);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',104);
uint bonus = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',493);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',105);
for (uint index = timeSlices.length; index > 0; index--) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',494);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',106);
if(timeSlices[index - 1] < _at) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',43,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',495);
        break;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',43,1);}

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',497);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',107);
bonus = timeBonuses[timeSlices[index - 1]];
    }

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',500);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',108);
return bonus;
  }

  function validPurchase(
    address _beneficiary, 
    uint _weiAmount, 
    uint _tokenAmount,
    uint _extraAmount,
    uint _totalAmount,
    uint _time) 
  public returns(bool) 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',20);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',512);
    _tokenAmount;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',513);
    _extraAmount;

    // ! Check min purchase value (since 02.2018)
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',516);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',109);
if (isMinimumValue) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',44,0);
      // ! Check min purchase value in ether (since 02.2018)
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',518);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',110);
if (isMinimumInEther && _weiAmount < minimumPurchaseValue) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',45,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',519);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',111);
return false;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',45,1);}


      // ! Check min purchase value in tokens (since 02.2018)
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',523);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',112);
if (!isMinimumInEther && _tokenAmount < minimumPurchaseValue) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',46,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',524);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',113);
return false;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',46,1);}

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',44,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',528);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',114);
if (_time < startTime || _time > endTime) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',47,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',529);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',115);
return false;
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',47,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',532);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',116);
if (isKnownOnly && !userRegistry.knownAddress(_beneficiary)) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',48,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',533);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',117);
return false;
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',48,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',536);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',118);
uint finalBeneficiaryInvest = beneficiaryInvest[_beneficiary].add(_weiAmount);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',537);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',119);
uint finalTotalSupply = soldTokens.add(_totalAmount);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',539);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',120);
if (isWhitelisted) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',49,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',540);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',121);
WhitelistRecord storage record = whitelist[_beneficiary];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',541);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',122);
if (!record.allow || 
          record.min > finalBeneficiaryInvest ||
          record.max < finalBeneficiaryInvest) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',50,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',544);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',123);
return false;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',50,1);}

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',49,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',548);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',124);
if (isCappedInEther) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',51,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',549);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',125);
if (weiRaised.add(_weiAmount) > hardCap) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',52,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',550);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',126);
return false;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',52,1);}

    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',51,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',553);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',127);
if (finalTotalSupply > hardCap) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',53,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',554);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',128);
return false;
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',53,1);}

    }

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',558);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',129);
return true;
  }

                                                                                        
  function updateTokenValue(address _token, uint _value) onlyOwner public {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',21);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',563);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',54);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',130);
require(address(allowedTokens[_token]) != address(0x0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',54);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',564);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',131);
tokensValues[_token] = _value;
  }

  // ██████╗ ███████╗ █████╗ ██████╗ 
  // ██╔══██╗██╔════╝██╔══██╗██╔══██╗
  // ██████╔╝█████╗  ███████║██║  ██║
  // ██╔══██╗██╔══╝  ██╔══██║██║  ██║
  // ██║  ██║███████╗██║  ██║██████╔╝
  // ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
  function success() public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',22);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',574);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',132);
if (isCappedInEther) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',55,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',575);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',133);
return weiRaised >= softCap;
    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',55,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',577);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',134);
return token.totalSupply() >= softCap;
    }
  }

  function capped() public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',23);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',582);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',135);
if (isCappedInEther) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',56,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',583);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',136);
return weiRaised >= hardCap;
    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',56,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',585);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',137);
return token.totalSupply() >= hardCap;
    }
  }

  function ended() public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',24);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',590);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',138);
return capped() || block.timestamp >= endTime;
  }


  //  ██████╗ ██╗   ██╗████████╗███████╗██╗██████╗ ███████╗
  // ██╔═══██╗██║   ██║╚══██╔══╝██╔════╝██║██╔══██╗██╔════╝
  // ██║   ██║██║   ██║   ██║   ███████╗██║██║  ██║█████╗  
  // ██║   ██║██║   ██║   ██║   ╚════██║██║██║  ██║██╔══╝  
  // ╚██████╔╝╚██████╔╝   ██║   ███████║██║██████╔╝███████╗
  //  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝╚═════╝ ╚══════╝
  // fallback function can be used to buy tokens
  function () external payable {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',25);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',602);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',139);
buyTokens(msg.sender);
  }

  function buyTokens(address _beneficiary) inState(State.Active) public payable {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',26);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',606);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',57);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',140);
require(!isDisableEther);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',57);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',607);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',141);
uint shipAmount = sellTokens(_beneficiary, msg.value, block.timestamp);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',608);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',58);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',142);
require(shipAmount > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',58);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',609);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',143);
forwardEther();
  }

  function buyWithHash(address _beneficiary, uint _value, uint _timestamp, bytes32 _hash) 
    inState(State.Active) onlyOwner public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',27);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',615);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',59);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',144);
require(isAllowToIssue);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',59);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',616);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',145);
uint shipAmount = sellTokens(_beneficiary, _value, _timestamp);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',617);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',60);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',146);
require(shipAmount > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',60);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',618);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',147);
HashBuy(_beneficiary, _value, shipAmount, _timestamp, _hash);
  }
  
  function receiveApproval(address _from, 
                           uint256 _value, 
                           address _token, 
                           bytes _extraData) public 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',28);

    // Debug(msg.sender, appendUintToString("Should be equal: ", toUint(_extraData)));
    // Debug(msg.sender, appendUintToString("and: ", tokensValues[_token]));
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',628);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',61);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',148);
require(toUint(_extraData) == tokensValues[_token]);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',61);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',629);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',62);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',149);
require(tokensValues[_token] > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',62);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',630);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',63);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',150);
require(forwardTokens(_from, _token, _value));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',63);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',632);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',151);
uint weiValue = _value.mul(tokensValues[_token]).div(10 ** allowedTokens[_token].decimals());
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',633);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',64);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',152);
require(weiValue > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',64);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',635);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',153);
Debug(msg.sender, appendUintToString("Token to wei: ", weiValue));
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',636);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',154);
uint shipAmount = sellTokens(_from, weiValue, block.timestamp);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',637);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',65);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',155);
require(shipAmount > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',65);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',639);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',156);
AltBuy(_from, _token, _value, weiValue, shipAmount);
  }

  function claimFunds() onlyOwner public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',29);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',643);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',66);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',157);
require(state == State.Claim || (isAllowClaimBeforeFinalization && success()));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',66);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',644);
    wallet.transfer(address(this).balance);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',645);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',158);
return true;
  }

  function claimTokenFunds(address _token) onlyOwner public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',30);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',649);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',67);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',159);
require(state == State.Claim || (isAllowClaimBeforeFinalization && success()));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',67);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',650);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',160);
uint balance = allowedTokens[_token].balanceOf(address(this));
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',651);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',68);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',161);
require(balance > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',68);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',652);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',69);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',162);
require(allowedTokens[_token].transfer(wallet, balance));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',69);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',653);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',163);
return true;
  }

  function claimRefundEther(address _beneficiary) inState(State.Refund) public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',31);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',657);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',70);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',164);
require(weiDeposit[_beneficiary] > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',70);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',658);
    _beneficiary.transfer(weiDeposit[_beneficiary]);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',659);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',165);
return true;
  }

  function claimRefundTokens(address _beneficiary, address _token) inState(State.Refund) public returns(bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',32);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',663);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',71);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',166);
require(altDeposit[_token][_beneficiary] > 0);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',71);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',664);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',72);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',167);
require(allowedTokens[_token].transfer(_beneficiary, altDeposit[_token][_beneficiary]));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',72);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',665);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',168);
return true;
  }

  function addToWhitelist(address _beneficiary, uint _min, uint _max) onlyOwner public
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',33);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',670);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',73);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',169);
require(_beneficiary != address(0));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',73);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',671);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',74);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',170);
require(_min <= _max);__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',74);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',673);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',171);
if (_max == 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',75,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',674);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',172);
_max = 10 ** 40; // should be huge enough? :0
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',75,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',677);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',173);
whitelist[_beneficiary] = WhitelistRecord(true, _min, _max);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',678);
    whitelisted.push(_beneficiary);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',679);
    whitelistedCount++;

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',681);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',174);
Whitelisted(_beneficiary, _min, _max);
  }
  
  function setPersonalBonus(
    address _beneficiary, 
    uint _bonus, 
    address _refererAddress, 
    uint _refererBonus) onlyOwner public {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',34);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',689);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',175);
personalBonuses[_beneficiary] = PersonalBonusRecord(
      _bonus,
      _refererAddress,
      _refererBonus
    );

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',695);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',176);
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
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',35);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',708);
    uint beneficiaryTokens;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',709);
    uint extraTokens;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',710);
    uint totalTokens;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',711);
    uint refererTokens;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',712);
    address refererAddress;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',713);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',177);
(totalTokens, beneficiaryTokens, extraTokens, refererTokens, refererAddress) = calculateEthAmount(
      _beneficiary, 
      _weiAmount, 
      timestamp, 
      token.totalSupply());

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',719);
    __AssertPreCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',76);
 __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',178);
require(validPurchase(_beneficiary,   // Check if current purchase is valid
                          _weiAmount, 
                          beneficiaryTokens,
                          extraTokens,
                          totalTokens,
                          timestamp));__AssertPostCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',76);


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',726);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',179);
weiRaised = weiRaised.add(_weiAmount); // update state (wei amount)
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',727);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',180);
beneficiaryInvest[_beneficiary] = beneficiaryInvest[_beneficiary].add(_weiAmount);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',728);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',181);
shipTokens(_beneficiary, beneficiaryTokens);     // ship tokens to beneficiary
    // soldTokens = soldTokens.add(beneficiaryTokens);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',730);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',182);
EthBuy(msg.sender,             // Fire purchase event
                  _beneficiary, 
                  _weiAmount, 
                  beneficiaryTokens);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',734);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',183);
ShipTokens(_beneficiary, beneficiaryTokens);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',736);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',184);
if (isExtraDistribution) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',77,0);            // calculate and
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',737);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',185);
shipTokens(extraTokensHolder,       // ship extra tokens (team, foundation and etc)
                 extraTokens);

      // soldTokens = soldTokens.add(extraTokens);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',741);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',186);
ShipTokens(extraTokensHolder, extraTokens);
    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',77,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',744);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',187);
if (isPersonalBonuses) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',78,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',745);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',188);
PersonalBonusRecord storage record = personalBonuses[_beneficiary];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',746);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',189);
if (record.refererAddress != address(0) && record.refererBonus > 0) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',79,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',747);
         __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',190);
shipTokens(record.refererAddress, refererTokens);
        // soldTokens = soldTokens.add(_amount);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',749);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',191);
ShipTokens(record.refererAddress, refererTokens);
      }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',79,1);}

    }else { __BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',78,1);}


__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',753);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',192);
soldTokens = soldTokens.add(totalTokens);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',754);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',193);
return beneficiaryTokens;
  }

  function shipTokens(address _beneficiary, uint _amount) 
    inState(State.Active) internal 
  {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',36);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',760);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',194);
if (isTransferShipment) {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',80,0);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',761);
      token.transfer(_beneficiary, _amount);
    } else {__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',80,1);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',763);
      token.mint(_beneficiary, _amount);
    }
  }

  function forwardEther() internal returns (bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',37);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',768);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',195);
weiDeposit[msg.sender] = msg.value;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',769);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',196);
return true;
  }

  function forwardTokens(address _beneficiary, address _tokenAddress, uint _amount) internal returns (bool) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',38);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',773);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',197);
TokenInterface allowedToken = allowedTokens[_tokenAddress];
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',774);
    allowedToken.transferFrom(_beneficiary, address(this), _amount);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',775);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',198);
altDeposit[_tokenAddress][_beneficiary] = _amount;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',776);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',199);
return true;
  }

  // ██╗   ██╗████████╗██╗██╗     ███████╗
  // ██║   ██║╚══██╔══╝██║██║     ██╔════╝
  // ██║   ██║   ██║   ██║██║     ███████╗
  // ██║   ██║   ██║   ██║██║     ╚════██║
  // ╚██████╔╝   ██║   ██║███████╗███████║
  //  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝
  function toUint(bytes left) public returns (uint) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',39);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',786);
      uint out;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',787);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',200);
for (uint i = 0; i < 32; i++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',788);
           __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',201);
out |= uint(left[i]) << (31 * 8 - i * 8);
      }
      
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',791);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',202);
return out;
  }


  // ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
  // ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
  // ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
  // ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
  // ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
  // ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 
  event Debug(address indexed sender, string message);
  
  function uintToString(uint v) public returns (string str) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',40);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',804);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',203);
uint maxlength = 100;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',805);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',204);
bytes memory reversed = new bytes(maxlength);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',806);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',205);
uint i = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',807);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',206);
while (v != 0) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',808);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',207);
uint remainder = v % 10;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',809);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',208);
v = v / 10;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',810);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',209);
reversed[i++] = byte(48 + remainder);
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',812);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',210);
bytes memory s = new bytes(i);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',813);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',211);
for (uint j = 0; j < i; j++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',814);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',212);
s[j] = reversed[i - 1 - j];
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',816);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',213);
str = string(s);
  }

  function addressToString(address x) public returns (string) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',41);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',820);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',214);
bytes memory s = new bytes(40);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',821);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',215);
for (uint i = 0; i < 20; i++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',822);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',216);
byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',823);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',217);
byte hi = byte(uint8(b) / 16);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',824);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',218);
byte lo = byte(uint8(b) - 16 * uint8(hi));
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',825);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',219);
s[2*i] = char(hi);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',826);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',220);
s[2*i+1] = char(lo);            
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',828);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',221);
return string(s);
  }

  function char(byte b) public returns (byte c) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',42);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',832);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',222);
if (b < 10) { __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',223);
__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',81,0);return byte(uint8(b) + 0x30);}
    else { __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',224);
__BranchCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',81,1);return byte(uint8(b) + 0x57);}
  }

  function appendUintToString(string inStr, uint v) public returns (string str) {__FunctionCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',43);

__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',837);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',225);
uint maxlength = 100;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',838);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',226);
bytes memory reversed = new bytes(maxlength);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',839);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',227);
uint i = 0;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',840);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',228);
while (v != 0) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',841);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',229);
uint remainder = v % 10;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',842);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',230);
v = v / 10;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',843);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',231);
reversed[i++] = byte(48 + remainder);
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',845);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',232);
bytes memory inStrb = bytes(inStr);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',846);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',233);
bytes memory s = new bytes(inStrb.length + i);
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',847);
    uint j;
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',848);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',234);
for (j = 0; j < inStrb.length; j++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',849);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',235);
s[j] = inStrb[j];
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',851);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',236);
for (j = 0; j < i; j++) {
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',852);
       __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',237);
s[j + inStrb.length] = reversed[i - 1 - j];
    }
__CoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',854);
     __StatementCoverageTokenInterface('/Users/aler/crypto/altestate-3/contracts/base/Crowdsale.sol',238);
str = string(s);
  }
}