import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GigBlocksModule = buildModule("GigBlocksModule", (m) => {
  
    const gigBlocks = m.contract("GigBlocksMainTesting3", [], {});

    return { gigBlocks };
});
  
export default GigBlocksModule;