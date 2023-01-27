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

contract Badge is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    address authorizingAddress;
    Counters.Counter private _tokenIds;
    struct NFTData{
        string name;
        uint level;
        uint startDate;
        string designation;
        uint expiration;
        bool isVerified;
        uint verifiedOn;
    }

    mapping(uint256 => NFTData) public tokenIdToLevels;
    mapping(address => uint256[]) public addressToTokenIds;

    modifier onlyAuthorizedAddress {
        require(msg.sender == authorizingAddress,"Not authorised");
        _;
    }

    constructor(address _authorizingAddress) ERC721 ("Badge", "badge"){
        authorizingAddress = _authorizingAddress;
    }
    
    function mint(string memory name, uint startDate, string memory designation, uint expiration,  address to) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(to, newItemId);
        tokenIdToLevels[newItemId] = NFTData(name,1, startDate,designation,expiration,false,0);
        addressToTokenIds[to].push(newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function generateCharacter(uint256 tokenId) private view returns(string memory){
    NFTData memory level = getLevels(tokenId);
    bytes memory svg = abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
        '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
        '<rect width="100%" height="100%" fill="black" />',
        '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',"Name: ",level.name,'</text>',
        '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.level.toString(),'</text>',
        '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.startDate.toString(),'</text>',
        '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.designation,'</text>',
        '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.isVerified,'</text>',
        '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.verifiedOn.toString(),'</text>',
        '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Level: ",level.expiration,'</text>',
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

    function authorizeValidity(uint tokenId) public onlyAuthorizedAddress {
        NFTData storage nftData = tokenIdToLevels[tokenId];
        nftData.isVerified = true;
        nftData.verifiedOn = block.timestamp;
    }

    function upgrade(uint256 _tokenId, string memory _name, uint _expiration) public onlyAuthorizedAddress{
        require(_exists(_tokenId));
        NFTData storage nftData = tokenIdToLevels[_tokenId];
        nftData.name = _name;
        nftData.expiration = _expiration;
        _setTokenURI(_tokenId, getTokenURI(_tokenId));
    }
}
