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
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
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
    using SafeMath for uint;

    mapping (bytes32 => uint) public filled;
    mapping (bytes32 => uint) public cancelled;
    mapping (bytes32 => Order) public orders;
    bytes32[] public orderHashes;

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

        // TODO use increaseApproval
        if (ERC20Interface(makerToken).approve(owner, order.makerAmount)) {
            orderHashes.push(order.orderHash);
            orders[order.orderHash] = order;
            return 0;
        } else {
            emit LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
            return 1;
        }
    }

    function cancelOrder(
        address makerToken, 
        string takerChain, 
        address takerToken, 
        uint makerAmount,
        uint takerAmount,
        uint cancelTakerAmount) public returns (uint) {
        Order memory order = Order({
            maker: msg.sender,
            makerToken: makerToken,
            takerChain: takerChain,
            takerToken: takerToken,
            makerAmount: makerAmount,
            takerAmount: takerAmount,
            orderHash: getOrderHash(msg.sender, makerToken, takerChain, takerToken, makerAmount, takerAmount)
        });

        uint remainingAmount = order.takerAmount.sub(filled[order.orderHash].add(cancelled[order.orderHash]));
        if (remainingAmount > 0) {
            uint cancelledAmount = cancelTakerAmount > remainingAmount ? remainingAmount : cancelTakerAmount;
            cancelled[order.orderHash] = cancelled[order.orderHash].add(cancelledAmount);
            // revoke approval
            ERC20Interface(makerToken).approve(owner, 0);
            return 0;
        } else {
            emit LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
            return 1;
        }
    }

    function fillOrder(
        address maker,
        address makerToken, 
        string takerChain, 
        address takerToken, 
        uint makerAmount,
        uint takerAmount,
        address taker,
        uint fillAmount) public returns (uint) {
        Order memory order = Order({
            maker: maker,
            makerToken: makerToken,
            takerChain: takerChain,
            takerToken: takerToken,
            makerAmount: makerAmount,
            takerAmount: takerAmount,
            orderHash: getOrderHash(maker, makerToken, takerChain, takerToken, makerAmount, takerAmount)
        });

        uint remainingAmount = order.takerAmount.sub(filled[order.orderHash].add(cancelled[order.orderHash]));
        if (remainingAmount >= fillAmount) {
            filled[order.orderHash] = filled[order.orderHash].add(fillAmount);
            if (ERC20Interface(makerToken).transferFrom(maker, taker, fillAmount)) {
                return 0;
            } else {
                emit LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);
                return 1;
            }
        } else {
            emit LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);
            return 1;
        }
    }

    function getOrderFilled(bytes32 orderHash) public view returns (uint) {
        return filled[orderHash];
    }

    function getOrderCancelled(bytes32 orderHash) public view returns (uint) {
        return cancelled[orderHash];
    }

    function getOrder(bytes32 orderHash) public view returns(address, address, string, address, uint, uint) {
        Order memory order = orders[orderHash];
        return (order.maker, order.makerToken, order.takerChain, order.takerToken, order.makerAmount, order.takerAmount);
    }

    // TODO add page params
    function getOpenOrderHashes() public view returns(bytes32[]) {
        uint per_page = 10;
        bytes32[] memory result = new bytes32[](per_page);
        uint counter = 0;
        for(uint i = 0; i < orderHashes.length; i++) {
            bytes32 orderHash = orderHashes[i];
            Order memory order = orders[orderHash];
            if (order.takerAmount.sub(filled[order.orderHash].add(cancelled[order.orderHash])) > 0) {
                result[counter] = orderHash;
                counter++;
                if (counter == per_page) {
                    return result;
                }
            }
        }
        return result;
    }

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
            abi.encodePacked(
                address(this),
                maker,
                makerToken,
                takerChain,
                takerToken,
                makerAmount,
                takerAmount
            )
        );
    }
}


