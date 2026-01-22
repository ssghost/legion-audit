// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

contract GetHash {
    enum SaleAction { INVEST, WITHDRAW_EXCESS_CAPITAL, CLAIM_TOKEN_ALLOCATION }
    function getHash(
        address investor,
        address saleContract,
        uint256 investAmount,
        uint256 tokenAllocationRate,
        uint8 action
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                investor,
                saleContract,
                investAmount,
                tokenAllocationRate,
                action
            )
        );
    }
}