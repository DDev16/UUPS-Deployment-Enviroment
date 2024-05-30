// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

import "./DeedHashedStates.sol";

contract DeedHashedV2 is Initializable, ERC721, AccessControl, Ownable, Pausable, UUPSUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    event TokenMinted(uint256 indexed tokenId, DeedHashedStates.TokenState indexed tokenState, string indexed tokenURI);
    event TokenStateUpdated(uint256 indexed tokenId, DeedHashedStates.TokenState indexed tokenState, string indexed tokenURI);
    event TokenURIUpdated(uint256 indexed tokenId, DeedHashedStates.TokenState indexed tokenState, string indexed tokenURI);
    event TokenMetadataLocked(uint256 indexed tokenId);
    event TokenMetadataUnlocked(uint256 indexed tokenId);
    event ContractURIUpdated(string indexed contractURI);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TRANSFERRER_ROLE = keccak256("TRANSFERRER_ROLE");
    bytes32 public constant STATE_UPDATER_ROLE = keccak256("STATE_UPDATER_ROLE");
    bytes32 public constant METADATA_LOCKER_ROLE = keccak256("METADATA_LOCKER_ROLE");
    bytes32 public constant TOKEN_URI_UPDATER_ROLE = keccak256("TOKEN_URI_UPDATER_ROLE");
    bytes32 public constant CONTRACT_URI_UPDATER_ROLE = keccak256("CONTRACT_URI_UPDATER_ROLE");

    struct Token {
        DeedHashedStates.TokenState state;
        uint256 tokenId;
        string tokenURI;
        bool isMetadataLocked;
    }

    mapping (uint256 => Token) internal tokens;
    string public contractURI;
    string private _name;
    string private _symbol;

    function initialize(
        address _roleAdmin,
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _contractURI
    ) public initializer {
        __ERC721_init(_tokenName, _tokenSymbol);
        __AccessControl_init();
        __Ownable_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        _name = _tokenName;
        _symbol = _tokenSymbol;
        contractURI = _contractURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
        _setupRole(MINTER_ROLE, _roleAdmin);
        _setupRole(TRANSFERRER_ROLE, _roleAdmin);
        _setupRole(STATE_UPDATER_ROLE, _roleAdmin);
        _setupRole(METADATA_LOCKER_ROLE, _roleAdmin);
        _setupRole(TOKEN_URI_UPDATER_ROLE, _roleAdmin);
        _setupRole(CONTRACT_URI_UPDATER_ROLE, _roleAdmin);

        _transferOwnership(_roleAdmin);
    }

    modifier onlyRoleHolder(bytes32 role) {
        require(hasRole(role, msg.sender), "NOT_AUTHORIZED");
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address _to, string memory _tokenURI) public onlyRoleHolder(MINTER_ROLE) whenNotPaused {
        require(bytes(_tokenURI).length > 0, "EMPTY_TOKEN_URI");
        _tokenIdCounter.increment();
        uint256 newTokenId = _tokenIdCounter.current();
        _mint(_to, newTokenId);
        tokens[newTokenId] = Token(DeedHashedStates.TokenState.InitialSetup, newTokenId, _tokenURI, false);
        emit TokenMinted(newTokenId, DeedHashedStates.TokenState.InitialSetup, _tokenURI);
    }

    function updateTokenNameAndSymbol(string memory _tokenName, string memory _tokenSymbol) public onlyOwner {
        _name = _tokenName;
        _symbol = _tokenSymbol;
    }

    function updateContractURI(string memory _contractURI) public onlyRoleHolder(CONTRACT_URI_UPDATER_ROLE) {
        contractURI = _contractURI;
        emit ContractURIUpdated(_contractURI);
    }

    function updateTokenState(uint256 _tokenId, DeedHashedStates.TokenState _state) public onlyRoleHolder(STATE_UPDATER_ROLE) whenNotPaused {
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        Token storage token = tokens[_tokenId];
        require(!token.isMetadataLocked, "METADATA_LOCKED");
        token.state = _state;
        emit TokenStateUpdated(_tokenId, _state, token.tokenURI);
    }

    function updateTokenURI(uint256 _tokenId, string memory _tokenURI) public onlyRoleHolder(TOKEN_URI_UPDATER_ROLE) whenNotPaused {
        require(bytes(_tokenURI).length > 0, "EMPTY_TOKEN_URI");
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        Token storage token = tokens[_tokenId];
        require(!token.isMetadataLocked, "METADATA_LOCKED");
        token.tokenURI = _tokenURI;
        emit TokenURIUpdated(_tokenId, token.state, _tokenURI);
    }

    function updateTokenStateAndURI(uint256 _tokenId, DeedHashedStates.TokenState _state, string memory _tokenURI) public onlyRoleHolder(STATE_UPDATER_ROLE) onlyRoleHolder(TOKEN_URI_UPDATER_ROLE) whenNotPaused {
        require(bytes(_tokenURI).length > 0, "EMPTY_TOKEN_URI");
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        Token storage token = tokens[_tokenId];
        require(!token.isMetadataLocked, "METADATA_LOCKED");
        token.state = _state;
        token.tokenURI = _tokenURI;
        emit TokenStateUpdated(_tokenId, _state, _tokenURI);
        emit TokenURIUpdated(_tokenId, _state, _tokenURI);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenInfo(uint256 _tokenId) public view returns (Token memory) {
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        return tokens[_tokenId];
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        return tokens[_tokenId].tokenURI;
    }

    function lockMetadata(uint256 _tokenId) public onlyRoleHolder(METADATA_LOCKER_ROLE) whenNotPaused {
        require(_exists(_tokenId), "INVALID_TOKEN_ID");
        Token storage token = tokens[_tokenId];
        require(!token.isMetadataLocked, "ALREADY_LOCKED");
        token.isMetadataLocked = true;
        emit TokenMetadataLocked(_tokenId);
    }

    function unlockMetadata(uint256 _tokenId) public whenNotPaused {
        require(ownerOf(_tokenId) == msg.sender, "NOT_TOKEN_OWNER");
        Token storage token = tokens[_tokenId];
        require(token.isMetadataLocked, "ALREADY_UNLOCKED");
        token.isMetadataLocked = false;
        emit TokenMetadataUnlocked(_tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyRoleHolder(TRANSFERRER_ROLE) whenNotPaused {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyRoleHolder(TRANSFERRER_ROLE) whenNotPaused {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyRoleHolder(TRANSFERRER_ROLE) whenNotPaused {
        _safeTransfer(from, to, tokenId, data);
    }

    function grantRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
        emit RoleRevoked(role, account, msg.sender);
    }

    function renounceRole(bytes32 role, address account) public override {
        require(account == msg.sender, "CAN_ONLY_RENOUNCE_FOR_SELF");
        _revokeRole(role, account);
        emit RoleRevoked(role, account, msg.sender);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) public onlyRole(getRoleAdmin(DEFAULT_ADMIN_ROLE)) {
        _setRoleAdmin(role, adminRole);
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
