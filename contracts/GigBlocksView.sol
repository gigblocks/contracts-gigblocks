// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksJobManagement.sol";

abstract contract GigBlocksView is GigBlocksJobManagement {
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

    function getActiveJobCount() public view override returns (uint256) {
        return activeJobs.length;
    }
}