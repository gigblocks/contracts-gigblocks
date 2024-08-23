// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract GigBlocksResolverENS {
    address constant L1_SLOAD_ADDRESS = 0x0000000000000000000000000000000000000101;
    address constant ENS_PUBLIC_RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;
    uint256 constant COIN_TYPE = 60;
    uint256 constant SLOT = 2;
    uint256 constant RECORD_VERSION = 0;

    function resolveENS(bytes32 node) public view returns (address resolved, bytes memory rawResult) {
        bytes32 finalSlot = calculateFinalSlot(node);
        rawResult = readSingleSlot(ENS_PUBLIC_RESOLVER, finalSlot);
        resolved = address(uint160(uint256(bytes32(rawResult))));
        return (resolved, rawResult);
    }

    function calculateFinalSlot(bytes32 node) public pure returns (bytes32) {
        bytes32 topSlot = keccak256(abi.encodePacked(uint256(RECORD_VERSION), uint256(SLOT)));
        bytes32 middleSlot = keccak256(abi.encodePacked(node, topSlot));
        return keccak256(abi.encodePacked(COIN_TYPE, middleSlot));
    }

    function readSingleSlot(address l1_contract, bytes32 slot) public view returns (bytes memory) {
        bytes memory input = abi.encodePacked(l1_contract, slot);

        bool success;
        bytes memory result;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        return result;
    }

    function debugInfo(bytes32 node) public view returns (
        bytes32 finalSlot,
        bytes memory input,
        address resolvedAddress,
        bytes memory rawResult
    ) {
        finalSlot = calculateFinalSlot(node);
        input = abi.encodePacked(ENS_PUBLIC_RESOLVER, finalSlot);
        (resolvedAddress, rawResult) = resolveENS(node);
        return (finalSlot, input, resolvedAddress, rawResult);
    }
}