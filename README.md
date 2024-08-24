# GigBlocks

GigBlocks is a decentralized freelancing platform built on blockchain technology. It enables secure, transparent, and efficient interactions between clients and freelancers.

## Key Components

### GigBlocksMain.sol
The main contract that ties together all the functionality of the GigBlocks platform.

### GigBlocksJobManagement.sol
Handles the core job-related operations:
- Creating and updating jobs
- Applying for jobs
- Assigning freelancers
- Completing and approving jobs
- Managing payments

### GigBlocksUserManager.sol
Manages user profiles and reputation:
- User registration
- Profile updates
- User ratings
- Social media connections
- ENS integration

### GigBlocksResolverScrollENS.sol
Integrates with Scroll's ENS (Ethereum Name Service) for resolving ENS names to Ethereum addresses.

### GigBlocksReputation.sol
Implements a comprehensive reputation system:
- Minting reputation tokens (ERC721) for users
- Tracking completed projects
- Managing social media verifications
- Handling ENS claims
- Calculating reputation scores based on various factors

### GigBlocksView.sol
Provides view functions for retrieving platform data:
- Fetching active jobs with pagination
- Retrieving job details by ID
- Getting job applicants for a specific job
- Listing applied jobs for a freelancer
- Viewing jobs posted by a client
- Retrieving jobs assigned to a freelancer
- Counting various job-related statistics

## Features

- Decentralized job marketplace
- Reputation system with social media verification
- ENS integration for user-friendly addresses
- Secure escrow payments
- User ratings and reviews
- Comprehensive view functions for easy data retrieval
- Reputation tokens (NFTs) representing user standing on the platform

## License

This project is licensed under the MIT License.
