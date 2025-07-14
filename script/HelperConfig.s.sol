//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWERS= 2000e8;
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig{
        address priceFeed;
    }

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepEthConfig();
        }
        else{
            activeNetworkConfig = getCreateAnvilEthConfig();
        }
    }

    function getSepEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
        return sepConfig;
    }

    function getCreateAnvilEthConfig() public returns(NetworkConfig memory){
        
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, INITIAL_ANSWERS
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed : address(mockPriceFeed)
        });
        return anvilConfig;
    }
}