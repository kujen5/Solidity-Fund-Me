// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";
import {StdCheats} from "forge-std/StdCheats.sol"; // we need the "hoax" function from it => Sets up a prank from an address that has some ether => If the balance is not specified, it will be set to 2^128 wei.
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol"; // we need this to check if the chain is zkSync or not using this

contract FundMeTest is Test, CodeConstants, ZkSyncChainChecker {
    FundMe public fundMe;
    HelperConfig public helperConfig;
    address public KUJEN = makeAddr("KUJEN"); // yep, thats me :)
    uint256 public constant USER_INITIAL_BALANCE = 10 ether;
    uint256 public constant VALUE_TO_FUND = 0.1 ether;
    uint256 public constant GAS_PRICE = 1;

    function setUp() external {
        // first check if this is a ZkSync chain
        if (!isZkSyncChain()) {
            // this check is not about loading configs, its about deciding how to deploy FundMe
            DeployFundMe deployer = new DeployFundMe();
            (fundMe, helperConfig) = deployer.deployFundMe();
        } else {
            // deploy with mock if chain is zksync
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
                DECIMALS,
                INITIAL_PRICE
            );
            fundMe = new FundMe(address(mockPriceFeed));
        }
        vm.deal(KUJEN, USER_INITIAL_BALANCE); // give KUJEN user 10 ether initially
    }

    modifier funded() {
        vm.prank(KUJEN);
        fundMe.fund{value: VALUE_TO_FUND}();
        assert(address(fundMe).balance > 0);
        _; // injection point => modifier will be called on function, so function logic will be implemented after modifier logic at _
    }

    function testFundFailsWithoutSufficientEthereumInWallet() public {
        vm.expectRevert(FundMe.FundMe__NotEnoughEthInFunds.selector);
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded skipZkSync {
        uint256 amountFunded = fundMe.AddressToAmountFunded(KUJEN);
        assertEq(amountFunded, VALUE_TO_FUND);
    }

    function testFunderAddedToArrayOfFunders() public funded skipZkSync {
        address funder = fundMe.getFunderByIndex(0);
        assertEq(funder, KUJEN);
    }

    function testOnlyOwnerCanWithdrawFunds() public funded skipZkSync {
        vm.expectRevert(FundMe.FundMe__NotOwnerOfThisContract.selector);
        vm.prank(address(5));
        fundMe.withdraw();
    }

    function testPriceFeedSetCorrectly() public skipZkSync {
        address retreivedPriceFeed = address(fundMe.getPriceFeed());
        // (address expectedPriceFeed) = helperConfig.activeNetworkConfig();
        (, , , address priceFeed) = helperConfig.activeNetworkConfig();
        address expectedPriceFeed = priceFeed;
        assertEq(retreivedPriceFeed, expectedPriceFeed);
    }

    function testWithdrawFromASingleFunder() public funded skipZkSync {
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingContractOwnerBalance = address(fundMe.getOwner())
            .balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 finalContractOwnerBalance = address(fundMe.getOwner()).balance;
        assertEq(
            startingFundMeBalance + startingContractOwnerBalance,
            finalContractOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public skipZkSync {
        uint160 numberOfFunders = 1337;
        uint160 startingFundersIndex = 1;
        for (
            uint160 i = startingFundersIndex;
            i < numberOfFunders + startingFundersIndex;
            i++
        ) {
            hoax(address(i), USER_INITIAL_BALANCE);
            fundMe.fund{value: VALUE_TO_FUND}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingContractOwnerBalance = address(fundMe.getOwner())
            .balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingContractOwnerBalance ==
                address(fundMe.getOwner()).balance
        );
        assert(
            numberOfFunders * VALUE_TO_FUND ==
                fundMe.getOwner().balance - startingContractOwnerBalance
        );
    }
}
