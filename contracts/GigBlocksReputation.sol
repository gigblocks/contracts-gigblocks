// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract GigBlocksReputationTesting4 is ERC721, Ownable {
    using ECDSA for bytes32;

    event ReputationMinted(address indexed user, uint256 tokenId);
    event ProjectPointsAdded(address indexed user, uint256 points);
    event ReputationUpdated(address indexed user, uint8 socialMediaFlags, bool hasENS, uint256 completedProjects, uint256 totalCompletedProjects);

    error NotGigBlocksMain();
    error UserAlreadyHasReputationToken();
    error UserDoesNotHaveReputationToken();

    constructor() ERC721("GigBlocksReputation", "GBR") Ownable(msg.sender) {}

    modifier onlyGigBlocksMain() {
        if (msg.sender != gigBlocksMain) revert NotGigBlocksMain();
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
        if (userToTokenId[user] != 0) revert UserAlreadyHasReputationToken();

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _safeMint(user, newTokenId);
        reputationMetadata[newTokenId] = ReputationMetadata(0, false, 0);
        userToTokenId[user] = newTokenId;

        emit ReputationMinted(user, newTokenId);
    }

    function incrementCompletedProjects(address user) external onlyGigBlocksMain {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) revert UserDoesNotHaveReputationToken();

        ReputationMetadata storage metadata = reputationMetadata[tokenId];
        metadata.completedProjects++;

        emit ProjectPointsAdded(user, 1);
        emit ReputationUpdated(user, metadata.socialMediaFlags, metadata.hasENS, metadata.completedProjects, metadata.completedProjects);
    }

    function getReputation(address user) external view onlyGigBlocksMain returns (uint8 socialMediaFlags, bool hasENS, uint256 completedProjects) {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) revert UserDoesNotHaveReputationToken();
        ReputationMetadata memory metadata = reputationMetadata[tokenId];
        return (metadata.socialMediaFlags, metadata.hasENS, metadata.completedProjects);
    }
}