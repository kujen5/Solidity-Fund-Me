// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";
import {console} from "forge-std/Test.sol";

abstract contract CodeConstants {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 1400e8; // 1400 * 10^8
    uint256 public constant LOCAL_ANVIL_CHAIN_ID = 31337;
    uint256 public constant ETHEREUM_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
}

contract HelperConfig is Script, CodeConstants {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        uint256 deployerKey;
        string chainName;
        uint256 chainID;
        address priceFeed;
    }
    mapping(uint256 => NetworkConfig) public networkConfigs;
    error HelperConfig__InvalidChainId();

    constructor() {
        networkConfigs[ZKSYNC_SEPOLIA_CHAIN_ID] = getZkSyncSepoliaConfig();
        networkConfigs[ETHEREUM_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
        networkConfigs[LOCAL_ANVIL_CHAIN_ID] = getOrCreateAnvilEthConfig();
        activeNetworkConfig = networkConfigs[block.chainid];
    }

    function getConfigByChainId(
        uint256 _chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[_chainId].priceFeed != address(0)) {
            return networkConfigs[_chainId];
        } else if (_chainId == LOCAL_ANVIL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        console2.log("You have deployed a mock contract!");
        console2.log("Deploying mocks...");
        vm.startBroadcast(vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY"));
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        console2.log("Mocks deployed!");
        NetworkConfig memory activeNetworkConfig = NetworkConfig({
            deployerKey: vm.envUint("DEFAULT_ANVIL_PRIVATE_KEY"),
            chainName: "Anvil",
            chainID: LOCAL_ANVIL_CHAIN_ID,
            priceFeed: address(mockPriceFeed)
        });
        return activeNetworkConfig;
    }

    function getZkSyncSepoliaConfig()
        public
        view
        returns (NetworkConfig memory zkSyncSepoliaNetworkConfig)
    {
        zkSyncSepoliaNetworkConfig = NetworkConfig({
            deployerKey: vm.envUint("ZKSYNC_SEPOLIA_PRIVATE_KEY"),
            chainName: "ZkSync Sepolia",
            chainID: ZKSYNC_SEPOLIA_CHAIN_ID,
            priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF
        });
    }

    function getEthSepoliaConfig()
        public
        view
        returns (NetworkConfig memory ethSepoliaNetworkConfig)
    {
        ethSepoliaNetworkConfig = NetworkConfig({
            deployerKey: vm.envUint("ETHEREUM_SEPOLIA_PRIVATE_KEY"),
            chainName: "Ethereum Sepolia",
            chainID: ETHEREUM_SEPOLIA_CHAIN_ID,
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }
}
