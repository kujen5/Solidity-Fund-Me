// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error FundMe__NotOwnerOfThisContract();
    error FundMe__NotEnoughEthInFunds();

    using PriceConverter for uint256; // This is how we reference a library so we can later use it (libraries are gas efficient)

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address private immutable i_owner;
    address[] private s_funders; // An array of addresses to keep track of funders
    uint256 public immutable MINIMUM_FUNDING_AMOUNT_IN_USD = 5 * 10 ** 18; // This is 5 USD, but we'll convert it to USD by dividing by the precision factor of 1*10^18
    AggregatorV3Interface s_priceFeed; // we'll be getting our ETH/USD conversion rate from here

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/
    mapping(address => uint256) public AddressToAmountFunded; // This is a mapping to keep track of funders and the amount they funded
    mapping(address => uint256) public AddressToFunderIndex;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event FundsAddedToContractBalance(address, uint256);
    event FundWithdrawnFromContract(uint256);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier OnlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwnerOfThisContract(); // If the one who's sending the transaction isn't i_owner (which is the contract original deployer) then revert.
        _; // Defines the injection point, meaning where your function logic should be implemented (after the revert statement).
    }

    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    /// @notice This function allows the user to fund the contract with ETH
    function fund() public payable {
        // payable means that the function can receive ETH
        // when having the payable, any ETH passed in the msg.value goes directly to the contract's balance
        if (
            msg.value.getConversionRate(s_priceFeed) <
            MINIMUM_FUNDING_AMOUNT_IN_USD
        ) {
            revert FundMe__NotEnoughEthInFunds();
        }
        AddressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender); // Add the funder to the array
        AddressToFunderIndex[msg.sender] = s_funders.length - 1; // Store the index of the funder in the array
        emit FundsAddedToContractBalance(msg.sender, msg.value);
    }

    /// @notice This function allows the owner of the contract to withdraw all the funds from the contract to his wallet
    function withdraw() public OnlyOwner {
        for (
            uint256 funderIndex;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            AddressToAmountFunded[funder] = 0; //Reset the recorder funded amount by everyone to 0
        }
        s_funders = new address[](0); // reinitialize s_funders as an empty array with an initial length of 0
        // this is an efficient way to reset the s_funders array without another loop
        (bool success, ) = i_owner.call{value: address(this).balance}(""); // transfer the whole balance of the contract to the owner
        require(success, "Transfer of funds failed");
    }

    function withdrawFundsFromSpecificFunder(
        address specificFunderAddress
    ) public OnlyOwner {
        uint256 amountFundedByAddress = AddressToAmountFunded[
            specificFunderAddress
        ];
        AddressToAmountFunded[specificFunderAddress] = 0; //restore amount to 0 since we're gonna withdraw it
        (bool success, ) = i_owner.call{value: amountFundedByAddress}(""); // transfer the whole balance of the specific user to the owner
        require(success, "Transfer of funds failed");
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeedVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunderByIndex(
        uint256 funderIndex
    ) public view returns (address) {
        return s_funders[funderIndex];
    }

    function getAmountFundedFromSpecificAddress(
        address _fundingAddress
    ) public view returns (uint256) {
        return AddressToAmountFunded[_fundingAddress];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
