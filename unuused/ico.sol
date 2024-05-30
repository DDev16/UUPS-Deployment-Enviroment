/**
 *Submitted for verification at Etherscan.io on 2024-04-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/New-ICO.sol


pragma solidity 0.8.20;




interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function decimals() external view returns (uint8);
}

contract ICO is Ownable, ReentrancyGuard {
    
    // state variables
    IERC20 public flearBearToken;
    bool public isPause = false;

    uint256 public preSaleSupply = 23100000000 * 10**18; //23.1 Billion preSale supply
    uint256 public totalSold; // get total sold token
    uint256 public oneTokenPriceInWei; // here we have to store 1 FLEAR = 7777 BEAR so, we have to store 7777 value with decimal

    struct UserInfo {
        uint256 flearValue;  // value in wei number native value
        uint256 bearToken; // value in wei token 
    }

    mapping(address => UserInfo) public userInfo; // user details

    event TokenPurchase(address buyer, uint256 tokenPrice, uint256 buyerTokenAmount);
    event ToggleSale();

    modifier isContractCall(address _account) {
        require(!isContract(_account), "Contract Address");
        _;
    }

    modifier inputNumberCheck(uint256 amount) {
        require(amount != 0, "Invalid number input");
        _;
    }

    modifier isActive() {
        require(!isPause, "Sale not Active");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    constructor(address _flearBearToken) Ownable(msg.sender) validAddress(_flearBearToken)
    {
        flearBearToken = IERC20(_flearBearToken); // token contract address
        oneTokenPriceInWei = 7777*10**flearBearToken.decimals();
    }
    
    /// @notice Function to update the supply
    /// @param _newSupply The new supply in wei
    function updatePreSaleSupply(uint256 _newSupply) external inputNumberCheck(_newSupply) onlyOwner {
        preSaleSupply = _newSupply;
    }

    /// @notice Function to update the price
    /// @param _oneTokenPriceInWei The new price in wei
    function updateOneTokenPriceInWei(uint256 _oneTokenPriceInWei) external inputNumberCheck(_oneTokenPriceInWei) onlyOwner {
        oneTokenPriceInWei = _oneTokenPriceInWei;
    }
    
    /// @notice Function to update the token address
    /// @param _tokenAddress The token address
    function updateToken(IERC20 _tokenAddress) external onlyOwner {
        flearBearToken = IERC20(_tokenAddress);
    }
    
    /// @notice Function to withdraw token from contract address if stuck
    /// @param _tokenAddress The token address of which we want to with token
    /// @param _tokenAmount The token amount in wei
    function withdrawTokenFromContract(address _tokenAddress, uint256 _tokenAmount) external onlyOwner returns(bool){
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this))>= _tokenAmount,"Insufficient token");
        token.transfer(msg.sender, _tokenAmount);
        return true;
    }
    
    /// @notice Function to withdraw native coin from contract address
    /// @param _flearAmount The native token amount
    function withdrawNativeCoin(uint256 _flearAmount) external onlyOwner returns(bool){
        require(address(this).balance >= _flearAmount, "Insufficient fund on contract");
        payable(owner()).transfer(_flearAmount);
        return true;
    }
    
    /// @notice Function to get the native coin of contract address
    function getNativeBalance() external view returns(uint256){
        return address(this).balance;
    }
    
    /// @notice Function to get estimate price of token
    /// @param flearBearAmount The token amount user want to buy, the value in wei
    function estimateFund(uint256 flearBearAmount) public view inputNumberCheck(flearBearAmount) returns(uint256){
        uint256 payableValue = (flearBearAmount* 10**18) / oneTokenPriceInWei;
        return payableValue;
    }

    /// @notice Function to buy flearBear token with native token, the fund goes to contract if someone buy.
    /// @param flearBearAmount The amount of flearBear token user want to buy. ex: user want 500 bear token then we have to pass 500*10**18(value in wei)
    /// @dev We have to send value like if someone try to buy token direct then they have to pass value as well, estimateFund will return the value corresponsing to bear token.
    function preSale(uint256 flearBearAmount) external payable isActive inputNumberCheck(flearBearAmount) isContractCall(msg.sender) nonReentrant
        returns (bool)
    {
        require(flearBearToken.balanceOf(address(this))>= flearBearAmount,"Insufficient token on contract");
        uint256 estimatedNative = estimateFund(flearBearAmount);
        totalSold += flearBearAmount;
        require(totalSold <= preSaleSupply,"Pre-sale supply reached");
        require(msg.value >= estimatedNative, "Insufficient funds");
        userInfo[msg.sender].flearValue += msg.value;
        userInfo[msg.sender].bearToken += flearBearAmount;
        flearBearToken.transfer(msg.sender, flearBearAmount);
        emit TokenPurchase(msg.sender, msg.value, flearBearAmount);
        return true;
    }

    /// @notice Function to toggle the buy functionality
    function toggleSale() external onlyOwner returns (bool) {
        isPause = !isPause;
        emit ToggleSale();
        return isPause;
    }

    // function to check contract address
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // To received native fund on contract
    receive() external payable {}
}