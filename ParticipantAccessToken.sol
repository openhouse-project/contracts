pragma solidity ^0.8.0;

Oimport "@openzeppelin/contracts@4.1.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.1.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.1.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.1.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.1.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.1.0/utils/Counters.sol";

contract ParticipantAccessToken is ERC721, ERC721Enumerable, Pausable, AccessControl, ERC721Burnable {
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Participant Access Token", "PAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function safeMint(address to) public {
        require(hasRole(MINTER_ROLE, msg.sender));
        _safeMint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function pause() public {
        require(hasRole(PAUSER_ROLE, msg.sender));
        _pause();
    }

    function unpause() public {
        require(hasRole(PAUSER_ROLE, msg.sender));
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
