pragma solidity ^0.5.0;

contract ReserveLike {
}

contract KlaytnDai {
    string public constant name = "Klaytn Dai";
    string public constant symbol = "KDAI";

    string public constant version = "0413";

    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event SetOwner(address owner);

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
        emit SetOwner(_owner);
    }

    function add(uint a, uint b) private pure returns (uint) {
        require(a <= uint(-1) - b);
        return a + b;
    }

    function sub(uint a, uint b) private pure returns (uint) {
        require(a >= b);
        return a - b;
    }

    ReserveLike public Reserve;

    function setReserve(address reserve) public onlyOwner {
        Reserve = ReserveLike(reserve);
    }

    constructor() public {
        owner = msg.sender;
    }

    uint8 public constant decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;  // (holder, spender)

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed holder, address indexed spender, uint amount);

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        if (from != msg.sender && allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = sub(allowance[from][msg.sender], amount);
        }

        if (to == address(Reserve)) {
            burn(from, amount);
            return true;
        }

        balanceOf[from] = sub(balanceOf[from], amount);
        balanceOf[to] = add(balanceOf[to], amount);

        emit Transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function mint(address user, uint amount) private {
        balanceOf[user] = add(balanceOf[user], amount);
        totalSupply = add(totalSupply, amount);

        emit Transfer(address(0), user, amount);
    }

    function burn(address user, uint amount) private {
        balanceOf[user] = sub(balanceOf[user], amount);
        totalSupply = sub(totalSupply, amount);

        emit Transfer(user, address(0), amount);
    }

    function transfer(address to, uint amount) public returns (bool) {
        if (msg.sender == address(Reserve)) {
            mint(to, amount);
            return true;
        }

        return transferFrom(msg.sender, to, amount);
    }
}

