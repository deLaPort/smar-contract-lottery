// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 raffleEntranceFee,
            uint256 automationUpdateInterval,
            address vrfCoordinatorV2,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address linkToken,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();

        // Fund the subscription
        if (subscriptionId == 0) {
            CreateSubscription createSubscribtion = new CreateSubscription();
            subscriptionId = createSubscribtion.createSubscription(
                vrfCoordinatorV2,
                deployerKey
            );
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinatorV2,
                subscriptionId,
                linkToken,
                deployerKey
            );
        }

        // Deploy the raffle
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            raffleEntranceFee,
            automationUpdateInterval,
            vrfCoordinatorV2,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            vrfCoordinatorV2,
            subscriptionId,
            deployerKey
        );
        return (raffle, helperConfig);
    }
}
