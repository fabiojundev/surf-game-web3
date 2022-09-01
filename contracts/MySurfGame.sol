// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract MySurfGame {
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

    CharacterAttributes[] defaultCharacters;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterManeuver,
        uint256[] memory characterTubeRiding,
        uint256[] memory characterAerial
    ) {
        // Faz um loop por todos os personagens e salva os valores deles no
        // contrato para que possamos usa-los depois para mintar as NFTs
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
    }
}
