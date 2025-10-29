# Noir Lab Environment

Welcome to the **Noir Lab**! This repository provides a fully pre-configured development environment for students to complete their lab using [Noir](https://noir-lang.org/), a domain-specific language for writing zero-knowledge proofs.

## Quick Start (with GitHub Codespaces)

This repo is designed for **zero local setup**. You can do everything from your browser using GitHub Codespaces.

### Steps:

1. **Fork** this repository to your own GitHub account.
2. Click the **`<> Code`** button on your fork, then click **`Codespaces` → `Create codespace on main`**.
3. Wait for the Codespace to initialize (this takes a minute or two).
4. Open the built-in terminal and you're ready to go!

> Make sure you are working inside your **own fork**. Do not push to this base repository.

---

## What's Pre-Installed

Inside this Codespace environment, the following tools are pre-configured:

- [Noir Language](https://noir-lang.org/)
- [nargo](https://noir-lang.org/docs/nargo/overview/) (Noir’s package manager and CLI)
- Barretenberg backend (via `bbup`) for proof generation and verification
- Common utilities (git, bash, etc.)

No need to install anything extra — just start coding.

### Noir Backends

Noir supports **multiple proving backends** — different cryptographic engines that generate and verify proofs. Some backends are optimized for speed, some for compatibility with smart contracts, and others for minimal proof sizes.

In this lab, we are using the **Barretenberg backend**, installed via `bbup`. Barretenberg is a widely-used and efficient backend maintained by Aztec. It supports proof generation and verification for Noir circuits and integrates smoothly with `nargo`.

---

## Lab Instructions

For this lab, we will be working with the **hello_world** example Noir project. 

### About Noir and `nargo`

Noir is a language designed for writing **zero-knowledge circuits**. These circuits are functions that can proved in a zero-knowledge proof. At its core, Noir is a _compiler_ that turns Rust-like code into a constraint system: a mathematical representation of a function. Many zero-knowledge proof systems require the statement to be formatted in a constraint system form. Noir does not generate or verify zero-knowledge proofs -- later on in the lab we'll use that we'll use Barretenberg to do that.

Noir can also generate **witnesses** that are compliant with the same constraint system. A witness is a ZK term for the prover's secrets.

`nargo` is the CLI tool for managing Noir projects, compiling circuits, and preparing inputs for proving systems.

### Initializing the Project

Use the terminal in Github codespaces to enter the lab1 directory (```cd lab1```). Then, create the project using the following command:

```bash
nargo new hello_world
```

This creates two key files:

- `src/main.nr`: A boilerplate circuit.
- `Nargo.toml`: Project metadata (name, author, dependencies, etc.).

### Understanding `main.nr`

The project contains some code defining a circuit function in `main.nr`. You can open this file to see what's inside, and even run tests from inside Codespaces.

In Noir, function inputs are **private by default**, meaning they must be provided by the prover, and should not be revealed to the verifier. However, it's often the case that some inputs are be publicly known, to both prover and verifier. This can be done by marking inputs as **public** using the `pub` keyword. Here's an modified version of the `main.nr` circuit that proves you know a value `x` that is **not equal** to a public `y`, without revealing `x`:

```rust
fn main(x: Field, y: pub Field) {
    assert(x != y);
}
```

Here `x` is a secret value (provided by the prover), and `y` is a public (fixed) variable, known to both prover and verifier.

> Learn more about public/private inputs in the [Noir Data Types documentation](https://noir-lang.org/docs/dev/noir/concepts/data_types/).

### Compiling and Executing

1. Change into your new project directory:
```bash
cd hello_world
```

2. Run `nargo check` to create a `Prover.toml` file. 
```bash
nargo check
```

This file is for specifying prover inputs, and will be read when Noir generates the witness.


3. Edit `Prover.toml` with valid inputs, for instance:
```toml
x = "1"
y = "2"
```

4. Execute the circuit:
```bash
nargo execute
```

This command will:
- Compile your circuit (if needed), outputting `./target/hello_world.json`
- Generate a **witness** based on your inputs, saved to `./target/hello_world.gz`

With both the compiled circuit and witness, you’re now ready to generate a zero-knowledge proof.


## ⚙️ Using the Barretenberg CLI (`bb`)

Different proving backends may offer different tools and commands. For Barretenberg, the CLI tool `bb` is used to generate and verify proofs.

### 🧪 Verifying Backend Setup

You can confirm that Barretenberg is properly installed by running:

```bash
bb --version
```

This ensures the backend is ready for use with `nargo`.

---

### Generate a Proof
Without changing directories, run:

```bash
bb prove --scheme ultra_honk --oracle_hash keccak -b ./target/hello_world.json -w ./target/hello_world.gz -o ./target
```

This will generate a zero-knowledge proof in `target/proof`. The proof attests to the fact that the inputs in `Prover.toml` satisfy the function in `main.nr`.

> **Tip:** File naming can be confusing when working with compiled circuits and witnesses. If you're unsure whether files are up-to-date, delete the `target` folder and recompile to avoid version mismatches.

### Verify the Proof

The proof is now generated in the target folder. To verify it, we first need to compute the verification key from the compiled circuit, and use it to verify.

## What is a Verification Key?

When generating zero-knowledge proofs, two key artifacts are produced:

- **Proving Key**: This key is used by the prover to generate a proof for a specific computation. It contains information about the circuit's structure and is essential for creating a valid proof that can be verified.

- **Verifying Key**: This key is used by the verifier to check the validity of the proof. It ensures that the proof corresponds to the specific circuit and public inputs. The verifying key allows the verifier to efficiently verify the proof without needing to know the entire circuit structure.


The **verification key ties the proof to a specific circuit**. It ensures that a proof was generated using the correct circuit logic and can’t be reused or forged for different computations. It is public and can be used by verifiers (e.g., graders or smart contracts) to confirm that the prover executed the correct circuit on valid inputs, without revealing those inputs.

---

To generate a verification key:

```bash
bb write_vk --scheme ultra_honk  --oracle_hash keccak -b ./target/hello_world.json -o ./target
```

To verify the proof/witness and make sure it is consistent with the verification key we run :

```bash
bb verify --scheme ultra_honk --oracle_hash keccak -k ./target/vk -p ./target/proof
```
---
> **Note:** Verifiers know nothing about the private inputs — they only use the compiled circuit (via the verification key) and the proof. This ensures private inputs remain confidential.



---

## Deploying to Solidity on Sepolia via Remix

Noir circuits can be deployed to the Ethereum blockchain using a verifier smart contract generated by Barretenberg. In this lab, we will deploy the `hello_world` verifier to the Sepolia testnet using Remix IDE. (We’ve already covered how to use Remix and connect it to Sepolia via MetaMask, so we won’t repeat those steps here.)

### 1. Generate a Solidity Verifier Contract

You can use Barretenberg to create a Solidy contract that performs verification for your circuit. Run the following:

```bash
bb write_solidity_verifier --scheme ultra_honk -k ./target/vk -o ./target/Verifier.sol
```

You will now find a `Verifier.sol` contract in your `./target` directory.

### 2. Compile in Remix

- Open Remix and create a new workspace.
- Copy and paste the contents of `Verifier.sol` into a new file.
- Enable optimization in the **Advanced Compiler Settings** (2000 runs is fine).
- Compile the contract. You may see warnings about contract size or stack depth — these can be ignored for our purposes.

### 3. Deploy to Sepolia

- Select the `HonkVerifier` contract in the Deploy tab. By default, another contract is selected: click the `CONTRACT` field to change it.
- Connect to Sepolia via MetaMask.
- Deploy the contract to the network and wait a few seconds for it to be confirmed.

### 4. Verify Proof On-Chain


Now let's verify the proof that we generated with Barretenberg. On Remix, find your deployed contract on the left panel and click the dropdown for the `Verify()` function. This should show you two inputs you'll need to specify: the proof, and the public inputs.

We need to generate the values to be entered here:

#### Extract the Proof for Remix

```bash
echo "\"0x$(od -An -v -t x1 ./target/proof | tr -d ' \n' | sed 's/^.\{72\}//')\""

```

This command does the following:

- Runs `od -An -v -t x1 ./target/proof` to dump the file as hex.
- Pipes the output to `tr -d ' \n'` to remove spaces and newlines.
- Pipes that into `sed 's/^.\{72\}//'` to remove the first 72 characters (proof size the first 4 bytes + public input of size 32 bytes).
- Embeds the result into a string prefixed with `"0x` and wrapped in quotes via `echo`

This is the zero-knowledge proof. Copy the output and paste it into Remix.

#### Extract the Public Input from the Proof

Rum the following:

``` bash
echo "[\"0x$(od -An -v -t x1 ./target/proof | tr -d ' \n' | sed 's/^.\{8\}//' | cut -c1-64)\"]"
```
This command does the following:

- Runs `od -An -v -t x1 ./target/proof` to dump the file as hex.
- Pipes the output to `tr -d ' \n'` to remove spaces and newlines.
- Pipes that into `sed 's/^.\{8\}//'` to remove the first 8 hex characters (metadata about the proof size).
- Pipes that into `cut -c1-64` that takes the first public parameter made of 32 bytes
- Embeds the result into a string prefixed with `"0x` and wrapped in quotes and brackets via `echo`

This is the public input. Paste this into Remix. The Verifier contract expects the public input to be a list, so you'll need to put square brackets ([]) around this input. 

Now, call `Verify()`.


#### Verify Function Success and Remix Behavior

The `verify` function in your contract is designed to **succeed silently** if the proof is valid—it simply completes execution without reverting, and it does not return any data. This means that a successful verification is indicated by the absence of a revert rather than by an explicit return value.

In Remix, however, this design can lead to some confusion. Since Remix's ABI decoder expects a return value from a function call, it may interpret the absence of output as an "out-of-gas" error. This is not actually due to insufficient gas, but rather because Remix is trying to decode a return value that doesn't exist. 

When testing your `verify` function in Remix, focus on whether the transaction completes without reverting rather than on the output. A non-reverting call is your signal that the proof verification was successful.

---
