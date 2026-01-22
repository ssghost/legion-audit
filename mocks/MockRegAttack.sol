// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract MockRegAttack {
    mapping(bytes32 => address) private s_addresses;

    function setLegionAddress(bytes32 id, address addr) external {
        s_addresses[id] = addr;
    }

    function getLegionAddress(bytes32 id) external view returns (address) {
        return s_addresses[id];
    }
}