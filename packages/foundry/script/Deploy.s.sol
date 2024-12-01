//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import { DeployNFTCollection } from "./DeployNFTCollection.s.sol";
import { DeployNFTMarketplace } from "./DeployNFTMarketplace.s.sol";

contract DeployScript is ScaffoldETHDeploy {
  function run() external {

    // deploy NFTCollection contract
    DeployNFTCollection deployNFTCollection = new DeployNFTCollection();
    deployNFTCollection.run();

    // deploy NFTMarketplace contract
    DeployNFTMarketplace deployNFTMarketplace = new DeployNFTMarketplace();
    deployNFTMarketplace.run();
  }
}
