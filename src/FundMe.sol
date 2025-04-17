// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    address private immutable i_owner;
    uint256 public immutable MINIMUM_FUNDING_AMOUNT_IN_USD = 5 * 10 ** 18; // This is 5 ETH, but we'll convert it to USD by dividing by the precision factor of 1*10^18
    AggregatorV3Interface s_priceFeed; // we'll be getting our ETH/USD conversion rate from here

    error FundMe__NotOwnerOfThisContract();

    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwnerOfThisContract(); // If the one who's sending the transaction isn't i_owner (which is the contract original deployer) then revert.
        _; // Defines the injection point, meaning where your function logic should be implemented (after the revert statement).
    }

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public {}

    function withdraw() public OnlyOwner {}

    function getOwner() public {}

    function getPriceFeed() public {}

    function getFunderByIndex() public {}

    function getAddressToAmountFunded() public {}

    function getPriceFeedVersion() public {}
}
