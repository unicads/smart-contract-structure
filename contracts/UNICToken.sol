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

contract UNICToken is owned, StandardToken {
    
    string public constant name = 'UNIC Token';
    string public constant symbol = 'UNIC';
    uint8 public constant decimals = 18;
    
    uint256 public initialSupply = 250000000 * 10 ** uint256(decimals);

    uint public constant airDropLimit = 1000000 * 10**18;
    
    address public icoManager;
    
    mapping (address => uint256) public WhiteList;
    mapping (address => uint256) public Female;

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
      return true;
    }

    function setWhiteList(address[] dests) onlyOwner external {
      uint256 i = 0;
      while (i < dests.length) {
        if(dests[i] != 0x0){
          WhiteList[dests[i]] = 1;
        }
      }
    }

    function setFemaleBonus(address[] dests) onlyOwner external {
      uint256 i = 0;
      while (i < dests.length) {
        if(dests[i] != 0x0){
          Female[dests[i]] = 1;
          WhiteList[dests[i]] = 1;
        }
      }
    }
    
    function airDrop(address[] dests, uint256 value) onlyOwner external {
      uint256 i = 0;
      uint256 toSend = value * 10**18;
      while (i < dests.length) {
        if(dests[i] != 0x0){
          transfer(dests[i], toSend);
        }
        i++;
      }
    } 
}

contract Crowdsale is owned, UNICToken {
    
  using SafeMath for uint;
  
  UNICToken public token = new UNICToken();
  
  address constant multisig = 0xf9eDB6cF8dCEe45584BbE27E3DB8Ca9d578d0d60;
  uint constant rate = 3400 * 10**18;

/* <Marketing> */

  uint public constant presaleFemaleStart = 1520467200;       /** 08.03 */
  uint public constant presaleFemaleEnd = 1520553600;         /** 09.03 */
  uint public constant presaleFemaleDiscount = 60;  

  uint public constant presalePiStart = 1520985600;           /** 14.03 The day of number PI */
  uint public constant presalePiEnd = 1521072000;             /** 15.03 */
  uint public constant presalePiDiscount = 34;

  uint public constant presaleWMStart = 1522800000;           /** 04.04 The Day of webmaster 404 */
  uint public constant presaleWMEnd = 1522886400;             /** 05.04 */
  uint public constant presaleWMDiscount = 24;

  uint public constant presaleCosmosStart = 1523491200;       /** 12.04 The day of cosmonautics */
  uint public constant presaleCosmosEnd = 1523577600;         /** 13.04 */
  uint public constant presaleCosmosDiscount = 24;

  uint public constant presaleMayStart = 1525132800;          /** 01.05 International Solidarity Day for Workers */
  uint public constant presaleMayEnd = 1525219200;            /** 02.05 */
  uint public constant presaleMayDiscount = 15;

/* </Marketing> */

  uint public constant presaleWhitelistDiscount = 40;
  uint public constant presaleWhitelistTokensLimit = 750000 * 10**18;

  uint public constant presaleStart = 1520503200;           /** 08.03 */
  uint public constant presaleEnd = 1521453600;             /** 19.03 */
  uint public constant presaleDiscount = 30;
  uint public constant presaleTokensLimit = 5000000 * 10**18;

  uint public constant firstRoundICOStart = 1522317600;      /** 29.03 */
  uint public constant firstRoundICOEnd = 1523527200;        /** 12.04 */
  uint public constant firstRoundICODiscount = 20;
  uint public constant firstRoundICOTokensLimit = 6250000 * 10**18;

  uint public constant secondRoundICOStart = 1524736800;     /** 26.04 */
  uint public constant secondRoundICOEnd = 1526551200;       /** 17.05 */
  uint public constant secondRoundICODiscount = 10;
  uint public constant secondRoundICOTokensLimit = 43750000 * 10**18;

  uint public etherRaised;
  uint public tokensSold;
  uint public tokensSoldWhitelist;

  modifier saleIsOn() {
    require((now >= presaleStart && now <= presaleEnd) ||
      (now >= firstRoundICOStart && now <= firstRoundICOEnd)
      || (now >= secondRoundICOStart && now <= secondRoundICOEnd)
      );
    _;
  }

  function Crowdsale() public onlyOwner {
    etherRaised = 0;
    tokensSold = 0;
    tokensSoldWhitelist = 0;
  }
  
  function() external payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address _buyer) saleIsOn public payable {
    assert(_buyer != 0x0);
    if(msg.value > 0){

      uint tokens = rate.mul(msg.value).div(1 ether);
      uint discountTokens = 0;
      if(now >= presaleStart && now <= presaleEnd) {
          discountTokens = tokens.mul(presaleDiscount).div(100);
          if(WhiteList[_buyer]==1) {
              discountTokens = tokens.mul(presaleWhitelistDiscount).div(100);
          }
          if(now >= presaleFemaleStart && now <= presaleFemaleEnd && Female[_buyer]==1) {
              discountTokens = tokens.mul(presaleFemaleDiscount).div(100);
          }
          if(now >= presalePiStart && now <= presalePiEnd) {
              discountTokens = tokens.mul(presalePiDiscount).div(100);
          }
      }
      if(now >= firstRoundICOStart && now <= firstRoundICOEnd) {
          discountTokens = tokens.mul(firstRoundICODiscount).div(100);
          if(now >= presaleWMStart && now <= presaleWMEnd) {
              discountTokens = tokens.mul(presaleWMDiscount).div(100);
          }
          if(now >= presaleCosmosStart && now <= presaleCosmosEnd) {
              discountTokens = tokens.mul(presaleCosmosDiscount).div(100);
          }
      }
      if(now >= secondRoundICOStart && now <= secondRoundICOEnd) {
          discountTokens = tokens.mul(secondRoundICODiscount).div(100);
          if(now >= presaleMayStart && now <= presaleMayEnd) {
              discountTokens = tokens.mul(presaleMayDiscount).div(100);
          }
      }
      
      uint tokensWithBonus = tokens.add(discountTokens);
      
      if(
          (now >= presaleStart && now <= presaleEnd && presaleTokensLimit > tokensSold + tokensWithBonus &&
            ((WhiteList[_buyer]==1 && presaleWhitelistTokensLimit > tokensSoldWhitelist + tokensWithBonus) || WhiteList[_buyer]!=1)
          ) ||
          (now >= firstRoundICOStart && now <= firstRoundICOEnd && firstRoundICOTokensLimit > tokensSold + tokensWithBonus) ||
          (now >= secondRoundICOStart && now <= secondRoundICOEnd && secondRoundICOTokensLimit > tokensSold + tokensWithBonus)
      ){
      
        multisig.transfer(msg.value);
        etherRaised = etherRaised.add(msg.value);
        token.transfer(msg.sender, tokensWithBonus);
        tokensSold = tokensSold.add(tokensWithBonus);
        if(WhiteList[_buyer]==1) {
          tokensSoldWhitelist = tokensSoldWhitelist.add(tokensWithBonus);
        }
      }
    }
  }
}
