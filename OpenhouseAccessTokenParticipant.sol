pragma solidity ^0.8.0;

import "@openzeppelin/contracts@4.1.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.1.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.1.0/access/Ownable.sol";

contract OpenhouseAccessTokenParticipant is ERC721, ERC721Burnable, Ownable {
    constructor() ERC721("Openhouse Access Token - Participant", "PARTICIPATE") {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}
