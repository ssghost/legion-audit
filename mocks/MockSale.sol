// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { ILegionVestingManager } from "https://github.com/ssghost/legion-audit/blob/main/src/interfaces/vesting/ILegionVestingManager.sol";

contract MockSale {
    bytes32 public acceptedMerkleRoot;
    
    event ClaimSuccessful(uint256 allocation, uint64 duration, uint64 tgeRate);

    function setAcceptedMerkleRoot(bytes32 _root) external {
        acceptedMerkleRoot = _root;
    }

    function claimTokenAllocation(
        uint256 allocation,
        ILegionVestingManager.LegionInvestorVestingConfig calldata vestingConfig,
        bytes32[] calldata proof
    ) external {
        proof;
        
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, allocation))));
        
        require(leaf == acceptedMerkleRoot, "Invalid Proof!");

        emit ClaimSuccessful(allocation, vestingConfig.vestingDurationSeconds, vestingConfig.tokenAllocationOnTGERate);
    }
}