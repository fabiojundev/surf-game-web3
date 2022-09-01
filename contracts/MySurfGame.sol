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
        address owner;
        uint256 score;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    CharacterAttributes[] defaultCharacters;

    //tokenId => NFT attributes mapping
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    struct BigBoss {
        string name;
        string imageURI;
        uint256 waves;
        uint256 maxWaves;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    //address => holder mapping, used to easily access nft holder
    mapping(address => uint256) public nftHolders;
    mapping(uint256 => address) public players;

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp, uint256 newScore);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterManeuver,
        uint256[] memory characterTubeRiding,
        uint256[] memory characterAerial,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossWaves,
        uint256 bossAttackDamage
    ) ERC721("Surfers", "SURFER") {
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            waves: bossWaves,
            maxWaves: bossWaves,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Pico de Surfe inicializado com sucesso %s com %s de ondas, img %s",
            bigBoss.name,
            bigBoss.waves,
            bigBoss.imageURI
        );

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
                    aerial: characterAerial[i],
                    owner: address(0),
                    score: 0
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
            aerial: defaultCharacters[_characterIndex].aerial,
            owner: msg.sender,
            score: 0
        });

        console.log(
            "Mintou NFT c/ tokenId %s e characterIndex %s",
            newItemId,
            _characterIndex
        );

        // Keep track of the holder
        nftHolders[msg.sender] = newItemId;
        players[newItemId] = msg.sender;

        // Increment for next use
        _tokenIds.increment();

        // Emit NFT Minted
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
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
                '", "description": "Esta NFT da acesso ao meu jogo NFT!", "image": "ipfs://',
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

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get tokenId of the surfer NFT from user wallet
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If user has tokenId in our map, return surfer.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllPlayers()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        CharacterAttributes[] memory allPlayers = new CharacterAttributes[](_tokenIds.current() -1);
        for (uint256 i = 1; i < _tokenIds.current(); i += 1) {
            allPlayers[i-1] = nftHolderAttributes[i];
        }
        return allPlayers;
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    function random(uint256 number) public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % number;
    }

    function getAttackDamage(CharacterAttributes storage _player)
        internal
        view
        returns (uint256)
    {
        uint256 attackType = random(3);
        uint256 damage = _player.maneuver;
        if (0 == attackType) {
            damage = _player.tubeRiding;
            console.log("Surfista realizou Manobra com nota %s", damage);
        } else if (1 == attackType) {
            damage = _player.tubeRiding;
            console.log("Surfista pegou um Tubo com nota %s", damage);
        } else if (2 == attackType) {
            damage = _player.aerial;
            console.log("Surfista fez um Aereo com nota %s", damage);
        }
        return damage;
    }

    function attackBoss() public {
        console.log("========== Pegou a onda =========");
        // Get player's NFT
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nAtleta %s fez o drop com %s de HP.",
            player.name,
            player.hp
        );
        console.log(
            "Habilidades - manobras: %s, tubos: %s, aereo: %s",
            player.maneuver,
            player.tubeRiding,
            player.aerial
        );
        console.log(
            "\nPico %s tem %s de Ondas e %s de canseira por onda",
            bigBoss.name,
            bigBoss.waves,
            bigBoss.attackDamage
        );

        // Assure surfer has HP to paddle out.
        require(
            player.hp > 0,
            "Error: personagem precisa ter HP para atacar o boss."
        );

        // Assure boss has waves
        require(
            bigBoss.waves > 0,
            "Error: Pico precisa ter Ondas para permitir surfe."
        );

        uint256 attackDamage = getAttackDamage(player);
        // Allow the player to surf waves
        if (bigBoss.waves < attackDamage) {
            bigBoss.waves = 0;
        } else {
            bigBoss.waves = bigBoss.waves - attackDamage;
        }

        // The surfer got tired, deduce HP
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        player.score += attackDamage;

        console.log(
            "\nO pico ainda tem %s ondas antes de terminar o swell",
            bigBoss.waves
        );
        console.log(
            "O surfista gastou energia e ficou com HP: %s\n",
            player.hp
        );

        // Emit wave catched
        emit AttackComplete(bigBoss.waves, player.hp, player.score);
    }
}
