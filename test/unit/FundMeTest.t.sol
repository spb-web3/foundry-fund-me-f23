// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 1 ether);
    }

    function testMinimumDollarIsFive() public {
        bool result = fundMe.MINIMUM_USD() == 5e18;

        assertEq(result, true, "Minimum USD is not 5");
        assertEqUint(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessageSender() public {
        console.log("Owner is: ", fundMe.i_owner());
        console.log("Message sender is: ", msg.sender);
        console.log("This is : ", address(this));

        bool result = fundMe.i_owner() == msg.sender;
        assertEq(result, true, "Owner is not message sender");
    }

    function testVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEqUint(version, 4);
    }

    function testFundFailsWhenNotEnoughEthSent() public {
        vm.expectRevert();
        fundMe.fund{value: 15}();
    }

    function testFundUpdatesFundedDataStructure() public {
        uint256 amountBeforeFunding = fundMe.getAddressToAmountFunded(USER);

        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountAfterFunding = fundMe.getAddressToAmountFunded(USER);

        assertEqUint(amountBeforeFunding + SEND_VALUE, amountAfterFunding);

        console.log("%s", address(this));
        console.log("%s", amountBeforeFunding);
        console.log("%s", amountAfterFunding);
    }

    function testFundUpdatesFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funderZero = fundMe.getFunder(0);
        assertEq(funderZero, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        address owner = fundMe.getOwner();
        uint256 ownerStartingBalance = owner.balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        vm.prank(owner);
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, ownerStartingBalance + fundMeStartingBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (
            uint160 index = startingFunderIndex;
            startingFunderIndex < numberOfFunders;
            startingFunderIndex++
        ) {
            hoax(address(index), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 ownerStartingBalance = owner.balance;
        uint256 fundMeStartingBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner);
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;
        console.log("Gas used: ", gasUsed);

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(owner.balance, ownerStartingBalance + fundMeStartingBalance);
    }
}
