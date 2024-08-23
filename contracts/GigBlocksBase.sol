// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IGigBlocks.sol";
import "./GigBlocksUserManager.sol";
import "./GigBlocksEnums.sol";

abstract contract GigBlocksBase is Ownable, GigBlocksUserManager, IGigBlocks {}