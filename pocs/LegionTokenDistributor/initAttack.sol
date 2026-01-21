// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "../../src/distribution/LegionTokenDistributor.sol";
import "../../mocks/MockERC20.sol";
import "../../mocks/MockReg.sol";

contract InitAttack {
    LegionTokenDistributor public distributor;
    MockERC20 public token;
    MockRegistry public registry;

    function testExploit() public {
        token = new MockERC20();
        registry = new MockRegistry();
        
        distributor = new LegionTokenDistributor();

        ILegionTokenDistributor.TokenDistributorInitializationParams memory params = 
            ILegionTokenDistributor.TokenDistributorInitializationParams({
                legionFeeOnTokensSoldBps: 0,
                referrerFeeOnTokensSoldBps: 0,
                referrerFeeReceiver: address(0),
                askToken: address(token),
                addressRegistry: address(registry),
                projectAdmin: address(this),
                totalAmountToDistribute: 1000 ether
            });

        token.approve(address(distributor), type(uint256).max);

        distributor.initialize(params);
        
        require(token.balanceOf(address(distributor)) == 1000 ether, "Init Failed");
    }

    receive() external payable {}
}