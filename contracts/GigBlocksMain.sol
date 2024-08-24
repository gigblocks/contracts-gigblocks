// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksView.sol";

contract GigBlocksMainTesting6 is GigBlocksView {
    constructor(address _reputationContractAddress) GigBlocksView(_reputationContractAddress) {}
}