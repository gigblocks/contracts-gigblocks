// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksEnums.sol";

interface IGigBlocks {
        struct Job {
        uint256 id;
        address client;
        address freelancer;
        string jobDetailsIPFS;
        uint256 payment;
        uint256 deadline;
        bool isPaid;
        GigBlocksEnums.JobCategory category;
        GigBlocksEnums.JobStatus status;
        uint256 applicantCount;
    }

    struct Applicant {
        string freelancerName;
        address freelancerWalletAddress;
        string freelancerEmail;
        uint256 bidAmount;
        uint256 bidTime;
        string coverLetter;
    }

    struct EscrowPayment {
        address payer;
        address payee;
        uint256 amount;
        bool released;
        bool refunded;
    }

    //Job Functions
    function createJob(string memory _jobDetailsIPFS, GigBlocksEnums.JobCategory _category) external;
    function updateJobDetails(uint256 _jobId, string calldata _jobDetailsIPFS) external;
    function applyForJob(uint256 _jobId, string memory _name, string memory _email, uint256 _bidAmount, uint256 _bidTime, string memory _coverLetter) external;
    function assignFreelancer(uint256 _jobId, address _freelancer, uint256 _payment, uint256 _deadline) external payable;
    function completeJob(uint256 _jobId) external;
    function approveJob(uint256 _jobId) external;
    function claimPayment(uint256 _jobId) external;

    //View Functions
    function getActiveJobs(uint256 _offset, uint256 _limit) external view returns (Job[] memory);
    function getJobById(uint256 _jobId) external view returns (Job memory);
    function getJobApplicants(uint256 _jobId, uint256 _offset, uint256 _limit) external view returns (Applicant[] memory);
    function getAppliedJobs(address _freelancer, uint256 _offset, uint256 _limit) external view returns (Job[] memory);
    function getActiveJobCount() external view returns (uint256);
    function getJobApplicantCount(uint256 _jobId) external view returns (uint256);
    function getAppliedJobCount(address _freelancer) external view returns (uint256);
    function getFreelancerJobs(address _freelancer, uint256 _offset, uint256 _limit) external view returns (Job[] memory);
    function getClientJobs(address _client, uint256 _offset, uint256 _limit) external view returns (Job[] memory);
    function getClientJobCount(address _client) external view returns (uint256);
    function getFreelancerJobCount(address _freelancer) external view returns (uint256);
}