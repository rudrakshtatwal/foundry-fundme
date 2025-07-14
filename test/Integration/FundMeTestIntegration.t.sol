// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/interactions.s.sol";

contract FundMeTestIntegration is Test{
    uint256 SEND_VALUE = 0.01 ether;
    FundMe fundme;
    address USER = makeAddr("user");
     function SetUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER,SEND_VALUE);
     }

     function testUserCanFundInteractions() public {
        vm.prank(USER);
        vm.deal(USER,SEND_VALUE);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundme));
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));

        address funder = fundme.getFunder(0);
        assertEq(funder,USER);
        assertEq(address(fundme).balance,0);
     }
}