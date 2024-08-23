// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./GigBlocksEnums.sol";

abstract contract GigBlocksUserManager is AccessControl, ReentrancyGuard {
    using GigBlocksEnums for GigBlocksEnums.JobCategory;

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
