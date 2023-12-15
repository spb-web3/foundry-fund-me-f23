// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function run() public {
        address payable mostRecentlyDeployedFundMe = getMostRecentlyDeployedFundMe();
        fundFundMe(mostRecentlyDeployedFundMe);
    }

    function getMostRecentlyDeployedFundMe()
        public
        view
        returns (address payable)
    {
        address fundMe = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        return payable(fundMe);
    }

    function fundFundMe(address payable fundMe) public payable {
        vm.startBroadcast();
        FundMe(fundMe).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("FundMe funded with %s", SEND_VALUE);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function run() public {
        address payable mostRecentlyDeployedFundMe = getMostRecentlyDeployedFundMe();
        withdrawFundMe(mostRecentlyDeployedFundMe);
    }

    function getMostRecentlyDeployedFundMe()
        public
        view
        returns (address payable)
    {
        address fundMe = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        return payable(fundMe);
    }

    function withdrawFundMe(address payable fundMe) public payable {
        vm.startBroadcast();
        FundMe(fundMe).withdraw();
        vm.stopBroadcast();
        console.log("FundMe withdraw() called");
    }
}
