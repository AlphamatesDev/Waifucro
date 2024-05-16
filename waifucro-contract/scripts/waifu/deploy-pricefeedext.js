const { utils } = require("ethers");
const crypto = require( 'crypto' );

async function main() {
    const PriceFeedExt = await ethers.getContractFactory("PriceFeedExt");
    const priceFeedExt = await PriceFeedExt.deploy("CRO Price by Band protocol", "8");
    await priceFeedExt.deployed();
    console.log("PriceFeedExt address: ", priceFeedExt.address);

    const tx = await priceFeedExt.initialize(
        true, 
        "0xe0d0e68297772dd5a1f1d99897c581e2082dba5b",
        "1000",
        "0x23199c2bcb1303f667e733b9934db9eca5991e765b45f5ed18bc4b231415f2fe",
        "0xDA7a001b254CD22e46d3eAB04d937489c93174C3",
        "CRO",
        "USD");

    await tx.wait();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });