# picus-benchmarks

Benchmark circuits for [Picus](https://github.com/chyanju/Picus), a security analysis tool for detecting under-constrained signals in zero-knowledge proof circuits.

## Structure

```
circom/                             # Circom/R1CS benchmarks
├── compile.sh                      # Compilation helper script
├── libs/                           # Shared circomlib dependencies
├── circomlib-cff5ab6/              # iden3/circomlib — core ZK circuit library
├── circomlibex-cff5ab6/            # circomlib parameterized variants
├── semaphore-0f0fc95/              # Semaphore identity proofs
├── darkforest-eth-9033eaf-fixed/
├── hermez-network-9a696e3-fixed/
├── maci-9b1b1a6-fixed/
├── circom-ecdsa-d87eb70/
├── circom-bigint-7505e5c/
├── circom-pairing-743d761/
├── ed25519-099d19c-fixed/
├── keccak256-circom-af3e898/
├── aes-circom-0784f74/
├── circomlib-ml-adb9edd/
├── circomlib-matrix-d41bae3/
├── motivating/                     # Toy examples
├── buggy-mix/                      # Circuits with known bugs
└── ...
```

Each directory is pinned to a specific git commit (indicated by the hash suffix) for reproducibility.

## Usage

### Compile circuits

The `compile.sh` script in `circom/` handles compilation with the correct flags for Picus analysis. Requires [circom](https://docs.circom.io/) 2.0+ on `PATH`.

```bash
cd circom

# Compile all circuits in a project directory
./compile.sh build circomlib-cff5ab6

# Compile a single circuit file
./compile.sh build-file circomlib-cff5ab6/AND@gates.circom

# Remove compiled outputs from a project directory
./compile.sh clean circomlib-cff5ab6
```

Output (`.r1cs` and `.sym` files) is written alongside the source `.circom` files. Already-compiled circuits are skipped on re-runs.

> **Note on compilation flags:** The script compiles with `--O0` (all optimizations disabled). This is a requirement for Picus — the analyzer operates on the raw constraint structure, and compiler optimizations can alter or remove constraints in ways that affect under-constrained signal detection.

### Analyze with Picus

```bash
picus check --r1cs circom/circomlib-cff5ab6/AND@gates.r1cs
```

## Reference

These benchmarks are part of the evaluation for:

```bibtex
@article{pailoor2023automated,
  author = {Pailoor, Shankara and Chen, Yanju and Wang, Franklyn and Rodr\'{i}guez, Clara and Van Geffen, Jacob and Morton, Jason and Chu, Michael and Gu, Brian and Feng, Yu and Dillig, Isil},
  title = {Automated Detection of Under-Constrained Circuits in Zero-Knowledge Proofs},
  year = {2023},
  volume = {7},
  number = {PLDI},
  journal = {Proc. ACM Program. Lang.},
  articleno = {165},
  doi = {10.1145/3591283}
}
```

## License

[MIT](LICENSE)
