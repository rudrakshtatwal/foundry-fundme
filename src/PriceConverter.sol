// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";



library PriceConverter{
     function GetPrice(AggregatorV3Interface pricefeed) internal view returns(uint256){

        (,int256 price,,,) = pricefeed.latestRoundData();
        return uint256(price) * 1e10;
    }

    function GetConversionRate(uint256 ethAmount,AggregatorV3Interface pricefeed ) internal view returns(uint256){
        uint256 ethPrice = GetPrice(pricefeed);
        uint256 ethAmountInUsd = ethAmount* ethPrice/ 1e18;
        return ethAmountInUsd;

    }

    
}