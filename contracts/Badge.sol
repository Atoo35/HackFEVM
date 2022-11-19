// SPDX-License-Identifier: MIT
//0x696e1aF3b2750d6CbEFa5Afe17150253aD461e73
//0xA53c3Af634f3bf736FA62d9943720fb93205e42F
//0xedB244a0D82B622A6CadeB04527c9D4E2a19380d
//0x0494205C225a0c70e029b4330311d2553Dac6C24
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Badge is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    struct NFTData{
        string name;
        uint level;
    }
    mapping(uint256 => NFTData) public tokenIdToLevels;
    mapping(address => uint256[]) public addressToTokenIds;

    constructor() ERC721 ("Badge", "badge"){
    }
    
    function mint(string memory name, address to) public onlyOwner {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        tokenIdToLevels[newItemId] = NFTData(name,1);
        addressToTokenIds[to].push(newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){
    NFTData memory level = getLevels(tokenId);
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Name: ",level.name,'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.level.toString(),'</text>',
        '</svg>'
    );
    return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,",
            Base64.encode(svg)
        )    
    );  
    }

    function getLevels(uint256 tokenId) public view returns (NFTData memory) {
    NFTData memory levels = tokenIdToLevels[tokenId];
    return levels;
    }

    function getAllTokenIdsOfAddress(address user) public view returns (uint256[] memory){
        return addressToTokenIds[user];
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Badge #', tokenId.toString(), '",',
            '"description": "Badge",',
            '"image": "',generateCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        )
    );
    }

     function train(uint256 tokenId, string memory name) public onlyOwner{
        require(_exists(tokenId));
        NFTData storage currentLevel = tokenIdToLevels[tokenId];
        tokenIdToLevels[tokenId].level = currentLevel.level + 1;
        tokenIdToLevels[tokenId].name = name;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}