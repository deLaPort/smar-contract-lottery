// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../../script/Interactions.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract IntegrationsTest is StdCheats, Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;

    address public constant USER = address(1);

    // uint256 public constant SEND_VALUE = 1e18;
    // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
    // uint256 public constant SEND_VALUE = 1000000000000000000;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanCreateSubscriptionFundSubscriptionAndAddConsumer()
        public
    {
        CreateSubscription createSubscription = new CreateSubscription();
        uint64 subscriptionId = createSubscription.createSubscription(
            address(raffle),
            vm.envUint("PRIVATE_KEY")
        );

        FundSubscription fundSubscription = new FundSubscription();
        fundSubscription.fundSubscription(
            address(raffle),
            subscriptionId,
            address(raffle),
            vm.envUint("PRIVATE_KEY")
        );

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            address(raffle),
            subscriptionId,
            vm.envUint("PRIVATE_KEY")
        );
    }

    // function testUserCanFundAndOwnerWithdraw() public {
    //     FundFundMe fundFundMe = new FundFundMe();
    //     fundFundMe.fundFundMe(address(fundMe));

    //     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
    //     withdrawFundMe.withdrawFundMe(address(fundMe));

    //     assert(address(fundMe).balance == 0);
    // }
}
