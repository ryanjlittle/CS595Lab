# Noir Lab 2: Credit Score Proof

Welcome to **Lab 2** of the Noir Zero-Knowledge Proof series. In this lab, we'll look at a more realistic and sophisticated ZK system using Noir. We will see a circuit that proves that a person’s credit score is above a threshold **without revealing the credit score itself**, and generate Merkle proofs to show that this person is part of a registered list.

## Part 1: The Noir Circuit

Together we will implement a Noir circuit that:

- Takes as input:
  - `name: Field` (public)
  - `lastname: Field` (public)
  - `credit_score: u16` (private)
  - `index: Field` (private)
  - `hashpath: [Field; 5]` (private)
  - `root: Field` (public)

- Reconstructs the Merkle leaf by hashing the inputs with Pedersen hash
- Recomputes the Merkle root using `compute_merkle_root`
- Asserts:
  - `credit_score > 500`
  - the recomputed root equals the public root

First, navigate to the `circuit` directory:
```bash
cd circuit
```

In `src/main.nr` is a template Noir code with a skeleton of our function. It also contains a fully implemented `compute_merkle_root` function that we will use. We'll work together to fill in the blanks here. 


### Commands Recap

#### Compile Circuit
```bash
nargo execute
```

#### Generate Proof
```bash
bb prove --scheme ultra_honk --oracle_hash keccak -b ./target/[circuit].json -w ./target/[witness].gz -o ./target
```

#### Generate Verifcation Key
```bash
bb write_vk --scheme ultra_honk  --oracle_hash keccak -b ./target/[circuit].json -o ./target
```

#### Verify the Proof/Witness is Consistent with the Verification Key
```bash
bb verify --scheme ultra_honk --oracle_hash keccak -k ./target/vk -p ./target/proof
```

---

## Part 2: Demo of generating `Prover.toml` with JS

In the `js_tooling` directory, we've included several JavaScript files that handle Merkle tree construction, input encoding, and TOML generation. These rovide a better interfact for interacting with Noir proofs.

### `MerkleTree.ts` — Reusable Merkle Tree Class

This is a fully self-contained and reusable `MerkleTree` class that:

- Uses the **same Pedersen hash function** as Noir (via `@aztec/bb.js`)
- Supports:
  - Inserting leaves
  - Generating Merkle proofs
  - Computing the Merkle root
- Can be reused in future ZK projects where you need Merkle proofs

This class is compatible with the `compute_merkle_root` function Noir's `std::hash::pedersen_hash` functions, so your JS and circuit logic stay in sync.

---

### `demo.ts` — Simple Usage Example

This file demonstrates how to use the `MerkleTree` class in a straightforward, test-style setup.

It shows:
- How to insert data into the tree
- How to generate and inspect inclusion proofs
- How to compute the Merkle root and log the results

---

### `generateToml.ts` — Automatic Input Generator

This file automates the creation of a `Prover.toml` file for your Noir circuit. It does the following:

- Defines a list of "students" (e.g., people with `firstName`, `lastName`, and `creditScore`)
- Encodes their data as `Field`s, as expected by the Noir circuit
- Inserts them into the Merkle tree
- Generates a Merkle proof for one of them
- Writes all necessary values (`name`, `lastname`, `credit_score`, `hashpath`, `index`, `root`) into a TOML file

You can run it with:

```bash
npm install
npx ts-node generateToml.ts
```

This will produce a fully valid `Prover.toml`. You can copy this file into the `credit_score` directory, switch to that directory, and run

```bash
nargo execute
```