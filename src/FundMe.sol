// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    
    
    address public s_i_owner; //immutable
    uint256 public constant s_MINIMUM_USD = 5*10**18;
    address[] private s_funders;
    mapping (address funder=> uint256 amountFunded) s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed){
        s_i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable{
        require(msg.value.GetConversionRate(s_priceFeed) >= s_MINIMUM_USD , "Amount is less than min payable amount");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    modifier onlyOwner(){
        if(msg.sender!=s_i_owner) revert NotOwner();
        _;
    }

    function withdraw() public onlyOwner{
        uint256 funders_length = s_funders.length;
        for(uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
             address funder=s_funders[funderIndex];
             s_addressToAmountFunded[funder]=0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function GetVersion() public view returns(uint256){
        return s_priceFeed.version();
    }
    
    function GetAddressToAmountFunded(address fundersAddress) external view returns (uint256){
        return s_addressToAmountFunded[fundersAddress];
    }

    function getFunder(uint256 index) public returns(address){
        return s_funders[index];
    }

    function getOwner() public view returns(address){
        return s_i_owner;
    }

    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

   fallback() external payable { }
   receive() external payable {}

}
