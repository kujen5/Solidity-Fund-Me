// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 deployerKey,
            string memory chainName,
            uint256 chainId,
            address priceFeed
        ) = helperConfig.activeNetworkConfig();
        console.log("Deploying on chain %s with id %s", chainName, chainId);
        vm.startBroadcast(deployerKey);
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
