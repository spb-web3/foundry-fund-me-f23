// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        fundMe = new DeployFundMe().run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndWithdrawIntegration() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(payable(address(fundMe)));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(payable(address(fundMe)));

        assert(address(fundMe).balance == 0);
    }
}
