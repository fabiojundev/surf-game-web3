const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory("MySurfGame");
    const gameContract = await gameContractFactory.deploy(
        ["Kelly Slater", "Tatiana Webb", "Gabriel Medina"],
        [
            "https://i.imgur.com/sMjDMLX.png",
            "https://i.imgur.com/I4gpXTD.png",
            "https://i.imgur.com/tHmPkfi.png",
        ],
        [200, 150, 100], // HP values
        [100, 80, 50], // maneuver
        [100, 100, 80], //tubes
        [80, 100, 40] //aerials
    );
    await gameContract.deployed();
    console.log("Contrato implantado no endereço:", gameContract.address);
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