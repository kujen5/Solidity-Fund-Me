// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console2} from "forge-std/Test.sol";
import {WithdrawFundMe, FundFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MockV3Aggregator} from "../mock/MockV3Aggregator.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test, ZkSyncChainChecker, CodeConstants {
    FundMe public fundMe;
    HelperConfig helperConfig = new HelperConfig();
    uint256 public constant INITIAL_USER_BALANCE = 10 ether;
    uint256 public constant VALUE_TO_FUND = 1 ether;
    address public KUJEN = makeAddr("KUJEN"); //yep that's me 2.0 :)

    function setUp() external {
        // first check if this is a ZkSync chain
        if (!isZkSyncChain()) {
            // this check is not about loading configs, its about deciding how to deploy FundMe
            DeployFundMe deployer = new DeployFundMe();
            (fundMe, helperConfig) = deployer.deployFundMe();
        } else {
            // deploy with mock if chain is zksync
            helperConfig = new HelperConfig();
            (, , , address priceFeed) = helperConfig.activeNetworkConfig();
            address expectedPriceFeed = priceFeed;
            fundMe = new FundMe(expectedPriceFeed);
        }
        vm.deal(KUJEN, INITIAL_USER_BALANCE); // give KUJEN user 10 ether initially
    }

    function testUserFundingAndOwnerWithdrawingFromContractWithoutOtherExternalFunding()
        public
        skipZkSync
    {
        uint256 initialUserBalance = address(KUJEN).balance;
        uint256 initialOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(KUJEN);
        fundMe.fund{value: VALUE_TO_FUND}();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 finalUserBalance = address(KUJEN).balance;
        uint256 finalOwnerBalance = address(fundMe.getOwner()).balance;

        assertEq(finalOwnerBalance, initialOwnerBalance + VALUE_TO_FUND);
        assertEq(initialUserBalance, finalUserBalance + VALUE_TO_FUND);
    }

    /* commented for now cuz am running into problems I've never seen lol. Will work on it in the future
    function testUserFundingAndOwnerWithdrawingFromContractWithtOtherExternalFunding()
        public
        skipZkSync
    {
        uint256 initialUserBalance = address(KUJEN).balance;
        uint256 initialOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(KUJEN);
        fundMe.fund{value: VALUE_TO_FUND}();

        FundFundMe fundFundMe = new FundFundMe{value: INITIAL_USER_BALANCE}();
        console2.log(
            "balance of fundfundme contract is %s",
            address(fundFundMe).balance
        );
        if (address(fundFundMe).balance > 0.1 ether) {
            console2.log("enough funds");
        }
        fundFundMe.fundFundMe(address(fundMe));
        console2.log(
            "balance of fundfundme contract is %s",
            address(fundFundMe).balance
        );
        uint256 totalFundingValue = VALUE_TO_FUND + fundFundMe.VALUE_TO_FUND();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 finalUserBalance = address(KUJEN).balance;
        uint256 finalOwnerBalance = address(fundMe.getOwner()).balance;

        assertEq(finalOwnerBalance, initialOwnerBalance + totalFundingValue);
        assertEq(initialUserBalance, finalUserBalance + VALUE_TO_FUND);
    }*/
}
