// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

contract FundMe {
    address private immutable i_owner;

    error FundMe__NotOwnerOfThisContract();

    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwnerOfThisContract(); // If the one who's sending the transaction isn't i_owner (which is the contract original deployer) then revert.
        _; // Defines the injection point, meaning where your function logic should be implemented (after the revert statement).
    }

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public {}

    function withdraw() public {}

    function getOwner() public {}

    function getPriceFeed() public {}

    function getFunderByIndex() public {}

    function getAddressToAmountFunded() public {}

    function getPriceFeedVersion() public {}
}
