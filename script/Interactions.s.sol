// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 public constant VALUE_TO_FUND = 0.1 ether;

    constructor() payable {}

    function fundFundMe(address mostRecentlyDeployedFundMeContract) public payable {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedFundMeContract)).fund{value: VALUE_TO_FUND}();
        vm.stopBroadcast();
        console.log(
            "Just funded the FundMe contract at address %s with %s", mostRecentlyDeployedFundMeContract, VALUE_TO_FUND
        );
    }

    function run() external {
        address mostRecentlyDeployedFundMeContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); //use devopstools to retrieve the latest instance of FundMe on the current blockchain
        fundFundMe(mostRecentlyDeployedFundMeContract);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployedFundMeContract) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedFundMeContract)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployedFundMeContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployedFundMeContract);
    }
}
