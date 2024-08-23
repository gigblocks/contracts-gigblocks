import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GigBlocksModule = buildModule("GigBlocksModule", (m) => {
  
    const gigBlocks = m.contract("GigBlocksMainTesting2", [], {});

    return { gigBlocks };
});
  
export default GigBlocksModule;