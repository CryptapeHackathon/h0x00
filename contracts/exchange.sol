pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Exchanger is Owned {
    uint[] public deleted;
    Order[] public orders;

    struct Order {
        // 发起人的地址
        address maker;
        // 发起人的代币合约地址
        address makerToken;
        // 兑换代币的链名（暂时用RPC地址代替）
        string  takerChain;
        // 兑换代币的合约地址
        address takerToken;
        uint makerAmount;
        uint takerAmount;
    }

    function createOrder(
        address makerToken, 
        string takerChain, 
        address takerToken, 
        uint makerAmount,
        uint takerAmount) public {
        Order memory order = Order({
            maker: msg.sender,
            makerToken: makerToken,
            takerChain: takerChain,
            takerToken: takerToken,
            makerAmount: makerAmount,
            takerAmount: takerAmount
        });

        if (ERC20Interface(order.maker).approve(owner, order.makerAmount)) {
            orders.push(order);
        }
    }

    function cancelOrder(uint orderId) public onlyOwner {
        deleted.push(orderId);
    }

    function fillOrder(uint orderId, address taker) public onlyOwner {
        Order storage order = orders[orderId];
        deleted.push(orderId);
        ERC20Interface(order.maker).transferFrom(order.maker, taker, order.makerAmount);
    }
}
