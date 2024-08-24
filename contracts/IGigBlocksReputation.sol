// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


interface IGigBlocksReputation {
    function mintReputation(address _user) external;
    function connectSocialMedia(address _user, string calldata platform, bytes calldata signature) external;
    function claimENS(address _user) external;
    function getReputation(address _user) external view returns (uint8 socialMediaFlags, bool hasENS, uint256 completedProjects);
    function getReputationScore(address _user) external view returns (uint256);
    function incrementCompletedProjects(address _user) external;
    function isEligibleForENS(address _user) external view returns (bool);
}