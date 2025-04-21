// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {FundMe} from "../src/FundMe.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {console} from "forge-std/console.sol";

contract DeployFundMe is Script {
    struct NetworkConfig {
        uint256 deployerKey;
        string chainName;
        uint256 chainID;
        address priceFeed;
    }

    function deployFundMe() public returns (FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfigByChainId(block.chainid);
        uint256 deployerKey = config.deployerKey;
        string memory chainName = config.chainName;
        uint256 chainId = config.chainID;
        address priceFeed = config.priceFeed;
        console.log("Deploying on chain %s with id %s", chainName, chainId);
        console.log("Price Feed address: %s", priceFeed);
        console.log("Deployer key: %s", deployerKey);
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }

    function run() external returns (FundMe, HelperConfig) {
        return deployFundMe();
    }
}
