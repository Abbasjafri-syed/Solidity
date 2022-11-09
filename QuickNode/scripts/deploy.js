
const hre = require("hardhat");

async function main() {

  const Erc20_Token = await hre.ethers.getContractFactory("Governance_Token");
  const ErcToken = await Erc20_Token.deploy("Governance", "GVR");

  await ErcToken.deployed();

  console.log(
    "Erc20_Token Contract is deployed at Address:", ErcToken.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});