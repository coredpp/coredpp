# CoreDPP

An open standard for [digital product passports (DPP)](https://en.wikipedia.org/wiki/Material_passport).

CoreDPP is based in five ideas:

1. Each DPP can live in the blockchain.
2. A DPP only discloses information related to sustainability (such as country of origin, type of material, emissions, etc.). It does not disclose ownership.
3. Each event that transforms a product can have a data object attached to it, which explains the transformation it underwent.
4. These data objects can be structured according to an open-ended format that can be modified and extended to become as specialized or as interoperable as required.
5. The documents that prove the statements for the origin or transformation of a passport can also be stored onchain, but encrypted in a way that only the owners of those passports can disclose them to auditors or purchasers.

CoreDPP is an initiative spearheaded by [FuelFWD](https://fuelfwd.io).

Let's explain each idea by asking *why*.

*Why blockchain?*: the blockchain can be understood as a distributed database that cannot be controlled by any single entity. As such, it is a source of truth that can be trusted by multiple actors. If DPPs (and their facts) exist in the blockchain, they can be independently verified.

*Why only sustainability information?*: perhaps the greatest obstacle to DPPs is the understandable need of economic operators to be secretive of who are their suppliers and customers. DPP protocols often assume that the ownership of a DPP has to be an integral part of the DPP itself. If we instead challenge that assumption and only place sustainability information in the DPP, we remove what is perhaps the main obstacle for their adoption. We also avoid the thorny problem of selective disclosure, which in its most general formulation (which has to account for changes over time and transitive relationships), in the context of an external source of truth (the blockchain) has proven intractable. Therefore, each DPP is owned by exactly one digital wallet, so the de facto ownership of a DPP cannot be ascertained.

*Why event data objects (EDO)?*: products undergo transformations as they travel through the value chain. These transformations are most clearly understood as *events* that occur to a product. These events can be understood as discrete data objects that express the salient facts of a certain transformation. The blockchain ecosystem provides IPFS as a cheap and reliable way to store larger amounts of information: this is the ideal place to put all of the information of a DPP. The DPP that is on the blockchain can simply point to its latest EDO, which in turn will point to the previous one.

*Why an open format for EDOs?*: it is impossible to come up with a complete format to specify EDOs. This would require near-perfect knowledge of every industry that would use DPPs, as well as near-perfect foresight of how they might use it in the future. Instead, we want to go with the time-honored approach of specifying only those basic rules that can set the basis for both specialization and interoperability.

*Why store supporting documents onchain?*: while economic operators want to maintain privacy on the details of their operations, they also need to disclose them to auditors and regulatory bodies. This represents a substantial operational burden to them and therefore a major obstacle in the adoption of DPPs. If the documents are placed onchain, but encrypted in a way that only allows the owner of the passport to decrypt its contents, DPPs can carry with themselves all the information needed to prove their own compliance. The only remaining challenge is that of managing the private keys of each DPP in a way that can be provided only to auditors or regulatory bodies, a challenge that is much smaller in size and tractability than that of creating a private information silo that connects DPPs to supporting documents.

## Making CoreDPP concrete: EU biofuels

> "We favor the visible, the embedded, the personal, the narrated, and the tangible; we scorn the abstract." -- Nicholas Nassim Taleb

Following the advice implicit in Taleb's wisdom, we'll now explain CoreDPP in the context of applying it to the production and distribution of biofuels for the EU, a market we understand.

Let's illustrate with the following example:

1. A company `X` buys 100 tons of soybean.
2. Company `X` extracts oil from the soybean. The result is 20 tons of soybean oil; a byproduct of the extraction is 80 tons of soybean meal.
3. Company `X` sells the 20 tons of soybean oil to company `Y`.
4. Company `Y` processes the soybean oil into biodiesel. The result is 20 tons of biodiesel.
5. Company `Y` transports the biodiesel to a facility owned by company `Z`.
6. Company `Y` sells the biodiesel to company `Z`.

We have to start by putting those 100 tons of soybean into a DPP. Which begets the first question: which blockchain do we use?

We'll pick **Ethereum**. It is an established blockchain that supports [smart contracts](https://en.wikipedia.org/wiki/Smart_contract). While smart contracts are not used by CoreDPP, they could be potentially be employed by specific uses of it, therefore we deem it better to build on top of Ethereum (rather than Bitcoin, which doesn't support them). Another advantage of building on top of Ethereum instead of Bitcoin is that Ethereum recently switched to [proof of stake](https://en.wikipedia.org/wiki/Proof_of_stake), which sharply reduces the energy required by a blockchain transaction (and therefore, by a DPP).

Since we do not want any ownership information to be disclosed by DPPs, we must create a new [crypto wallet](https://en.wikipedia.org/wiki/Cryptocurrency_wallet) for each DPP. This is very straightforward, since, in essence, a crypto wallet is a pair of cryptographic keys (a public one and a private one). Please refer to Appendix A to see how this can be done.

Now, a typical ETH transaction looks like this:

```js
{
  "nonce": "0x1",                 // The next transaction count for the sender
  "gasPrice": "0x09184e72a000",   // Gas price in Wei
  "gasLimit": "0x5208",           // 21,000 units of gas
  "v": "0x1c",                    // Part of the signature of the sender
  "r": "0x5e5c22...",             // Part of the signature of the sender
  "s": "0x4ba3a1..."              // Part of the signature of the sender
  "to": "0xRecipientAddressHere", // Recipient address
  "value": "0x0",                 // Amount of ETH to send in Wei
  "data": "...",                  // No data for a simple ETH transfer
}
```

But just let's focus on the essentials of how an ETH transaction can represent a DPP and consider instead the following body:

```js
{
  "from": "..."                                       // The ETH address of the wallet associated with the DPP
  "to": "0x2a6eb8f7918b5016609487b1bc672767b7d90116", // A fixed address that can help identify every CoreDPP DPP
  "value": "0x0",                                     // No currency is sent; we just care about putting this entry in the blockchain
  "data": "...",                                      // IPFS hash containing the EDO (event data object)
}
```

1. The `from` address is then the ETH address of a newly created wallet that is associated 1:1 with those 100 tons of soybean. In a real ETH transaction, the fields `v`, `r` and `s` can be derived from `from`.

2. The `to` value is an arbitrary amount; while CoreDPP users are free to use any address here, those who would like their DPPs to be searchable could simply use the following address: `0x2a6eb8f7918b5016609487b1bc672767b7d90116`

3. The `value` sent is 0, since we do not want to transfer wealth, just register information in the blockchain.

4. Finally, `data` is merely the IPFS hash that contains the EDO for these 100 tons of soybean.

Before sending this transaction, we need to transfer enough [gas fee](https://en.wikipedia.org/wiki/Ethereum#Gas) so that the transaction can take place. This will intrinsically require the cost of two ETH transactions: one to transfer the gas fee to the DPP's wallet, and a second one to execute the transaction that actually creates the DPP. As of August 2024, the cost of creating a DPP with this scheme is well under 1 euro and therefore is deemed economically feasible.

Now, if we just sent this transaction, our DPP will be in the blockchain!

Let's now focus on the EDO: when the DPP is created, we will first have a creation event. It could look like this:

```json
{
  "type": "creation",
  "material": "soybean",
  "amount": {
    "value": 100,
    "unit": "ton"
  },
  "origin": "BR",
  "emissions": {
    "Eec": {
      "value": 30,
      "unit": "kg CO2/GJ"
  },
  "certificationBody": "ISCC",
  "documents": [
    "..."
  ],
  "schema": "https://..."
}
```

A few things to note about this EDO:

- It is a JSON file.
- The `amount` is specified as both a value and a unit. This particular EDO schema doesn't assume units.
- `origin` is the [ISO 3166 country code](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes) of where the soybean was produced (in this case, Brazil).
- `emissions` are just registered for `Eec`, which stands for greenhouse emissions generated by extraction or cultivation.
- `documents` is an array that contains zero or more IPFS hashes, each of them pointing to an actual document that contains a sustainability declaration concerning those 100 tons of soybean.
- `schema` is a link to a JSON schema that sets the rules for this EDO. We'll show an example schema later, once we see more EDOs.

Now for the interesting bit: the sustainability declaration (usually in PDF format) can be also placed in IPFS, but encrypted with the private key of the wallet that owns the DPP, so that only its owner can access the document. This is a way to prove to an auditor that the sustainability declaration was indeed received as-is at the time that the DPP was created. And, assuming that the encryption is done properly, and that quantum computers haven't rendered cryptography useless, this will not disclose any information to any third parties.

Let's continue the journey: now company `X` extracts oil from these 100 tons of soybean. It then will create a new EDO that could look like this:

```json
{
  "type": "extraction",
  "product": "soybean oil",
  "emissions": {
    "Ep": {
      "value": 4,
      "unit": "kg CO2/GJ"
    }
  },
  "conversionFactor": 5,
  "allocationFactor": 0.4,
  "location": "NL",
  "certificationBody": "ISCC",
  "documents": [
    "..."
  ],
  "schema": "https://...",
  "parentEDO": "..."
}
```

As for emissions, we add emissions for production (`Ep`).

The conversion factor determines the amount of soybean oil yielded from the soybean. In this case, `100 tons of soybean / 5 = 20 tons of oil`.

The allocation factor determines how are the total emissions so far (both from cultivation and processing) are going to be distributed between the soybean oil and the soybean meal. Here we are going to transfer 40% of the emissions to the soybean oil. In practice, this means that to the 30 tons per kg CO2/GJ (20 from cultivation and 10 from processing), only `30 * 0.4 = 12 kg CO2/GJ` will be assigned. From the 10 tons per kg CO2/GJ of the extraction, only 40% (4) will be assigned to the soybean oil.

In `documents`, rather than a sustainability declaration, we could instead add one or more PDFs that contain the certification that ISCC granted to company `X`, which certifies that company `X` is able to sustainably process soybean into soybean oil.

Finally, we add a new field `parentEDO`, which is the IPFS hash of the previous EDO (the one concerned with the creation of the DPP).

Once this EDO is created and placed in IPFS, a new transaction is sent to the ETH blockchain, with the following shape:

```js
{
  "from": "..."                                       // Same as in the first transaction
  "to": "0x62f3dde03176d429d91ea7dda42e735849d3104f", // Same as in the first transaction
  "value": "0x0",                                     // Same as in the first transaction
  "data": "...",                                      // IPFS hash containing the extraction EDO
}
```

In this way, the DPP points to the latest EDO, and previous events can be reconstructed through looking up previous EDOs. An EDO without the `parentEDO` field is considered to be a creation event.

We're ready to continue the journey. Company `X` sells the passport to company `Y`. From the perspective of the DPP, company `X` has to deliver to `company Y` the private key of the wallet. Depending on the arrangement between them, company `X` might delete its own copy of the private key, or just keep it for auditing purposes (since, without access to it, the documents stored onchain could not be decrypted by them). Now, quite ironically, the transfer of ownership of the DPP is not anywhere reflected in the blockchain. This is, as we mentioned above, by design.

When company `Y` receives the soybean oil, it promptly converts it into biofuel. They create the following EDO:

```json
{
  "type": "processing",
  "product": "biodiesel",
  "emissions": {
    "Ep": {
      "value": 5,
      "unit": "kg CO2/GJ"
    }
  },
  "conversionFactor": 1,
  "location": "NL",
  "certificationBody": "ISCC",
  "documents": [
    "..."
  ],
  "schema": "https://...",
  "parentEDO": "..."
}
```

A few things to note:

- We only count the emissions added by this step, rather than double counting the previous emissions. For example, `Ep` was `10 kg CO2/GJ` when converting soybean to soybean oil; we now add 5 more to reflect the emissions for expressing conversion from soybean oil to biodiesel.
- The conversion factor is 1, which means that 20 tons of soybean oil yield 20 tons of biodiesel.
- The parent EDO is the IPFS hash of the event reflecting the extraction of soybean oil from soybean.

As company `X` did before, company `Y` needs to send a transaction to the blockchain to update the IPFS hash.

```js
{
  "from": "..."                                       // Same as in the first transaction
  "to": "0x62f3dde03176d429d91ea7dda42e735849d3104f", // Same as in the first transaction
  "value": "0x0",                                     // Same as in the first transaction
  "data": "...",                                      // IPFS hash containing the processing EDO
}
```

Now company `Y` will transport the biodiesel. This will incur emissions, so another EDO is called for.

```json
{
  "type": "transport",
  "emissions": {
    "Etd": {
      "value": 30,
      "unit": "kg CO2/GJ"
    }
  },
  "means": "truck",
  "distance": {
    "value": 500,
    "unit": "km"
  }
  "destination": "DE",
  "certificationBody": "ISCC",
  "documents": [
    "..."
  ],
  "schema": "https://...",
  "parentEDO": "..."
}
```

As before, company `Y` needs to send a transaction to the blockchain to update the IPFS hash.

When company `Y` sells the biodiesel to company `Z`, the private key of the DPP must again be transferred.

If company `X` so desires, it can also create a *new DPP* for the soybean meal it obtained when it separated the soybean into soybean oil and soybean meal. The EDO could look like this:

```json
{
  "type": "extraction",
  "product": "soybean meal",
  "emissions": {
    "Ep": {
      "value": 6,
      "unit": "kg CO2/GJ"
    }
  },
  "conversionFactor": 1.25,
  "allocationFactor": 0.6,
  "location": "NL",
  "certificationBody": "ISCC",
  "documents": [
    "..."
  ],
  "schema": "https://...",
  "parentEDO": "..."
}
```

The `parentEDO` would be the EDO of the creation of the first passport.

Let's now appreciate what CoreDPP makes possible:

- Anyone with the `from` address (the hex public key of the DPP) can reconstruct the entire history of the product.
- Anyone with the `to` address (the arbitrary hex public key we suggest for all CoreDPPs) can list all DPPs, then do the above for any products.
- Anyone with the private key to a DPP can open all the supporting documents that prove the assertions. The documents cannot be changed or tampered.
- No ownership (or ownership transfer) is disclosed anywhere in the blockchain.

## TODO: schema

## License

CoreDPP is spearheaded by [FuelFWD](https://fuelfwd.io) and is released into the public domain.

## Appendix A: creating a cryptographic wallet

In Ubuntu (or many \*nix systems) this process is straightforward:

- Make sure that you have openssl installed.
- Generate a private key: `openssl ecparam -genkey -name secp256k1 -out private_key.pem`; the private key will now be available at `private_key.pem`.
- Convert the private key into hexadecimal format: `openssl ec -in private_key.pem -text -noout | grep priv -A 3 | tail -n +2 | tr -d "\n[:space:]" | sed 's/^00//' > private_key.hex`; the hex private key will be available at `private_key.hex`.
- Convert the public key into hexadecimal format: `openssl ec -in $keyName-private.pem -pubout -outform DER | tail -c 65 | xxd -p -c 65 > $keyName-public.hex`
- There's no further use for `private_key.pem`, so you can delete it: `rm private_key.pem`.
- Get the Ethereum address from the public key: `cat public_key.hex | xxd -r -p | openssl dgst -sha3-256 | awk '{print "0x"substr($2,length($2)-39)}' > eth_address.hex`; the Ethereum will be available at `eth_address.hex`.

You can also use this script:

```bash
#!/bin/bash

if [ -z "$1" ]; then
  echo "Please enter a name for your keypair"
  exit 1
fi

# Read the public key from the provided file
keyName="$1"

openssl ecparam -genkey -name secp256k1 -out $keyName-private.pem
openssl ec -in $keyName-private.pem -text -noout | grep priv -A 3 | tail -n +2 | tr -d "\n[:space:]" | sed 's/^00//' > $keyName-private.hex
openssl ec -in $keyName-private.pem -pubout -outform DER | tail -c 65 | xxd -p -c 65 > $keyName-public.hex
rm $keyName-private.pem
cat $keyName-public.hex | xxd -r -p | openssl dgst -sha3-256 | awk '{print "0x"substr($2,length($2)-39)}' > $keyName-address.hex
```
