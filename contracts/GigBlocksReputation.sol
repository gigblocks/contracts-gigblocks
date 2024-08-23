// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract GigBlocksReputationTesting4 is ERC721, Ownable {
    using ECDSA for bytes32;

    constructor() ERC721("GigBlocksReputation", "GBR") Ownable(msg.sender) {}

    address public gigBlocksMain;

    struct ReputationMetadata {
        uint8 socialMediaFlags;
        bool hasENS;
        uint256 completedProjects;
    }

    mapping(uint256 => ReputationMetadata) public reputationMetadata;
    mapping(address => uint256) public userToTokenId;
}