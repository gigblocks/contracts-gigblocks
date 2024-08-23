// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IGigBlocks.sol";
import "./GigBlocksUserManager.sol";
import "./GigBlocksEnums.sol";

abstract contract GigBlocksBase is Ownable, GigBlocksUserManager, IGigBlocks {
    using GigBlocksEnums for GigBlocksEnums.JobStatus;
    using GigBlocksEnums for GigBlocksEnums.JobCategory;

    // Mappings
    mapping(uint256 => Job) public jobs;

    // State Variables
    uint256[] public jobIds;
    uint256[] public activeJobs;

    // Events
    event JobCreated(uint256 indexed jobId, address indexed client, string jobDetailsIPFS, uint256 payment, GigBlocksEnums.JobCategory category, uint256 deadline);
    event JobUpdated(uint256 indexed jobId, string jobDetailsIPFS);

    // Errors
    error OffsetOutOfBounds();
    error NotClient();
    error NotJobOwner();
    error JobDoesNotExist();

    constructor() GigBlocksUserManager() Ownable(msg.sender) {}   
}