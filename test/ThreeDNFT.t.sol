// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ThreeDNFT} from "../src/ThreeDNFT.sol";

contract ThreeDNFTTest is Test {
    ThreeDNFT public nft;
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        nft = new ThreeDNFT("3D Print NFT Collection", "3DPNFT");
    }

    function test_MintSimple() public {
        string memory name = "Test Print";
        string memory modelUrl = "https://ipfs.io/ipfs/QmTest123";
        string memory imageUrl = "https://ipfs.io/ipfs/QmImage123";

        uint256 tokenId = nft.mintSimple(user1, name, modelUrl, imageUrl);

        assertEq(nft.ownerOf(tokenId), user1);
        assertEq(nft.totalSupply(), 1);

        (
            string memory retrievedName,
            ,
            string memory retrievedModelUrl,
            string memory retrievedImageUrl
        ) = nft.getBasicMetadata(tokenId);

        assertEq(retrievedName, name);
        assertEq(retrievedModelUrl, modelUrl);
        assertEq(retrievedImageUrl, imageUrl);
    }

    function test_MintWithFullMetadata() public {
        ThreeDNFT.NFTMetadata memory metadata = ThreeDNFT.NFTMetadata({
            name: "Complex 3D Print",
            description: "A detailed 3D printed object",
            modelFileUrl: "https://ipfs.io/ipfs/QmModel456",
            imageUrl: "https://ipfs.io/ipfs/QmImage456",
            material: "PLA",
            printer: "Prusa i3 MK3S",
            layerHeight: 200,
            printTime: 120,
            color: "Red",
            timestamp: 0,
            additionalData: '{"infill": 20, "supports": true}'
        });

        uint256 tokenId = nft.mint(user1, metadata, "");

        assertEq(nft.ownerOf(tokenId), user1);
        
        ThreeDNFT.NFTMetadata memory retrieved = nft.getMetadata(tokenId);
        assertEq(retrieved.name, metadata.name);
        assertEq(retrieved.material, metadata.material);
        assertEq(retrieved.printer, metadata.printer);
        assertEq(retrieved.layerHeight, metadata.layerHeight);
        assertEq(retrieved.printTime, metadata.printTime);
        assertEq(retrieved.color, metadata.color);
        assertEq(retrieved.additionalData, metadata.additionalData);
        assertGt(retrieved.timestamp, 0); // Timestamp dovrebbe essere impostato
    }

    function test_AnyoneCanMint() public {
        vm.prank(user2);
        uint256 tokenId = nft.mintSimple(
            user2,
            "User2 Print",
            "https://ipfs.io/ipfs/QmUser2",
            "https://ipfs.io/ipfs/QmUser2Img"
        );

        assertEq(nft.ownerOf(tokenId), user2);
    }

    function test_GetPrintDetails() public {
        ThreeDNFT.NFTMetadata memory metadata = ThreeDNFT.NFTMetadata({
            name: "Technical Print",
            description: "",
            modelFileUrl: "",
            imageUrl: "",
            material: "PETG",
            printer: "Ender 3",
            layerHeight: 150,
            printTime: 90,
            color: "Blue",
            timestamp: 0,
            additionalData: ""
        });

        uint256 tokenId = nft.mint(user1, metadata, "");

        (
            string memory material,
            string memory printer,
            uint256 layerHeight,
            uint256 printTime,
            string memory color
        ) = nft.getPrintDetails(tokenId);

        assertEq(material, "PETG");
        assertEq(printer, "Ender 3");
        assertEq(layerHeight, 150);
        assertEq(printTime, 90);
        assertEq(color, "Blue");
    }

    function test_UpdateMetadata() public {
        uint256 tokenId = nft.mintSimple(
            user1,
            "Original Name",
            "https://ipfs.io/ipfs/QmOriginal",
            "https://ipfs.io/ipfs/QmOriginalImg"
        );

        ThreeDNFT.NFTMetadata memory originalMetadata = nft.getMetadata(tokenId);
        uint256 originalTimestamp = originalMetadata.timestamp;

        // Aggiorna i metadati
        ThreeDNFT.NFTMetadata memory updatedMetadata = ThreeDNFT.NFTMetadata({
            name: "Updated Name",
            description: "Updated description",
            modelFileUrl: "https://ipfs.io/ipfs/QmUpdated",
            imageUrl: "https://ipfs.io/ipfs/QmUpdatedImg",
            material: "ABS",
            printer: "Ultimaker",
            layerHeight: 100,
            printTime: 60,
            color: "Green",
            timestamp: 0,
            additionalData: "{}"
        });

        vm.prank(user1);
        nft.updateMetadata(tokenId, updatedMetadata);

        ThreeDNFT.NFTMetadata memory retrieved = nft.getMetadata(tokenId);
        assertEq(retrieved.name, "Updated Name");
        assertEq(retrieved.material, "ABS");
        assertEq(retrieved.timestamp, originalTimestamp); // Timestamp originale preservato
    }

    function test_UpdateMetadataOnlyOwner() public {
        uint256 tokenId = nft.mintSimple(
            user1,
            "Test",
            "https://ipfs.io/ipfs/QmTest",
            "https://ipfs.io/ipfs/QmTestImg"
        );

        ThreeDNFT.NFTMetadata memory updatedMetadata = ThreeDNFT.NFTMetadata({
            name: "Hacked",
            description: "",
            modelFileUrl: "",
            imageUrl: "",
            material: "",
            printer: "",
            layerHeight: 0,
            printTime: 0,
            color: "",
            timestamp: 0,
            additionalData: ""
        });

        vm.prank(user2);
        vm.expectRevert("Not the owner");
        nft.updateMetadata(tokenId, updatedMetadata);
    }

    function test_TotalSupply() public {
        assertEq(nft.totalSupply(), 0);

        nft.mintSimple(user1, "Print 1", "url1", "img1");
        assertEq(nft.totalSupply(), 1);

        nft.mintSimple(user2, "Print 2", "url2", "img2");
        assertEq(nft.totalSupply(), 2);

        vm.prank(user1);
        nft.mintSimple(user1, "Print 3", "url3", "img3");
        assertEq(nft.totalSupply(), 3);
    }

    function test_MultipleMints() public {
        for (uint256 i = 0; i < 10; i++) {
            string memory name = string(abi.encodePacked("Print ", vm.toString(i)));
            nft.mintSimple(user1, name, "url", "img");
        }

        assertEq(nft.totalSupply(), 10);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.ownerOf(9), user1);
    }
}

