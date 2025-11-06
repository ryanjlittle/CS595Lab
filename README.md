# CS 595 Zero‑Knowledge Labs

Hands‑on labs and homework assignments that teach modern zero‑knowledge proof engineering with **Noir**, **Barretenberg**, and **Solidity**—runnable in a single click via GitHub Codespaces or locally with Docker.

---

## What’s inside?

*Each lab/homework ships with its own detailed README—start there for step‑by‑step instructions.*

| Lab / Homework | Learning goal                                                                                                       | Tech highlights                                               |
| -------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **lab1**       | Build a hello‑world circuit, generate a proof, auto‑generate a Solidity verifier, and deploy on Ethereum with Remix | Noir, `nargo`, Barretenberg CLI                               |
| **lab2**       | Develop more involved circuits using Merkle trees: prove a credit‑score > 500 and verify Merkle inclusion           | Pedersen hash, custom TypeScript Merkle‑tree tooling          |
| **hw5**    (WIP! Not posted yet)    | Implement a Tornado‑style mixer (“Whirlwind”) with privacy‑preserving deposit & withdrawal                          | Dual Noir circuits → Solidity verifiers, mixer smart contract |

A pre‑configured **`.devcontainer/`** supplies Noir, VS Code extensions, pinned Barretenberg binaries, and a post‑create sanity check.

---

## Quick‑start / Installation

1. **Fork** this repository.
2. Click **Code → Codespaces → Create codespace on `main`**.
3. Wait \~2 minutes while the container builds.
4. Open a terminal inside VS Code and dive in — `nargo` and `bb` are already on your `PATH`.

```

> **Tip:** In VS Code you can also select **“Dev Containers: Open Folder in Container…”** to reuse the same Dockerfile and `devcontainer.json`.

---

## License

This project is released under the **MIT License**.

