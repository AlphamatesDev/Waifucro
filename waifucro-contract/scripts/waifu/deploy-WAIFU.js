const { utils } = require("ethers");
const crypto = require( 'crypto' );

async function main() {
    const WAIFU = await ethers.getContractFactory("WAIFU");
    const waifu = await WAIFU.deploy();
    await waifu.deployed();
    console.log("WAIFU address: ", waifu.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });