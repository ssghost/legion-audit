// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../../src/distribution/LegionTokenDistributor.sol";
import "../../mocks/MockERC20.sol";
import "../../mocks/MockReg.sol";

contract LegionDoS {
    LegionTokenDistributor distributor;
    MockERC20 askToken;
    MockRegistry registry;

    address referrerFeeReceiver = address(0x4);

    constructor() {
        askToken = new MockERC20();
        registry = new MockRegistry();
        distributor = new LegionTokenDistributor();

        ILegionTokenDistributor.TokenDistributorInitializationParams memory params = 
            ILegionTokenDistributor.TokenDistributorInitializationParams({
                totalAmountToDistribute: 1000 ether,
                legionFeeOnTokensSoldBps: 100, 
                referrerFeeOnTokensSoldBps: 0, 
                referrerFeeReceiver: referrerFeeReceiver,
                askToken: address(askToken),
                addressRegistry: address(registry),
                projectAdmin: address(this) 
            });

        distributor.initialize(params);

        askToken.mint(address(this), 10000 ether);
        askToken.approve(address(distributor), type(uint256).max);
    }

    function test_DoS_WhenFeeDiffersByOneWei() public {
        uint256 amount = 1000 ether;
        uint256 expectedLegionFee = 10 ether; 
        uint256 offChainCalculatedFee = expectedLegionFee - 1; 

        try distributor.supplyTokens(amount, offChainCalculatedFee, 0) {
            revert("Test Failed: SupplyTokens should have reverted but succeeded");
        } catch (bytes memory /*lowLevelData*/) {
        }
    }
}