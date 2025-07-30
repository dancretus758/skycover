# Skycover: Decentralized Crop Insurance Protocol

A blockchain-based platform for weather-indexed crop insurance using smart contracts. Skycover provides affordable, transparent, and automated insurance policies for smallholder farmers, powered by oracles and parametric triggers.

---

## Overview

Skycover is composed of multiple Clarity smart contracts that together manage crop insurance lifecycle processes, from policy creation to automated claim payouts based on external weather or satellite data.

### Key Objectives:

- Protect smallholder farmers from climate-related losses
- Automate claims using verifiable data sources
- Eliminate intermediaries and reduce fraud
- Promote financial inclusion in agriculture

---

## Smart Contracts

Skycover includes 9 core contracts:

1. **PolicyFactory** – Creates individual crop insurance policies  
2. **PolicyTemplate** – Contains logic for standard policy types and durations  
3. **Underwriting** – Handles risk scoring and premium calculations  
4. **FarmerRegistry** – Registers and verifies farmer identities  
5. **WeatherOracleConsumer** – Receives weather/satellite data via oracle feeds  
6. **ClaimsEngine** – Evaluates triggers and approves payouts  
7. **PayoutVault** – Escrows and releases funds to farmers  
8. **DisputeResolution** – Decentralized arbitration for claim disputes  
9. **GovernanceDAO** – Community-managed upgrades and parameters

---

## Features

- Automated payouts based on rainfall, drought, or NDVI triggers
- Permissionless policy creation
- Transparent premium and payout logic
- Integrated farmer identity registry
- Dispute resolution via DAO arbitration
- Oracle-based external data feeds (Chainlink/RedStone)

---

## Contract Details

### **PolicyFactory**

- Deploys new `PolicyInstance` contracts  
- Tracks policy ownership and lifecycle  
- Enforces compliance with standard templates

### **PolicyTemplate**

- Defines insured parameters: crop type, location, trigger, season  
- Premium-to-coverage ratio logic  
- Customizable per region or cooperative

### **Underwriting**

- Risk scoring using region, historical data, and seasonality  
- Calculates base premium  
- Applies subsidy or loyalty discounts

### **FarmerRegistry**

- Verifies identities with national databases or cooperatives  
- Links to wallet addresses  
- Optional KYC layer for compliance

### **WeatherOracleConsumer**

- Connects to trusted weather APIs via Chainlink/RedStone  
- Supports rainfall, temperature, NDVI, or storm indexes  
- Verifiable, tamper-resistant data

### **ClaimsEngine**

- Trigger evaluation engine  
- Matches oracle data to policy thresholds  
- Initiates payout if conditions are met

### **PayoutVault**

- Holds premium pools  
- Releases stablecoin payouts to farmers  
- Supports batch disbursements

### **DisputeResolution**

- Escrow-based appeal mechanism  
- DAO or multisig arbitration  
- Final on-chain decision making

### **GovernanceDAO**

- Manages protocol upgrades  
- Adjusts risk weights, oracle sources, or payout ratios  
- Community voting and proposals

---

## Installation

1. Install [Clarinet CLI](https://docs.stacks.co/clarity/clarinet-cli)
2. Clone this repository
3. Compile contracts: `clarinet check`
4. Run tests: `npm run test`
5. Deploy contracts: `clarinet deploy`

---

## Usage

Each smart contract module is independently deployable and modular. Farmers interact via a mobile-first dApp connected to Clarity contracts. Insurers, cooperatives, and oracles interact with contract-specific interfaces.

For example:

- Farmers register and purchase coverage via `PolicyFactory`
- Weather oracles send data to `WeatherOracleConsumer`
- `ClaimsEngine` evaluates triggers and invokes `PayoutVault`

Refer to each contract file for function definitions and usage.

---

## Testing

Skycover contracts are tested using Clarinet:

```bash
npm run test
```

## License

MIT License