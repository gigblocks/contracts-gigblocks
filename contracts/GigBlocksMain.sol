// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksView.sol";

contract GigBlocksMainTesting4 is GigBlocksView {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}