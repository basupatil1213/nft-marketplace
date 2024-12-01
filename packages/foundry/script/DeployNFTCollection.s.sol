//SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../contracts/NFTCollection.sol";
import "./DeployHelpers.s.sol";

contract DeployNFTCollection is ScaffoldETHDeploy {
  // use `deployer` from `ScaffoldETHDeploy`
  function run() external ScaffoldEthDeployerRunner {
    NFTCollection nftCollectionContract = new NFTCollection("HuskyNFTCollection", "HNFT");
    console.logString(
      string.concat(
        "NFTCollection contract deployed at: ", vm.toString(address(nftCollectionContract))
      )
    );
  }
}