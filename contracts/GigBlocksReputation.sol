// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract GigBlocksReputationTesting4 is ERC721, Ownable {
    using ECDSA for bytes32;

    event ReputationMinted(address indexed user, uint256 tokenId);

    constructor() ERC721("GigBlocksReputation", "GBR") Ownable(msg.sender) {}

    modifier onlyGigBlocksMain() {
        require(msg.sender == gigBlocksMain, "Caller is not the GigBlocksMain contract");
        _;
    }

    address public gigBlocksMain;

    struct ReputationMetadata {
        uint8 socialMediaFlags;
        bool hasENS;
        uint256 completedProjects;
    }

    mapping(uint256 => ReputationMetadata) public reputationMetadata;
    mapping(address => uint256) public userToTokenId;

    uint256 private _tokenIds;

    function mintReputation(address user) external onlyGigBlocksMain {
        require(userToTokenId[user] == 0, "User already has a reputation token");

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _safeMint(user, newTokenId);
        reputationMetadata[newTokenId] = ReputationMetadata(0, false, 0);
        userToTokenId[user] = newTokenId;

        emit ReputationMinted(user, newTokenId);
    }
}