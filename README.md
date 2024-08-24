# GigBlocks Smart Contracts

This repository contains the smart contracts for the GigBlocks decentralized freelancing platform built on the Scroll blockchain. GigBlocks aims to revolutionize the freelancing industry by providing a transparent, secure, and decentralized platform for global freelancers and clients.

## Table of Contents

1. [Overview](#overview)
2. [Contract Structure](#contract-structure)
3. [Key Features](#key-features)

## Overview

GigBlocks smart contracts manage the core functionality of our decentralized freelancing platform, including job management, user profiles, reputation systems, and ENS integration. These contracts are designed to operate on the Scroll blockchain, leveraging its Layer 2 scaling solutions for efficient and cost-effective transactions.

## Contract Structure

Our smart contract architecture consists of the following main components:

- `GigBlocksMain.sol`: The main contract that orchestrates all platform operations and serves as the entry point for interactions.
- `IGigBlocks.sol`: Interface defining the core functionalities of the GigBlocks platform.
- `GigBlocksBase.sol`: Base contract containing shared functionalities and data structures.
- `GigBlocksJobManagement.sol`: Handles job creation, application, assignment, completion, approvement, and claim payment.
- `GigBlocksUserManager.sol`: Manages user registration, profile updates, and user-related operations.
- `GigBlocksReputation.sol`: Implements the reputation system using ERC-721 mechanism.
- `GigBlocksView.sol`: Provides view functions for querying platform data without modifying state.

## Key Features

1. **Job Management**: 
   - Create and post jobs
   - Applying for a job
   - Assign freelancers to jobs
   - Complete jobs
   - Approve jobs
   - Claim payment

2. **User Profiles**: 
   - Register users (freelancers and clients)
   - Update user profiles and preferences
   - Manage user ratings

3. **Reputation System**: 
   - NFT-based reputation tokens
   - Reputation scores based on completed projects and ratings
   - Social media verification
   - ENS Claiming

4. **ENS Integration**: 
   - Claim ENS subdomains as part of the reputation system
   - Link ENS names to user address

5. **Payment Handling**:
   - Escrow system for secure payments
