const { utils } = require("ethers");
const crypto = require( 'crypto' );

async function main() {
    const WAIFUTest = await ethers.getContractFactory("WAIFUTest");
    const waifuTest = await WAIFUTest.deploy();
    await waifuTest.deployed();
    console.log("WAIFUTest address: ", waifuTest.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });