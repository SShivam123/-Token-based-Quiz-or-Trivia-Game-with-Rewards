const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying TokenQuizGame contract with account:", deployer.address);

  const TokenQuizGame = await hre.ethers.getContractFactory("TokenQuizGame");
  const rewardTokenAddress = process.env.REWARD_TOKEN_ADDRESS;
  const rewardAmount = hre.ethers.utils.parseUnits("10", 18); // 10 tokens reward per correct answer

  const tokenQuizGame = await TokenQuizGame.deploy(rewardTokenAddress, rewardAmount);

  await tokenQuizGame.deployed();

  console.log("TokenQuizGame deployed to:", tokenQuizGame.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
