import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GigBlocksENSModule = buildModule("GigBlocksENSModule", (m) => {
  
    const gigBlocksENS = m.contract("GigBlocksResolverScrollENS", [], {});

    return { gigBlocksENS };
});
  
export default GigBlocksENSModule;