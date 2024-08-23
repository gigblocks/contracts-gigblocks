// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library GigBlocksEnums {
    enum JobCategory {
        FullstackDevelopment,
        FrontEndDevelopment,
        BackEndDevelopment,
        SmartContractDevelopment,
        DAppDevelopment,
        UiUxDesign,
        GraphicDesign,
        TokenDesign,
        BlockchainArchitecture,
        ConsensusLayerDevelopment,
        Layer2Solutions
    }

    enum JobStatus {
        Open,
        InProgress,
        Completed,
        Approved,
        Refunded
    }
}
