// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RealEstateToken is ERC721, Ownable, AccessControl {
    struct Property {
        string name;
        string location;
        uint256 price;
        bool isForSale;
        bool isForRent;
        bool isInspected;
        uint256 mortgageBalance;
    }

    struct Mortgage {
        uint256 amount;
        uint256 installmentsRemaining;
        uint256 installmentAmount;
    }

    struct LeaseAgreement {
        uint256 rentalPeriod;
        uint256 monthlyRent;
        uint256 deposit;
        address renter;
        bool isActive;
    }

    bytes32 public constant REAL_ESTATE_AGENT_ROLE = keccak256("REAL_ESTATE_AGENT_ROLE");
    uint256 public nextTokenId;
    mapping(uint256 => Property) public properties;
    mapping(uint256 => address[]) public propertyOwnershipHistory;
    mapping(uint256 => Mortgage) public propertyMortgages;
    mapping(uint256 => LeaseAgreement) public propertyLeases;
    mapping(uint256 => uint256) public escrowBalances;
    mapping(uint256 => bool) public propertyDisputes;

    event PropertyListedForSale(uint256 indexed tokenId, uint256 price);
    event PropertySold(uint256 indexed tokenId, address indexed newOwner);
    event MortgageCreated(uint256 indexed tokenId, uint256 amount, uint256 installments);
    event LeaseCreated(uint256 indexed tokenId, uint256 rentalPeriod, uint256 monthlyRent);
    event PropertyInspected(uint256 indexed tokenId);
    event DisputeResolved(uint256 indexed tokenId);
    event ListedByAgent(uint256 indexed tokenId, address indexed agent);

    constructor() ERC721('RealEstateToken', 'RET') {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerProperty(string memory name, string memory location, uint256 price) public onlyOwner {
        uint256 tokenId = nextTokenId++;
        properties[tokenId] = Property(name, location, price, false, false, false, 0);
        _safeMint(msg.sender, tokenId);
        propertyOwnershipHistory[tokenId].push(msg.sender);
    }

    function listPropertyForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can sell the property");
        properties[tokenId].isForSale = true;
        properties[tokenId].price = price;
        emit PropertyListedForSale(tokenId, price);
    }

    function buyProperty(uint256 tokenId) public payable {
        require(properties[tokenId].isForSale, "Property is not for sale");
        require(properties[tokenId].isInspected, "Property has not been inspected");
        require(msg.value == properties[tokenId].price, "Incorrect price paid");
        properties[tokenId].isForSale = false;
        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        propertyOwnershipHistory[tokenId].push(msg.sender);
        releaseEscrow(tokenId, seller);
        emit PropertySold(tokenId, msg.sender);
    }

    function createMortgage(uint256 tokenId, uint256 amount, uint256 installments, uint256 installmentAmount) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can create a mortgage");
        propertyMortgages[tokenId] = Mortgage(amount, installments, installmentAmount);
        emit MortgageCreated(tokenId, amount, installments);
    }

    function payMortgageInstallment(uint256 tokenId) public payable {
        Mortgage storage mortgage = propertyMortgages[tokenId];
        require(mortgage.installmentsRemaining > 0, "Mortgage already paid off");
        require(msg.value == mortgage.installmentAmount, "Incorrect installment amount");
        mortgage.amount -= msg.value;
        mortgage.installmentsRemaining--;
        address owner = ownerOf(tokenId);
        payable(owner).transfer(msg.value);
    }

    function createLeaseAgreement(uint256 tokenId, uint256 rentalPeriod, uint256 monthlyRent, uint256 deposit) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can create a lease agreement");
        propertyLeases[tokenId] = LeaseAgreement(rentalPeriod, monthlyRent, deposit, address(0), false);
        emit LeaseCreated(tokenId, rentalPeriod, monthlyRent);
    }

    function signLeaseAgreement(uint256 tokenId) public payable {
        LeaseAgreement storage lease = propertyLeases[tokenId];
        require(msg.value == lease.deposit, "Incorrect deposit amount");
        lease.renter = msg.sender;
        lease.isActive = true;
        depositToEscrow(tokenId);
    }

    function assignAgent(address agent) public onlyOwner {
        _setupRole(REAL_ESTATE_AGENT_ROLE, agent);
    }

    function listPropertyByAgent(uint256 tokenId, uint256 price) public {
        require(hasRole(REAL_ESTATE_AGENT_ROLE, msg.sender), "Caller is not a real estate agent");
        properties[tokenId].isForSale = true;
        properties[tokenId].price = price;
        emit ListedByAgent(tokenId, msg.sender);
    }

    function inspectProperty(uint256 tokenId) public {
        require(hasRole(REAL_ESTATE_AGENT_ROLE, msg.sender) || msg.sender == ownerOf(tokenId), "Unauthorized");
        properties[tokenId].isInspected = true;
        emit PropertyInspected(tokenId);
    }

    function resolveDispute(uint256 tokenId) public onlyOwner {
        propertyDisputes[tokenId] = false;
        emit DisputeResolved(tokenId);
    }

    function depositToEscrow(uint256 tokenId) public payable {
        escrowBalances[tokenId] += msg.value;
    }

    function releaseEscrow(uint256 tokenId, address to) public onlyOwner {
        require(propertyDisputes[tokenId] == false, "Dispute in progress");
        uint256 amount = escrowBalances[tokenId];
        escrowBalances[tokenId] = 0;
        payable(to).transfer(amount);
    }

     /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return ERC721.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }
}
