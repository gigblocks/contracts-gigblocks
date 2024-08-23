// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksBase.sol";

abstract contract GigBlocksJobManagement is GigBlocksBase {
    constructor(address _reputationContractAddress) GigBlocksBase(_reputationContractAddress) {}
    
    function createJob(string calldata _jobDetailsIPFS, GigBlocksEnums.JobCategory _category) external override nonReentrant {
        if (!isRegistered(msg.sender)) revert UserNotRegistered();
        if (!isClient(msg.sender)) revert NotClient();

        uint256 newJobId = uint256(jobIds.length + 1);
        jobIds.push(newJobId);

        Job storage newJob = jobs[newJobId];
        newJob.id = newJobId;
        newJob.client = msg.sender;
        newJob.freelancer = address(0);
        newJob.jobDetailsIPFS = _jobDetailsIPFS;
        newJob.category = _category;
        newJob.payment = 0;
        newJob.deadline = 0;
        newJob.isPaid = false;
        newJob.status = GigBlocksEnums.JobStatus.Open;

        activeJobs.push(newJobId);

        emit JobCreated(newJobId, msg.sender, _jobDetailsIPFS, 0, _category, 0);
    }

    function updateJobDetails(uint256 _jobId, string calldata _jobDetailsIPFS) external override nonReentrant {
        Job storage job = jobs[_jobId];
        if (job.client != msg.sender) revert NotJobOwner();
        job.jobDetailsIPFS = _jobDetailsIPFS;

        emit JobUpdated(_jobId, _jobDetailsIPFS);
    }

    function applyForJob(uint256 _jobId, string memory _name, string memory _email, uint256 _bidAmount, uint256 _bidTime, string memory _coverLetter) external {
        if (_jobId > jobIds.length || _jobId <= 0) revert InvalidJobId();
        Job storage job = jobs[_jobId];
        if (job.status != GigBlocksEnums.JobStatus.Open) revert InvalidJobStatus();

        jobApplicants[_jobId].push(Applicant({
            freelancerName: _name,
            freelancerWalletAddress: msg.sender,
            freelancerEmail: _email,
            bidAmount: _bidAmount,
            bidTime: _bidTime,
            coverLetter: _coverLetter
        }));

        job.applicantCount++;

        emit ApplicationSubmitted(_jobId, msg.sender);
    }

    function assignFreelancer(uint256 _jobId, address _freelancer, uint256 _payment, uint256 _deadline) external payable nonReentrant {
        Job storage job = jobs[_jobId];
        if (job.client != msg.sender) revert NotJobOwner();
        if (job.status != GigBlocksEnums.JobStatus.Open) revert InvalidJobStatus();
        if (msg.value != _payment) revert InvalidPaymentAmount();
        if (!isRegistered(_freelancer)) revert UserNotRegistered();
        if (!isFreelancer(_freelancer)) revert NotFreelancer();
        if (_deadline <= block.timestamp) revert InvalidDeadline();

        job.freelancer = _freelancer;
        job.payment = _payment;
        job.deadline = _deadline;
        job.status = GigBlocksEnums.JobStatus.InProgress;

        _depositPayment(_jobId, msg.sender);
        _removeActiveJob(_jobId);
        
        emit FreelancerAssigned(_jobId, _freelancer, _payment, _deadline);
    }

    function completeJob(uint256 _jobId) external override nonReentrant {
        Job storage job = jobs[_jobId];
        if (job.freelancer != msg.sender) revert FreelancerNotAssigned();
        if (job.status != GigBlocksEnums.JobStatus.InProgress) revert InvalidJobStatus();
        if (block.timestamp > job.deadline) revert JobDeadlinePassed();

        job.status = GigBlocksEnums.JobStatus.Completed;
        emit JobCompleted(_jobId);
    }

    function approveJob(uint256 _jobId) external override nonReentrant {
        Job storage job = jobs[_jobId];
        if (job.client != msg.sender) revert NotJobOwner();
        if (job.status != GigBlocksEnums.JobStatus.Completed) revert InvalidJobStatus();

        job.status = GigBlocksEnums.JobStatus.Approved;
        reputationContract.incrementCompletedProjects(msg.sender);

        emit JobApproved(_jobId);
    }

    function claimPayment(uint256 _jobId) external override nonReentrant {
        Job storage job = jobs[_jobId];
        if (job.freelancer != msg.sender) revert FreelancerNotAssigned();
        if (job.status != GigBlocksEnums.JobStatus.Approved) revert JobNotApproved();
        if (job.isPaid) revert PaymentAlreadyReleased();

        job.isPaid = true;
        uint256 amountToRelease = _releasePayment(_jobId, payable(msg.sender));
        _removeActiveJob(_jobId);

        payable(msg.sender).transfer(amountToRelease);
        reputationContract.incrementCompletedProjects(msg.sender);

        emit PaymentReleased(_jobId, msg.sender, amountToRelease);
    }
}