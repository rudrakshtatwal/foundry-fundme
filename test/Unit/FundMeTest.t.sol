//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundme;
    address USER = makeAddr("user");
    modifier funded(){
        vm.prank(USER);
        fundme.fund{value: 10e18}();
        _;
    }

    function setUp() external{
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme=deployFundMe.run();
        vm.deal(USER, 10e18);
    }
    function testMinDollar() public{
        assertEq(fundme.s_MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() public{
        vm.prank(USER);
        FundMe f = new FundMe(USER);
        assertEq(f.s_i_owner(),USER);
    }
    function testPriceFeedVersion() public{
        uint256 version = fundme.GetVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER);
        fundme.fund{value: 10e18}();
         uint256 funds = fundme.GetAddressToAmountFunded(USER);
         assertEq(funds, 10e18);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundme.fund{value: 10e18}();
        address funder_here = fundme.getFunder(0);
        assertEq(funder_here, USER);
    }
    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();
        // // Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testWithdrawWithMultipleFunders() public funded{
        
        uint160 i;
        uint160 NumberOfFunders = 10;
        for(i=1;i<NumberOfFunders;i++){
            hoax(address(i),10e18);
            fundme.fund{value: 10e18}();
        }
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        
        assertEq(address(fundme).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, fundme.getOwner().balance);
    }
}