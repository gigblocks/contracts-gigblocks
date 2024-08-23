// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GigBlocksEnums.sol";
import "./GigBlocksReputation.sol";

abstract contract GigBlocksUserManager is ReentrancyGuard {
    using GigBlocksEnums for GigBlocksEnums.JobCategory;

    GigBlocksReputationTesting4 public reputationContract;

    struct UserProfile {
        string profileIPFS;
        uint8 flags;
        uint256 registrationDate;
        GigBlocksEnums.JobCategory[] preferences;
    }

    mapping(address => UserProfile) private users;
    address[] private userAddresses;

    event ProfileUpdated(address indexed user, string profileIPFS);
    event PreferencesUpdated(address indexed user, GigBlocksEnums.JobCategory[] preferences);
    event UserRegistered(address indexed user, uint256 registrationDate, bool isFreelancer, bool isClient);

    error UserAlreadyRegistered();
    error InvalidUserType();
    error UserNotRegistered();

    constructor(address _reputationContractAddress) {
        reputationContract = GigBlocksReputationTesting4(_reputationContractAddress);
    }

    function register(
        string calldata _profileIPFS,
        GigBlocksEnums.JobCategory[] calldata _preferences,
        bool _isFreelancer,
        bool _isClient
    ) external nonReentrant {
        if (isRegistered(msg.sender)) revert UserAlreadyRegistered();
        if (!_isFreelancer && !_isClient) revert InvalidUserType();

        users[msg.sender] = UserProfile({
            profileIPFS: _profileIPFS,
            flags: 1 | (_isFreelancer ? 2 : 0) | (_isClient ? 4 : 0),
            registrationDate: block.timestamp,
            preferences: _preferences
        });

        userAddresses.push(msg.sender);
        reputationContract.mintReputation(msg.sender);

        emit UserRegistered(msg.sender, block.timestamp, _isFreelancer, _isClient);
    }

    function updateProfileIPFS(string calldata _profileIPFS) external nonReentrant {
        if (users[msg.sender].flags & 1 == 0) revert UserNotRegistered();
        users[msg.sender].profileIPFS = _profileIPFS;
        emit ProfileUpdated(msg.sender, _profileIPFS);
    }

    function updateUserPreferences(GigBlocksEnums.JobCategory[] calldata _preferences) external nonReentrant {
        if (users[msg.sender].flags & 1 == 0) revert UserNotRegistered();
        users[msg.sender].preferences = _preferences;
        emit PreferencesUpdated(msg.sender, _preferences);
    }

    function connectSocialMedia(string calldata platform, bytes calldata signature) external nonReentrant {
        if (users[msg.sender].flags & 1 == 0) revert UserNotRegistered();
        reputationContract.connectSocialMedia(msg.sender, platform, signature);
    }

    function claimENS() external nonReentrant {
        if (users[msg.sender].flags & 1 == 0) revert UserNotRegistered();
        reputationContract.claimENS(msg.sender);
    }

    function getReputation(address _user) external view returns (uint8 socialMediaFlags, bool hasENS, uint256 completedProjects) {
        if (users[_user].flags & 1 == 0) revert UserNotRegistered();
        return reputationContract.getReputation(_user);
    }

    function getReputationScore(address _user) external view returns (uint256) {
        require(users[_user].flags & 1 != 0, "User is not registered");
        return reputationContract.getReputationScore(_user);
    }

    function getUserProfile(address _user) external view returns (UserProfile memory) {
        return users[_user];
    }

    function isRegistered(address _user) public view returns (bool) {
        return users[_user].flags & 1 != 0;
    }

    function isFreelancer(address _user) public view returns (bool) {
        return users[_user].flags & 2 != 0;
    }

    function isClient(address _user) public view returns (bool) {
        return users[_user].flags & 4 != 0;
    }
}
