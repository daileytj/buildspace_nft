// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private _totalSupply = 50;

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] firstWords = ["Aggressive", "Brave", "Cheerful", "Delightful", "Dark", "Encouraging", "Frantic", "Grotesque", "Horrible", "Itchy", "Lively", "Mysterious", "Nervous", "Obedient", "Obnoxious", "Pleasant", "Quaint", "Repulsive", "Shy", "Silly", "Splendid", "Tender", "Unusual", "Uptight", "Wandering", "Zany"];
  string[] secondWords = ["Ashwinder", "Bowtruckle", "Cantaur", "Chimaera", "Demiguise", "Dragon", "Erumpent", "Fairy", "Firedrake", "Fwooper", "Ghoul", "Gnome", "Griffin", "Hippogriff", "Imp", "Jackalope", "Manticore", "Niffler", "Phoenix", "Pixie", "Salamander", "Snail", "Spider", "Toad", "Troll", "Unicorn", "Werewolf", "Yeti" ];
  string[] thirdWords = ["Ear", "Fang", "Tooth", "Pants", "Shirt", "Glasses", "Glove", "Toes", "Eye", "Flesh", "Egg", "Tongue", "Knee", "Elbow", "Hair", "Feather", "Scales", "Tail", "Heart", "Soul", "Eyebrow", "Shoe", "Wings", "Club", "Sword", "Dagger", "Chainsaw", "Horn", "Blubber", "Skin", "Fur", "Toast", "Burger", "Steak", "Liver", "Kidney"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

  function getTotalNFTsMintedCount () public view returns (uint) {
    return _tokenIds.current();
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // seed the random generator
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    require(_totalSupply > newItemId, "SOLD OUT: Theres a mint limit of 50");

    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}




