// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {ThreeDNFT} from "../src/ThreeDNFT.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Nome e simbolo della collezione
        string memory collectionName = "3D Print NFT Collection";
        string memory collectionSymbol = "3DPNFT";

        // Deploy del contratto
        ThreeDNFT nft = new ThreeDNFT(collectionName, collectionSymbol);

        console.log("ThreeDNFT deployed at:", address(nft));
        console.log("Collection Name:", collectionName);
        console.log("Collection Symbol:", collectionSymbol);
        console.log("Deployer:", msg.sender);

        vm.stopBroadcast();
    }
}

