const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MySurfGame");
    const gameContract = await gameContractFactory.deploy(
        ["Kelly Slater", "Gabriel Medina", "Tatiana Webb"],
        [
            "QmVU8NoVdzkQaBMaxWzujpEDfehz2wpD2ZPxWvyQupcpEd",
            "QmSwf2uHVoh4enqNji3huhqj767xtThgQP4ivy6mbSYRc4",
            "Qma69BCxWcd5ZJDALXLRBESk4jhXoUMsHuXsmp6gE7GFaM",
        ],
        [200, 150, 100], // HP values
        [100, 80, 50], // maneuver
        [100, 100, 80], //tubes
        [80, 100, 40], //aerials
        "Pipeline - Hawaii",
        "https://i.imgur.com/GtFuybO.jpg",
        5000, //boss waves
        20 //boss Atack
    );
    await gameContract.deployed();
    console.log("Contrato implantado no endereço:", gameContract.address);

    let txn;
    // Só temos três personagens.
    // Uma NFT com personagem no index 2 da nossa array.
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();

    txn = await gameContract.getAllPlayers();
    console.log("getAllPlayers",txn);

    // Pega o valor da URI da NFT
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri);

    txn = await gameContract.attackBoss();
    await txn.wait();
    
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();