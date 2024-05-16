const { ethers, upgrades } = require("hardhat");

async function main() {
  // const Presale = await ethers.getContractFactory("Presale");
  // const presale = await upgrades.deployProxy(Presale, [], { initializer: 'initialize' });
  // await presale.deployed();
  // console.log("Presale deployed to:", presale.address);


  const Presale = await ethers.getContractFactory("Presale");
  const presale = await Presale.attach("0x472e100Bb681b502a603568fCe47D60D06fFBC44");
  
  let tx = await presale.setTimeToStart(1715801896);
  await tx.wait();

  tx = await presale.setTimeToEnd(1716537600);
  await tx.wait();

  tx = await presale.setTimeToClaim(1716541200);
  await tx.wait();
}

main();