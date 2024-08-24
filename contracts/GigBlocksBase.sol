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
    mapping(uint256 => Applicant[]) internal jobApplicants;
    mapping(uint256 => EscrowPayment) public escrows;
    uint256 public platformFeePercentage;

    // State Variables
    uint256[] public jobIds;
    uint256[] public activeJobs;

    // Events
    event JobCreated(uint256 indexed jobId, address indexed client, string jobDetailsIPFS, uint256 payment, GigBlocksEnums.JobCategory category, uint256 deadline);
    event JobUpdated(uint256 indexed jobId, string jobDetailsIPFS);
    event ApplicationSubmitted(uint256 indexed jobId, address indexed applicant);
    event PaymentDeposited(uint256 indexed jobId, address indexed payer, uint256 amount);
    event FreelancerAssigned(uint256 indexed jobId, address indexed freelancer, uint256 payment, uint256 deadline);
    event JobCompleted(uint256 indexed jobId);
    event JobApproved(uint256 indexed jobId);
    event PaymentReleased(uint256 indexed jobId, address indexed recipient, uint256 amount);

    // Errors
    error OffsetOutOfBounds();
    error NotClient();
    error NotFreelancer();
    error NotJobOwner();
    error InsufficientReputationScore();
    error JobDoesNotExist();
    error InvalidJobId();
    error InvalidJobStatus();
    error InvalidPaymentAmount();
    error InvalidDeadline();
    error PaymentAlreadyDeposited();
    error JobDeadlinePassed();
    error FreelancerNotAssigned();
    error PaymentAlreadyReleased();
    error JobNotApproved();

    constructor(address _reputationContractAddress) GigBlocksUserManager(_reputationContractAddress) Ownable(msg.sender) {
        platformFeePercentage = 5; // 0.05%
    }   

    // Internal functions
    function _removeActiveJob(uint256 _jobId) internal {
        for (uint256 i = 0; i < activeJobs.length; i++) {
            if (activeJobs[i] == _jobId) {
                activeJobs[i] = activeJobs[activeJobs.length - 1];
                activeJobs.pop();
                break;
            }
        }
    }

    function _depositPayment(uint256 _jobId, address _payer) internal {
        if (escrows[_jobId].amount != 0) revert PaymentAlreadyDeposited();
        escrows[_jobId] = EscrowPayment(
            _payer,
            address(0),
            msg.value,
            false,
            false
        );

        emit PaymentDeposited(_jobId, _payer, msg.value);
    }

    function _releasePayment(uint256 _jobId, address payable _payee) internal returns (uint256) {
        EscrowPayment storage escrow = escrows[_jobId];
        if (escrow.released || escrow.refunded) revert PaymentAlreadyReleased();
        
        uint256 fee = escrow.amount * platformFeePercentage / 10000;
        uint256 amountToRelease = escrow.amount - fee;
        
        escrow.payee = _payee;
        escrow.released = true;

        payable(owner()).transfer(fee);

        return amountToRelease;
    }
}