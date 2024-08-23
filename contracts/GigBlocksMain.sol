// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./GigBlocksUserManager.sol";

contract GigBlocksMainTesting2 is GigBlocksUserManager {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}