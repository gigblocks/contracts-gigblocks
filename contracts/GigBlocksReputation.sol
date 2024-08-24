// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract GigBlocksReputationTesting6 is ERC721, Ownable {
    using ECDSA for bytes32;

    address public authorizedSigner;
    address public gigBlocksMain;

    struct ReputationMetadata {
        uint8 socialMediaFlags;
        bool hasENS;
        uint256 completedProjects;
    }

    mapping(uint256 => ReputationMetadata) public reputationMetadata;
    mapping(address => uint256) public userToTokenId;

    uint256 constant REQUIRED_PROJECTS_FOR_ENS = 2;
    uint256 private _tokenIds;

    event ReputationMinted(address indexed user, uint256 tokenId);
    event ProjectPointsAdded(address indexed user, uint256 points);
    event ReputationUpdated(address indexed user, uint8 socialMediaFlags, bool hasENS, uint256 completedProjects, uint256 totalCompletedProjects);
    event SocialMediaConnected(address indexed user, string platform);
    event ENSClaimed(address indexed user);

    error NotGigBlocksMain();
    error UserAlreadyHasReputationToken();
    error UserDoesNotHaveReputationToken();
    error InvalidSignature();
    error InvalidPlatform();
    error PlatformAlreadyConnected();
    error UserIsNotEligibleForENS();
    error ENSAlreadyClaimed();

    constructor(address _authorizedSigner) ERC721("GigBlocksReputation", "GBR") Ownable(msg.sender) {
        authorizedSigner = _authorizedSigner;
    }

    modifier onlyGigBlocksMain() {
        if (msg.sender != gigBlocksMain) revert NotGigBlocksMain();
        _;
    }

    function setGigBlocksMain(address _gigBlocksMain) external onlyOwner {
        gigBlocksMain = _gigBlocksMain;
    }

    function setAuthorizedSigner(address _newSigner) external onlyOwner {
        authorizedSigner = _newSigner;
    }

    function mintReputation(address user) external onlyGigBlocksMain {
        if (userToTokenId[user] != 0) revert UserAlreadyHasReputationToken();

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _safeMint(user, newTokenId);
        reputationMetadata[newTokenId] = ReputationMetadata(0, false, 0);
        userToTokenId[user] = newTokenId;

        emit ReputationMinted(user, newTokenId);
    }

    function connectSocialMedia(address user, string calldata platform, bytes calldata signature) external onlyGigBlocksMain {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) revert UserDoesNotHaveReputationToken();

        bytes32 messageHash = keccak256(abi.encodePacked(user, platform));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);

        address signer = ECDSA.recover(ethSignedMessageHash, signature);
        if (signer != authorizedSigner) revert InvalidSignature();

        ReputationMetadata storage metadata = reputationMetadata[tokenId];
        uint8 flag;

        if (keccak256(abi.encodePacked(platform)) == keccak256(abi.encodePacked("github"))) {
            flag = 1;
        } else if (keccak256(abi.encodePacked(platform)) == keccak256(abi.encodePacked("linkedin"))) {
            flag = 2;
        } else if (keccak256(abi.encodePacked(platform)) == keccak256(abi.encodePacked("twitter"))) {
            flag = 4;
        } else {
            revert InvalidPlatform();
        }

        if ((metadata.socialMediaFlags & flag) != 0) revert PlatformAlreadyConnected();
        metadata.socialMediaFlags |= flag;
        
        emit SocialMediaConnected(user, platform);
    }

    function claimENS(address user) external onlyGigBlocksMain {
        if (!isEligibleForENS(user)) revert UserIsNotEligibleForENS();
        uint256 tokenId = userToTokenId[user];
        ReputationMetadata storage metadata = reputationMetadata[tokenId];
        if (metadata.hasENS) revert ENSAlreadyClaimed();

        metadata.hasENS = true;
        emit ENSClaimed(user);
        emit ReputationUpdated(user, metadata.socialMediaFlags, true, metadata.completedProjects, metadata.completedProjects);
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

    function getReputationScore(address user) external view returns (uint256) {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) revert UserDoesNotHaveReputationToken();
        ReputationMetadata memory metadata = reputationMetadata[tokenId];
        
        uint256 score = 0;
        
        if (metadata.hasENS) {
            score += 50;
        }
        
        uint8 socialMediaCount = 0;
        for (uint8 i = 0; i < 3; i++) {
            if ((metadata.socialMediaFlags & (1 << i)) != 0) {
                socialMediaCount++;
            }
        }
        score += socialMediaCount * 10;
        
        uint256 projectPoints = metadata.completedProjects > 2 ? 20 : metadata.completedProjects * 10;
        score += projectPoints;
        
        return score > 100 ? 100 : score;
    }

    function isEligibleForENS(address user) public view onlyGigBlocksMain returns (bool) {
        uint256 tokenId = userToTokenId[user];
        if (tokenId == 0) revert UserDoesNotHaveReputationToken();
        return reputationMetadata[tokenId].completedProjects >= REQUIRED_PROJECTS_FOR_ENS;
    }
}