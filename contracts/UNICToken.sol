pragma solidity ^0.4.18;

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
    uint256 c = a / b;
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

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address owner) public constant returns (uint256 balance);
  function transfer(address to, uint256 value) public returns (bool success);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256 remaining);
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
  function approve(address spender, uint256 value) public returns (bool success);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;
 
  mapping (address => uint256) public balances;
 
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to] && _value > 0 && _to != address(this) && _to != address(0)) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    } else { return false; }
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;
 
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to] && _value > 0 && _to != address(this) && _to != address(0)) {
        var _allowance = allowed[_from][msg.sender];
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    } else { return false; }
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
      if (((_value == 0) || (allowed[msg.sender][_spender] == 0)) && _spender != address(this) && _spender != address(0)) {
          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);
          return true;
      } else { return false; }
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}

contract KYCToken is StandardToken, owned {
    mapping (address => uint256) public KYC;
    mapping (address => uint256) public WhiteList;
      
    function KYCstatus(address _contributor) public returns (string);
    
    function setICOManager(address _newIcoManager) public returns (bool);
}

contract UNICToken is owned, KYCToken {
    
    string public constant name = 'UNICToken';
    string public constant symbol = 'UNIC';
    uint8 public constant decimals = 18;
    
    uint256 public initialSupply = 250000000 * 10 ** uint256(decimals);
    
    address public icoManager;

    modifier onlyManager() {
        require(msg.sender == icoManager);
        _;
    }

    function UNICToken() public onlyOwner {
      totalSupply = initialSupply;
      balances[msg.sender] = initialSupply;
    }

    function setICOManager(address _newIcoManager) public onlyOwner returns (bool) {
      assert(_newIcoManager != 0x0);
      icoManager = _newIcoManager;
    }

    function approveKYC(address _contributor) public onlyManager {
      if(_contributor != 0x0){
        KYC[_contributor] = 1;
      }
    }
    
    function setWhiteList(address _contributor) public onlyManager {
      if(_contributor != 0x0){
        WhiteList[_contributor] = 1;
      }
    }

    function KYCstatus(address _contributor) public returns (string){
      if(_contributor != 0x0){
        if(KYC[_contributor]==1){
          return 'KYC approved';
        }else{
          return 'KYC not verified';
        }
      }
    }   
}

contract Crowdsale is owned, KYCToken {
    
  using SafeMath for uint;
  
  UNICToken public token = new UNICToken();
  
  address constant multisig = 0xDE4951a749DE77874ee72778512A2bA1e9032e7a;
  uint constant rate = 840;
  
  uint public constant presaleStart = 1518084000;        /** 08.02 */
  uint public presaleEnd = 1518861600;          /** 17.02 */
  uint public presaleDiscount = 30;
  uint public presaleTokensLimit = 4250000 * 1000000000000000000;
  uint public presaleWhitelistDiscount = 40;
  uint public presaleWhitelistTokensLimit = 750000 * 1000000000000000000;

  uint public firstRoundICOStart = 1520503200;  /** 08.03 */
  uint public firstRoundICOEnd = 1521712800;    /** 22.03 */
  uint public firstRoundICODiscount = 15;
  uint public firstRoundICOTokensLimit = 6250000 * 1000000000000000000;

  uint public secondRoundICOStart = 1522922400; /** 05.04 */
  uint public secondRoundICOEnd = 1524736800;   /** 26.04 */
  uint public secondRoundICOTokensLimit = 43750000 * 1000000000000000000;

  uint public etherRaised;
  uint public tokensSold;

  modifier saleIsOn() {
    require((now >= presaleStart && now <= presaleEnd && presaleTokensLimit > tokensSold) ||
      (now >= firstRoundICOStart && now <= firstRoundICOEnd && firstRoundICOTokensLimit > tokensSold)
      || (now >= secondRoundICOStart && now <= secondRoundICOEnd && secondRoundICOTokensLimit > tokensSold)
      );
    _;
  }

  function Crowdsale() internal onlyOwner {
    etherRaised = 0;
    tokensSold = 0;
  }

  function sellTokens(address _buyer) saleIsOn public payable {
    assert(_buyer != 0x0);
    if(KYC[_buyer]==1 && msg.value > 0){

      multisig.transfer(msg.value);
      etherRaised = etherRaised.add(msg.value);
      uint tokens = rate.mul(msg.value).div(1 ether);
      uint discountTokens = 0;
      if(now >= presaleStart && now <= presaleEnd) {
          if(WhiteList[_buyer]==1) {
              discountTokens = tokens.mul(presaleWhitelistDiscount).div(100);
          }else{
              discountTokens = tokens.mul(presaleDiscount).div(100);
          }
      }
      if(now >= firstRoundICOStart && now <= firstRoundICOEnd) {discountTokens = tokens.mul(firstRoundICODiscount).div(100);}

      uint tokensWithBonus = tokens.add(discountTokens);
      tokensSold = tokensSold.add(tokensWithBonus);
      token.transfer(msg.sender, tokensWithBonus);
    }
  }
 
  function() external payable {
    sellTokens(msg.sender);
  }

  function crowdsaleDetails() public constant returns (uint, uint) {
    return (etherRaised,tokensSold);
  }
    
}
