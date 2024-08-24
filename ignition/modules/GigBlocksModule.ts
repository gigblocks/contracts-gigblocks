import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const GigBlocksModule = buildModule("GigBlocksModule", (m) => {
  const gigBlocksReputation = m.contract("GigBlocksReputationTesting5", [
    "0x67BA06dB6d9c562857BF08AB1220a16DfA455c45"
  ]);

  const gigBlocksMain = m.contract("GigBlocksTesting5", [
    gigBlocksReputation
  ]);

  m.call(gigBlocksReputation, "setGigBlocksMain", [
    gigBlocksMain
  ]);

  return { gigBlocksReputation, gigBlocksMain };
});

export default GigBlocksModule;