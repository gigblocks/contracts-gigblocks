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
        uint256 totalRating;
        uint256 ratingCount;
    }

    struct Rating {
        string username;
        string description;
        uint8 stars;
        uint256 ratedAt;
    }

    mapping(address => UserProfile) private users;
    mapping(address => Rating[]) private userRatings;
    address[] private userAddresses;

    uint8 public constant MAX_RATING = 5;

    event ProfileUpdated(address indexed user, string profileIPFS);
    event PreferencesUpdated(address indexed user, GigBlocksEnums.JobCategory[] preferences);
    event UserRegistered(address indexed user, uint256 registrationDate, bool isFreelancer, bool isClient);
    event RatingAdded(address indexed ratedUser, address indexed rater, uint8 stars, string description);

    error UserAlreadyRegistered();
    error InvalidUserType();
    error UserNotRegistered();
    error InvalidRating();
    error CannotRateSelf();

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
            preferences: _preferences,
            totalRating: 0,
            ratingCount: 0
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

    function addRating(address _user, string calldata _username, uint8 _stars, string calldata _description) external nonReentrant {
        if (!isRegistered(_user)) revert UserNotRegistered();
        if (_stars < 1 || _stars > MAX_RATING) revert InvalidRating();
        if (_user == msg.sender) revert CannotRateSelf();

        UserProfile storage profile = users[_user];
        profile.totalRating += _stars;
        profile.ratingCount++;

        userRatings[_user].push(Rating({
            username: _username,
            description: _description,
            stars: _stars,
            ratedAt: block.timestamp
        }));

        emit RatingAdded(_user, msg.sender, _stars, _description);
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
        if (!isRegistered(_user)) revert UserNotRegistered();
        return reputationContract.getReputationScore(_user);
    }

    function getUserRatings(address _user, uint256 _offset, uint256 _limit) external view returns (Rating[] memory) {
        if (!isRegistered(_user)) revert UserNotRegistered();
        
        Rating[] storage allRatings = userRatings[_user];
        uint256 totalRatings = allRatings.length;

        if (_offset >= totalRatings) {
            return new Rating[](0);
        }

        uint256 remainingRatings = totalRatings - _offset;
        uint256 ratingsToReturn = remainingRatings < _limit ? remainingRatings : _limit;

        Rating[] memory result = new Rating[](ratingsToReturn);
        for (uint256 i = 0; i < ratingsToReturn; i++) {
            result[i] = allRatings[_offset + i];
        }

        return result;
    }

    function getUserRatingCount(address _user) external view returns (uint256) {
        if (!isRegistered(_user)) revert UserNotRegistered();
        return userRatings[_user].length;
    }

    function getUserAverageRating(address _user) external view returns (uint256) {
        if (!isRegistered(_user)) revert UserNotRegistered();
        UserProfile storage profile = users[_user];
        if (profile.ratingCount == 0) return 0;
        return (profile.totalRating * 100) / profile.ratingCount;
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
