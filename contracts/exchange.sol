pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
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
    mapping (bytes32 => uint) public filled;
    mapping (bytes32 => uint) public cancelled;
    mapping (bytes32 => Order) public orders;

    // Error Codes
    enum Errors {
        ORDER_EXPIRED,                    // Order has already expired
        ORDER_FULLY_FILLED_OR_CANCELLED,  // Order has already been fully filled or cancelled
        INSUFFICIENT_BALANCE_OR_ALLOWANCE // Insufficient balance or allowance for token transfer
    }

    event LogError(uint8 indexed errorId, bytes32 indexed orderHash);

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
        bytes32 orderHash;
    }

    function createOrder(
        address makerToken, 
        string takerChain, 
        address takerToken, 
        uint makerAmount,
        uint takerAmount) public returns (uint) {
        Order memory order = Order({
            maker: msg.sender,
            makerToken: makerToken,
            takerChain: takerChain,
            takerToken: takerToken,
            makerAmount: makerAmount,
            takerAmount: takerAmount,
            orderHash: getOrderHash(msg.sender, makerToken, takerChain, takerToken, makerAmount, takerAmount)
        });
        require(order.maker == msg.sender);

        if (ERC20Interface(order.maker).approve(owner, order.makerAmount)) {
            orders[order.orderHash] = order;
            return 0;
        } else {
            emit LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
            return 1;
        }
    }

    // function cancelOrder(address[3] orderAddresses, uint[2] orderValues, string takerChain) public returns (uint) {

    // }

    // function fillOrder() {

    // }

    function getOrderHash(
        address maker,
        address makerToken, 
        string takerChain, 
        address takerToken, 
        uint makerAmount,
        uint takerAmount)
        public
        view
        returns (bytes32)
    {
        return keccak256(
            address(this),
            maker,
            makerToken,
            takerChain,
            takerToken,
            makerAmount,
            takerAmount
        );
    }
}


