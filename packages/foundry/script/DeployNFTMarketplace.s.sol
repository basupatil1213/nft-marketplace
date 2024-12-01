//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../contracts/NFTMarketplace.sol";
import "./DeployHelpers.s.sol";

contract DeployNFTMarketplace is ScaffoldETHDeploy {
  // use `deployer` from `ScaffoldETHDeploy`
  function run() external ScaffoldEthDeployerRunner {
    NFTMarketplace nftMarketplaceContract = new NFTMarketplace(deployer);
    console.logString(
      string.concat(
        "NFTMarketplace contract deployed at: ", vm.toString(address(nftMarketplaceContract))
      )
    );
  }
}