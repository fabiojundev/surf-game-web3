// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./libraries/Base64.sol";

contract MySurfGame is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 maneuver;
        uint256 tubeRiding;
        uint256 aerial;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    //tokenId => NFT attributes mapping
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    //address => holder mapping, used to easily access nft holder
    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterManeuver,
        uint256[] memory characterTubeRiding,
        uint256[] memory characterAerial
    ) ERC721("Surfers", "SURFER") {
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    maneuver: characterManeuver[i],
                    tubeRiding: characterTubeRiding[i],
                    aerial: characterAerial[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];

            console.log("--------------------------------------\n");
            console.log(
                "** Atleta inicializado: %s com %s de HP, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
            console.log(
                "** Habilidades: manobras: %s, tubos: %s, aereo: %s \n",
                c.maneuver,
                c.tubeRiding,
                c.aerial
            );
        }
        //init to 1
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        // current tokenId, incremented to 1 in consctructor
        uint256 newItemId = _tokenIds.current();

        // Set tokenId to the wallet address who called the contract.
        _safeMint(msg.sender, newItemId);

        // Map tokenId => to character's attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            maneuver: defaultCharacters[_characterIndex].maneuver,
            tubeRiding: defaultCharacters[_characterIndex].tubeRiding,
            aerial: defaultCharacters[_characterIndex].aerial
        });

        console.log(
            "Mintou NFT c/ tokenId %s e characterIndex %s",
            newItemId,
            _characterIndex
        );

        // Keep track of the holder
        nftHolders[msg.sender] = newItemId;

        // Increment for next use
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strManeuver = Strings.toString(charAttributes.maneuver);
        string memory strTubeRiding = Strings.toString(
            charAttributes.tubeRiding
        );
        string memory strAerial = Strings.toString(charAttributes.aerial);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                " -- NFT #: ",
                Strings.toString(_tokenId),
                '", "description": "Esta NFT da acesso ao meu jogo NFT!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Maneuver", "value": ',
                strManeuver,
                '}, { "trait_type": "TubeRiding", "value": ',
                strTubeRiding,
                '}, { "trait_type": "Aerial", "value": ',
                strAerial,
                "} ]}"
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
