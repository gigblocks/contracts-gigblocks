// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract GigBlocksResolverScrollENS  {

    address constant L1_SLOAD_ADDRESS = 0x0000000000000000000000000000000000000101;
    address constant ENS_PUBLIC_RESOLVER = 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD;
    uint256 constant SCROLL_COIN_TYPE = 2148018000;
    uint256 constant SLOT = 2;
    uint256 constant RECORD_VERSION = 0;


    function resolveENS(bytes32 node) public view returns (address) {
        //Calculate the slot for the top-level mapping (version)
        bytes32 topSlot = keccak256(abi.encodePacked(uint256(RECORD_VERSION), uint256(SLOT)));

        //Calculate the slot for the second-level mapping (node)
        bytes32 middleSlot = keccak256(abi.encodePacked(node, topSlot));

        //Calculate the slot for the innermost mapping (coinType)
        bytes32 finalSlot = keccak256(abi.encodePacked(SCROLL_COIN_TYPE, middleSlot));

        bytes memory input = abi.encodePacked(ENS_PUBLIC_RESOLVER, finalSlot);

        bool success;
        bytes memory result;
        address resolved;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        resolved = getAddressFromBytes(result);

        return resolved;

    }

    function bytesToBytes32(bytes memory source) private pure returns (bytes32 result) {
        if (source.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToAddress(bytes32 _data) private pure returns (address) {
        address addr;
        assembly {
            addr := shr(96, _data)
        }
        return addr;
    }

    function getAddressFromBytes(bytes memory source) private pure returns (address) {
        bytes32 data = bytesToBytes32(source);
        return bytes32ToAddress(data);
    }

}