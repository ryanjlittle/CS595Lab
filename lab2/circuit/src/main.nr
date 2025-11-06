pub fn compute_merkle_root<let N: u32>(leaf: Field, index: Field, hash_path: [Field; N]) -> Field {
    let n = hash_path.len();
    let index_bits: [u1; N] = index.to_le_bits();
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] != 0;
        let (hash_left, hash_right) = if path_bit {
            (hash_path[i], current)
        } else {
            (current, hash_path[i])
        };
        current = std::hash::pedersen_hash([hash_left, hash_right]);
    }
    current
}

fn main(
    firstname: pub Field,
    lastname: pub Field,
    credit_score: u16,
    index: Field,
    hashpath: [Field; 5], // for depth-5 Merkle tree
    root: pub Field,
) {
    // 1. Enforce credit_score > 500
    assert(credit_score > 500);
    
    // 2. Convert credit_score to Field
    
    // 3. Construct the message: name || lastname || credit_score
   
    // 4. Hash the message into a Merkle leaf

    // 5. Recompute Merkle root from leaf and path

    // 6. Verify it matches the expected root
}


#[test]
fn test_main() {
    let credit_score: u16 = 580;
    let hashpath: [Field; 5] = [
        0x2286ad17d543990fd00a607866b628b044f850b202aa2ae2823f4449da4be196, 
        0x2374ebee717a419b2c4d90c5a64568559edae036e3c3f9f3b2ba10bc565f309f,
        0x0ae910ad0629ed19e4826cd25e08eff05b717719eddfbc8299dcb88e0f95d8a3,
        0x10a631ede2e9c9ea88f1277199d58d1e6cb573a05e811ebcc9c62a7592fc751e,
        0x1bf7675fd91e584ae4ca9433f82a5928685482175dddcb2a9cd71ac5ee51dad1
    ];

    let index: Field = 1;
    let firstname: Field = 0x120b138d1ece5fd647afba497e7ea7a2d7cc17b786468f6ebc1e0a6c0fffffff; // this encodes the string "Bob" as a bb field element
    let lastname: Field = 0x23091b0186ce5fd647afba497e7ea7a2d7cc17b786468f6ebc1e0a6c0fffffff; // this encodes the string "Smith" as a bb field element
    let root: Field = 0x078288b2bc9f26aed984007db1be4cda20e6f39f54b1e50c134f9e265c7a7bfc;
    
    main(firstname, lastname, credit_score, index, hashpath, root);
}
