// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksJobManagement.sol";

abstract contract GigBlocksView is GigBlocksJobManagement {
    constructor(address _reputationContractAddress) GigBlocksJobManagement(_reputationContractAddress) {}
    
    function getActiveJobs(uint256 _offset, uint256 _limit) external view override returns (Job[] memory) {
        uint256 totalActiveJobs = activeJobs.length;
        if (_offset >= totalActiveJobs) revert OffsetOutOfBounds();

        uint256 remainingJobs = totalActiveJobs - _offset;
        uint256 jobsToReturn = remainingJobs < _limit ? remainingJobs : _limit;

        Job[] memory result = new Job[](jobsToReturn);

        for (uint256 i = 0; i < jobsToReturn; i++) {
            result[i] = jobs[activeJobs[_offset + i]];
        }

        return result;
    }

    function getJobById(uint256 _jobId) external view override returns (Job memory) {
        Job memory job = jobs[_jobId];
        if (job.client == address(0)) revert JobDoesNotExist();
        return job;
    }

    function getJobApplicants(uint256 _jobId, uint256 _offset, uint256 _limit) external view returns (Applicant[] memory) {
        if (_jobId > jobIds.length || _jobId <= 0) revert InvalidJobId();
        Applicant[] storage allApplicants = jobApplicants[_jobId];
        uint256 totalApplicants = allApplicants.length;

        if (_offset >= totalApplicants) return new Applicant[](0);

        uint256 remainingApplicants = totalApplicants - _offset;
        uint256 applicantsToReturn = remainingApplicants < _limit ? remainingApplicants : _limit;

        Applicant[] memory result = new Applicant[](applicantsToReturn);
        for (uint256 i = 0; i < applicantsToReturn; i++) {
            result[i] = allApplicants[_offset + i];
        }

        return result;
    }

    function getClientJobs(address _client, uint256 _offset, uint256 _limit) external view override returns (Job[] memory) {
        uint256[] memory clientJobIds = new uint256[](_limit);
        uint256 count = 0;

        for (uint256 i = _offset; i < jobIds.length && count < _limit; i++) {
            if (jobs[jobIds[i]].client == _client) {
                clientJobIds[count] = jobIds[i];
                count++;
            }
        }

        Job[] memory result = new Job[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = jobs[clientJobIds[i]];
        }

        return result;
    }

    function getFreelancerJobs(address _freelancer, uint256 _offset, uint256 _limit) external view override returns (Job[] memory) {
        uint256[] memory freelancerJobIds = new uint256[](_limit);
        uint256 count = 0;

        for (uint256 i = _offset; i < jobIds.length && count < _limit; i++) {
            if (jobs[jobIds[i]].freelancer == _freelancer) {
                freelancerJobIds[count] = jobIds[i];
                count++;
            }
        }

        Job[] memory result = new Job[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = jobs[freelancerJobIds[i]];
        }

        return result;
    }

    function getActiveJobCount() public view override returns (uint256) {
        return activeJobs.length;
    }

    function getJobApplicantCount(uint256 _jobId) external view returns (uint256) {
        require(_jobId > 0 && _jobId <= jobIds.length, "Invalid job ID");
        return jobApplicants[_jobId].length;
    }

    function getClientJobCount(address _client) public view override returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < jobIds.length; i++) {
            if (jobs[jobIds[i]].client == _client) {
                count++;
            }
        }
        return count;
    }

    function getFreelancerJobCount(address _freelancer) public view override returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < jobIds.length; i++) {
            if (jobs[jobIds[i]].freelancer == _freelancer) {
                count++;
            }
        }
        return count;
    }
}