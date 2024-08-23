// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksBase.sol";

abstract contract GigBlocksJobManagement is GigBlocksBase {
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
}