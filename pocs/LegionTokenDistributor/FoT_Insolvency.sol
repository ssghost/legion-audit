// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../../src/distribution/LegionTokenDistributor.sol";
import "../../mocks/MockFeeToken.sol";
import "../../mocks/MockReg.sol"; 

contract FoT_Insolvency {
    LegionTokenDistributor distributor;
    MockFeeToken feeToken;
    MockRegistry registry;
    address projectAdmin = address(this);
    address referrerFeeReceiver = address(0x4);
    
    function test_InsolvencyWithFeeToken() public {
        feeToken = new MockFeeToken();
        registry = new MockRegistry(); 
        distributor = new LegionTokenDistributor();

        ILegionTokenDistributor.TokenDistributorInitializationParams memory params = 
            ILegionTokenDistributor.TokenDistributorInitializationParams({
                totalAmountToDistribute: 100 ether, 
                legionFeeOnTokensSoldBps: 0, 
                referrerFeeOnTokensSoldBps: 0, 
                referrerFeeReceiver: referrerFeeReceiver,
                askToken: address(feeToken),
                addressRegistry: address(registry),
                projectAdmin: projectAdmin
            });

        distributor.initialize(params);

        feeToken.approve(address(distributor), 100 ether);
        
        distributor.supplyTokens(100 ether, 0, 0);

        uint256 contractBalance = feeToken.balanceOf(address(distributor));
        
        if (contractBalance < 100 ether) {
        } else {
            revert("Test Failed: Fee was not deducted, insolvency not reproduced");
        }
    }
}