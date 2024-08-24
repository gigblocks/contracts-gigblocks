// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksView.sol";

contract GigBlocksMain is GigBlocksView {
    constructor(address _reputationContractAddress) GigBlocksView(_reputationContractAddress) {}
}